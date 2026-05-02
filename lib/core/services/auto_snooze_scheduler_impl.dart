import 'package:doit/core/services/auto_snooze_scheduler.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';

/// Concrete auto-snooze scheduler with repeat count limits.
///
/// Due's behavior:
/// - By default, auto snooze repeats 5 times (configurable up to 10).
/// - On app launch or acting on any notification, Due re-snoozes all
///   overdue items indefinitely (resets the count).
class AutoSnoozeSchedulerImpl implements AutoSnoozeScheduler {
  final NotificationService notificationService;
  final DateTime Function() _now;

  static const int autoSnoozeIdOffset = 100000;

  AutoSnoozeSchedulerImpl({
    required this.notificationService,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  @override
  Future<int> scheduleNextSnooze(Reminder reminder) async {
    if (!reminder.autoSnoozeEnabled || reminder.isCompleted) {
      await cancelSnooze(reminder.id);
      return reminder.autoSnoozeCount;
    }

    final currentTime = _now();
    if (!reminder.isOverdue(currentTime)) return reminder.autoSnoozeCount;

    // Check if we've hit the limit (0 = indefinite).
    if (reminder.isAutoSnoozeLimitReached) {
      await cancelSnooze(reminder.id);
      return reminder.autoSnoozeCount;
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
      payload: reminder.id,
    );

    return reminder.autoSnoozeCount + 1;
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

  @override
  Future<List<Reminder>> resnoozeAllOnLaunch(
      List<Reminder> activeReminders) async {
    final updated = <Reminder>[];
    for (final reminder in activeReminders) {
      if (reminder.autoSnoozeEnabled && reminder.isOverdue(_now())) {
        // Reset count and schedule — on launch, Due snoozes indefinitely.
        final reset = reminder.copyWith(autoSnoozeCount: 0);
        await scheduleNextSnooze(reset);
        updated.add(reset);
      } else {
        updated.add(reminder);
      }
    }
    return updated;
  }

  int _autoSnoozeNotificationId(String reminderId) {
    return reminderId.hashCode.abs() + autoSnoozeIdOffset;
  }
}
