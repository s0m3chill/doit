import 'package:equatable/equatable.dart';

/// Core domain entity representing a reminder.
/// This is the heart of the app — no framework dependencies here.
class Reminder extends Equatable {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final String repeatInterval; // none, daily, weekly, monthly, yearly
  final bool autoSnoozeEnabled;
  final int autoSnoozeInterval; // minutes between auto-snooze nags
  final int? snoozeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    this.repeatInterval = 'none',
    this.autoSnoozeEnabled = true,
    this.autoSnoozeInterval = 5,
    this.snoozeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this reminder is overdue right now.
  bool isOverdue(DateTime now) => !isCompleted && dueDate.isBefore(now);

  /// Whether this reminder is a recurring one.
  bool get isRecurring => repeatInterval != 'none';

  /// Compute the next due date based on the repeat interval.
  /// Returns null if not recurring.
  DateTime? nextOccurrence() {
    if (!isRecurring) return null;
    switch (repeatInterval) {
      case 'daily':
        return dueDate.add(const Duration(days: 1));
      case 'weekly':
        return dueDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(
          dueDate.year,
          dueDate.month + 1,
          dueDate.day,
          dueDate.hour,
          dueDate.minute,
        );
      case 'yearly':
        return DateTime(
          dueDate.year + 1,
          dueDate.month,
          dueDate.day,
          dueDate.hour,
          dueDate.minute,
        );
      default:
        return null;
    }
  }

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    String? repeatInterval,
    bool? autoSnoozeEnabled,
    int? autoSnoozeInterval,
    int? snoozeMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      autoSnoozeEnabled: autoSnoozeEnabled ?? this.autoSnoozeEnabled,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        dueDate,
        isCompleted,
        repeatInterval,
        autoSnoozeEnabled,
        autoSnoozeInterval,
        snoozeMinutes,
        createdAt,
        updatedAt,
      ];
}
