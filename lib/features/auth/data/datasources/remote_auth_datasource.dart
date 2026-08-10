import 'dart:async';
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
}

