import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
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
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: AppRoute.main.path,
    routes: [
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
      ),
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
      GoRoute(
        name: AppRoute.main.name,
        path: AppRoute.main.path,
        builder: (context, state) => const MainScreen(),
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
          final title = state.extra as String?;
          return CardsScreen(title: title, showBackButton: true);
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
    ],
  );
}
