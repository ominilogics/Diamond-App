import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final AppDatabase _db;

  NotificationsRepositoryImpl(this._db);

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return (_db.select(_db.notificationsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map((row) => _mapToEntity(row)).toList());
  }

  @override
  Future<void> syncNotifications() async {
    // In a real app, you would fetch from Supabase here.
    // For now, we will just insert some initial notifications if the table is empty 
    // to simulate the "sync" from the server.
    
    final count = await _db.select(_db.notificationsTable).get();
    if (count.isEmpty) {
      final now = DateTime.now();
      await _db.batch((batch) {
        batch.insertAll(_db.notificationsTable, [
          NotificationsTableCompanion.insert(
            title: "New cards just dropped!",
            description: "Check out the new Premium diamond series.",
            createdAt: now.subtract(const Duration(minutes: 3)),
          ),
          NotificationsTableCompanion.insert(
            title: "Limited time offer",
            description: "Get 50% off on all premium cards today.",
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
          NotificationsTableCompanion.insert(
            title: "Happy Siblings Day!",
            description: "Send a card to your sibling to show some love.",
            createdAt: now.subtract(const Duration(days: 1)),
          ),
          NotificationsTableCompanion.insert(
            title: "Mother's Day is coming!",
            description: "Don't forget to prepare a card.",
            createdAt: DateTime(2026, 4, 7),
          ),
        ]);
      });
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    await (_db.update(_db.notificationsTable)..where((t) => t.id.equals(id)))
        .write(const NotificationsTableCompanion(isRead: Value(true)));
    
    // Here you would also update Supabase in the background
  }

  NotificationEntity _mapToEntity(NotificationTableData data) {
    return NotificationEntity(
      id: data.id,
      remoteId: data.remoteId,
      title: data.title,
      description: data.description,
      createdAt: data.createdAt,
      isRead: data.isRead,
    );
  }
}
