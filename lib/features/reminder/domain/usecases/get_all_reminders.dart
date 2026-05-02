import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';

class GetAllReminders extends UseCase<List<Reminder>, NoParams> {
  final ReminderRepository repository;

  GetAllReminders(this.repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(NoParams params) {
    return repository.getAllReminders();
  }
}
