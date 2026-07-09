import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/datasources/local_order_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';

final orderRepositoryProvider = Provider((ref) {
  final db = ref.watch(appDatabaseProvider);
  final localDataSource = LocalOrderDataSource(db);
  return OrderRepositoryImpl(localDataSource);
});

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderEntity>>>((ref) {
      return OrderNotifier(ref.watch(orderRepositoryProvider));
    });

class OrderNotifier extends StateNotifier<AsyncValue<List<OrderEntity>>> {
  final OrderRepositoryImpl _repository;

  OrderNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      state = const AsyncValue.loading();
      final orders = await _repository.getOrders();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addOrder(OrderEntity order) async {
    try {
      await _repository.addOrder(order);
      await loadOrders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeOrder(int id) async {
    try {
      await _repository.removeOrder(id);
      await loadOrders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
