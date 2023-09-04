import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'scout_badge.g.dart';

Future<Isar> getDB() async {
  final dir = await getApplicationDocumentsDirectory();
  try {
    return await Isar.open([ScoutBadgeSchema],
        directory: dir.path, name: "ScoutBadges");
  } catch (e) {
    return Isar.getInstance("ScoutBadges")!;
  }
}

@collection
class ScoutBadge {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  late String? url;
  late String? name;
  late String? description;
  late String? imageURL;

  late bool? parsedGoogleSheetInfo;
  late bool? completed;
  late bool? isBadgeGiven;
  late bool? isCertGiven;
}
