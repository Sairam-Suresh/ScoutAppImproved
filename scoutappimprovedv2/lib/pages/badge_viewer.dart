import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:isar/isar.dart';

import '../logic/scout_badge.dart';

class BadgeViewer extends HookWidget {
  BadgeViewer({super.key, required this.name}) {
    futureDB = getDB();
  }

  var futureDB;

  final String name;

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<Isar> db = useFuture(futureDB);
    var badge = useState<ScoutBadge?>(null);

    useEffect(() {
      return () {
        db.data?.close();
      };
    }, []);

    useEffect(() {
      if (db.hasData) {
        db.data!.scoutBadges
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
                  Image.network(
                    badge.value!.imageURL!,
                    height: 200,
                    width: 200,
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
