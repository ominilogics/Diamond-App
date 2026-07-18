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
        debugPrint('[NOTIFICATIONS_DEBUG] NotificationsProvider: groupedNotificationsProvider mapping ${notifications.length} notifications.');
        final Map<String, List<NotificationEntity>> grouped = {
          'newNotifications': [],
          'earlierNotifications': [],
        };
        for (final n in notifications) {
          final now = DateTime.now();
          final difference = now.difference(n.createdAt);
          
          if (!n.isRead || difference.inHours < 24) {
            grouped['newNotifications']!.add(n);
          } else {
            grouped['earlierNotifications']!.add(n);
          }
        }
        
        // Remove empty groups
        if (grouped['newNotifications']!.isEmpty) grouped.remove('newNotifications');
        if (grouped['earlierNotifications']!.isEmpty) grouped.remove('earlierNotifications');
        
        return grouped;
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
