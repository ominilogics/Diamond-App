import 'package:daimond/core/routing/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routing/app_router.dart';

import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}

class LocalNotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    // Initialize timezone for scheduling
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // For iOS, request permissions later manually
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
        _handlePayload(response.payload);
      },
    );

    // Setup Firebase Messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Setup foreground FCM message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      
      // We can use flutter_local_notifications to show a heads-up display while app is open!
      if (message.notification != null) {
        _flutterLocalNotificationsPlugin.show(
          id: message.hashCode,
          title: message.notification!.title,
          body: message.notification!.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'event_reminders_channel',
              'Event Reminders',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          // We can pass routing path here if we included it in FCM data payload
          payload: '/notifications', 
        );
      }
    });

    String _getRouteFromMessage(RemoteMessage message) {
      final type = message.data['type'] as String?;
      if (type == 'new card') return AppRoute.cards.path; 
      if (type == 'event reminder') return AppRoute.events.path;
      if (type == 'special offer') return AppRoute.subscription.path;
      return AppRoute.main.path;
    }

    // Handle FCM Notification Taps (App in Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM Notification caused app to open from background! Data: ${message.data}');
      _handlePayload(_getRouteFromMessage(message));
    });

    // Handle FCM Notification Taps (App was Killed)
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM Notification caused app to open from KILLED state! Data: ${initialMessage.data}');
      _handlePayload(_getRouteFromMessage(initialMessage)); 
    }

    // Handle local AlarmManager notification taps from killed state
    final NotificationAppLaunchDetails? launchDetails = 
        await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final payload = launchDetails.notificationResponse?.payload;
      debugPrint('App launched from killed state via notification. Payload: $payload');
      _handlePayload(payload);
    }
    
    // Sync FCM Token
    _syncFcmToken();
    // Listen to Supabase Auth changes to sync token after login
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn || 
          data.event == AuthChangeEvent.initialSession) {
        _syncFcmToken();
      }
    });
  }

  Future<void> _syncFcmToken() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return;

      // 🟢 ALWAYS check SharedPreferences before uploading the token!
      final prefs = await SharedPreferences.getInstance();
      final pushEnabled = prefs.getBool('pushNotifications') ?? true;
      
      if (!pushEnabled) {
        debugPrint('Push notifications are disabled in settings. Skipping FCM token sync.');
        return;
      }

      final newCardAlerts = prefs.getBool('newCardAlerts') ?? true;
      final eventReminders = prefs.getBool('eventReminders') ?? true;
      final specialOffers = prefs.getBool('specialOffers') ?? false;

      // Get the token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        debugPrint('FCM Token: $fcmToken');
        // Save to Supabase with current preferences
        await Supabase.instance.client.from('user_fcm_tokens').upsert({
          'user_id': session.user.id,
          'token': fcmToken,
          'new_card_alerts': newCardAlerts,
          'event_reminders': eventReminders,
          'special_offers': specialOffers,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      // Listen to token changes
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          await Supabase.instance.client.from('user_fcm_tokens').upsert({
            'user_id': session.user.id,
            'token': fcmToken,
            'new_card_alerts': newCardAlerts,
            'event_reminders': eventReminders,
            'special_offers': specialOffers,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
      }).onError((err) {
        debugPrint('Error listening to FCM token refresh: $err');
      });
    } catch (e) {
      debugPrint('Failed to sync FCM token: $e');
    }
  }

  void _handlePayload(String? payload) {
    if (payload == null) return;
    
    // Abstract NotificationRouter implementation
    try {
      // In the future, this can decode JSON: `{"route": "/card-detail", "id": "123"}`
      if (payload.isNotEmpty) {
        // Delayed to guarantee the MaterialApp and GoRouter have fully mounted
        Future.delayed(const Duration(milliseconds: 1500), () {
          final currentPath = AppRouter.router.routerDelegate.currentConfiguration.uri.path;
          
          // Only push the route if we aren't already looking at it!
          if (currentPath != payload) {
            AppRouter.router.push(payload);
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to route notification payload: $e');
    }
  }

  @override
  Future<void> requestPermissions() async {
    // Android 13+ Notification Permission
    await Permission.notification.request();

    // iOS Notification Permissions
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Android 14+ Exact Alarms Permission (Required for scheduled alarms in killed state)
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestExactAlarmsPermission();
      
      // Explicitly create the channel so FCM can use it immediately!
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'event_reminders_channel',
          'Event Reminders',
          description: 'Notifications for upcoming events',
          importance: Importance.max,
        ),
      );
    }

    // Request Firebase Messaging Permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  Future<void> scheduleEventReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // If the date is in the past, don't schedule
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('Cannot schedule notification in the past: $scheduledDate');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'event_reminders_channel',
      'Event Reminders',
      channelDescription: 'Notifications for upcoming events and reminders',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use timezone-aware scheduling
    final tz.TZDateTime scheduledTzDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    // [OPTION B - BACKEND FCM]
    // Local scheduling has been intentionally disabled. 
    // Event reminders will now be processed centrally by Supabase pg_cron
    // and delivered reliably via Firebase Cloud Messaging even when killed.
    /*
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTzDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      debugPrint('✅ Notification scheduled locally for id: $id at $scheduledTzDate');
    } catch (e) {
      debugPrint('❌ Failed to schedule notification: $e');
    }
    */
  }

  @override
  Future<void> cancelReminder(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id: id);
      debugPrint('✅ Notification cancelled successfully for id: $id');
    } catch (e) {
      debugPrint('❌ Failed to cancel notification: $e');
    }
  }
}
