import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: AppRoute.login.path,
    routes: [
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
    ],
  );
}
