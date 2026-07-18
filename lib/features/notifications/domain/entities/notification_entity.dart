class NotificationEntity {
  final int? id;
  final String? remoteId;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isRead;
  final String? payload;

  NotificationEntity({
    this.id,
    this.remoteId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isRead = false,
    this.payload,
  });
}
