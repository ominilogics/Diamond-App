import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/remote_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final dataSource = RemoteAuthDataSourceImpl(client);
  return AuthRepositoryImpl(dataSource);
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(false);

  Future<void> signIn(String email, String password, Function(String) onError, Function() onSuccess) async {
    state = true;
    final result = await repository.signIn(email, password);
    state = false;
    result.fold(
      (failure) => onError(failure.message),
      (_) => onSuccess(),
    );
  }

  Future<void> signUp(String email, String password, String fullName, Function(String) onError, Function() onSuccess) async {
    state = true;
    final result = await repository.signUp(email, password, fullName);
    state = false;
    result.fold(
      (failure) => onError(failure.message),
      (_) => onSuccess(),
    );
  }

  Future<void> resetPassword(String email, Function(String) onError, Function() onSuccess) async {
    state = true;
    final result = await repository.resetPassword(email);
    state = false;
    result.fold(
      (failure) => onError(failure.message),
      (_) => onSuccess(),
    );
  }

  Future<void> signOut() async {
    state = true;
    await repository.signOut();
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
