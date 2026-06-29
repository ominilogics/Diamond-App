import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders();
  Future<void> addOrder(OrderEntity order);
  Future<void> removeOrder(int id);
}
