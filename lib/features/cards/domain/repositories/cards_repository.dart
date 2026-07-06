import 'dart:async';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/card_entity.dart';
import '../entities/category_entity.dart';

abstract class CardsRepository {
  /// Watches the local Drift database for instant offline-first rendering.
  Stream<List<CategoryEntity>> watchCategories();

  /// Watches the local Drift database for cards, optionally filtered by category or featured status.
  Stream<List<CardEntity>> watchCards({String? categoryId, bool? isFeatured});

  /// Triggers a background network sync with Supabase. New data is merged into Drift seamlessly.
  Future<Either<Failure, void>> syncData();
}
