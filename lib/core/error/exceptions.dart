/// Base exception for data layer operations.
/// These are caught at the repository level and converted to [Failure]s.
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}

class DatabaseException extends AppException {
  const DatabaseException([super.message = 'Database operation failed']);
}

class NotificationException extends AppException {
  const NotificationException(
      [super.message = 'Notification operation failed']);
}
