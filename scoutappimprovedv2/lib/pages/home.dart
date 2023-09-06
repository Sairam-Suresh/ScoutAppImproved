import 'dart:async';

import 'package:async/async.dart';
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
  CancelableOperation? scoutBadgeLoaderSub;
  var futureDB = getDB();
  var doneLoadingFromOnline = false;
  StreamSubscription<void>? listenerInstance;

  @override
  void dispose() {
    scoutBadgeLoaderSub?.cancel();
    debugPrint((scoutBadgeLoaderSub?.isCanceled).toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<Isar> db = useFuture(futureDB);

    var badges = useState<List<ScoutBadge>?>(null);
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'https://www.googleapis.com/auth/spreadsheets'],
    );
    var account = useState<GoogleSignInAccount?>(null);
    var sheetsApi = useState<SheetsApi?>(null);

    var isDarkMode =
        useState(MediaQuery.of(context).platformBrightness == Brightness.dark);

    useOnPlatformBrightnessChange((previous, current) {
      isDarkMode.value = current == Brightness.dark;
    });

    useEffect(() {
      account.value = null;

      googleSignIn.signInSilently(reAuthenticate: true).then((value) {
        account.value = value;
      }).onError((error, stackTrace) {
        account.value = null;
      });

      ScoutBadgeManager().parse(account.value).then((value) {
        // The value is the boolean which tells us whether the parser is doing its thing or not doing it because another instance is already running
        setState(() {
          doneLoadingFromOnline = value;
        });
      });

      return () async {
        await listenerInstance?.cancel();
        await db.data?.close();
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

                                return (temp?.map((e) => ScoutBadgeListTile(
                                    badge: e, onChange: () {})))!;
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
                            account, isDarkMode, googleSignIn, (isLogOut) {
                          googleSignIn.signInSilently().then((value) {
                            account.value = value;
                          }).onError((error, stackTrace) {
                            account.value = null;
                          });
                        }),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Achieved Badges",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, bottom: 8.0),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...(badges.value!.map((e) => (e.completed != null)
                                ? SizedBox(child: ScoutBadgeCard(badge: e))
                                : Container())).toList()
                          ],
                        ),
                      )),
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
                            onPressed: () {}, child: const Text("View all"))
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: badges.value!.isNotEmpty
                        ? account.value != null
                            ? RefreshIndicator(
                                onRefresh: () => ScoutBadgeManager()
                                    .updateFromGSheets(account.value!),
                                child: ListView(
                                  shrinkWrap: true,
                                  children: badges.value!
                                      .map((e) => ScoutBadgeListTile(
                                          badge: e, onChange: () {}))
                                      .toList(),
                                ),
                              )
                            : ListView(
                                shrinkWrap: true,
                                children: badges.value!
                                    .map((e) => ScoutBadgeListTile(
                                        badge: e, onChange: () {}))
                                    .toList(),
                              )
                        : const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "D:",
                                  style: TextStyle(fontSize: 40),
                                ),
                                Text(
                                  "No Badges Found with that search term",
                                  style: TextStyle(fontSize: 30),
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
      GoogleSignIn googleSignIn,
      Function(bool logOut) onUpdate) {
    return GestureDetector(
      onTap: () {
        context.push("/settings/", extra: onUpdate);
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
