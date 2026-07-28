import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> signIn(String email, String password) async {
    try {
      await remoteDataSource.signIn(email, password);
      return Either.right(null);
    } on TimeoutException {
      return Either.left(
        AuthFailure('Connection timed out. Please check your internet.'),
      );
    } on SocketException {
      return Either.left(
        AuthFailure('No internet connection. Please try again.'),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e) {
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
        AuthFailure('Connection timed out. Please check your internet.'),
      );
    } on SocketException {
      return Either.left(
        AuthFailure('No internet connection. Please try again.'),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e) {
      return Either.left(
        AuthFailure('An unexpected error occurred during sign up.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return Either.right(null);
    } on TimeoutException {
      return Either.left(
        AuthFailure('Connection timed out. Please check your internet.'),
      );
    } on SocketException {
      return Either.left(
        AuthFailure('No internet connection. Please try again.'),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e) {
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
    try {
      await remoteDataSource.signInWithGoogle();
      return Either.right(null);
    } on TimeoutException {
      return Either.left(
        AuthFailure('Connection timed out. Please check your internet.'),
      );
    } on SocketException {
      return Either.left(
        AuthFailure('No internet connection. Please try again.'),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e, stack) {
      debugPrint('[Google Sign-In Error]: $e');
      debugPrint('[Google Sign-In StackTrace]: $stack');
      return Either.left(
        AuthFailure('An unexpected error occurred during Google Sign-In.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(
    String fullName, {
    String? dateOfBirth,
  }) async {
    try {
      await remoteDataSource.updateProfile(fullName, dateOfBirth: dateOfBirth);
      return Either.right(null);
    } on TimeoutException {
      return Either.left(
        AuthFailure('Connection timed out. Please check your internet.'),
      );
    } on SocketException {
      return Either.left(
        AuthFailure('No internet connection. Please try again.'),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } on PostgrestException catch (e) {
      return Either.left(AuthFailure(_parseErrorMessage(e.message)));
    } catch (e) {
      return Either.left(
        AuthFailure('An unexpected error occurred while updating profile.'),
      );
    }
  }

  String _parseErrorMessage(String originalMessage) {
    final lowerMessage = originalMessage.toLowerCase();

    // 1. Network / Server 5xx / Connection errors
    if (lowerMessage.contains('500') ||
        lowerMessage.contains('501') ||
        lowerMessage.contains('502') ||
        lowerMessage.contains('503') ||
        lowerMessage.contains('504') ||
        lowerMessage.contains('522') ||
        lowerMessage.contains('error code:') ||
        lowerMessage.contains('network') ||
        lowerMessage.contains('timeout')) {
      return 'Something went wrong. Please check your internet connection or try again later.';
    }

    // 2. Login credentials failure
    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid credentials') ||
        lowerMessage.contains('wrong password') ||
        lowerMessage.contains('user not found')) {
      return 'Invalid email or password. Please try again.';
    }

    // 3. User already registered
    if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('already registered') ||
        lowerMessage.contains('already in use') ||
        lowerMessage.contains('email address is already registered')) {
      return 'This email is already registered. Please log in instead.';
    }

    // 4. Rate limiting / Throttling

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

    // 9. Protect against raw technical database / backend exceptions
    if (lowerMessage.contains('postgrest') ||
        lowerMessage.contains('database') ||
        lowerMessage.contains('sql') ||
        lowerMessage.contains('jwt') ||
        lowerMessage.contains('exception') ||
        lowerMessage.contains('null') ||
        lowerMessage.contains('column') ||
        lowerMessage.contains('table') ||
        lowerMessage.contains('syntax')) {
      return 'An unexpected error occurred. Please try again.';
    }

    return originalMessage;
  }
}

