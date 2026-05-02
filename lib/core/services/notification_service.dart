import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';

/// Domain-level contract for notification operations.
/// No framework imports — implementations live in the data/services layer.
abstract class NotificationService {
  /// Initialize the notification system. Call once at startup.
  Future<Either<Failure, void>> initialize();

  /// Schedule a notification for a specific reminder at [scheduledDate].
  /// [id] must be a stable int derived from the reminder's string ID.
  Future<Either<Failure, void>> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });

  /// Schedule a repeating auto-snooze notification that fires every
  /// [intervalMinutes] starting from [startDate] until cancelled.
  Future<Either<Failure, void>> scheduleAutoSnooze({
    required int id,
    required String title,
    required String body,
    required DateTime startDate,
    required int intervalMinutes,
  });

  /// Cancel a specific notification by its [id].
  Future<Either<Failure, void>> cancelNotification(int id);

  /// Cancel all scheduled notifications.
  Future<Either<Failure, void>> cancelAllNotifications();
}
