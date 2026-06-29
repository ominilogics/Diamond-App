import '../../../../core/database/app_database.dart';
import '../../domain/entities/order_entity.dart';
import 'package:drift/drift.dart';

class LocalOrderDataSource {
  final AppDatabase db;
  LocalOrderDataSource(this.db);

  Future<List<OrderEntity>> getOrders() async {
    final result = await db.select(db.ordersTable).get();
    return result.map((row) => OrderEntity(
      id: row.id,
      cardId: row.cardId,
      title: row.title,
      message: row.message,
      addedAt: row.addedAt,
    )).toList();
  }

  Future<void> addOrder(OrderEntity order) async {
    await db.into(db.ordersTable).insert(
      OrdersTableCompanion.insert(
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
}
