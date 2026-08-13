import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class RemoteAuthDataSource {
  Future<void> signIn(String email, String password);
  Future<void> signUp(
    String email,
    String password,
    String fullName, {
    String? dateOfBirth,
  });
  Future<void> resetPassword(String email);
  Future<void> signOut();
  Future<void> signInWithGoogle();
  Future<void> updateProfile(String fullName, {String? dateOfBirth});
  Future<void> deleteAccount({Function(String)? onProgress});
}

class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  final SupabaseClient supabaseClient;
  static const Duration timeoutDuration = Duration(seconds: 15);

  RemoteAuthDataSourceImpl(this.supabaseClient);

  @override
  Future<void> signIn(String email, String password) async {
    await supabaseClient.auth
        .signInWithPassword(
          email: email,
          password: password,
        )
        .timeout(timeoutDuration);
  }

  @override
  Future<void> signUp(
    String email,
    String password,
    String fullName, {
    String? dateOfBirth,
  }) async {
    final data = {'custom_name': fullName, 'full_name': fullName};
    if (dateOfBirth != null) {
      data['date_of_birth'] = dateOfBirth;
    }

    final currentUser = supabaseClient.auth.currentUser;
    if (currentUser != null && (currentUser.isAnonymous ?? false)) {
      // Option B: Cloud Guest - Upgrade anonymous session to permanent email session
      final response = await supabaseClient.auth
          .updateUser(
            UserAttributes(
              email: email,
              password: password,
              data: data,
            ),
          )
          .timeout(timeoutDuration);
      if (response.user == null) {
        throw const AuthException('Failed to convert anonymous account.');
      }
    } else {
      // Standard new user sign up
      final response = await supabaseClient.auth
          .signUp(
            email: email,
            password: password,
            data: data,
          )
          .timeout(timeoutDuration);

      // Auto-confirm might auto-login the user, we want them to explicitly log in.
      if (response.session != null) {
        await supabaseClient.auth.signOut().timeout(timeoutDuration);
      }
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    final bool emailExists = await supabaseClient
        .rpc('check_email_exists', params: {'email_to_check': email})
        .timeout(timeoutDuration);

    if (!emailExists) {
      throw const AuthException(
        'Please use the correct email. This email is not registered.',
      );
    }

    await supabaseClient.auth
        .resetPasswordForEmail(email)
        .timeout(timeoutDuration);
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut().timeout(timeoutDuration);
  }

  @override
  Future<void> signInWithGoogle() async {
    const webClientId =
        '672659691643-ebersoi5iqd20siva6ajdm5vjpb69lhp.apps.googleusercontent.com';
    final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: webClientId);
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google sign in was aborted.');
    }
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw const AuthException('No ID Token found.');
    }

    final currentUser = supabaseClient.auth.currentUser;
    if (currentUser != null && (currentUser.isAnonymous ?? false)) {
      // Option B: Cloud Guest - Link Google to anonymous session
      await supabaseClient.auth
          .signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          )
          .timeout(timeoutDuration);
    } else {
      // Standard Google sign in
      await supabaseClient.auth
          .signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          )
          .timeout(timeoutDuration);
    }
  }

  @override
  Future<void> updateProfile(String fullName, {String? dateOfBirth}) async {
    final data = {'custom_name': fullName, 'full_name': fullName};
    if (dateOfBirth != null) {
      data['date_of_birth'] = dateOfBirth;
    }
    final response = await supabaseClient.auth
        .updateUser(UserAttributes(data: data))
        .timeout(timeoutDuration);
    if (response.user == null) {
      throw const AuthException('Failed to update profile.');
    }
  }

  @override
  Future<void> deleteAccount({Function(String)? onProgress}) async {
    final currentUser = supabaseClient.auth.currentUser;
    if (currentUser == null) {
      debugPrint('⚠️ [ACCOUNT_DELETION] No active user session found to delete.');
      return;
    }
    final userId = currentUser.id;
    debugPrint('🔥 [ACCOUNT_DELETION] Initiating remote account deletion for User ID: $userId');

    onProgress?.call('Deleting account data...');

    try {
      debugPrint('  ├── [REMOTE_DELETE] Executing Supabase RPC procedure: delete_user_account()');
      await supabaseClient.rpc('delete_user_account').timeout(timeoutDuration);
      debugPrint('  └── [REMOTE_DELETE] Successfully deleted user account & cascading rows from Supabase.');
    } catch (rpcError) {
      debugPrint('⚠️ [REMOTE_DELETE] Supabase RPC delete_user_account procedure notice: $rpcError');
      debugPrint('  ├── [FALLBACK_CLEANUP] Executing client-side per-table fallback cleanup for User ID: $userId...');

      // Per-table fallback deletes isolated so one table's RLS policy doesn't halt the rest
      try {
        onProgress?.call('Deleting favorites...');
        await supabaseClient.from('favorites').delete().eq('user_id', userId);
        debugPrint('  ├── [FALLBACK_CLEANUP] Deleted favorites rows');
      } catch (e) {
        debugPrint('  ├── [FALLBACK_CLEANUP] Favorites table notice: $e');
      }

      try {
        onProgress?.call('Deleting events...');
        await supabaseClient.from('events').delete().eq('user_id', userId);
        debugPrint('  ├── [FALLBACK_CLEANUP] Deleted events rows');
      } catch (e) {
        debugPrint('  ├── [FALLBACK_CLEANUP] Events table notice: $e');
      }

      try {
        onProgress?.call('Deleting orders...');
        await supabaseClient.from('orders').delete().eq('user_id', userId);
        debugPrint('  ├── [FALLBACK_CLEANUP] Deleted orders rows');
      } catch (e) {
        debugPrint('  ├── [FALLBACK_CLEANUP] Orders table notice: $e');
      }

      try {
        onProgress?.call('Deleting notifications...');
        await supabaseClient.from('notifications').delete().eq('user_id', userId);
        debugPrint('  ├── [FALLBACK_CLEANUP] Deleted notifications rows');
      } catch (e) {
        debugPrint('  ├── [FALLBACK_CLEANUP] Notifications table notice: $e');
      }

      try {
        onProgress?.call('Deleting push tokens...');
        await supabaseClient.from('user_fcm_tokens').delete().eq('user_id', userId);
        debugPrint('  ├── [FALLBACK_CLEANUP] Deleted user_fcm_tokens rows');
      } catch (e) {
        debugPrint('  ├── [FALLBACK_CLEANUP] FCM tokens table notice: $e');
      }

      // If the RPC is missing (PGRST202), fallback completed remote table wipes
      final errorStr = rpcError.toString();
      if (errorStr.contains('PGRST202') || errorStr.contains('delete_user_account')) {
        debugPrint('ℹ️ [REMOTE_DELETE] Note: Deploy public.delete_user_account() in Supabase SQL Editor for complete auth.users removal.');
        return;
      }

      rethrow;
    }
  }
}

