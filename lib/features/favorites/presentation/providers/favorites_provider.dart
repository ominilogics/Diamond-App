import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../data/datasources/local_favorites_datasource.dart';
import '../../data/repositories/favorites_repository_impl.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final localDataSource = LocalFavoritesDataSourceImpl(db);
  return FavoritesRepositoryImpl(localDataSource);
});

class FavoritesNotifier extends AsyncNotifier<List<FavoriteEntity>> {
  @override
  Future<List<FavoriteEntity>> build() async {
    return _fetchFavorites();
  }

  Future<List<FavoriteEntity>> _fetchFavorites() async {
    final repository = ref.read(favoritesRepositoryProvider);
    final result = await repository.getFavorites();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (favorites) => favorites,
    );
  }

  Future<void> toggleFavorite(FavoriteEntity favorite) async {
    final repository = ref.read(favoritesRepositoryProvider);
    final result = await repository.toggleFavorite(favorite);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidateSelf(),
    );
    await future;
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<FavoriteEntity>>(() {
  return FavoritesNotifier();
});

final isFavoriteProvider = FutureProvider.family<bool, String>((ref, cardId) async {
  final favorites = await ref.watch(favoritesProvider.future);
  return favorites.any((f) => f.cardId == cardId);
});
