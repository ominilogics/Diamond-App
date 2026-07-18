import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification_entity.dart';

abstract class RemoteNotificationsDataSource {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String remoteId);
  Future<void> deleteNotification(String remoteId);
}

class RemoteNotificationsDataSourceImpl implements RemoteNotificationsDataSource {
  final SupabaseClient supabaseClient;

  RemoteNotificationsDataSourceImpl(this.supabaseClient);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('[NOTIFICATIONS_DEBUG] RemoteNotificationsDataSource: userId is NULL. Cannot fetch notifications.');
      return [];
    }

    try {
      debugPrint('[NOTIFICATIONS_DEBUG] RemoteNotificationsDataSource: Fetching from Supabase table "notifications" for userId=$userId');
      final response = await supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', userId);
          
      debugPrint('[NOTIFICATIONS_DEBUG] RemoteNotificationsDataSource: Supabase returned ${(response as List).length} rows.');

      if (response.isEmpty) {
        debugPrint('[NOTIFICATIONS_DEBUG] RemoteNotificationsDataSource: 0 rows returned. (This means either the table is empty for this user, OR RLS policies are silently blocking SELECT).');
      } else {
        debugPrint('[NOTIFICATIONS_DEBUG] RemoteNotificationsDataSource: Sample first row: ${response.first}');
      }

      return response.map((data) => NotificationEntity(
        id: 0, 
        remoteId: data['id']?.toString(),
        title: data['title']?.toString() ?? 'No Title',
        description: data['description']?.toString() ?? '',
        createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
        isRead: data['is_read'] ?? false,
        payload: data['payload']?.toString(),
      )).toList();
    } catch (e, stack) {
      debugPrint('[NOTIFICATIONS_DEBUG] RemoteNotificationsDataSource ERROR: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String remoteId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await supabaseClient
        .from('notifications')
        .update({'is_read': true})
        .match({'id': remoteId, 'user_id': userId});
  }

  @override
  Future<void> deleteNotification(String remoteId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await supabaseClient
        .from('notifications')
        .delete()
        .match({'id': remoteId, 'user_id': userId});
  }
}
