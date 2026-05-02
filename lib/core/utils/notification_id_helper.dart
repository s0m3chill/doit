/// Derives a stable int notification ID from a reminder's string UUID.
/// Keeps notification ID logic in one place.
class NotificationIdHelper {
  NotificationIdHelper._();

  /// Primary notification ID for the initial due-date alert.
  static int primaryId(String reminderId) => reminderId.hashCode.abs();

  /// Auto-snooze notification ID — offset to avoid collision with primary.
  static int autoSnoozeId(String reminderId) =>
      reminderId.hashCode.abs() + 100000;
}
