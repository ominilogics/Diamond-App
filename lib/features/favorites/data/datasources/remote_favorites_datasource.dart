import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/favorite_entity.dart';

abstract class RemoteFavoritesDataSource {
  Future<List<FavoriteEntity>> getFavorites();
  Future<void> addFavorite(FavoriteEntity favorite);
  Future<void> removeFavorite(String cardId);
}

class RemoteFavoritesDataSourceImpl implements RemoteFavoritesDataSource {
  final SupabaseClient supabaseClient;

  RemoteFavoritesDataSourceImpl(this.supabaseClient);

  @override
  Future<List<FavoriteEntity>> getFavorites() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('favorites')
        .select()
        .eq('user_id', userId);

    return (response as List).map((data) => FavoriteEntity(
      id: 0, // Remote doesn't use the Drift local ID
      cardId: data['card_id'],
      title: data['title'],
      colorValue: data['color_value'],
      supabaseUserId: data['user_id'],
      favoritedAt: DateTime.parse(data['favorited_at']),
    )).toList();
  }

  @override
  Future<void> addFavorite(FavoriteEntity favorite) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await supabaseClient.from('favorites').upsert({
      'user_id': userId,
      'card_id': favorite.cardId,
      'title': favorite.title,
      'color_value': favorite.colorValue,
      'favorited_at': favorite.favoritedAt.toIso8601String(),
    }, onConflict: 'user_id, card_id');
  }

  @override
  Future<void> removeFavorite(String cardId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await supabaseClient
        .from('favorites')
        .delete()
        .match({'user_id': userId, 'card_id': cardId});
  }
}
