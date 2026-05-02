import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/timer/domain/repositories/timer_repository.dart';

class DeleteTimer extends UseCase<void, String> {
  final TimerRepository repository;

  DeleteTimer(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteTimer(params);
  }
}
