import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';

class SearchReminders extends UseCase<List<Reminder>, String> {
  final ReminderRepository repository;

  SearchReminders(this.repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(String params) {
    if (params.trim().isEmpty) {
      return repository.getActiveReminders();
    }
    return repository.searchReminders(params);
  }
}
