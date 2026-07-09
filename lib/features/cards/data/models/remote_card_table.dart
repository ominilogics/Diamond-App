import 'package:drift/drift.dart';
import 'remote_category_table.dart';

@DataClassName('RemoteCardTableData')
class RemoteCardsTable extends Table {
  TextColumn get id => text()(); // UUID from Supabase
  TextColumn get categoryId => text().references(RemoteCategoriesTable, #id)();
  TextColumn get title => text()();
  TextColumn get coverImageUrl => text()();
  TextColumn get defaultFrontMessage => text().nullable()();
  TextColumn get defaultInsideMessage => text().nullable()();
  RealColumn get price => real().withDefault(const Constant(5.99))();
  BoolColumn get isFeatured => boolean().withDefault(const Constant(false))();
  IntColumn get colorValue => integer()
      .nullable()(); // SQLite integer is 64-bit, perfectly fits ARGB unsigned 32-bit
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
