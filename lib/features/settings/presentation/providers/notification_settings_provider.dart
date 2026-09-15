import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

enum PushToggleResult {
  success,
  permissionDenied,
  permanentlyDenied,
}

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

class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier() : super(const NotificationSettingsState()) {
    _loadSettings();
  }

  Future<void> refreshPermissionState() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    bool osPermissionGranted = true;
    if (!kIsWeb) {
      final status = await Permission.notification.status;
      osPermissionGranted =
          status.isGranted || status.isProvisional || status.isLimited;
    }

    final savedPush = prefs.getBool('pushNotifications') ?? true;
    final pushNotifications = osPermissionGranted && savedPush;

    state = NotificationSettingsState(
      pushNotifications: pushNotifications,
      newCardAlerts: prefs.getBool('newCardAlerts') ?? true,
      eventReminders: prefs.getBool('eventReminders') ?? true,
      specialOffers: prefs.getBool('specialOffers') ?? true,
    );

    if (pushNotifications) {
      await _syncFcmTokenIfLoggedIn();
    }
  }

  Future<void> _syncFcmTokenIfLoggedIn() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        int retry = 0;
        while (apnsToken == null && retry < 6) {
          await Future.delayed(const Duration(milliseconds: 500));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          retry++;
        }
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await Supabase.instance.client.from('user_fcm_tokens').upsert({
          'user_id': session.user.id,
          'token': token,
          'new_card_alerts': state.newCardAlerts,
          'event_reminders': state.eventReminders,
          'special_offers': state.specialOffers,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
      if (state.newCardAlerts) {
        await FirebaseMessaging.instance.subscribeToTopic('new_card_alerts');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('new_card_alerts');
      }

      if (state.specialOffers) {
        await FirebaseMessaging.instance.subscribeToTopic('special_offers');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('special_offers');
      }
    } catch (e) {
      debugPrint('Error syncing push notification state: $e');
    }
  }

  Future<PushToggleResult> togglePushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      await prefs.setBool('pushNotifications', true);
      await prefs.setBool('newCardAlerts', true);
      await prefs.setBool('eventReminders', true);
      await prefs.setBool('specialOffers', true);

      if (!kIsWeb) {
        var status = await Permission.notification.status;
        if (!status.isGranted && !status.isProvisional && !status.isLimited) {
          status = await Permission.notification.request();
        }

        if (!status.isGranted && !status.isProvisional && !status.isLimited) {
          state = NotificationSettingsState(
            pushNotifications: false,
            newCardAlerts: true,
            eventReminders: true,
            specialOffers: true,
          );
          if (status.isPermanentlyDenied) {
            return PushToggleResult.permanentlyDenied;
          }
          return PushToggleResult.permissionDenied;
        }
      }

      state = const NotificationSettingsState(
        pushNotifications: true,
        newCardAlerts: true,
        eventReminders: true,
        specialOffers: true,
      );
      await _syncFcmTokenIfLoggedIn();
      return PushToggleResult.success;
    } else {
      await prefs.setBool('pushNotifications', false);
      state = state.copyWith(pushNotifications: false);

      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        try {
          await Supabase.instance
              .client
              .from('user_fcm_tokens')
              .delete()
              .eq('user_id', session.user.id);

          await FirebaseMessaging.instance.unsubscribeFromTopic('new_card_alerts');
          await FirebaseMessaging.instance.unsubscribeFromTopic('special_offers');
        } catch (e) {
          debugPrint('Error removing push notification token: $e');
        }
      }
      return PushToggleResult.success;
    }
  }



  Future<void> toggleNewCardAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('newCardAlerts', value);
    state = state.copyWith(newCardAlerts: value);

    if (value) {
      await FirebaseMessaging.instance.subscribeToTopic('new_card_alerts');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('new_card_alerts');
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && state.pushNotifications) {
      try {
        await Supabase.instance.client.from('user_fcm_tokens').update({
          'new_card_alerts': value,
        }).eq('user_id', session.user.id);
      } catch (e) {
        debugPrint('DB sync error: $e');
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
        debugPrint('DB sync error: $e');
      }
    }
  }

  Future<void> toggleSpecialOffers(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('specialOffers', value);
    state = state.copyWith(specialOffers: value);

    if (value) {
      await FirebaseMessaging.instance.subscribeToTopic('special_offers');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('special_offers');
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && state.pushNotifications) {
      try {
        await Supabase.instance.client.from('user_fcm_tokens').update({
          'special_offers': value,
        }).eq('user_id', session.user.id);
      } catch (e) {
        debugPrint('DB sync error: $e');
      }
    }
  }
}


final notificationSettingsProvider = StateNotifierProvider<
    NotificationSettingsNotifier, NotificationSettingsState>(
  (ref) => NotificationSettingsNotifier(),
);

