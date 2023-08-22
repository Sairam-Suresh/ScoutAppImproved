import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoutappimprovedv2/logic/scout_badge.dart';
import 'package:scoutappimprovedv2/logic/scout_badge_manager.dart';

class Home extends HookWidget {
  Home({Key? key}) : super(key: key) {
    futureDB = getDB();
  }

  var futureDB;

  Future<Isar> getDB() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      return await Isar.open([ScoutBadgeSchema],
          directory: dir.path, inspector: true, name: "ScoutBadges");
    } catch (e) {
      return Isar.getInstance("ScoutBadges")!;
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<Isar> db = useFuture(futureDB);
    var badges = useState<List<ScoutBadge>?>(null);

    useEffect(() {
      ScoutBadgeManager().parse();

      return () {
        debugPrint("R");
        db.data?.close();
      };
    }, []);

    useEffect(() {
      if (db.hasData) {
        db.data!.scoutBadges
            .watchLazy(fireImmediately: true)
            .listen((event) async {
          print("fired!");
          badges.value = await db.data!.scoutBadges.where().findAll();
        });
      }
      return null;
    }, [db.hasData]);

    return badges.value != null
        ? ListView(
            children: badges.value!.map((e) => Text(e.name!)).toList(),
          )
        : const CircularProgressIndicator();
  }
}
