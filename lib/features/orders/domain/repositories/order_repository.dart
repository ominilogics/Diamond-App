import 'package:daimond/core/error/failures.dart';
import 'package:daimond/core/utils/either.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders();
  Future<Either<Failure, void>> addOrder(OrderEntity order);
  Future<Either<Failure, void>> removeOrder(int id);
  Future<Either<Failure, void>> syncOrders();
}
