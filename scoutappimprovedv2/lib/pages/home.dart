import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' hide Padding;
import 'package:isar/isar.dart';
import 'package:scoutappimprovedv2/widgets/scout_badge_card.dart';
import 'package:scoutappimprovedv2/widgets/scout_badge_list_tile.dart';

import '../logic/scout_badge/scout_badge.dart';
import '../logic/scout_badge_manager.dart';

class Home extends StatefulHookWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var futureDB = getDB();
  var doneLoadingFromOnline = false;
  StreamSubscription<void>? listenerInstance;
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/spreadsheets'],
  );

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<Isar> db = useFuture(futureDB);

    var badges = useState<List<ScoutBadge>?>(null);

    var account = useState<GoogleSignInAccount?>(null);
    var sheetsApi = useState<SheetsApi?>(null);

    var isDarkMode =
        useState(MediaQuery.of(context).platformBrightness == Brightness.dark);

    useOnPlatformBrightnessChange((previous, current) {
      isDarkMode.value = current == Brightness.dark;
    });

    useEffect(() {
      account.value = null;

      StreamSubscription<ScoutBadge?>? scoutBadgeManagerSub;

      googleSignIn.signInSilently(reAuthenticate: true).then((value) {
        account.value = value;
        futureDB.then((obtainedDBInstance) {
          scoutBadgeManagerSub =
              ScoutBadgeManager().parse(account.value).listen(
                  (value) {
                    if (value != null) {
                      obtainedDBInstance.writeTxn(() async {
                        await obtainedDBInstance.scoutBadges.put(value);
                      });
                    } else {
                      // Means that the network is down
                    }
                  },
                  onError: (error, trace) {},
                  onDone: () {
                    setState(() {
                      doneLoadingFromOnline = true;
                    });
                  });
        });
      }).onError((error, stackTrace) {
        account.value = null;
        futureDB.then((obtainedDBInstance) {
          scoutBadgeManagerSub =
              ScoutBadgeManager().parse(account.value).listen(
                  (value) {
                    if (value != null) {
                      obtainedDBInstance.writeTxn(() async {
                        await obtainedDBInstance.scoutBadges.put(value);
                      });
                    } else {
                      // Means that the network is down
                    }
                  },
                  onError: (error, trace) {},
                  onDone: () {
                    setState(() {
                      doneLoadingFromOnline = true;
                    });
                  });
        });
      });

      return () async {
        await listenerInstance?.cancel();
        await db.data?.close();
        await scoutBadgeManagerSub?.cancel();
      };
    }, []);

    useEffect(() {
      if (db.hasData) {
        listenerInstance = db.data!.scoutBadges
            .watchLazy(fireImmediately: true)
            .listen((event) async {
          badges.value = await db.data!.scoutBadges.where().findAll();
        });
      }
      return null;
    }, [db.hasData]);

    return Scaffold(
      body: badges.value != null // && sheetsApi.value != null
          ? SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SearchAnchor.bar(
                            suggestionsBuilder: (BuildContext context,
                                SearchController controller) {
                              if (controller.text != "") {
                                var temp =
                                    badges.value?.asMap().values.toList();

                                temp?.removeWhere((element) => !(element.name
                                        ?.toLowerCase()
                                        .contains(
                                            controller.text.toLowerCase()) ??
                                    false));

                                return (temp?.map(
                                    (e) => ScoutBadgeListTile(badge: e)))!;
                              } else {
                                return [];
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        buildGoogleAvatar(context, doneLoadingFromOnline,
                            account, isDarkMode, googleSignIn),
                      ],
                    ),
                  ),
                  if (badges.value!.isNotEmpty &&
                      badges.value!.firstWhereOrNull((element) =>
                              element.completed != "" &&
                              element.completed != null) !=
                          null)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Achieved Badges",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  if (badges.value!.isNotEmpty &&
                      badges.value!.firstWhereOrNull((element) =>
                              element.completed != "" &&
                              element.completed != null) !=
                          null)
                    Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, bottom: 8.0),
                          child: GridView.count(
                            crossAxisCount: 1,
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...((() {
                                var tempBadges =
                                    badges.value!.map((e) => e).toList();

                                tempBadges.removeWhere(
                                    (element) => !(element.completed != null));

                                return tempBadges
                                    .map((e) => ScoutBadgeCard(badge: e));
                              })())
                            ],
                          ),
                        )),
                  if (badges.value!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const Text(
                            "Other Badges",
                            style: TextStyle(fontSize: 20),
                          ),
                          const Spacer(),
                          FilledButton(
                              onPressed: () {
                                context.push("/view_all_badges/");
                              },
                              child: const Text("View all"))
                        ],
                      ),
                    ),
                  Expanded(
                    flex: 10,
                    child: badges.value!.isNotEmpty
                        ? account.value != null
                            ? RefreshIndicator(
                                onRefresh: () => ScoutBadgeManager()
                                    .updateFromGSheets(account.value!),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: badges.value!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          ScoutBadgeListTile(
                                              badge: badges.value![index]),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: badges.value!.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        ScoutBadgeListTile(
                                            badge: badges.value![index]),
                              )
                        : const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Please wait...",
                                  style: TextStyle(fontSize: 40),
                                ),
                                Text(
                                  "We are collecting your badges.",
                                  style: TextStyle(fontSize: 30),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "If this takes a very long time, please ensure that your device is connected to the internet and relaunch this app.",
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
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
      bool doneLoadingFromOnline,
      ValueNotifier<GoogleSignInAccount?> account,
      ValueNotifier<bool> isDarkMode,
      GoogleSignIn googleSignIn) {
    return GestureDetector(
      onTap: () {
        context.push("/settings/");
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
              doneLoadingFromOnline
                  ? Container()
                  : const SizedBox(
                      width: 55,
                      height: 55,
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
