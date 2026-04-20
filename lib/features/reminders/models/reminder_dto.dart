class ReminderModel {
  final int? id;
  final String title;
  final String? notes;
  final DateTime targetDate;
  final bool isNotificationEnabled;

  ReminderModel({
    this.id,
    required this.title,
    this.notes,
    required this.targetDate,
    required this.isNotificationEnabled,
  });
}
