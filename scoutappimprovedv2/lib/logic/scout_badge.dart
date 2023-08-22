import 'package:isar/isar.dart';

part 'scout_badge.g.dart';

@collection
class ScoutBadge {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  late String? url;
  late String? name;
  late String? description;
  late String? imageURL;
}
