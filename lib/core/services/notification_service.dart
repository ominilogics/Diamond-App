import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_notification_service_impl.dart';

abstract class NotificationService {
  Stream<void> get onNotificationReceived;
  Stream<String> get onPayloadHandled;
  Future<void> init();
  Future<void> requestPermissions();
  Future<void> scheduleEventReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  });
  Future<void> cancelReminder(int id);
}

// We'll define the implementation provider shortly.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationServiceImpl();
});
