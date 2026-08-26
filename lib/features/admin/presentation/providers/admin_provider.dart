import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(Supabase.instance.client);
});

final adminCategoriesProvider = FutureProvider<List<AdminCategory>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchCategories();
});

final adminCardsProvider = FutureProvider<List<AdminCard>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchCards();
});

final adminPurchasesProvider = FutureProvider<List<AdminPurchase>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchPurchases();
});

final adminUsersProvider = FutureProvider<List<AdminUser>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchUsers();
});

final adminOccasionsProvider = FutureProvider<List<AdminOccasion>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchOccasions();
});

final adminSystemHealthProvider = FutureProvider<AdminSystemHealth>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchSystemHealth();
});
