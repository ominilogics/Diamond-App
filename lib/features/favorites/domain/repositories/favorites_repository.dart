import 'package:daimond/core/utils/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/favorite_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites();
  Future<Either<Failure, void>> toggleFavorite(FavoriteEntity favorite);
  Future<Either<Failure, bool>> isFavorite(String cardId);
}
