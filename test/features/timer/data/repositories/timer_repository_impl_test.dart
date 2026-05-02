import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/timer/data/datasources/timer_local_data_source.dart';
import 'package:doit/features/timer/data/models/countdown_timer_model.dart';
import 'package:doit/features/timer/data/repositories/timer_repository_impl.dart';

class MockTimerLocalDataSource extends Mock implements TimerLocalDataSource {}

void main() {
  late TimerRepositoryImpl repository;
  late MockTimerLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockTimerLocalDataSource();
    repository = TimerRepositoryImpl(localDataSource: mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(CountdownTimerModel(
      id: 'fallback',
      label: 'fallback',
      durationSeconds: 60,
      createdAt: DateTime(2025),
    ));
  });

  final now = DateTime(2025, 1, 1);
  final tModel = CountdownTimerModel(
    id: '1',
    label: 'Eggs',
    durationSeconds: 180,
    createdAt: now,
  );

  group('getAllTimers', () {
    test('should return list of timers on success', () async {
      when(() => mockDataSource.getAllTimers())
          .thenAnswer((_) async => [tModel]);

      final result = await repository.getAllTimers();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (timers) => expect(timers, [tModel]),
      );
    });

    test('should return DatabaseFailure on exception', () async {
      when(() => mockDataSource.getAllTimers())
          .thenThrow(const DatabaseException('error'));

      final result = await repository.getAllTimers();

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('createTimer', () {
    test('should return created timer on success', () async {
      when(() => mockDataSource.createTimer(any()))
          .thenAnswer((_) async => tModel);

      final result = await repository.createTimer(tModel);

      expect(result, Right(tModel));
    });

    test('should return DatabaseFailure on exception', () async {
      when(() => mockDataSource.createTimer(any()))
          .thenThrow(const DatabaseException('error'));

      final result = await repository.createTimer(tModel);

      expect(result, isA<Left>());
    });
  });

  group('deleteTimer', () {
    test('should return Right(null) on success', () async {
      when(() => mockDataSource.deleteTimer(any()))
          .thenAnswer((_) async {});

      final result = await repository.deleteTimer('1');

      expect(result, const Right(null));
    });

    test('should return DatabaseFailure on exception', () async {
      when(() => mockDataSource.deleteTimer(any()))
          .thenThrow(const DatabaseException('error'));

      final result = await repository.deleteTimer('1');

      expect(result, isA<Left>());
    });
  });
}
