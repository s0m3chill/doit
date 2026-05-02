import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';

class GetOverdueCount extends UseCase<int, NoParams> {
  final ReminderRepository repository;
  final DateTime Function() _now;

  GetOverdueCount(this.repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    final result = await repository.getActiveReminders();
    return result.map((reminders) {
      final currentTime = _now();
      return reminders.where((r) => r.isOverdue(currentTime)).length;
    });
  }
}
