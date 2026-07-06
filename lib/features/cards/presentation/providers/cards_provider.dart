import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/repositories/cards_repository.dart';
import '../../data/repositories/cards_repository_impl.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/entities/category_entity.dart';

final cardsRepositoryProvider = Provider<CardsRepository>((ref) {
  return CardsRepositoryImpl(
    supabaseClient: Supabase.instance.client,
    localDb: ref.watch(appDatabaseProvider),
  );
});

final categoriesStreamProvider = StreamProvider<List<CategoryEntity>>((ref) {
  final repository = ref.watch(cardsRepositoryProvider);
  return repository.watchCategories();
});

final allCardsStreamProvider = StreamProvider<List<CardEntity>>((ref) {
  final repository = ref.watch(cardsRepositoryProvider);
  return repository.watchCards();
});

final featuredCardsStreamProvider = Provider<AsyncValue<List<CardEntity>>>((ref) {
  final asyncCards = ref.watch(allCardsStreamProvider);
  return asyncCards.whenData((cards) => cards.where((c) => c.isFeatured).toList());
});

final categoryCardsStreamProvider = Provider.family<AsyncValue<List<CardEntity>>, String>((ref, categoryId) {
  final asyncCards = ref.watch(allCardsStreamProvider);
  return asyncCards.whenData((cards) => cards.where((c) => c.categoryId == categoryId).toList());
});

final cardDetailProvider = Provider.family<AsyncValue<CardEntity?>, String>((ref, cardId) {
  final asyncCards = ref.watch(allCardsStreamProvider);
  return asyncCards.whenData((cards) => cards.where((c) => c.id == cardId).firstOrNull);
});

final syncCardsProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(cardsRepositoryProvider);
  await repository.syncData();
});

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final searchResultsProvider = Provider.autoDispose<AsyncValue<List<CardEntity>>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  
  final asyncCards = ref.watch(allCardsStreamProvider);

  if (query.isEmpty) {
    return const AsyncValue.data([]);
  }

  return asyncCards.whenData((cards) {
    // Basic Tokenization for multi-word search
    final tokens = query.split(RegExp(r'\s+'));
    
    // Efficient O(N) multi-field linear scan filter
    final results = cards.where((card) {
      final title = card.title.toLowerCase();
      final front = card.defaultFrontMessage?.toLowerCase() ?? '';
      final inside = card.defaultInsideMessage?.toLowerCase() ?? '';
      
      // Fast AND logic: every token must be found in at least one of the fields
      for (final token in tokens) {
        if (!title.contains(token) && !front.contains(token) && !inside.contains(token)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Advanced Sorting based on multi-field relevance scoring
    results.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      final titleA = a.title.toLowerCase();
      final frontA = a.defaultFrontMessage?.toLowerCase() ?? '';
      final insideA = a.defaultInsideMessage?.toLowerCase() ?? '';

      final titleB = b.title.toLowerCase();
      final frontB = b.defaultFrontMessage?.toLowerCase() ?? '';
      final insideB = b.defaultInsideMessage?.toLowerCase() ?? '';
      
      // Score A
      if (titleA == query) scoreA += 100; // Exact title match
      else if (titleA.startsWith(query)) scoreA += 50; // Title prefix match
      else if (titleA.contains(query)) scoreA += 25; // Title partial match
      else if (frontA.contains(query)) scoreA += 10; // Front message match
      else if (insideA.contains(query)) scoreA += 5; // Inside message match

      // Score B
      if (titleB == query) scoreB += 100;
      else if (titleB.startsWith(query)) scoreB += 50;
      else if (titleB.contains(query)) scoreB += 25;
      else if (frontB.contains(query)) scoreB += 10;
      else if (insideB.contains(query)) scoreB += 5;
      
      return scoreB.compareTo(scoreA); // Highest score at the top
    });

    return results;
  });
});
