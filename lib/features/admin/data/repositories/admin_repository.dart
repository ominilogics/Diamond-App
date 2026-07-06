import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AdminCategory {
  final String id;
  final String name;
  final bool isActive;
  AdminCategory({required this.id, required this.name, required this.isActive});
}

class AdminCard {
  final String id;
  final String categoryId;
  final String title;
  final String coverImageUrl;
  final String defaultFrontMessage;
  final String defaultInsideMessage;
  final bool isActive;
  AdminCard({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.coverImageUrl,
    required this.defaultFrontMessage,
    required this.defaultInsideMessage,
    required this.isActive,
  });
}

class AdminRepository {
  final SupabaseClient _supabase;

  AdminRepository(this._supabase);

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  Future<void> addCategory(String name) async {
    final id = const Uuid().v4();
    await _supabase.from('categories').insert({
      'id': id,
      'name': name,
      'is_active': true,
    });
  }

  Future<void> updateCategory(String id, String name, bool isActive) async {
    await _supabase.from('categories').update({
      'name': name,
      'is_active': isActive,
    }).eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await _supabase.from('categories').update({'is_active': false}).eq('id', id);
  }

  Future<List<AdminCategory>> fetchCategories() async {
    final response = await _supabase.from('categories').select().order('name');
    return response.map((row) => AdminCategory(
      id: row['id'],
      name: row['name'],
      isActive: row['is_active'],
    )).toList();
  }

  // ---------------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------------

  Future<void> addCard({
    required String categoryId,
    required String title,
    required String defaultFrontMessage,
    required String defaultInsideMessage,
    required Uint8List imageBytes,
    required String fileExtension, // e.g., 'jpg', 'png'
  }) async {
    final cardId = const Uuid().v4();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_card_template.$fileExtension';

    await _supabase.storage.from('card_assets').uploadBinary(
          fileName,
          imageBytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExtension',
            upsert: true,
          ),
        );

    final imageUrl = _supabase.storage.from('card_assets').getPublicUrl(fileName);

    // 2. Insert Card record
    await _supabase.from('cards').insert({
      'id': cardId,
      'category_id': categoryId,
      'title': title,
      'cover_image_url': imageUrl,
      'default_front_message': defaultFrontMessage,
      'default_inside_message': defaultInsideMessage,
      'is_featured': false,
      'price': 5.99,
      'is_active': true,
    });
  }

  Future<void> updateCard({
    required String cardId,
    required String title,
    required bool isActive,
  }) async {
    await _supabase.from('cards').update({
      'title': title,
      'is_active': isActive,
    }).eq('id', cardId);
  }

  Future<void> deleteCard(String cardId) async {
    await _supabase.from('cards').update({'is_active': false}).eq('id', cardId);
  }

  Future<List<AdminCard>> fetchCards() async {
    final response = await _supabase.from('cards').select().order('title');
    return response.map((row) => AdminCard(
      id: row['id'],
      categoryId: row['category_id'],
      title: row['title'],
      coverImageUrl: row['cover_image_url'],
      defaultFrontMessage: row['default_front_message'] ?? '',
      defaultInsideMessage: row['default_inside_message'] ?? '',
      isActive: row['is_active'],
    )).toList();
  }
}
