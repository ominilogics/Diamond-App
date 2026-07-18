import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/cards/presentation/screens/cards_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/testing/presentation/screens/testing_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/terms_and_conditions_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/cards/presentation/screens/card_detail_screen.dart';
import '../../features/cards/presentation/screens/preview_card_screen.dart';
import '../../features/cards/presentation/screens/edit_card_screen.dart';
import '../../features/orders/presentation/screens/order_history_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/settings/presentation/screens/my_drafts_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'app_routes.dart';


class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static bool hasSeenOnboarding = false;
  static String? initialDeepLink;

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialDeepLink ?? (Supabase.instance.client.auth.currentSession != null 
        ? (kIsWeb ? AppRoute.adminDashboard.path : AppRoute.main.path) 
        : (kIsWeb ? AppRoute.login.path : (hasSeenOnboarding ? AppRoute.login.path : AppRoute.onboarding.path))),
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthRoute = state.matchedLocation == AppRoute.onboarding.path ||
                          state.matchedLocation == AppRoute.login.path || 
                          state.matchedLocation == '${AppRoute.login.path}/${AppRoute.signup.path}' || 
                          state.matchedLocation == '${AppRoute.login.path}/${AppRoute.forgotPassword.path}';

      if (session == null) {
        // Prevent web users from accessing onboarding
        if (kIsWeb && state.matchedLocation == AppRoute.onboarding.path) {
          return AppRoute.login.path;
        }
        
        // Prevent users who have seen onboarding from going back to it
        if (state.matchedLocation == AppRoute.onboarding.path && hasSeenOnboarding) {
          return AppRoute.login.path;
        }

        if (!isAuthRoute) {
          return kIsWeb ? AppRoute.login.path : (hasSeenOnboarding ? AppRoute.login.path : AppRoute.onboarding.path);
        }
      } else {
        if (isAuthRoute) {
          final isAnonymous = Supabase.instance.client.auth.currentUser?.isAnonymous ?? false;
          
          // Allow anonymous guests to access login/signup pages so they can upgrade their accounts
          if (isAnonymous) {
            return null;
          }

          // If on web, redirect directly to admin dashboard
          if (kIsWeb) {
            return AppRoute.adminDashboard.path;
          }
          return AppRoute.main.path;
        }
        
        // Prevent web users from accessing consumer app routes
        if (kIsWeb && state.matchedLocation != AppRoute.adminDashboard.path) {
           return AppRoute.adminDashboard.path;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        name: AppRoute.onboarding.name,
        path: AppRoute.onboarding.path,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: AppRoute.editProfile.name,
        path: AppRoute.editProfile.path,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        name: AppRoute.testing.name,
        path: AppRoute.testing.path,
        builder: (context, state) => const TestingScreen(),
      ),
      GoRoute(
        name: AppRoute.login.name,
        path: AppRoute.login.path,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            name: AppRoute.signup.name,
            path: AppRoute.signup.path,
            builder: (context, state) => const SignUpScreen(),
          ),
          GoRoute(
            name: AppRoute.forgotPassword.name,
            path: AppRoute.forgotPassword.path,
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
        ],
      ),
      GoRoute(
        name: AppRoute.main.name,
        path: AppRoute.main.path,
        builder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialTab = tabStr != null ? int.tryParse(tabStr) : null;
          return MainScreen(initialTabIndex: initialTab);
        },
      ),
      GoRoute(
        name: AppRoute.notifications.name,
        path: AppRoute.notifications.path,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        name: AppRoute.cards.name,
        path: AppRoute.cards.path,
        builder: (context, state) {
          String? title;
          String? categoryId;
          
          if (state.extra is String) {
            title = state.extra as String;
          } else if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            title = extra['title'] as String?;
            categoryId = extra['categoryId'] as String?;
          }
          
          return CardsScreen(
            title: title, 
            showBackButton: true,
            initialCategoryId: categoryId,
          );
        },
      ),
      GoRoute(
        name: AppRoute.events.name,
        path: AppRoute.events.path,
        builder: (context, state) => const EventsScreen(showBackButton: true),
      ),
      GoRoute(
        name: AppRoute.privacyPolicy.name,
        path: AppRoute.privacyPolicy.path,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        name: AppRoute.termsAndConditions.name,
        path: AppRoute.termsAndConditions.path,
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        name: AppRoute.cardDetail.name,
        path: AppRoute.cardDetail.path,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CardDetailScreen(
            cardId: extra['cardId'] as String? ?? 'unknown',
            title: extra['title'] as String? ?? 'Card Details',
            orderId: extra['orderId'] as int?,
            initialMessage: extra['initialMessage'] as String?,
            cardColorValue: extra['cardColorValue'] as int?,
            coverImageUrl: extra['coverImageUrl'] as String?,
            frontMessage: extra['frontMessage'] as String?,
          );
        },
      ),
      GoRoute(
        name: AppRoute.previewCard.name,
        path: AppRoute.previewCard.path,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PreviewCardScreen(
            message: extra['message'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        name: AppRoute.editCard.name,
        path: AppRoute.editCard.path,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return EditCardScreen(
            cardId: extra['cardId'] as String? ?? 'unknown',
            coverImageUrl: extra['coverImageUrl'] as String?,
            frontMessage: extra['frontMessage'] as String?,
            initialMessage: extra['initialMessage'] as String?,
            draftId: extra['draftId'] as int?,
          );
        },
      ),
      GoRoute(
        name: AppRoute.notificationSettings.name,
        path: AppRoute.notificationSettings.path,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        name: AppRoute.orderHistory.name,
        path: AppRoute.orderHistory.path,
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        name: AppRoute.subscription.name,
        path: AppRoute.subscription.path,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        name: AppRoute.myDrafts.name,
        path: AppRoute.myDrafts.path,
        builder: (context, state) => const MyDraftsScreen(),
      ),
      GoRoute(
        name: AppRoute.adminDashboard.name,
        path: AppRoute.adminDashboard.path,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
