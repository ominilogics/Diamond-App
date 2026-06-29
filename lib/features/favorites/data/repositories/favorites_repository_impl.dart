import 'package:daimond/core/utils/either.dart';
import 'package:drift/drift.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local_favorites_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final LocalFavoritesDataSource localDataSource;

  FavoritesRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites() async {
    try {
      final models = await localDataSource.getFavorites();
      final entities = models.map((m) => FavoriteEntity(
        id: m.id,
        cardId: m.cardId,
        title: m.title,
        colorValue: m.colorValue,
        supabaseUserId: m.supabaseUserId,
        favoritedAt: m.favoritedAt,
      )).toList();
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
      
      await localDataSource.toggleFavorite(companion);
      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to toggle favorite: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String cardId) async {
    try {
      final result = await localDataSource.isFavorite(cardId);
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to check favorite status: $e'));
    }
  }
}
