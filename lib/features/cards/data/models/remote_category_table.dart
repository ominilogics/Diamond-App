import 'package:drift/drift.dart';

@DataClassName('RemoteCategoryTableData')
class RemoteCategoriesTable extends Table {
  TextColumn get id => text()(); // UUID from Supabase
  TextColumn get name => text()();
  TextColumn get iconUrl => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
