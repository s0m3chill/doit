import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';

/// Repository contract — defined in domain, implemented in data layer.
/// Returns `Either<Failure, T>` for explicit error handling.
abstract class ReminderRepository {
  Future<Either<Failure, List<Reminder>>> getAllReminders();
  Future<Either<Failure, List<Reminder>>> getActiveReminders();
  Future<Either<Failure, List<Reminder>>> getCompletedReminders();
  Future<Either<Failure, Reminder>> getReminderById(String id);
  Future<Either<Failure, Reminder>> createReminder(Reminder reminder);
  Future<Either<Failure, Reminder>> updateReminder(Reminder reminder);
  Future<Either<Failure, void>> deleteReminder(String id);
  Future<Either<Failure, Reminder>> completeReminder(String id);
  Future<Either<Failure, Reminder>> snoozeReminder(
      String id, int snoozeMinutes);
}
