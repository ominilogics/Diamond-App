import 'package:drift/drift.dart';

@DataClassName('EventTableData')
class EventsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get reminder => text()();
  BoolColumn get isCustom => boolean()();
}
