class CategoryEntity {
  final String id;
  final String name;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.sortOrder,
    required this.isActive,
  });
}
