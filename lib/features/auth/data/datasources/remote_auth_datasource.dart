import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RemoteAuthDataSource {
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password, String fullName);
  Future<void> resetPassword(String email);
  Future<void> signOut();
}

class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  final SupabaseClient supabaseClient;

  RemoteAuthDataSourceImpl(this.supabaseClient);

  @override
  Future<void> signIn(String email, String password) async {
    await supabaseClient.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp(String email, String password, String fullName) async {
    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    
    // Auto-confirm might auto-login the user, we want them to explicitly log in.
    if (response.session != null) {
      await supabaseClient.auth.signOut();
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    final bool emailExists = await supabaseClient.rpc(
      'check_email_exists',
      params: {'email_to_check': email},
    );

    if (!emailExists) {
      throw const AuthException('Please use the correct email. This email is not registered.');
    }

    await supabaseClient.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }
}
