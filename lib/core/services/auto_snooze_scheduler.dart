import 'package:doit/features/reminder/domain/entities/reminder.dart';

/// Domain-level contract for the auto-snooze scheduling engine.
/// Manages the persistent nagging loop for overdue reminders.
abstract class AutoSnoozeScheduler {
  /// Schedule the next auto-snooze notification for a reminder.
  /// If the reminder is overdue and has auto-snooze enabled,
  /// this will schedule a notification [autoSnoozeInterval] minutes from now.
  Future<void> scheduleNextSnooze(Reminder reminder);

  /// Cancel all auto-snooze notifications for a specific reminder.
  Future<void> cancelSnooze(String reminderId);

  /// Re-evaluate all active reminders and schedule/cancel as needed.
  /// Called on app startup and after any reminder mutation.
  Future<void> syncAllSnoozes(List<Reminder> activeReminders);
}
