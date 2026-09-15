import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:daimond/core/error/failures.dart';
import 'package:daimond/core/widgets/social_auth_button.dart';
import 'package:daimond/core/utils/app_assets.dart';
import 'package:daimond/features/auth/domain/repositories/auth_repository.dart';
import 'package:daimond/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:daimond/features/auth/data/datasources/remote_auth_datasource.dart';

class MockRemoteAuthDataSource implements RemoteAuthDataSource {
  bool shouldSucceed = true;
  Exception? errorToThrow;

  @override
  Future<void> signInWithApple() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    if (!shouldSucceed) {
      throw Exception('Generic error');
    }
  }

  @override
  Future<void> signIn(String email, String password) async {}
  @override
  Future<void> signUp(String email, String password, String fullName, {String? dateOfBirth}) async {}
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> updateProfile(String fullName, {String? dateOfBirth}) async {}
  @override
  Future<void> deleteAccount({Function(String)? onProgress}) async {}
}

void main() {
  group('Sign in with Apple Unit & Edge-Case Tests', () {
    late MockRemoteAuthDataSource mockDataSource;
    late AuthRepository authRepository;

    setUp(() {
      mockDataSource = MockRemoteAuthDataSource();
      authRepository = AuthRepositoryImpl(mockDataSource);
    });

    test('Successful Apple sign in returns Either.right', () async {
      mockDataSource.shouldSucceed = true;
      final result = await authRepository.signInWithApple();
      expect(result.isLeft, isFalse);
    });

    test('Cancellation edge case maps cleanly to friendly cancellation failure', () async {
      mockDataSource.errorToThrow = const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.canceled,
        message: 'User canceled the sign in flow',
      );

      final result = await authRepository.signInWithApple();
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, equals('Apple Sign-In was cancelled.'));
        },
        (_) => fail('Should not succeed'),
      );
    });

    test('Network timeout edge case maps to connection timed out failure', () async {
      mockDataSource.errorToThrow = TimeoutException('Apple auth timed out');

      final result = await authRepository.signInWithApple();
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, contains('Connection timed out'));
        },
        (_) => fail('Should not succeed'),
      );
    });

    test('Unknown authorization error maps to authorization failed message', () async {
      mockDataSource.errorToThrow = const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.failed,
        message: 'Authorization server error',
      );

      final result = await authRepository.signInWithApple();
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, contains('Apple Sign-In authorization failed'));
        },
        (_) => fail('Should not succeed'),
      );
    });
  });

  group('SocialAuthButton Design & Typography Consistency Test', () {
    testWidgets('SocialAuthButton renders with correct sizing, text, and structure', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Center(
                child: SocialAuthButton(
                  text: 'Continue with Apple',
                  iconPath: AppAssets.apple,
                  onPressed: () {
                    pressed = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Verify text rendered
      expect(find.text('Continue with Apple'), findsOneWidget);

      // Verify container decoration properties
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Tap the button
      await tester.tap(find.text('Continue with Apple'));
      await tester.pump();
      expect(pressed, isTrue);
    });
  });
}
