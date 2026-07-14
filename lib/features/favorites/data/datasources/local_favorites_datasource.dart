import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart';

abstract class LocalFavoritesDataSource {
  Future<List<FavoriteTableData>> getFavorites();
  Future<void> toggleFavorite(FavoritesTableCompanion favorite);
  Future<bool> isFavorite(String cardId);
  Future<void> syncWithRemote(List<FavoritesTableCompanion> remoteFavorites);
}

class LocalFavoritesDataSourceImpl implements LocalFavoritesDataSource {
  final AppDatabase db;

  LocalFavoritesDataSourceImpl(this.db);

  @override
  Future<List<FavoriteTableData>> getFavorites() async {
    return await (db.select(db.favoritesTable)..orderBy([
          (t) =>
              OrderingTerm(expression: t.favoritedAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  @override
  Future<void> toggleFavorite(FavoritesTableCompanion favorite) async {
    final existing = await (db.select(
      db.favoritesTable,
    )..where((t) => t.cardId.equals(favorite.cardId.value))).getSingleOrNull();
    if (existing != null) {
      await db.favoritesTable.deleteWhere((t) => t.id.equals(existing.id));
    } else {
      await db.into(db.favoritesTable).insert(favorite);
    }
  }

  @override
  Future<bool> isFavorite(String cardId) async {
    final existing = await (db.select(
      db.favoritesTable,
    )..where((t) => t.cardId.equals(cardId))).getSingleOrNull();
    return existing != null;
  }

  @override
  Future<void> syncWithRemote(List<FavoritesTableCompanion> remoteFavorites) async {
    await db.transaction(() async {
      for (final remoteFav in remoteFavorites) {
        await db.into(db.favoritesTable).insert(
          remoteFav,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
