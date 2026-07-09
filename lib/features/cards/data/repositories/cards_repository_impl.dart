import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/cards_repository.dart';
import 'package:drift/drift.dart' as drift;

class CardsRepositoryImpl implements CardsRepository {
  final SupabaseClient supabaseClient;
  final AppDatabase localDb;

  CardsRepositoryImpl({required this.supabaseClient, required this.localDb});

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    return (localDb.select(localDb.remoteCategoriesTable)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => CategoryEntity(
                  id: row.id,
                  name: row.name,
                  iconUrl: row.iconUrl,
                  sortOrder: row.sortOrder,
                  isActive: row.isActive,
                ),
              )
              .where((cat) => cat.isActive)
              .toList(),
        );
  }

  @override
  Stream<List<CardEntity>> watchCards({String? categoryId, bool? isFeatured}) {
    final query = localDb.select(localDb.remoteCardsTable);
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (isFeatured != null) {
      query.where((t) => t.isFeatured.equals(isFeatured));
    }

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => CardEntity(
              id: row.id,
              categoryId: row.categoryId,
              title: row.title,
              coverImageUrl: row.coverImageUrl,
              defaultFrontMessage: row.defaultFrontMessage,
              defaultInsideMessage: row.defaultInsideMessage,
              price: row.price,
              isFeatured: row.isFeatured,
              colorValue: row.colorValue,
              isActive: row.isActive,
            ),
          )
          .where((card) => card.isActive)
          .toList(),
    );
  }

  @override
  Future<Either<Failure, void>> syncData() async {
    try {
      // Fetch Categories
      final categoriesResponse = await supabaseClient
          .from('categories')
          .select();

      // Fetch Cards
      final cardsResponse = await supabaseClient.from('cards').select();

      // Upsert into Drift
      await localDb.transaction(() async {
        for (var cat in categoriesResponse) {
          await localDb
              .into(localDb.remoteCategoriesTable)
              .insertOnConflictUpdate(
                RemoteCategoryTableData(
                  id: cat['id'],
                  name: cat['name'],
                  iconUrl: cat['icon_url'],
                  sortOrder: cat['sort_order'] ?? 0,
                  isActive: cat['is_active'] ?? true,
                  createdAt: DateTime.parse(cat['created_at']),
                ),
              );
        }

        for (var card in cardsResponse) {
          await localDb
              .into(localDb.remoteCardsTable)
              .insertOnConflictUpdate(
                RemoteCardTableData(
                  id: card['id'],
                  categoryId: card['category_id'],
                  title: card['title'],
                  coverImageUrl: card['cover_image_url'],
                  defaultFrontMessage: card['default_front_message'],
                  defaultInsideMessage: card['default_inside_message'],
                  price: (card['price'] as num?)?.toDouble() ?? 5.99,
                  isFeatured: card['is_featured'] ?? false,
                  colorValue: card['color_value'],
                  isActive: card['is_active'] ?? true,
                  createdAt: DateTime.parse(card['created_at']),
                ),
              );
        }
      });

      return Either.right(null);
    } on SocketException {
      return Either.left(
        ServerFailure('No internet connection. Using offline cache.'),
      );
    } on PostgrestException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(
        ServerFailure('An unexpected error occurred while syncing data.'),
      );
    }
  }
}
