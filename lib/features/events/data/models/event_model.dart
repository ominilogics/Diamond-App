import 'package:isar/isar.dart';

part 'event_model.g.dart';

@collection
class EventModel {
  Id id = Isar.autoIncrement;

  late String title;

  late DateTime date;

  late String reminder;

  late bool isCustom;
}
