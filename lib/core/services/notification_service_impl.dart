import 'package:dartz/dartz.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/services/notification_service.dart';

/// Concrete implementation using flutter_local_notifications.
/// Single responsibility: translate domain notification requests into platform calls.
class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin plugin;

  /// Notification action identifiers for interactive notifications.
  static const String completeActionId = 'complete';
  static const String snooze1ActionId = 'snooze_1';
  static const String snooze5ActionId = 'snooze_5';
  static const String snooze15ActionId = 'snooze_15';
  static const String snooze30ActionId = 'snooze_30';
  static const String snooze60ActionId = 'snooze_60';
  static const String reminderCategoryId = 'reminder_category';

  NotificationServiceImpl({required this.plugin});

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            reminderCategoryId,
            actions: [
              DarwinNotificationAction.plain(
                completeActionId,
                'Done',
                options: {DarwinNotificationActionOption.destructive},
              ),
              DarwinNotificationAction.plain(snooze1ActionId, '1 min'),
              DarwinNotificationAction.plain(snooze5ActionId, '5 min'),
              DarwinNotificationAction.plain(snooze15ActionId, '15 min'),
              DarwinNotificationAction.plain(snooze30ActionId, '30 min'),
              DarwinNotificationAction.plain(snooze60ActionId, '1 hour'),
            ],
          ),
        ],
      );

      final settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await plugin.initialize(settings);
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure('Failed to initialize notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await plugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure('Failed to schedule notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleAutoSnooze({
    required int id,
    required String title,
    required String body,
    required DateTime startDate,
    required int intervalMinutes,
  }) async {
    try {
      final tzStartDate = tz.TZDateTime.from(startDate, tz.local);

      await plugin.zonedSchedule(
        id,
        title,
        body,
        tzStartDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return const Right(null);
    } catch (e) {
      return Left(
          NotificationFailure('Failed to schedule auto-snooze: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelNotification(int id) async {
    try {
      await plugin.cancel(id);
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure('Failed to cancel notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async {
    try {
      await plugin.cancelAll();
      return const Right(null);
    } catch (e) {
      return Left(
          NotificationFailure('Failed to cancel all notifications: $e'));
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'doit_reminders',
        'Reminders',
        channelDescription: 'DoIt reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: reminderCategoryId,
      ),
    );
  }
}
