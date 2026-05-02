import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Follows the functional error handling pattern — no exceptions crossing layer boundaries.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed']);
}

class NotificationFailure extends Failure {
  const NotificationFailure([super.message = 'Notification operation failed']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}
