import 'package:dartz/dartz.dart';
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/reminder/data/datasources/reminder_local_data_source.dart';
import 'package:doit/features/reminder/data/models/reminder_model.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';

/// Implements the domain repository contract.
/// Catches data-layer exceptions and returns typed Failures.
class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;

  ReminderRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Reminder>>> getAllReminders() async {
    try {
      final reminders = await localDataSource.getAllReminders();
      return Right(reminders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getActiveReminders() async {
    try {
      final reminders = await localDataSource.getActiveReminders();
      return Right(reminders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getCompletedReminders() async {
    try {
      final reminders = await localDataSource.getCompletedReminders();
      return Right(reminders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> searchReminders(
      String query) async {
    try {
      final reminders = await localDataSource.searchReminders(query);
      return Right(reminders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Reminder>> getReminderById(String id) async {
    try {
      final reminder = await localDataSource.getReminderById(id);
      return Right(reminder);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Reminder>> createReminder(Reminder reminder) async {
    try {
      final model = ReminderModel.fromEntity(reminder);
      final result = await localDataSource.createReminder(model);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Reminder>> updateReminder(Reminder reminder) async {
    try {
      final now = DateTime.now();
      final model = ReminderModel.fromEntity(
        reminder.copyWith(updatedAt: now),
      );
      final result = await localDataSource.updateReminder(model);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String id) async {
    try {
      await localDataSource.deleteReminder(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Reminder>> completeReminder(String id) async {
    try {
      final existing = await localDataSource.getReminderById(id);
      final now = DateTime.now();
      final updated = ReminderModel(
        id: existing.id,
        title: existing.title,
        dueDate: existing.dueDate,
        isCompleted: true,
        repeatInterval: existing.repeatInterval,
        snoozeMinutes: existing.snoozeMinutes,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
      final result = await localDataSource.updateReminder(updated);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Reminder>> snoozeReminder(
      String id, int snoozeMinutes) async {
    try {
      final existing = await localDataSource.getReminderById(id);
      final now = DateTime.now();
      final newDueDate = now.add(Duration(minutes: snoozeMinutes));
      final updated = ReminderModel(
        id: existing.id,
        title: existing.title,
        dueDate: newDueDate,
        isCompleted: false,
        repeatInterval: existing.repeatInterval,
        snoozeMinutes: snoozeMinutes,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
      final result = await localDataSource.updateReminder(updated);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
