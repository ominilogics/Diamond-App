class EventEntity {
  final int id;
  final String title;
  final DateTime date;
  final String reminder;
  final bool isCustom;

  EventEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.reminder,
    this.isCustom = true,
  });
}
