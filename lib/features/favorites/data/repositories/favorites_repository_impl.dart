import 'package:flutter/foundation.dart';
import 'package:daimond/core/utils/either.dart';
import 'package:drift/drift.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local_favorites_datasource.dart';
import '../datasources/remote_favorites_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final LocalFavoritesDataSource localDataSource;
  final RemoteFavoritesDataSource remoteDataSource;

  FavoritesRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites() async {
    try {
      final models = await localDataSource.getFavorites();
      final entities = models
          .map(
            (m) => FavoriteEntity(
              id: m.id,
              cardId: m.cardId,
              title: m.title,
              colorValue: m.colorValue,
              supabaseUserId: m.supabaseUserId,
              favoritedAt: m.favoritedAt,
            ),
          )
          .toList();
      return Either.right(entities);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to fetch favorites: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(FavoriteEntity entity) async {
    try {
      final companion = FavoritesTableCompanion(
        cardId: Value(entity.cardId),
        title: Value(entity.title),
        colorValue: Value(entity.colorValue),
        supabaseUserId: Value(entity.supabaseUserId),
        favoritedAt: Value(entity.favoritedAt),
      );

      // Optimistic local update for zero-latency UX
      await localDataSource.toggleFavorite(companion);
      
      // Fire background sync to remote
      _syncToggleToRemote(entity);

      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to toggle favorite: $e'));
    }
  }

  Future<void> _syncToggleToRemote(FavoriteEntity entity) async {
    try {
      // Check current local state after the toggle
      final isLocalFavorite = await localDataSource.isFavorite(entity.cardId);
      if (isLocalFavorite) {
        await remoteDataSource.addFavorite(entity);
        debugPrint('✅ Successfully synced favorite ADD to Supabase background');
      } else {
        await remoteDataSource.removeFavorite(entity.cardId);
        debugPrint('✅ Successfully synced favorite REMOVE to Supabase background');
      }
    } catch (e) {
      // Log failure - in a fully robust system, this could queue the failure for a retry
      debugPrint('❌ Failed to sync favorite toggle to remote: $e');
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String cardId) async {
    try {
      final result = await localDataSource.isFavorite(cardId);
      return Either.right(result);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Failed to check favorite status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> syncFavorites() async {
    try {
      // 1. Fetch from remote
      final remoteFavorites = await remoteDataSource.getFavorites();
      
      // 2. Convert to companions
      final companions = remoteFavorites.map((fav) => FavoritesTableCompanion(
        cardId: Value(fav.cardId),
        title: Value(fav.title),
        colorValue: Value(fav.colorValue),
        supabaseUserId: Value(fav.supabaseUserId),
        favoritedAt: Value(fav.favoritedAt),
      )).toList();

      // 3. Merge locally
      await localDataSource.syncWithRemote(companions);

      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure('Failed to sync favorites with remote: $e'));
    }
  }
}
