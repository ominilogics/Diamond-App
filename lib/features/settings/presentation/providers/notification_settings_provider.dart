import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationSettingsState {
  final bool pushNotifications;
  final bool newCardAlerts;
  final bool eventReminders;
  final bool specialOffers;

  const NotificationSettingsState({
    this.pushNotifications = true,
    this.newCardAlerts = true,
    this.eventReminders = true,
    this.specialOffers = false,
  });

  NotificationSettingsState copyWith({
    bool? pushNotifications,
    bool? newCardAlerts,
    bool? eventReminders,
    bool? specialOffers,
  }) {
    return NotificationSettingsState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      newCardAlerts: newCardAlerts ?? this.newCardAlerts,
      eventReminders: eventReminders ?? this.eventReminders,
      specialOffers: specialOffers ?? this.specialOffers,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier() : super(const NotificationSettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationSettingsState(
      pushNotifications: prefs.getBool('pushNotifications') ?? true,
      newCardAlerts: prefs.getBool('newCardAlerts') ?? true,
      eventReminders: prefs.getBool('eventReminders') ?? true,
      specialOffers: prefs.getBool('specialOffers') ?? false,
    );
  }

  Future<void> togglePushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', value);
    state = state.copyWith(pushNotifications: value);

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    try {
      if (value) {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await Supabase.instance.client.from('user_fcm_tokens').upsert({
            'user_id': session.user.id,
            'token': token,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
        if (state.newCardAlerts) await FirebaseMessaging.instance.subscribeToTopic('new_card_alerts');
        if (state.specialOffers) await FirebaseMessaging.instance.subscribeToTopic('special_offers');
      } else {
        await Supabase.instance.client
            .from('user_fcm_tokens')
            .delete()
            .eq('user_id', session.user.id);
        
        await FirebaseMessaging.instance.unsubscribeFromTopic('new_card_alerts');
        await FirebaseMessaging.instance.unsubscribeFromTopic('special_offers');
      }
    } catch (e) {
      print('Error syncing push notification state: $e');
    }
  }

  Future<void> toggleNewCardAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('newCardAlerts', value);
    state = state.copyWith(newCardAlerts: value);
    
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && state.pushNotifications) {
      try {
        await Supabase.instance.client.from('user_fcm_tokens').update({
          'new_card_alerts': value,
        }).eq('user_id', session.user.id);
      } catch (e) {
        print('DB sync error (column might not exist yet): $e');
      }
    }
  }

  Future<void> toggleEventReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('eventReminders', value);
    state = state.copyWith(eventReminders: value);
    
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && state.pushNotifications) {
      try {
        await Supabase.instance.client.from('user_fcm_tokens').update({
          'event_reminders': value,
        }).eq('user_id', session.user.id);
      } catch (e) {
        print('DB sync error (column might not exist yet): $e');
      }
    }
  }

  Future<void> toggleSpecialOffers(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('specialOffers', value);
    state = state.copyWith(specialOffers: value);

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && state.pushNotifications) {
      try {
        await Supabase.instance.client.from('user_fcm_tokens').update({
          'special_offers': value,
        }).eq('user_id', session.user.id);
      } catch (e) {
        print('DB sync error (column might not exist yet): $e');
      }
    }
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
  (ref) => NotificationSettingsNotifier(),
);
