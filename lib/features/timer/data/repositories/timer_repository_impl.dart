import 'package:dartz/dartz.dart';
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/timer/data/datasources/timer_local_data_source.dart';
import 'package:doit/features/timer/data/models/countdown_timer_model.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';
import 'package:doit/features/timer/domain/repositories/timer_repository.dart';

class TimerRepositoryImpl implements TimerRepository {
  final TimerLocalDataSource localDataSource;

  TimerRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CountdownTimer>>> getAllTimers() async {
    try {
      final timers = await localDataSource.getAllTimers();
      return Right(timers);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CountdownTimer>> getTimerById(String id) async {
    try {
      final timer = await localDataSource.getTimerById(id);
      return Right(timer);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CountdownTimer>> createTimer(
      CountdownTimer timer) async {
    try {
      final model = CountdownTimerModel.fromEntity(timer);
      final result = await localDataSource.createTimer(model);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CountdownTimer>> updateTimer(
      CountdownTimer timer) async {
    try {
      final model = CountdownTimerModel.fromEntity(timer);
      final result = await localDataSource.updateTimer(model);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTimer(String id) async {
    try {
      await localDataSource.deleteTimer(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
