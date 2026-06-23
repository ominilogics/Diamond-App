import 'package:daimond/core/utils/either.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getCartItems();
  Future<Either<Failure, void>> addToCart(CartItemEntity item);
  Future<Either<Failure, void>> removeFromCart(int id);
}
