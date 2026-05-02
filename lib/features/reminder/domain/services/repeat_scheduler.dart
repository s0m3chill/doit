import 'package:doit/features/reminder/domain/entities/reminder.dart';

/// Pure domain service — computes the next reminder for recurring reminders.
/// No side effects, no dependencies on infrastructure.
class RepeatScheduler {
  /// Given a completed recurring reminder, produce the next occurrence.
  /// Returns null if the reminder is not recurring.
  Reminder? computeNextOccurrence({
    required Reminder completed,
    required String newId,
    required DateTime now,
  }) {
    final nextDue = completed.nextOccurrence();
    if (nextDue == null) return null;

    return Reminder(
      id: newId,
      title: completed.title,
      dueDate: nextDue,
      isCompleted: false,
      repeatInterval: completed.repeatInterval,
      autoSnoozeEnabled: completed.autoSnoozeEnabled,
      autoSnoozeInterval: completed.autoSnoozeInterval,
      createdAt: now,
      updatedAt: now,
    );
  }
}
