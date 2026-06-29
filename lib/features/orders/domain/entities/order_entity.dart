class OrderEntity {
  final int? id;
  final String cardId;
  final String title;
  final String message;
  final DateTime addedAt;

  OrderEntity({
    this.id,
    required this.cardId,
    required this.title,
    required this.message,
    required this.addedAt,
  });

  OrderEntity copyWith({
    int? id,
    String? cardId,
    String? title,
    String? message,
    DateTime? addedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      title: title ?? this.title,
      message: message ?? this.message,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
