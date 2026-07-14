class OrderEntity {
  final int? id;
  final String? remoteId;
  final String? supabaseUserId;
  final String cardId;
  final String title;
  final String message;
  final DateTime addedAt;

  OrderEntity({
    this.id,
    this.remoteId,
    this.supabaseUserId,
    required this.cardId,
    required this.title,
    required this.message,
    required this.addedAt,
  });

  OrderEntity copyWith({
    int? id,
    String? remoteId,
    String? supabaseUserId,
    String? cardId,
    String? title,
    String? message,
    DateTime? addedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      supabaseUserId: supabaseUserId ?? this.supabaseUserId,
      cardId: cardId ?? this.cardId,
      title: title ?? this.title,
      message: message ?? this.message,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
