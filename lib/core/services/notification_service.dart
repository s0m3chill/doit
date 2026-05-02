import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';

/// Callback signature for notification actions and taps.
typedef NotificationActionCallback = Future<void> Function(
    String actionId, String? payload);
typedef NotificationTapCallback = Future<void> Function(String? payload);

/// Domain-level contract for notification operations.
/// No framework imports — implementations live in the data/services layer.
abstract class NotificationService {
  /// Initialize the notification system. Call once at startup.
  Future<Either<Failure, void>> initialize({
    NotificationActionCallback? onAction,
    NotificationTapCallback? onTap,
  });

  /// Schedule a notification with optional sound/vibration settings.
  Future<Either<Failure, void>> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    HapticSoundSettings? settings,
  });

  /// Schedule a repeating auto-snooze notification.
  Future<Either<Failure, void>> scheduleAutoSnooze({
    required int id,
    required String title,
    required String body,
    required DateTime startDate,
    required int intervalMinutes,
    String? payload,
    HapticSoundSettings? settings,
  });

  /// Cancel a specific notification by its [id].
  Future<Either<Failure, void>> cancelNotification(int id);

  /// Cancel all scheduled notifications.
  Future<Either<Failure, void>> cancelAllNotifications();
}
