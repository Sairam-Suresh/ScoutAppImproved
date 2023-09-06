import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:isar/isar.dart';

import '../logic/scout_badge/scout_badge.dart';

class BadgeViewer extends HookWidget {
  BadgeViewer({super.key, required this.name}) {
    futureDB = getDB();
  }

  var futureDB;

  StreamSubscription? sub;

  final String name;

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
          print("fired!");
          badge.value = await db.data!.scoutBadges
              .filter()
              .nameMatches(name.replaceAll("_", " "))
              .findFirst();
        });
      }
      return null;
    }, [db.hasData]);

    return Scaffold(
      appBar: AppBar(
        title: Text(name.replaceAll("_", " ")),
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
                        child: Image.network(
                          badge.value!.imageURL!,
                          height: 200,
                          width: 200,
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
