class EventEntity {
  final int id;
  final String? remoteId;
  final String? supabaseUserId;
  final String title;
  final DateTime date;
  final String reminder;
  final bool isCustom;
  final DateTime? notificationTime;
  final bool isNotified;

  EventEntity({
    required this.id,
    this.remoteId,
    this.supabaseUserId,
    required this.title,
    required this.date,
    required this.reminder,
    this.isCustom = true,
    this.notificationTime,
    this.isNotified = false,
  });

  EventEntity copyWith({
    int? id,
    String? remoteId,
    String? supabaseUserId,
    String? title,
    DateTime? date,
    String? reminder,
    bool? isCustom,
    DateTime? notificationTime,
    bool? isNotified,
  }) {
    return EventEntity(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      supabaseUserId: supabaseUserId ?? this.supabaseUserId,
      title: title ?? this.title,
      date: date ?? this.date,
      reminder: reminder ?? this.reminder,
      isCustom: isCustom ?? this.isCustom,
      notificationTime: notificationTime ?? this.notificationTime,
      isNotified: isNotified ?? this.isNotified,
    );
  }
}
