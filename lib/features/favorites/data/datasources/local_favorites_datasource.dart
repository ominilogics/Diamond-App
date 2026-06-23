import 'package:isar/isar.dart';
import '../models/favorite_model.dart';

abstract class LocalFavoritesDataSource {
  Future<List<FavoriteModel>> getFavorites();
  Future<void> toggleFavorite(FavoriteModel favorite);
  Future<bool> isFavorite(String cardId);
}

class LocalFavoritesDataSourceImpl implements LocalFavoritesDataSource {
  final Isar isar;

  LocalFavoritesDataSourceImpl(this.isar);

  @override
  Future<List<FavoriteModel>> getFavorites() async {
    return await isar.favoriteModels.where().sortByFavoritedAtDesc().findAll();
  }

  @override
  Future<void> toggleFavorite(FavoriteModel favorite) async {
    await isar.writeTxn(() async {
      final existing = await isar.favoriteModels.where().cardIdEqualTo(favorite.cardId).findFirst();
      if (existing != null) {
        await isar.favoriteModels.delete(existing.id);
      } else {
        await isar.favoriteModels.put(favorite);
      }
    });
  }

  @override
  Future<bool> isFavorite(String cardId) async {
    final existing = await isar.favoriteModels.where().cardIdEqualTo(cardId).findFirst();
    return existing != null;
  }
}
