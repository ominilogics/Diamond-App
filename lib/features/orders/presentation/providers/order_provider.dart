import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/datasources/local_order_datasource.dart';
import '../../data/datasources/remote_order_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';

final orderRepositoryProvider = Provider((ref) {
  final db = ref.watch(appDatabaseProvider);
  final localDataSource = LocalOrderDataSource(db);
  final remoteDataSource = RemoteOrderDataSourceImpl(Supabase.instance.client);
  return OrderRepositoryImpl(localDataSource, remoteDataSource);
});

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderEntity>>>((ref) {
      return OrderNotifier(ref.watch(orderRepositoryProvider));
    });

class OrderNotifier extends StateNotifier<AsyncValue<List<OrderEntity>>> {
  final OrderRepositoryImpl _repository;

  OrderNotifier(this._repository) : super(const AsyncValue.loading()) {
    _syncAndLoad();
  }

  Future<void> _syncAndLoad() async {
    // Background sync
    _repository.syncOrders().then((_) {
      loadOrders();
    });
    // Immediately load cached orders
    await loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      final result = await _repository.getOrders();
      result.fold(
        (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
        (orders) => state = AsyncValue.data(orders),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addOrder(OrderEntity order) async {
    try {
      final result = await _repository.addOrder(order);
      result.fold(
        (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
        (_) => loadOrders(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeOrder(int id) async {
    try {
      final result = await _repository.removeOrder(id);
      result.fold(
        (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
        (_) => loadOrders(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
