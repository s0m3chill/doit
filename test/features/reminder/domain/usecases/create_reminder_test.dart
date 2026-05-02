import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:doit/features/reminder/domain/usecases/create_reminder.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  late CreateReminder usecase;
  late MockReminderRepository mockRepository;

  setUp(() {
    mockRepository = MockReminderRepository();
    usecase = CreateReminder(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(Reminder(
      id: 'fallback',
      title: 'fallback',
      dueDate: DateTime(2025),
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ));
  });

  final now = DateTime(2025, 1, 1);
  final tReminder = Reminder(
    id: '1',
    title: 'Test Reminder',
    dueDate: now,
    createdAt: now,
    updatedAt: now,
  );

  test('should create a reminder via the repository', () async {
    when(() => mockRepository.createReminder(any()))
        .thenAnswer((_) async => Right(tReminder));

    final result = await usecase(tReminder);

    expect(result, Right(tReminder));
    verify(() => mockRepository.createReminder(tReminder)).called(1);
  });

  test('should return ValidationFailure when title is empty', () async {
    final emptyTitleReminder = tReminder.copyWith(title: '');

    final result = await usecase(emptyTitleReminder);

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Should have returned a failure'),
    );
    verifyNever(() => mockRepository.createReminder(any()));
  });

  test('should return ValidationFailure when title is only whitespace',
      () async {
    final blankTitleReminder = tReminder.copyWith(title: '   ');

    final result = await usecase(blankTitleReminder);

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Should have returned a failure'),
    );
  });
}
