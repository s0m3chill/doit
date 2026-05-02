/// Domain-level contract for handling notification action callbacks.
/// When a user taps "Done" or "Snooze 5 min" on a notification,
/// this handler routes the action to the appropriate use case.
abstract class NotificationActionHandler {
  /// Process a notification action.
  /// [actionId] is the action identifier (e.g., 'complete', 'snooze_5').
  /// [payload] is the reminder ID passed as the notification payload.
  Future<void> handleAction(String actionId, String? payload);

  /// Handle a notification tap (user tapped the notification body itself).
  Future<void> handleNotificationTap(String? payload);
}
