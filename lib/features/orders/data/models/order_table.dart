import 'package:drift/drift.dart';

@DataClassName('OrderTableData')
class OrdersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get supabaseUserId => text().nullable()();
  TextColumn get cardId => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  DateTimeColumn get addedAt => dateTime()();
}
