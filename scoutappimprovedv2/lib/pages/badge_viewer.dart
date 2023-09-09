import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:isar/isar.dart';

import '../logic/scout_badge/scout_badge.dart';

class BadgeViewer extends StatefulHookWidget {
  const BadgeViewer({super.key, required this.name});

  final String name;

  @override
  State<BadgeViewer> createState() => _BadgeViewerState();
}

class _BadgeViewerState extends State<BadgeViewer> {
  var futureDB = getDB();

  StreamSubscription? sub;

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<Isar> db = useFuture(futureDB);
    var badge = useState<ScoutBadge?>(null);

    useEffect(() {
      return () {
        db.data?.close();
        sub?.cancel();
      };
    }, []);

    useEffect(() {
      if (db.hasData) {
        sub = db.data!.scoutBadges
            .watchLazy(fireImmediately: true)
            .listen((event) async {
          badge.value = await db.data!.scoutBadges
              .filter()
              .nameMatches(widget.name.replaceAll("_", " "))
              .findFirst();
        });
      }
      return null;
    }, [db.hasData]);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.replaceAll("_", " ")),
      ),
      body: (badge.value != null)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: 10, right: 10),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Image.network(
                            badge.value!.imageURL!,
                            height: 170,
                            width: 170,
                          ),
                        ),
                      ),
                      if (badge.value!.completed != null ||
                          badge.value!.badgeGiven != null ||
                          badge.value!.certGiven != null)
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (badge.value!.completed != null)
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Completed on"),
                                        Text(
                                          badge.value!.completed!,
                                          style: const TextStyle(fontSize: 30),
                                        )
                                      ]),
                                if (badge.value!.badgeGiven != null)
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Badge given on"),
                                        Text(
                                          badge.value!.badgeGiven!,
                                          style: const TextStyle(fontSize: 30),
                                        )
                                      ]),
                                if (badge.value!.certGiven != null)
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Certificate Given On"),
                                        Text(
                                          badge.value!.certGiven!,
                                          style: const TextStyle(fontSize: 30),
                                        )
                                      ])
                              ]),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Html(data: badge.value!.description!)
                ],
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}
