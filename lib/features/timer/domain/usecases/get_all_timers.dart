import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';
import 'package:doit/features/timer/domain/repositories/timer_repository.dart';

class GetAllTimers extends UseCase<List<CountdownTimer>, NoParams> {
  final TimerRepository repository;

  GetAllTimers(this.repository);

  @override
  Future<Either<Failure, List<CountdownTimer>>> call(NoParams params) {
    return repository.getAllTimers();
  }
}
