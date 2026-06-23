class FavoriteEntity {
  final int? id;
  final String cardId;
  final String title;
  final int colorValue;
  final String supabaseUserId;
  final DateTime favoritedAt;

  FavoriteEntity({
    this.id,
    required this.cardId,
    required this.title,
    required this.colorValue,
    required this.supabaseUserId,
    required this.favoritedAt,
  });
}
