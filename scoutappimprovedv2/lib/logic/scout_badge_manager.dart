import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoutappimprovedv2/logic/scout_badge/scout_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sensitive.dart';

class ScoutBadgeManager {
  List<String> _parsedUrls = [];

  Future<Isar> _getDB() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      return await Isar.open([ScoutBadgeSchema],
          directory: dir.path, inspector: true, name: "ScoutBadges");
    } catch (e) {
      return Isar.getInstance("ScoutBadges")!;
    }
  }

  Future<bool> parse() async {
    var db = await _getDB();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool("already_processing_badges") ?? false)) {
      prefs.setBool("already_processing_badges", true);

      var headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
            url: Uri.parse(
                "https://app.scout.sg/#/scouts/scouts_gridview/scouts")),
      );
      await headlessWebView.run();

      await Future.delayed(const Duration(seconds: 5));

      var urls =
          await headlessWebView.webViewController.evaluateJavascript(source: """
              JSON.stringify(
                Array.from(document.getElementsByTagName('a'))
                  .map(img => img.href)
              )
              """);
      _parsedUrls = List<String>.from(jsonDecode(urls));

      // Filter out the garbage
      _parsedUrls.removeWhere((element) =>
          element == "https://scout.sg/" ||
          element == "http://intranet.scout.org.sg/");

      _parsedUrls.removeWhere((element) {
        List<ScoutBadge> list =
            (db.scoutBadges.filter().urlEqualTo(element).findAllSync());

        if (list.isEmpty) {
          // Means it is not inside
          return false;
        } else {
          return true;
        }
      });

      headlessWebView.dispose();
      await Future.forEach(_parsedUrls, (String i) async {
        HeadlessInAppWebView tempView = HeadlessInAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(i)),
        );

        await tempView.run();

        await Future.delayed(const Duration(milliseconds: 5000));

        var image =
            await tempView.webViewController.evaluateJavascript(source: """
                JSON.stringify(
                Array.from(document.getElementsByTagName('img'))
                  .map(img => img.src)
              )
              """);

        var name =
            await tempView.webViewController.evaluateJavascript(source: """
                JSON.stringify(
                Array.from(document.getElementsByTagName('h2'))
                  .map(h2 => h2.textContent)
              )
                """);

        var desc =
            await tempView.webViewController.evaluateJavascript(source: """
      const spanElement = document.querySelector('span.ng-binding'); 

const elementsInsideSpan = Array.from(spanElement.childNodes);

const contentArray = elementsInsideSpan.map(node => {
  if (node.nodeType === Node.TEXT_NODE) {
    return node.textContent.trim();
  } else if (node.nodeType === Node.ELEMENT_NODE) {
    return node.outerHTML;
  }
});

JSON.stringify(contentArray);

      """);

        String imageURL = List<String>.from(jsonDecode(image))[0];
        String badgeName = List<String>.from(jsonDecode(name))[0];
        String description = List<String>.from(jsonDecode(desc)).join("");

        var newBadge = ScoutBadge()
          ..name = badgeName
          ..url = i
          ..description = description
          ..imageURL = imageURL;

        // Add new badge to the database

        await db.writeTxn(() async {
          db.scoutBadges.put(newBadge);
        });

        print(newBadge.name);

        tempView.dispose();
      });

      prefs.setBool("already_processing_badges", false);
      return true; // Parser Successfully Completed
    }

    return false; // Parser didnt parse as there is already another instance of it running.
  }

  Future<void> updateFromGSheets(GoogleSignInAccount account) async {
    var db = await _getDB();

    final credentials = ServiceAccountCredentials.fromJson(serviceAccountCreds);

    final client = await clientViaServiceAccount(
        credentials, [SheetsApi.spreadsheetsReadonlyScope]);
    var sheets = SheetsApi(client);

    final response =
        await sheets.spreadsheets.values.get(spreadsheetId, "A2:A");

    // db.scoutBadges.putAll(objects);

    // (await db.scoutBadges.where().findAll())
    // .map((element) {})
    // .toList();
  }
}
