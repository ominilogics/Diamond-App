import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/remote_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../features/payments/domain/repositories/payment_repository.dart';
import '../../../../features/payments/presentation/providers/payment_providers.dart';

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
  final PaymentRepository paymentRepository;

  AuthNotifier(this.repository, this.paymentRepository) : super(false);

  Future<void> signIn(
    String email,
    String password,
    Function(String) onError,
    Function() onSuccess,
  ) async {
    state = true;
    final result = await repository.signIn(email, password);
    state = false;
    result.fold((failure) => onError(failure.message), (_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        paymentRepository.loginUser(user.id);
      }
      onSuccess();
    });
  }

  Future<void> signUp(
    String email,
    String password,
    String fullName,
    String? dateOfBirth,
    Function(String) onError,
    Function() onSuccess,
  ) async {
    state = true;
    final result = await repository.signUp(
      email,
      password,
      fullName,
      dateOfBirth: dateOfBirth,
    );
    state = false;
    result.fold((failure) => onError(failure.message), (_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        paymentRepository.loginUser(user.id);
      }
      onSuccess();
    });
  }

  Future<void> resetPassword(
    String email,
    Function(String) onError,
    Function() onSuccess,
  ) async {
    state = true;
    final result = await repository.resetPassword(email);
    state = false;
    result.fold((failure) => onError(failure.message), (_) => onSuccess());
  }

  Future<void> signOut() async {
    state = true;
    await paymentRepository.logoutUser();
    await repository.signOut();
    state = false;
  }

  Future<void> signInWithGoogle(
    Function(String) onError,
    Function() onSuccess,
  ) async {
    state = true;
    final result = await repository.signInWithGoogle();
    state = false;
    result.fold((failure) => onError(failure.message), (_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        paymentRepository.loginUser(user.id);
      }
      onSuccess();
    });
  }

  Future<void> updateProfile(
    String fullName,
    String? dateOfBirth,
    Function(String) onError,
    Function() onSuccess,
  ) async {
    state = true;
    final result = await repository.updateProfile(
      fullName,
      dateOfBirth: dateOfBirth,
    );
    state = false;
    result.fold((failure) => onError(failure.message), (_) => onSuccess());
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return AuthNotifier(repository, paymentRepo);
});
