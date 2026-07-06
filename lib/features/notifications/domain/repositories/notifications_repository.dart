import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Stream<List<NotificationEntity>> watchNotifications();
  Future<void> syncNotifications();
  Future<void> markAsRead(int id);
}
