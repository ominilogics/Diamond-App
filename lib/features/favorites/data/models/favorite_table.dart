import 'package:drift/drift.dart';

@DataClassName('FavoriteTableData')
class FavoritesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId => text().unique()();
  TextColumn get title => text()();
  IntColumn get colorValue => integer()();
  TextColumn get supabaseUserId => text()();
  DateTimeColumn get favoritedAt => dateTime()();
}
