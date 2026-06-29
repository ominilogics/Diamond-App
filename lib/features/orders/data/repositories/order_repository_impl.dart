import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local_order_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final LocalOrderDataSource localDataSource;

  OrderRepositoryImpl(this.localDataSource);

  @override
  Future<List<OrderEntity>> getOrders() {
    return localDataSource.getOrders();
  }

  @override
  Future<void> addOrder(OrderEntity order) {
    return localDataSource.addOrder(order);
  }

  @override
  Future<void> removeOrder(int id) {
    return localDataSource.removeOrder(id);
  }
}
