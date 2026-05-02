import 'package:doit/core/services/auto_snooze_scheduler.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';

/// Concrete auto-snooze scheduler.
/// For each overdue reminder with auto-snooze enabled, schedules the next
/// notification [autoSnoozeInterval] minutes from now.
///
/// Uses a deterministic ID offset so auto-snooze notification IDs don't
/// collide with the initial due-date notification IDs.
class AutoSnoozeSchedulerImpl implements AutoSnoozeScheduler {
  final NotificationService notificationService;
  final DateTime Function() _now;

  /// Offset added to the reminder's notification ID to create a separate
  /// auto-snooze notification ID space.
  static const int autoSnoozeIdOffset = 100000;

  AutoSnoozeSchedulerImpl({
    required this.notificationService,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  @override
  Future<void> scheduleNextSnooze(Reminder reminder) async {
    if (!reminder.autoSnoozeEnabled || reminder.isCompleted) {
      await cancelSnooze(reminder.id);
      return;
    }

    final currentTime = _now();
    if (!reminder.isOverdue(currentTime)) {
      // Not overdue yet — no nagging needed.
      return;
    }

    final notificationId = _autoSnoozeNotificationId(reminder.id);
    final nextSnoozeTime = currentTime.add(
      Duration(minutes: reminder.autoSnoozeInterval),
    );

    await notificationService.scheduleAutoSnooze(
      id: notificationId,
      title: 'Reminder: ${reminder.title}',
      body: 'Overdue! Tap to complete or snooze.',
      startDate: nextSnoozeTime,
      intervalMinutes: reminder.autoSnoozeInterval,
    );
  }

  @override
  Future<void> cancelSnooze(String reminderId) async {
    final notificationId = _autoSnoozeNotificationId(reminderId);
    await notificationService.cancelNotification(notificationId);
  }

  @override
  Future<void> syncAllSnoozes(List<Reminder> activeReminders) async {
    for (final reminder in activeReminders) {
      if (reminder.autoSnoozeEnabled && reminder.isOverdue(_now())) {
        await scheduleNextSnooze(reminder);
      } else {
        await cancelSnooze(reminder.id);
      }
    }
  }

  /// Derive a stable int notification ID from the reminder's string ID.
  /// Uses hashCode with an offset to avoid collisions with due-date notifications.
  int _autoSnoozeNotificationId(String reminderId) {
    return reminderId.hashCode.abs() + autoSnoozeIdOffset;
  }
}
