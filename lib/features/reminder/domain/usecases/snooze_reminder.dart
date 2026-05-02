import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';

class SnoozeReminder extends UseCase<Reminder, SnoozeParams> {
  final ReminderRepository repository;

  SnoozeReminder(this.repository);

  @override
  Future<Either<Failure, Reminder>> call(SnoozeParams params) {
    return repository.snoozeReminder(params.id, params.snoozeMinutes);
  }
}

class SnoozeParams extends Equatable {
  final String id;
  final int snoozeMinutes;

  const SnoozeParams({required this.id, required this.snoozeMinutes});

  @override
  List<Object?> get props => [id, snoozeMinutes];
}
