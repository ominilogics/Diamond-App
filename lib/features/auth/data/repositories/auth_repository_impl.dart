import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  Future<bool> _hasInternetConnection() async {
    if (kIsWeb) return true;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(milliseconds: 1000));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> signIn(String email, String password) async {
    if (!await _hasInternetConnection()) {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    }
    try {
      await remoteDataSource.signIn(email, password);
      return Either.right(null);
    } on TimeoutException {
      return Either.left(
        AuthFailure(
          'Connection timed out. Please check your internet connection and try again.',
        ),
      );
    } on SocketException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on ClientException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on HttpException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') ||
          msg.contains('host lookup') ||
          msg.contains('clientexception') ||
          msg.contains('network')) {
        return Either.left(
          AuthFailure(
            'No internet connection. Please try again.',
          ),
        );
      }
      if (msg.contains('timeout')) {
        return Either.left(
          AuthFailure(
            'Connection timed out. Please check your internet connection and try again.',
          ),
        );
      }
      return Either.left(
        AuthFailure('An unexpected error occurred during login.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signUp(
    String email,
    String password,
    String fullName, {
    String? dateOfBirth,
  }) async {
    if (!await _hasInternetConnection()) {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    }
    try {
      await remoteDataSource.signUp(
        email,
        password,
        fullName,
        dateOfBirth: dateOfBirth,
      );
      return Either.right(null);
    } on TimeoutException {
      return Either.left(
        AuthFailure(
          'Connection timed out. Please check your internet connection and try again.',
        ),
      );
    } on SocketException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on ClientException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on HttpException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') ||
          msg.contains('host lookup') ||
          msg.contains('clientexception') ||
          msg.contains('network')) {
        return Either.left(
          AuthFailure(
            'No internet connection. Please try again.',
          ),
        );
      }
      if (msg.contains('timeout')) {
        return Either.left(
          AuthFailure(
            'Connection timed out. Please check your internet connection and try again.',
          ),
        );
      }
      return Either.left(
        AuthFailure('An unexpected error occurred during sign up.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    if (!await _hasInternetConnection()) {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    }
    try {
      await remoteDataSource.resetPassword(email);
      return Either.right(null);
    } on TimeoutException {
      return Either.left(
        AuthFailure(
          'Connection timed out. Please check your internet connection and try again.',
        ),
      );
    } on SocketException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on ClientException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on HttpException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') ||
          msg.contains('host lookup') ||
          msg.contains('clientexception') ||
          msg.contains('network')) {
        return Either.left(
          AuthFailure(
            'No internet connection. Please try again.',
          ),
        );
      }
      if (msg.contains('timeout')) {
        return Either.left(
          AuthFailure(
            'Connection timed out. Please check your internet connection and try again.',
          ),
        );
      }
      return Either.left(
        AuthFailure(
          'An unexpected error occurred while sending the reset link.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return Either.right(null);
    } catch (e) {
      return Either.left(AuthFailure('An error occurred during sign out.'));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithGoogle() async {
    if (!await _hasInternetConnection()) {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    }
    try {
      await remoteDataSource.signInWithGoogle();
      return Either.right(null);
    } on TimeoutException {
      return Either.left(
        AuthFailure(
          'Connection timed out. Please check your internet connection and try again.',
        ),
      );
    } on SocketException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on ClientException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on HttpException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e, stack) {
      debugPrint('[Google Sign-In Error]: $e');
      debugPrint('[Google Sign-In StackTrace]: $stack');
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') ||
          msg.contains('host lookup') ||
          msg.contains('clientexception') ||
          msg.contains('network')) {
        return Either.left(
          AuthFailure(
            'No internet connection. Please try again.',
          ),
        );
      }
      if (msg.contains('timeout')) {
        return Either.left(
          AuthFailure(
            'Connection timed out. Please check your internet connection and try again.',
          ),
        );
      }
      return Either.left(
        AuthFailure('An unexpected error occurred during Google Sign-In.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signInWithApple() async {
    if (!await _hasInternetConnection()) {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    }
    try {
      await remoteDataSource.signInWithApple();
      return Either.right(null);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return Either.left(AuthFailure('Apple Sign-In was cancelled.'));
      }
      return Either.left(AuthFailure('Apple Sign-In authorization failed: ${e.message}'));
    } on TimeoutException {
      return Either.left(
        AuthFailure(
          'Connection timed out. Please check your internet connection and try again.',
        ),
      );
    } on SocketException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on ClientException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on HttpException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e, stack) {
      debugPrint('[Apple Sign-In Error]: $e');
      debugPrint('[Apple Sign-In StackTrace]: $stack');
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') ||
          msg.contains('host lookup') ||
          msg.contains('clientexception') ||
          msg.contains('network')) {
        return Either.left(
          AuthFailure(
            'No internet connection. Please try again.',
          ),
        );
      }
      if (msg.contains('timeout')) {
        return Either.left(
          AuthFailure(
            'Connection timed out. Please check your internet connection and try again.',
          ),
        );
      }
      return Either.left(
        AuthFailure('An unexpected error occurred during Apple Sign-In.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(
    String fullName, {
    String? dateOfBirth,
  }) async {
    if (!await _hasInternetConnection()) {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    }
    try {
      await remoteDataSource.updateProfile(fullName, dateOfBirth: dateOfBirth);
      return Either.right(null);
    } on TimeoutException {
      return Either.left(
        AuthFailure(
          'Connection timed out. Please check your internet connection and try again.',
        ),
      );
    } on SocketException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on ClientException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on HttpException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') ||
          msg.contains('host lookup') ||
          msg.contains('clientexception') ||
          msg.contains('network')) {
        return Either.left(
          AuthFailure(
            'No internet connection. Please try again.',
          ),
        );
      }
      if (msg.contains('timeout')) {
        return Either.left(
          AuthFailure(
            'Connection timed out. Please check your internet connection and try again.',
          ),
        );
      }
      return Either.left(
        AuthFailure('An unexpected error occurred while updating profile.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({
    Function(String)? onProgress,
  }) async {
    if (!await _hasInternetConnection()) {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    }
    try {
      await remoteDataSource.deleteAccount(onProgress: onProgress);
      return Either.right(null);
    } on TimeoutException {
      return Either.left(
        AuthFailure(
          'Connection timed out. Please check your internet connection and try again.',
        ),
      );
    } on SocketException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on ClientException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on HttpException {
      return Either.left(
        AuthFailure(
          'No internet connection. Please try again.',
        ),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') ||
          msg.contains('host lookup') ||
          msg.contains('clientexception') ||
          msg.contains('network')) {
        return Either.left(
          AuthFailure(
            'No internet connection. Please try again.',
          ),
        );
      }
      if (msg.contains('timeout')) {
        return Either.left(
          AuthFailure(
            'Connection timed out. Please check your internet connection and try again.',
          ),
        );
      }
      return Either.left(
        AuthFailure('Failed to delete account. Please try again.'),
      );
    }
  }

  String _parseErrorMessage(String originalMessage) {
    final lowerMessage = originalMessage.toLowerCase();

    // 0. No internet / network lookup failure
    if (lowerMessage.contains('failed host lookup') ||
        lowerMessage.contains('no address associated with hostname') ||
        lowerMessage.contains('socketexception') ||
        lowerMessage.contains('clientexception') ||
        lowerMessage.contains('connection refused') ||
        lowerMessage.contains('network error') ||
        lowerMessage.contains('network request failed') ||
        lowerMessage.contains('failed to fetch') ||
        lowerMessage.contains('network_error')) {
      return 'No internet connection. Please try again.';
    }

    // 1. Timeout errors
    if (lowerMessage.contains('timeout') ||
        lowerMessage.contains('timed out')) {
      return 'Connection timed out. Please check your internet connection and try again.';
    }

    // 2. Server 5xx / Connection errors
    if (lowerMessage.contains('500') ||
        lowerMessage.contains('501') ||
        lowerMessage.contains('502') ||
        lowerMessage.contains('503') ||
        lowerMessage.contains('504') ||
        lowerMessage.contains('522') ||
        lowerMessage.contains('error code:')) {
      return 'Server error occurred. Please try again later.';
    }

    // 3. Login credentials failure
    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid credentials') ||
        lowerMessage.contains('wrong password') ||
        lowerMessage.contains('user not found')) {
      return 'Invalid email or password. Please try again.';
    }

    // 4. User already registered
    if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('already registered') ||
        lowerMessage.contains('already in use') ||
        lowerMessage.contains('email address is already registered')) {
      return 'This email is already registered. Please log in instead.';
    }

    // 5. Rate limiting / Throttling
    if (lowerMessage.contains('rate limit') ||
        lowerMessage.contains('too many requests') ||
        lowerMessage.contains('exceeded')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    }

    // 6. Google Sign-In cancellation
    if (lowerMessage.contains('google sign in was aborted') ||
        lowerMessage.contains('sign in was aborted') ||
        lowerMessage.contains('aborted')) {
      return 'Google Sign-In was cancelled.';
    }

    // 7. Password requirements
    if (lowerMessage.contains('password should be at least') ||
        lowerMessage.contains('weak password')) {
      return 'Password must be at least 6 characters long.';
    }

    // 8. Invalid email address
    if (lowerMessage.contains('invalid email') ||
        lowerMessage.contains('unable to validate email')) {
      return 'Please enter a valid email address.';
    }

    // 9. Protect against raw technical database / backend / schema / permission exceptions
    if (lowerMessage.contains('postgrest') ||
        lowerMessage.contains('database') ||
        lowerMessage.contains('sql') ||
        lowerMessage.contains('jwt') ||
        lowerMessage.contains('exception') ||
        lowerMessage.contains('null') ||
        lowerMessage.contains('column') ||
        lowerMessage.contains('table') ||
        lowerMessage.contains('syntax') ||
        lowerMessage.contains('pgrst') ||
        lowerMessage.contains('schema') ||
        lowerMessage.contains('function') ||
        lowerMessage.contains('permission denied') ||
        lowerMessage.contains('forbidden') ||
        lowerMessage.contains('delete_user_account')) {
      return 'An unexpected error occurred. Please try again.';
    }

    return originalMessage;
  }
}


