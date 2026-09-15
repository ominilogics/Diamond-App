import 'package:daimond/features/auth/data/datasources/remote_auth_datasource.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../features/payments/domain/repositories/payment_repository.dart';
import '../../../../features/payments/presentation/providers/payment_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/database/app_database.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final dataSource = RemoteAuthDataSourceImpl(client);
  return AuthRepositoryImpl(dataSource);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository repository;
  final PaymentRepository paymentRepository;
  final AppDatabase database;

  AuthNotifier(this.repository, this.paymentRepository, this.database) : super(false);

  Future<void> signIn(
    String email,
    String password,
    Function(String) onError,
    Function() onSuccess,
  ) async {
    state = true;
    final oldUser = Supabase.instance.client.auth.currentUser;
    final oldUserId = oldUser?.id;
    final wasAnonymous = oldUser?.isAnonymous ?? false;
    debugPrint('[AUTH] Attempting signIn for email: $email. Current User ID: $oldUserId (Anonymous: $wasAnonymous)');

    final result = await repository.signIn(email, password);
    
    result.fold(
      (failure) {
        state = false;
        onError(failure.message);
      },
      (_) async {
        final newUser = Supabase.instance.client.auth.currentUser;
        debugPrint('[AUTH] signIn successful. New User ID: ${newUser?.id}');
        
        // Handle account transitions (Guest -> Real or Real -> Real)
        if (oldUserId != null && newUser != null && oldUserId != newUser.id) {
          if (wasAnonymous) {
            debugPrint('[AUTH] Identity changed from Anonymous to Authenticated. Migrating guest data...');
            await _migrateGuestDataToSupabase(newUser.id);
            await database.claimAnonymousData(newUser.id);
          } else {
            debugPrint('[AUTH] Identity changed between Authenticated accounts. Wiping local data.');
            await database.clearUserData();
          }
        } else {
          debugPrint('[AUTH] Identity unchanged or new login. Local data preserved.');
        }

        if (newUser != null) {
          paymentRepository.loginUser(newUser.id);
        }
        state = false;
        onSuccess();
      },
    );
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
    debugPrint('[AUTH] Attempting signUp for email: $email');
    final result = await repository.signUp(
      email,
      password,
      fullName,
      dateOfBirth: dateOfBirth,
    );
    state = false;
    result.fold((failure) {
      debugPrint('[AUTH] signUp failed: ${failure.message}');
      onError(failure.message);
    }, (_) {
      final user = Supabase.instance.client.auth.currentUser;
      debugPrint('[AUTH] signUp successful. User ID: ${user?.id}. Local data preserved automatically.');
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
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    debugPrint('[AUTH] Attempting signOut for User ID: $currentUserId');
    
    // Revoke FCM token for the current user before signing out
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await Supabase.instance.client
            .from('user_fcm_tokens')
            .delete()
            .eq('token', fcmToken);
      }
    } catch (e) {
      debugPrint('[AUTH] Failed to delete FCM token on logout: $e');
    }

    try {
      await paymentRepository.logoutUser();
    } catch (e) {
      debugPrint('[AUTH] Failed to logout from payment provider: $e');
    }

    try {
      await repository.signOut();
    } catch (e) {
      debugPrint('[AUTH] Failed to signOut from repository: $e');
    }
    
    try {
      debugPrint('[AUTH] signOut successful. Wiping local user data.');
      await database.clearUserData();
    } catch (e) {
      debugPrint('[AUTH] Failed to clear local database: $e');
    }
    
    state = false;
  }

  Future<void> deleteAccount(
    Function(String) onError,
    Function() onSuccess, {
    Function(String)? onProgress,
  }) async {
    state = true;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    debugPrint('🚨 [ACCOUNT_DELETION] User requested permanent account deletion!');
    debugPrint('  ├── User ID: $currentUserId');
    debugPrint('  ├── Step 1/5: Calling remote deletion (Supabase auth.users & database tables)...');

    onProgress?.call('Deleting account data...');

    final result = await repository.deleteAccount(onProgress: onProgress);

    await result.fold(
      (failure) async {
        state = false;
        debugPrint('❌ [ACCOUNT_DELETION] Remote deletion failed: ${failure.message}');
        onError(failure.message);
      },
      (_) async {
        debugPrint('  ├── Step 2/5: Revoking FCM token & push notification registration...');
        onProgress?.call('Revoking push tokens...');
        try {
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null && currentUserId != null) {
            await Supabase.instance.client
                .from('user_fcm_tokens')
                .delete()
                .eq('token', fcmToken);
            debugPrint('  │   └── Revoked FCM Token: $fcmToken');
          }
        } catch (e) {
          debugPrint('  │   └── FCM token revoke notice: $e');
        }

        debugPrint('  ├── Step 3/5: Logging out of Payment Provider (RevenueCat)...');
        onProgress?.call('Clearing payment data...');
        try {
          await paymentRepository.logoutUser();
          debugPrint('  │   └── RevenueCat payment session cleared.');
        } catch (e) {
          debugPrint('  │   └── Payment provider logout notice: $e');
        }

        debugPrint('  ├── Step 4/5: Terminating Supabase Auth session...');
        onProgress?.call('Signing out session...');
        try {
          await repository.signOut();
          debugPrint('  │   └── Auth session signed out.');
        } catch (e) {
          debugPrint('  │   └── Auth signout notice: $e');
        }

        debugPrint('  ├── Step 5/5: Wiping local device database (Favorites, Events, Drafts, Orders, Notifications)...');
        onProgress?.call('Wiping local database...');
        try {
          await database.clearUserData();
        } catch (e) {
          debugPrint('  │   └── Local database wipe notice: $e');
        }

        debugPrint('🎉 [ACCOUNT_DELETION] Account and all associated data permanently deleted successfully!');
        state = false;
        onSuccess();
      },
    );
  }

  Future<void> signInWithGoogle(
    Function(String) onError,
    Function() onSuccess,
  ) async {
    state = true;
    final oldUser = Supabase.instance.client.auth.currentUser;
    final oldUserId = oldUser?.id;
    final wasAnonymous = oldUser?.isAnonymous ?? false;
    debugPrint('[AUTH] Attempting Google Sign-In. Current User ID: $oldUserId (Anonymous: $wasAnonymous)');
    
    final result = await repository.signInWithGoogle();
    
    result.fold(
      (failure) {
        state = false;
        onError(failure.message);
      },
      (_) async {
        final newUser = Supabase.instance.client.auth.currentUser;
        debugPrint('[AUTH] Google Sign-In successful. New User ID: ${newUser?.id}');
        
        if (oldUserId != null && newUser != null && oldUserId != newUser.id) {
          if (wasAnonymous) {
            debugPrint('[AUTH] Identity changed from Anonymous to Authenticated via Google. Migrating guest data...');
            await _migrateGuestDataToSupabase(newUser.id);
            await database.claimAnonymousData(newUser.id);
          } else {
            debugPrint('[AUTH] Identity changed between Authenticated accounts. Wiping local data.');
            await database.clearUserData();
          }
        } else {
          debugPrint('[AUTH] Identity unchanged or new login. Local data preserved.');
        }

        if (newUser != null) {
          paymentRepository.loginUser(newUser.id);
        }
        state = false;
        onSuccess();
      },
    );
  }

  Future<void> signInWithApple(
    Function(String) onError,
    Function() onSuccess,
  ) async {
    state = true;
    final oldUser = Supabase.instance.client.auth.currentUser;
    final oldUserId = oldUser?.id;
    final wasAnonymous = oldUser?.isAnonymous ?? false;
    debugPrint('[AUTH] Attempting Apple Sign-In. Current User ID: $oldUserId (Anonymous: $wasAnonymous)');

    final result = await repository.signInWithApple();

    result.fold(
      (failure) {
        state = false;
        onError(failure.message);
      },
      (_) async {
        final newUser = Supabase.instance.client.auth.currentUser;
        debugPrint('[AUTH] Apple Sign-In successful. New User ID: ${newUser?.id}');

        if (oldUserId != null && newUser != null && oldUserId != newUser.id) {
          if (wasAnonymous) {
            debugPrint('[AUTH] Identity changed from Anonymous to Authenticated via Apple. Migrating guest data...');
            await _migrateGuestDataToSupabase(newUser.id);
            await database.claimAnonymousData(newUser.id);
          } else {
            debugPrint('[AUTH] Identity changed between Authenticated accounts. Wiping local data.');
            await database.clearUserData();
          }
        } else {
          debugPrint('[AUTH] Identity unchanged or new login. Local data preserved.');
        }

        if (newUser != null) {
          paymentRepository.loginUser(newUser.id);
        }
        state = false;
        onSuccess();
      },
    );
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

  Future<void> _migrateGuestDataToSupabase(String newUserId) async {
    final supabase = Supabase.instance.client;
    
    try {
      // 1. Migrate Favorites
      final favorites = await database.select(database.favoritesTable).get();
      if (favorites.isNotEmpty) {
        final List<Map<String, dynamic>> favoritePayloads = favorites.map((f) => {
          'user_id': newUserId,
          'card_id': f.cardId,
        }).toList();
        await supabase.from('favorites').upsert(favoritePayloads, onConflict: 'user_id,card_id');
        debugPrint('[AUTH] Migrated ${favorites.length} favorites to $newUserId');
      }
    } catch (e) {
      debugPrint('[AUTH] Error migrating favorites: $e');
    }

    try {
      // 2. Migrate Events
      final events = await database.select(database.eventsTable).get();
      if (events.isNotEmpty) {
        final List<Map<String, dynamic>> eventPayloads = events.map((e) => {
          if (e.remoteId != null) 'id': e.remoteId,
          'user_id': newUserId,
          'title': e.title,
          'date': e.date.toIso8601String(),
          'reminder': e.reminder,
          'is_custom': e.isCustom,
        }).toList();
        
        for (var payload in eventPayloads) {
          await supabase.from('events').upsert(payload);
        }
        debugPrint('[AUTH] Migrated ${events.length} events to $newUserId');
      }
    } catch (e) {
      debugPrint('[AUTH] Error migrating events: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  final database = ref.watch(appDatabaseProvider);
  return AuthNotifier(repository, paymentRepo, database);
});
