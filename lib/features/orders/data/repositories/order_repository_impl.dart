import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:daimond/core/error/failures.dart';
import 'package:daimond/core/utils/either.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local_order_datasource.dart';
import '../datasources/remote_order_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final LocalOrderDataSource localDataSource;
  final RemoteOrderDataSource remoteDataSource;

  OrderRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    try {
      final orders = await localDataSource.getOrders();
      return Either.right(orders);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to get orders locally: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addOrder(OrderEntity order) async {
    try {
      final orderWithId = order.remoteId == null ? order.copyWith(remoteId: const Uuid().v4()) : order;

      // 1. Optimistic local update
      await localDataSource.addOrder(orderWithId);

      // 2. Background sync
      remoteDataSource.addOrder(orderWithId).then((_) {
        debugPrint('✅ Successfully synced order ADD to Supabase background');
      }).catchError((e) {
        debugPrint('❌ Failed to sync order ADD to Supabase: $e');
      });

      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to add order: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeOrder(int id) async {
    try {
      final orders = await localDataSource.getOrders();
      final order = orders.where((o) => o.id == id).firstOrNull;

      await localDataSource.removeOrder(id);

      if (order?.remoteId != null) {
        remoteDataSource.removeOrder(order!.remoteId!).then((_) {
          debugPrint('✅ Successfully synced order REMOVE to Supabase background');
        }).catchError((e) {
          debugPrint('❌ Failed to sync order REMOVE to Supabase: $e');
        });
      }

      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to remove order: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncOrders() async {
    try {
      final remoteOrders = await remoteDataSource.getOrders();
      await localDataSource.syncWithRemote(remoteOrders);
      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure('Failed to sync orders: $e'));
    }
  }
}
