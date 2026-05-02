import 'package:dartz/dartz.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';

/// Concrete implementation using flutter_local_notifications.
/// Respects user's haptic/sound settings when building notification details.
class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin plugin;

  static const String completeActionId = 'complete';
  static const String snooze1ActionId = 'snooze_1';
  static const String snooze5ActionId = 'snooze_5';
  static const String snooze15ActionId = 'snooze_15';
  static const String snooze30ActionId = 'snooze_30';
  static const String snooze60ActionId = 'snooze_60';
  static const String reminderCategoryId = 'reminder_category';

  NotificationServiceImpl({required this.plugin});

  @override
  Future<Either<Failure, void>> initialize({
    NotificationActionCallback? onAction,
    NotificationTapCallback? onTap,
  }) async {
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

      await plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (response) async {
          final payload = response.payload;
          final actionId = response.actionId;

          if (actionId != null && actionId.isNotEmpty && onAction != null) {
            await onAction(actionId, payload);
          } else if (onTap != null) {
            await onTap(payload);
          }
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(
          NotificationFailure('Failed to initialize notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    HapticSoundSettings? settings,
  }) async {
    try {
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await plugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        _notificationDetails(settings),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      return const Right(null);
    } catch (e) {
      return Left(
          NotificationFailure('Failed to schedule notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleAutoSnooze({
    required int id,
    required String title,
    required String body,
    required DateTime startDate,
    required int intervalMinutes,
    String? payload,
    HapticSoundSettings? settings,
  }) async {
    try {
      final tzStartDate = tz.TZDateTime.from(startDate, tz.local);

      await plugin.zonedSchedule(
        id,
        title,
        body,
        tzStartDate,
        _notificationDetails(settings),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
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
      return Left(
          NotificationFailure('Failed to cancel notification: $e'));
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

  /// Build notification details respecting user's sound/vibration preferences.
  NotificationDetails _notificationDetails(HapticSoundSettings? settings) {
    final playSound = settings?.soundEnabled ?? true;
    final enableVibration = settings?.vibrationEnabled ?? true;
    final soundName = settings?.notificationSound ?? 'default';
    final presentSound = playSound && soundName != 'none';

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'doit_reminders',
        'Reminders',
        channelDescription: 'DoIt reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: presentSound,
        enableVibration: enableVibration,
        sound: presentSound && soundName != 'default'
            ? RawResourceAndroidNotificationSound(soundName)
            : null,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: presentSound,
        categoryIdentifier: reminderCategoryId,
      ),
    );
  }
}
