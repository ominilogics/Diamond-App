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
