import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../data/datasources/local_favorites_datasource.dart';
import '../../data/datasources/remote_favorites_datasource.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final localDataSource = LocalFavoritesDataSourceImpl(db);
  final remoteDataSource = RemoteFavoritesDataSourceImpl(Supabase.instance.client);
  return FavoritesRepositoryImpl(localDataSource, remoteDataSource);
});

class FavoritesNotifier extends AsyncNotifier<List<FavoriteEntity>> {
  @override
  Future<List<FavoriteEntity>> build() async {
    // Fire off sync in background, and don't await it so we show local data immediately
    _syncAndRefresh();
    return _fetchFavorites();
  }

  Future<void> _syncAndRefresh() async {
    final repository = ref.read(favoritesRepositoryProvider);
    final result = await repository.syncFavorites();
    if (!result.isLeft) {
      // Refresh the state with newly synced data
      final updatedLocal = await _fetchFavorites();
      state = AsyncValue.data(updatedLocal);
    }
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
      (_) async {
        // Fetch strictly from local database to reflect the local toggle instantly
        // without triggering a full server sync that races the background update.
        final updatedLocal = await _fetchFavorites();
        state = AsyncValue.data(updatedLocal);
      },
    );
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<FavoriteEntity>>(() {
      return FavoritesNotifier();
    });

final isFavoriteProvider = FutureProvider.family<bool, String>((
  ref,
  cardId,
) async {
  final favorites = await ref.watch(favoritesProvider.future);
  return favorites.any((f) => f.cardId == cardId);
});
