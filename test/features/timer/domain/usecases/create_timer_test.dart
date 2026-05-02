import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';
import 'package:doit/features/timer/domain/repositories/timer_repository.dart';
import 'package:doit/features/timer/domain/usecases/create_timer.dart';

class MockTimerRepository extends Mock implements TimerRepository {}

void main() {
  late CreateTimer usecase;
  late MockTimerRepository mockRepository;

  setUp(() {
    mockRepository = MockTimerRepository();
    usecase = CreateTimer(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(CountdownTimer(
      id: 'fallback',
      label: 'fallback',
      durationSeconds: 60,
      createdAt: DateTime(2025),
    ));
  });

  final tTimer = CountdownTimer(
    id: '1',
    label: 'Eggs',
    durationSeconds: 180,
    createdAt: DateTime(2025),
  );

  test('should create a timer via the repository', () async {
    when(() => mockRepository.createTimer(any()))
        .thenAnswer((_) async => Right(tTimer));

    final result = await usecase(tTimer);

    expect(result, Right(tTimer));
    verify(() => mockRepository.createTimer(tTimer)).called(1);
  });

  test('should return ValidationFailure when label is empty', () async {
    final emptyLabel = tTimer.copyWith(label: '');

    final result = await usecase(emptyLabel);

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Should have returned a failure'),
    );
    verifyNever(() => mockRepository.createTimer(any()));
  });

  test('should return ValidationFailure when duration is zero', () async {
    final zeroDuration = tTimer.copyWith(durationSeconds: 0);

    final result = await usecase(zeroDuration);

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Should have returned a failure'),
    );
  });

  test('should return ValidationFailure when duration is negative', () async {
    final negativeDuration = tTimer.copyWith(durationSeconds: -10);

    final result = await usecase(negativeDuration);

    expect(result, isA<Left>());
  });
}
