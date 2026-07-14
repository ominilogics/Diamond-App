import '../../../../core/database/app_database.dart';
import '../../domain/entities/order_entity.dart';
import 'package:drift/drift.dart';

class LocalOrderDataSource {
  final AppDatabase db;
  LocalOrderDataSource(this.db);

  Future<List<OrderEntity>> getOrders() async {
    final result = await (db.select(db.ordersTable)..orderBy([(t) => OrderingTerm(expression: t.addedAt, mode: OrderingMode.desc)])).get();
    return result
        .map(
          (row) => OrderEntity(
            id: row.id,
            remoteId: row.remoteId,
            supabaseUserId: row.supabaseUserId,
            cardId: row.cardId,
            title: row.title,
            message: row.message,
            addedAt: row.addedAt,
          ),
        )
        .toList();
  }

  Future<void> addOrder(OrderEntity order) async {
    await db
        .into(db.ordersTable)
        .insert(
          OrdersTableCompanion.insert(
            remoteId: Value(order.remoteId),
            supabaseUserId: Value(order.supabaseUserId),
            cardId: order.cardId,
            title: order.title,
            message: order.message,
            addedAt: order.addedAt,
          ),
        );
  }

  Future<void> removeOrder(int id) async {
    await (db.delete(db.ordersTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> syncWithRemote(List<OrderEntity> remoteOrders) async {
    await db.transaction(() async {
      for (var order in remoteOrders) {
        if (order.remoteId == null) continue;
        final existing = await (db.select(db.ordersTable)..where((t) => t.remoteId.equals(order.remoteId!))).getSingleOrNull();
        if (existing == null) {
          await addOrder(order);
        } else {
          await (db.update(db.ordersTable)..where((t) => t.id.equals(existing.id))).write(
            OrdersTableCompanion(
              title: Value(order.title),
              message: Value(order.message),
              addedAt: Value(order.addedAt),
            ),
          );
        }
      }
    });
  }
}
