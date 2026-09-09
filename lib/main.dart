import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/database/app_database.dart';
import 'core/providers/database_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daimond/features/payments/data/repositories/revenue_cat_repository_impl.dart';
import 'package:daimond/features/payments/presentation/providers/payment_providers.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_notification_service_impl.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:daimond/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialize AppLinks for deep link handling
  if (!kIsWeb) {
    final appLinks = AppLinks();

    String? parseDeepLinkRoute(Uri uri) {
      final path = uri.path;
      final host = uri.host;
      final query = uri.hasQuery ? '?${uri.query}' : '';

      if (path.contains('/open-card') || host == 'open-card') {
        return '/open-card$query';
      }
      if (path.isNotEmpty && path != '/') {
        return '$path$query';
      }
      return null;
    }

    try {
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('[DEEP LINK DEBUG] Main caught cold link: $initialUri');
        AppRouter.initialDeepLink = parseDeepLinkRoute(initialUri);
      }
    } catch (e) {
      debugPrint('[DEEP LINK DEBUG] Error fetching initial deep link: $e');
    }

    appLinks.uriLinkStream.listen((uri) {
      debugPrint('[DEEP LINK DEBUG] Main caught warm stream link: $uri');
      final route = parseDeepLinkRoute(uri);
      if (route != null) {
        debugPrint('[DEEP LINK DEBUG] Navigating to normalized route: $route');
        AppRouter.router.push(route);
      }
    }, onError: (err) {
      debugPrint('[DEEP LINK DEBUG] Stream error: $err');
    });
  }

  // Load user preferences
  final prefs = await SharedPreferences.getInstance();
  AppRouter.hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  final appDatabase = AppDatabase();

  // Initialize RevenueCat and sync user if already logged in
  final paymentRepository = RevenueCatRepositoryImpl();
  await paymentRepository.initialize();
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    paymentRepository.loginUser(user.id);
  }

  // Initialize Notification Engine
  final notificationService = LocalNotificationServiceImpl();
  if (!kIsWeb) {
    await notificationService.init();
  }

  // Configure system UI overlays for Android edge-to-edge support
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
      runApp(ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(appDatabase),
          paymentRepositoryProvider.overrideWithValue(paymentRepository),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
      child: const MyApp(),
    ));
  });
}

final foregroundFCMStreamProvider = StreamProvider<void>((ref) {
  return ref.watch(notificationServiceProvider).onNotificationReceived;
});

final payloadHandledStreamProvider = StreamProvider<String>((ref) {
  return ref.watch(notificationServiceProvider).onPayloadHandled;
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Globally listen to unread notifications to update the launcher badge
    ref.listen<int>(unreadNotificationsCountProvider, (previous, next) {
      if (!kIsWeb) {
        if (next > 0) {
          AppBadgePlus.updateBadge(next);
        } else {
          AppBadgePlus.updateBadge(0);
        }
      }
    });

    // Trigger real-time database sync when a push notification is received in the foreground
    ref.listen(foregroundFCMStreamProvider, (previous, next) {
      debugPrint('[NOTIFICATIONS_DEBUG] Foreground push received. Triggering background sync!');
      ref.read(notificationsRepositoryProvider).syncNotifications();
    });


    // Mark notifications as read globally when a system tray payload is tapped
    ref.listen(payloadHandledStreamProvider, (_, asyncPayload) {
      final rawPayload = asyncPayload.valueOrNull;
      if (rawPayload != null && rawPayload.contains('_')) {
        // Strip the unique timestamp prefix to get the actual route payload
        final payload = rawPayload.substring(rawPayload.indexOf('_') + 1);
        
        debugPrint('[NOTIFICATIONS_DEBUG] Payload handled: $payload. Syncing then marking as read...');
        // 1. We must sync FIRST, because if the app was in the background, the notification is NOT in local Drift DB yet!
        ref.read(notificationsRepositoryProvider).syncNotifications().then((_) {
          // 2. Now that it is in the local DB, we can find it and mark it as read!
          ref.read(notificationsRepositoryProvider).markLatestAsReadByPayload(payload);
          ref.read(lastOpenedNotificationsProvider.notifier).markOpened();
        });
      }
    });

    return ScreenUtilInit(
      designSize: const Size(393, 852),

      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: MaterialApp.router(
            title: 'Daimond',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.transparent,
            ),
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
      },
    );
  }
}