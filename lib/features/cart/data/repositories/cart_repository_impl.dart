import 'package:daimond/core/utils/either.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/local_cart_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final LocalCartDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCartItems() async {
    try {
      final models = await localDataSource.getCartItems();
      final entities = models.map((model) => CartItemEntity(
        id: model.id,
        cardId: model.cardId,
        title: model.title,
        message: model.message,
        addedAt: model.addedAt,
      )).toList();
      return Either.right(entities);
    } catch (e) {
      return Either.left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(CartItemEntity entity) async {
    try {
      final model = CartItemModel()
        ..cardId = entity.cardId
        ..title = entity.title
        ..message = entity.message
        ..addedAt = entity.addedAt;

      if (entity.id != null) {
        model.id = entity.id!;
      }
      
      await localDataSource.addToCart(model);
      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(int id) async {
    try {
      await localDataSource.removeFromCart(id);
      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure(e.toString()));
    }
  }
}
