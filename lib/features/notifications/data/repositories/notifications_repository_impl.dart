import 'package:flutter/foundation.dart';
import 'package:daimond/core/error/failures.dart';
import 'package:daimond/core/utils/either.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/remote_notifications_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final AppDatabase _db;
  final RemoteNotificationsDataSource _remoteDataSource;

  NotificationsRepositoryImpl(this._db, this._remoteDataSource);

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return (_db.select(_db.notificationsTable)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .watch()
        .map((rows) => rows.map((row) => _mapToEntity(row)).toList());
  }

  @override
  Future<Either<Failure, void>> syncNotifications() async {
    try {
      final remoteNotifications = await _remoteDataSource.getNotifications();
      
      await _db.transaction(() async {
        for (var n in remoteNotifications) {
          if (n.remoteId == null) continue;
          // Check if it already exists by remoteId
          final existing = await (_db.select(_db.notificationsTable)
                ..where((t) => t.remoteId.equals(n.remoteId!)))
              .getSingleOrNull();

          if (existing == null) {
            await _db.into(_db.notificationsTable).insert(
                  NotificationsTableCompanion.insert(
                    remoteId: Value(n.remoteId),
                    title: n.title,
                    description: n.description,
                    createdAt: n.createdAt,
                    isRead: Value(n.isRead),
                  ),
                );
          } else {
            // Update read status if changed remotely
            await (_db.update(_db.notificationsTable)
                  ..where((t) => t.id.equals(existing.id)))
                .write(NotificationsTableCompanion(isRead: Value(n.isRead)));
          }
        }
      });
      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure('Failed to sync notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) async {
    try {
      // 1. Get the local notification to find remoteId
      final localNotif = await (_db.select(_db.notificationsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (localNotif == null) return Either.left(DatabaseFailure('Notification not found locally.'));

      // 2. Optimistic local update
      await (_db.update(_db.notificationsTable)..where((t) => t.id.equals(id)))
          .write(const NotificationsTableCompanion(isRead: Value(true)));

      // 3. Sync to remote if it has a remoteId
      if (localNotif.remoteId != null) {
        // Fire and forget, or await. Awaiting is fine since UI is optimistic via stream.
        _remoteDataSource.markAsRead(localNotif.remoteId!).then((_) {
          debugPrint('✅ Successfully synced notification MARK AS READ to Supabase background');
        }).catchError((e) {
          debugPrint('❌ Failed to sync notification MARK AS READ to Supabase: $e');
        });
      }
      
      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to mark as read: $e'));
    }
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
