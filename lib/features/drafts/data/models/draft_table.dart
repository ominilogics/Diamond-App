import 'package:drift/drift.dart';

@DataClassName('DraftTableData')
class DraftsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId => text()();
  TextColumn get coverText => text()();
  TextColumn get insideMessage => text()();
  DateTimeColumn get savedAt => dateTime()();
  TextColumn get draftName => text().nullable()();
}
