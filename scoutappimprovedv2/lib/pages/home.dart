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

    var isDarkMode =
        useState(MediaQuery.of(context).platformBrightness == Brightness.dark);

    useOnPlatformBrightnessChange((previous, current) {
      isDarkMode.value = current == Brightness.dark;
    });

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
                    child: Row(
                      children: [
                        Expanded(
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
                              if (searchText.value != "")
                                IconButton(
                                    onPressed: () {
                                      searchText.value = "";
                                      searchController.clear();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    icon: const Icon(Icons.clear))
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        if (searchText.value == "")
                          buildGoogleAvatar(context, doneLoadingFromOnline,
                              account, isDarkMode),
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

  GestureDetector buildGoogleAvatar(
      BuildContext context,
      ValueNotifier<bool> doneLoadingFromOnline,
      ValueNotifier<GoogleSignInAccount?> account,
      ValueNotifier<bool> isDarkMode) {
    return GestureDetector(
      onTap: () {
        context.go("/settings/", extra: doneLoadingFromOnline.value);
      },
      child: SizedBox(
        height: 60,
        width: 60,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: !isDarkMode.value
                    ? Colors.grey.withOpacity(0.8)
                    : Colors.black.withOpacity(0.5),
                blurStyle: BlurStyle.normal,
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 6),
              ),
            ],
          ),
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
      ),
    );
  }
}
