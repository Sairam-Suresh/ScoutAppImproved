import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' hide Padding;
import 'package:isar/isar.dart';
import 'package:scoutappimprovedv2/widgets/scout_badge_list_tile.dart';

import '../logic/scout_badge.dart';
import '../logic/scout_badge_manager.dart';

class Home extends HookWidget {
  Home({Key? key}) : super(key: key) {
    futureDB = getDB();
  }

  dynamic futureDB;

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<Isar> db = useFuture(futureDB);
    var doneLoadingFromOnline = useState(false);
    var badges = useState<List<ScoutBadge>?>(null);
    var searchText = useState("");
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'https://www.googleapis.com/auth/spreadsheets'],
    );
    var account = useState<GoogleSignInAccount?>(null);
    var searchController = useTextEditingController();
    var sheetsApi = useState<SheetsApi?>(null);
    StreamSubscription<void>? listenerInstance;

    useEffect(() {
      ScoutBadgeManager().parse().then((value) {
        doneLoadingFromOnline.value = true;
      });

      account.value = null;

      googleSignIn.signInSilently(reAuthenticate: true).then((value) {
        account.value = value;
      }).onError((error, stackTrace) {
        account.value = null;
      });

      return () {
        listenerInstance?.cancel();
        db.data?.close();
      };
    }, []);

    useEffect(() {
      if (db.hasData) {
        db.data!.scoutBadges
            .filter()
            .nameContains(searchText.value)
            .findAll()
            .then((value) {
          badges.value = value;
        });
      }
      return null;
    }, [searchText.value]);

    useEffect(() {
      if (db.hasData) {
        listenerInstance = db.data!.scoutBadges
            .watchLazy(fireImmediately: true)
            .listen((event) async {
          if (searchText.value == "") {
            badges.value = await db.data!.scoutBadges.where().findAll();
          } else {
            db.data!.scoutBadges
                .filter()
                .nameContains(searchText.value)
                .findAll()
                .then((value) {
              badges.value = value;
            });
          }
        });
      }
      return null;
    }, [db.hasData]);

    return Scaffold(
      body: badges.value != null // && sheetsApi.value != null
          ? SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchBar(
                      hintText: "Search for Badges",
                      onChanged: (text) {
                        searchText.value = text;
                      },
                      leading: const Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.search),
                        ],
                      ),
                      controller: searchController,
                      trailing: [
                        if (searchText.value == "")
                          GestureDetector(
                            onTap: () {
                              // googleSignIn.isSignedIn().then((value) {
                              //   if (!value) {
                              //     googleSignIn.signIn().then((value) {
                              //       account.value = value;
                              //       print(value?.photoUrl);
                              //     });
                              //   }
                              // });

                              context.go("/settings/",
                                  extra: doneLoadingFromOnline.value);
                            },
                            child: CircleAvatar(
                                child: Stack(
                              alignment: Alignment.center,
                              children: [
                                doneLoadingFromOnline.value
                                    ? Container()
                                    : const SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: CircularProgressIndicator()),
                                account.value == null
                                    ? const Icon(Icons.person)
                                    : SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: ClipOval(
                                          child: Image.network(
                                            account.value!.photoUrl!,
                                          ),
                                        ),
                                      ),
                              ],
                            )),
                          ),
                        if (searchText.value != "")
                          IconButton(
                              onPressed: () {
                                searchText.value = "";
                                searchController.clear();
                              },
                              icon: const Icon(Icons.clear))
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: badges.value!
                          .map((e) =>
                              ScoutBadgeListTile(badge: e, onChange: () {}))
                          .toList(),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
