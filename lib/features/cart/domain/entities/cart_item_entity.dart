class CartItemEntity {
  final int? id;
  final String cardId;
  final String title;
  final String message;
  final DateTime addedAt;

  CartItemEntity({
    this.id,
    required this.cardId,
    required this.title,
    required this.message,
    required this.addedAt,
  });
}
