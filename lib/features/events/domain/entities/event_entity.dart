class EventEntity {
  final int id;
  final String? remoteId;
  final String? supabaseUserId;
  final String title;
  final DateTime date;
  final String reminder;
  final bool isCustom;

  EventEntity({
    required this.id,
    this.remoteId,
    this.supabaseUserId,
    required this.title,
    required this.date,
    required this.reminder,
    this.isCustom = true,
  });

  EventEntity copyWith({
    int? id,
    String? remoteId,
    String? supabaseUserId,
    String? title,
    DateTime? date,
    String? reminder,
    bool? isCustom,
  }) {
    return EventEntity(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      supabaseUserId: supabaseUserId ?? this.supabaseUserId,
      title: title ?? this.title,
      date: date ?? this.date,
      reminder: reminder ?? this.reminder,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
