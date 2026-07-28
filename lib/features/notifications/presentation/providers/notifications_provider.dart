import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../data/repositories/notifications_repository_impl.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/remote_notifications_datasource.dart';

import 'package:shared_preferences/shared_preferences.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  final remote = RemoteNotificationsDataSourceImpl(Supabase.instance.client);
  return NotificationsRepositoryImpl(db, remote);
});

final notificationsLimitProvider = StateProvider<int>((ref) => 20);

final notificationsStreamProvider = StreamProvider<List<NotificationEntity>>((
  ref,
) {
  final limit = ref.watch(notificationsLimitProvider);
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.watchNotifications(limit: limit);
});

final lastOpenedNotificationsProvider = StateNotifierProvider<LastOpenedNotifier, DateTime?>((ref) {
  return LastOpenedNotifier();
});

class LastOpenedNotifier extends StateNotifier<DateTime?> {
  LastOpenedNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_opened_notifications');
    if (timestamp != null) {
      state = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
  }

  Future<void> markOpened() async {
    final now = DateTime.now();
    state = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_opened_notifications', now.millisecondsSinceEpoch);
  }
}

final groupedNotificationsProvider =
    Provider<AsyncValue<Map<String, List<NotificationEntity>>>>((ref) {
      final notificationsAsync = ref.watch(notificationsStreamProvider);

      return notificationsAsync.whenData((notifications) {
        final List<NotificationEntity> unreadList = [];
        final Map<String, List<NotificationEntity>> readGrouped = {};

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        const monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];

        for (final n in notifications) {
          if (!n.isRead) {
            unreadList.add(n);
          } else {
            final itemDate = DateTime(
              n.createdAt.year,
              n.createdAt.month,
              n.createdAt.day,
            );

            if (itemDate.isAtSameMomentAs(today)) {
              readGrouped.putIfAbsent('today', () => []).add(n);
            } else if (itemDate.isAtSameMomentAs(yesterday)) {
              readGrouped.putIfAbsent('yesterday', () => []).add(n);
            } else {
              final formattedDate = now.year == itemDate.year
                  ? '${monthNames[itemDate.month - 1]} ${itemDate.day}'
                  : '${monthNames[itemDate.month - 1]} ${itemDate.day}, ${itemDate.year}';
              readGrouped.putIfAbsent(formattedDate, () => []).add(n);
            }
          }
        }

        final Map<String, List<NotificationEntity>> result = {};
        if (unreadList.isNotEmpty) {
          result['unread'] = unreadList;
        }
        result.addAll(readGrouped);

        return result;
      });
    });



final syncNotificationsProvider = FutureProvider<void>((ref) async {
  debugPrint('[NOTIFICATIONS_DEBUG] NotificationsProvider: syncNotificationsProvider triggered!');
  final repository = ref.watch(notificationsRepositoryProvider);
  await repository.syncNotifications();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  final lastOpened = ref.watch(lastOpenedNotificationsProvider);
  
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) {
      if (lastOpened != null && n.createdAt.isBefore(lastOpened)) return false;
      return !n.isRead;
    }).length,
    orElse: () => 0,
  );
});
