import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';

class UpdateReminder extends UseCase<Reminder, Reminder> {
  final ReminderRepository repository;

  UpdateReminder(this.repository);

  @override
  Future<Either<Failure, Reminder>> call(Reminder params) {
    if (params.title.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Title cannot be empty')),
      );
    }
    return repository.updateReminder(params);
  }
}
