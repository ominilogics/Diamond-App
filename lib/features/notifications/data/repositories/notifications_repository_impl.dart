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
  Stream<List<NotificationEntity>> watchNotifications({int limit = 50}) {
    debugPrint('[NOTIFICATIONS_DEBUG] NotificationsRepository: watchNotifications stream initialized with limit $limit.');
    return (_db.select(_db.notificationsTable)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ])..limit(limit))
        .watch()
        .map((rows) {
          debugPrint('[NOTIFICATIONS_DEBUG] NotificationsRepository: watchNotifications emitted ${rows.length} rows from Drift DB.');
          return rows.map((row) => _mapToEntity(row)).toList();
        });
  }

  @override
  Future<Either<Failure, void>> syncNotifications() async {
    try {
      debugPrint('[NOTIFICATIONS_DEBUG] NotificationsRepository: Starting syncNotifications()...');

      // 1. Cleanup old local notifications to free up phone storage
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final deletedOld = await (_db.delete(_db.notificationsTable)
            ..where((t) => t.createdAt.isSmallerThanValue(thirtyDaysAgo)))
          .go();
      if (deletedOld > 0) {
        debugPrint('🧹 [NOTIFICATIONS_CLEANUP] Deleted $deletedOld notifications older than 30 days from device.');
      }

      final remoteNotifications = await _remoteDataSource.getNotifications();
      debugPrint('[NOTIFICATIONS_DEBUG] NotificationsRepository: Received ${remoteNotifications.length} notifications from RemoteDataSource.');
      
      int insertedCount = 0;
      int updatedCount = 0;
      
      await _db.transaction(() async {
        for (var n in remoteNotifications) {
          if (n.remoteId == null) continue;
          // Check if it already exists by remoteId
          final existing = await (_db.select(_db.notificationsTable)
                ..where((t) => t.remoteId.equals(n.remoteId!)))
              .getSingleOrNull();

          if (existing == null) {
            insertedCount++;
            await _db.into(_db.notificationsTable).insert(
                  NotificationsTableCompanion.insert(
                    remoteId: Value(n.remoteId),
                    title: n.title,
                    description: n.description,
                    createdAt: n.createdAt,
                    isRead: Value(n.isRead),
                    payload: Value(n.payload),
                  ),
                );
          } else {
            updatedCount++;
            // Update read status if changed remotely
            await (_db.update(_db.notificationsTable)
                  ..where((t) => t.id.equals(existing.id)))
                .write(NotificationsTableCompanion(isRead: Value(n.isRead)));
          }
        }
      });
      debugPrint('[NOTIFICATIONS_DEBUG] NotificationsRepository: Sync complete. Inserted $insertedCount, Updated $updatedCount into local Drift DB.');
      return Either.right(null);
    } catch (e, stack) {
      debugPrint('[NOTIFICATIONS_DEBUG] NotificationsRepository sync ERROR: $e\n$stack');
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

  @override
  Future<Either<Failure, void>> deleteNotification(int id) async {
    try {
      final localNotif = await (_db.select(_db.notificationsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (localNotif == null) return Either.left(DatabaseFailure('Notification not found locally.'));

      await (_db.delete(_db.notificationsTable)..where((t) => t.id.equals(id))).go();

      if (localNotif.remoteId != null) {
        // Fire and forget remote deletion
        _remoteDataSource.deleteNotification(localNotif.remoteId!).then((_) {
          debugPrint('✅ Successfully deleted notification from Supabase');
        }).catchError((e) {
          debugPrint('❌ Failed to delete notification from Supabase: $e');
        });
      }

      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to delete notification: $e'));
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
      payload: data.payload,
    );
  }
}
