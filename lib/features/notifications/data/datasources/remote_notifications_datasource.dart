import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification_entity.dart';

abstract class RemoteNotificationsDataSource {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String remoteId);
}

class RemoteNotificationsDataSourceImpl implements RemoteNotificationsDataSource {
  final SupabaseClient supabaseClient;

  RemoteNotificationsDataSourceImpl(this.supabaseClient);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('notifications')
        .select()
        .eq('user_id', userId);

    return (response as List).map((data) => NotificationEntity(
      id: 0, 
      remoteId: data['id'],
      title: data['title'],
      description: data['description'],
      createdAt: DateTime.parse(data['created_at']),
      isRead: data['is_read'] ?? false,
    )).toList();
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
}
