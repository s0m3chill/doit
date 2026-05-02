import 'package:doit/features/reminder/domain/entities/reminder.dart';

/// Domain-level contract for the auto-snooze scheduling engine.
abstract class AutoSnoozeScheduler {
  /// Schedule the next auto-snooze notification for a reminder.
  /// Respects the max count limit. Returns the updated snooze count.
  Future<int> scheduleNextSnooze(Reminder reminder);

  /// Cancel all auto-snooze notifications for a specific reminder.
  Future<void> cancelSnooze(String reminderId);

  /// Re-evaluate all active reminders and schedule/cancel as needed.
  /// Called after any reminder mutation.
  Future<void> syncAllSnoozes(List<Reminder> activeReminders);

  /// Re-snooze all overdue reminders on app launch.
  /// Resets snooze counts and schedules indefinitely (matching Due's behavior:
  /// "Due can auto snooze any overdue items indefinitely when you launch Due").
  Future<List<Reminder>> resnoozeAllOnLaunch(List<Reminder> activeReminders);
}
