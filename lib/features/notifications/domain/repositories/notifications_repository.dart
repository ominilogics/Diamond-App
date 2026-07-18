import 'package:daimond/core/error/failures.dart';
import 'package:daimond/core/utils/either.dart';
import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Stream<List<NotificationEntity>> watchNotifications({int limit = 50});
  Future<Either<Failure, void>> syncNotifications();
  Future<Either<Failure, void>> markAsRead(int id);
  Future<Either<Failure, void>> deleteNotification(int id);
}
