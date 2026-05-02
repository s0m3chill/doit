import 'package:doit/core/services/auto_snooze_scheduler.dart';
import 'package:doit/core/services/notification_action_handler.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/core/utils/notification_id_helper.dart';
import 'package:doit/features/reminder/domain/usecases/complete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/snooze_reminder.dart';

/// Routes notification actions to the appropriate use cases.
/// Single responsibility: map action IDs to domain operations.
class NotificationActionHandlerImpl implements NotificationActionHandler {
  final CompleteReminder completeReminder;
  final SnoozeReminder snoozeReminder;
  final NotificationService notificationService;
  final AutoSnoozeScheduler autoSnoozeScheduler;

  /// Callback invoked after any action completes, so the UI can refresh.
  final void Function()? onActionCompleted;

  NotificationActionHandlerImpl({
    required this.completeReminder,
    required this.snoozeReminder,
    required this.notificationService,
    required this.autoSnoozeScheduler,
    this.onActionCompleted,
  });

  @override
  Future<void> handleAction(String actionId, String? payload) async {
    if (payload == null || payload.isEmpty) return;

    final reminderId = payload;

    switch (actionId) {
      case 'complete':
        await _handleComplete(reminderId);
      case 'snooze_1':
        await _handleSnooze(reminderId, 1);
      case 'snooze_5':
        await _handleSnooze(reminderId, 5);
      case 'snooze_15':
        await _handleSnooze(reminderId, 15);
      case 'snooze_30':
        await _handleSnooze(reminderId, 30);
      case 'snooze_60':
        await _handleSnooze(reminderId, 60);
    }

    onActionCompleted?.call();
  }

  @override
  Future<void> handleNotificationTap(String? payload) async {
    // Tapping the notification body itself — no action needed beyond
    // opening the app. The UI will refresh on resume.
  }

  Future<void> _handleComplete(String reminderId) async {
    await completeReminder(reminderId);
    await notificationService
        .cancelNotification(NotificationIdHelper.primaryId(reminderId));
    await autoSnoozeScheduler.cancelSnooze(reminderId);
  }

  Future<void> _handleSnooze(String reminderId, int minutes) async {
    final params = SnoozeParams(id: reminderId, snoozeMinutes: minutes);
    final result = await snoozeReminder(params);
    await result.fold(
      (_) async {},
      (snoozed) async {
        // Cancel old notifications and schedule new one at snoozed time.
        await notificationService
            .cancelNotification(NotificationIdHelper.primaryId(reminderId));
        await autoSnoozeScheduler.cancelSnooze(reminderId);
        if (snoozed.dueDate.isAfter(DateTime.now())) {
          await notificationService.scheduleNotification(
            id: NotificationIdHelper.primaryId(reminderId),
            title: 'DoIt: ${snoozed.title}',
            body: 'Time to do it!',
            scheduledDate: snoozed.dueDate,
          );
        }
      },
    );
  }
}
