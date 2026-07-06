import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../data/repositories/notifications_repository_impl.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NotificationsRepositoryImpl(db);
});

final notificationsStreamProvider = StreamProvider<List<NotificationEntity>>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.watchNotifications();
});

final groupedNotificationsProvider = Provider<AsyncValue<Map<String, List<NotificationEntity>>>>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);

  return notificationsAsync.whenData((notifications) {
    final Map<String, List<NotificationEntity>> grouped = {};
    for (final n in notifications) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateToCheck = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);

      String title;
      if (dateToCheck == today) {
        title = 'today_key';
      } else if (dateToCheck == yesterday) {
        title = 'yesterday_key';
      } else {
        title = DateFormat('MMM d, yyyy').format(n.createdAt);
      }

      if (!grouped.containsKey(title)) {
        grouped[title] = [];
      }
      grouped[title]!.add(n);
    }
    return grouped;
  });
});

final syncNotificationsProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  await repository.syncNotifications();
});
