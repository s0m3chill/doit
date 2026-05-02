import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';

/// Repository contract for countdown timer persistence.
abstract class TimerRepository {
  Future<Either<Failure, List<CountdownTimer>>> getAllTimers();
  Future<Either<Failure, CountdownTimer>> getTimerById(String id);
  Future<Either<Failure, CountdownTimer>> createTimer(CountdownTimer timer);
  Future<Either<Failure, CountdownTimer>> updateTimer(CountdownTimer timer);
  Future<Either<Failure, void>> deleteTimer(String id);
}
