class CardEntity {
  final String id;
  final String categoryId;
  final String title;
  final String coverImageUrl;
  final String? defaultFrontMessage;
  final String? defaultInsideMessage;
  final double price;
  final bool isFeatured;
  final int? colorValue;
  final bool isActive;

  const CardEntity({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.coverImageUrl,
    this.defaultFrontMessage,
    this.defaultInsideMessage,
    required this.price,
    required this.isFeatured,
    this.colorValue,
    required this.isActive,
  });
}
