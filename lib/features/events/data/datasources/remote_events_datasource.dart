import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/event_entity.dart';

abstract class RemoteEventsDataSource {
  Future<List<EventEntity>> getCustomEvents();
  Future<String?> saveEvent(EventEntity event);
  Future<void> deleteEvent(String remoteId);
  Future<bool?> getEventNotifiedStatus(String remoteId);
}

class RemoteEventsDataSourceImpl implements RemoteEventsDataSource {
  final SupabaseClient supabaseClient;

  RemoteEventsDataSourceImpl(this.supabaseClient);

  @override
  Future<List<EventEntity>> getCustomEvents() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('events')
        .select()
        .eq('user_id', userId);

    return (response as List).map((data) => EventEntity(
      id: 0,
      remoteId: data['id'],
      supabaseUserId: data['user_id'],
      title: data['title'],
      date: DateTime.parse(data['date']),
      reminder: data['reminder'],
      isCustom: data['is_custom'] ?? true, // Read from DB, fallback to true
      notificationTime: data['notification_time'] != null ? DateTime.parse(data['notification_time']) : null,
      isNotified: data['is_notified'] ?? false,
    )).toList();
  }

  @override
  Future<String?> saveEvent(EventEntity event) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await supabaseClient.from('events').upsert({
      if (event.remoteId != null) 'id': event.remoteId,
      'user_id': userId,
      'title': event.title,
      'date': event.date.toIso8601String(),
      'reminder': event.reminder,
      'is_custom': event.isCustom,
      if (event.notificationTime != null) 'notification_time': event.notificationTime!.toUtc().toIso8601String(),
      'is_notified': event.isNotified,
    }).select('id').single();

    return response['id'] as String?;
  }

  @override
  Future<void> deleteEvent(String remoteId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await supabaseClient
        .from('events')
        .delete()
        .match({'id': remoteId, 'user_id': userId});
  }

  @override
  Future<bool?> getEventNotifiedStatus(String remoteId) async {
    try {
      final response = await supabaseClient
          .from('events')
          .select('is_notified')
          .eq('id', remoteId)
          .single()
          .timeout(const Duration(seconds: 3));
      return response['is_notified'] as bool?;
    } catch (_) {
      return null;
    }
  }
}
