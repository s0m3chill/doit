import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';
import 'package:doit/features/timer/domain/repositories/timer_repository.dart';

class CreateTimer extends UseCase<CountdownTimer, CountdownTimer> {
  final TimerRepository repository;

  CreateTimer(this.repository);

  @override
  Future<Either<Failure, CountdownTimer>> call(CountdownTimer params) {
    if (params.label.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Timer label cannot be empty')),
      );
    }
    if (params.durationSeconds <= 0) {
      return Future.value(
        const Left(ValidationFailure('Duration must be greater than zero')),
      );
    }
    return repository.createTimer(params);
  }
}
