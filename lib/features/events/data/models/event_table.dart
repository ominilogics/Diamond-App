import 'package:drift/drift.dart';

@DataClassName('EventTableData')
class EventsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get supabaseUserId => text().nullable()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get reminder => text()();
  BoolColumn get isCustom => boolean()();
  DateTimeColumn get notificationTime => dateTime().nullable()();
  BoolColumn get isNotified => boolean().withDefault(const Constant(false))();
}
