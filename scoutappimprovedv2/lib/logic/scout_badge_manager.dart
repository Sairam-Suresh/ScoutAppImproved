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

List<List<String>> groupByMarker(List<String> inputList, String marker) {
  List<List<String>> groupedLists = [];
  List<String> currentGroup = [];

  for (String item in inputList) {
    if (item == marker) {
      if (currentGroup.isNotEmpty) {
        groupedLists.add(currentGroup);
      }
      currentGroup = [marker];
    } else {
      currentGroup.add(item);
    }
  }

  // Add the last group if it's not empty
  if (currentGroup.isNotEmpty) {
    groupedLists.add(currentGroup);
  }

  return groupedLists;
}

List<Map<String, String>> combineLists(
    List<List<String>> keysList, List<String> valuesList) {
  List<Map<String, String>> result = [];
  int valueIndex = 0;

  for (int i = 0; i < keysList.length; i++) {
    Map<String, String> data = {};
    for (int j = 0; j < keysList[i].length; j++) {
      data[keysList[i][j]] = valuesList[valueIndex++];
    }
    result.add(data);
  }

  return result;
}

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

  Future<bool> parse(GoogleSignInAccount? account) async {
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
          ..imageURL = imageURL
          ..parsedGoogleSheetInfo = false
          ..completed = null
          ..badgeGiven = null
          ..certGiven = null;

        // Add new badge to the database

        await db.scoutBadges.put(newBadge);

        print(newBadge.name);

        tempView.dispose();
      });

      if (account != null) {
        await updateFromGSheets(account);
      }

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

    final responseHeaderBadges =
        (await sheets.spreadsheets.values.get(spreadsheetId, "E6:ZZZ6"))
            .values![0]
            .map((e) => e?.toString().replaceAll('\n', ""))
            .toList();

    final responseHeaderStats =
        (await sheets.spreadsheets.values.get(spreadsheetId, "E7:ZZZ7"))
            .values![0]
            .map((e) => e?.toString().replaceAll('\n', ""))
            .toList();

    responseHeaderStats.removeWhere((element) => element == "");
    responseHeaderBadges.removeWhere((element) => element == "");

    final responsePeople =
        (await sheets.spreadsheets.values.get(spreadsheetId, "B9:B"))
            .values!
            .map((e) => e.first)
            .toList();

    var userSheetIntPos = 9 + responsePeople.indexOf(account.email);

    final responseUserDates = (await sheets.spreadsheets.values
            .get(spreadsheetId, "E$userSheetIntPos:ZZZ$userSheetIntPos"))
        .values![0]
        .map((e) => e?.toString().replaceAll('\n', ""))
        .toList();

    print(responseHeaderBadges.length);
    print(responseUserDates);
    print(combineLists(
            groupByMarker(
                responseHeaderStats.map((e) => e!).toList(), "Completed"),
            responseUserDates.map((e) => e!).toList())
        .length);

    for (int i = 0; i < responseHeaderBadges.length; i++) {
      var targetBadge = responseHeaderBadges[i];
      var targetStats = combineLists(
          groupByMarker(
              responseHeaderStats.map((e) => e!).toList(), "Completed"),
          responseUserDates.map((e) => e!).toList())[i];

      var scoutBadgeInDB = await db.scoutBadges
          .filter()
          .nameContains(targetBadge!.toLowerCase(), caseSensitive: false)
          .findFirst();

      scoutBadgeInDB
        ?..parsedGoogleSheetInfo = true
        ..completed = (targetStats.keys.contains("Completed"))
            ? (targetStats["Completed"] != "")
                ? targetStats["Completed"]
                : null
            : null
        ..badgeGiven = (targetStats.keys.contains("Badge Given"))
            ? (targetStats["Badge Given"] != "")
                ? targetStats["Badge Given"]
                : null
            : null
        ..certGiven = (targetStats.keys.contains("Cert Given"))
            ? (targetStats["Cert Given"] != "")
                ? targetStats["Cert Given"]
                : null
            : null;

      if (scoutBadgeInDB != null) {
        await db.writeTxn(() => db.scoutBadges.put(scoutBadgeInDB));
      }
    }
    // db.scoutBadges.putAll(objects);
  }
}
