import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';

class DeleteReminder extends UseCase<void, String> {
  final ReminderRepository repository;

  DeleteReminder(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteReminder(params);
  }
}
