import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:doit/features/reminder/domain/usecases/search_reminders.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  late SearchReminders usecase;
  late MockReminderRepository mockRepository;

  setUp(() {
    mockRepository = MockReminderRepository();
    usecase = SearchReminders(mockRepository);
  });

  final now = DateTime(2025, 1, 1);
  final tReminders = [
    Reminder(
      id: '1',
      title: 'Buy groceries',
      dueDate: now,
      createdAt: now,
      updatedAt: now,
    ),
    Reminder(
      id: '2',
      title: 'Call dentist',
      dueDate: now,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  test('should search reminders by query', () async {
    when(() => mockRepository.searchReminders('groceries'))
        .thenAnswer((_) async => Right([tReminders.first]));

    final result = await usecase('groceries');

    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Should be Right'),
      (reminders) => expect(reminders.length, 1),
    );
    verify(() => mockRepository.searchReminders('groceries')).called(1);
  });

  test('should return active reminders when query is empty', () async {
    when(() => mockRepository.getActiveReminders())
        .thenAnswer((_) async => Right(tReminders));

    final result = await usecase('');

    expect(result.isRight(), true);
    verify(() => mockRepository.getActiveReminders()).called(1);
    verifyNever(() => mockRepository.searchReminders(any()));
  });

  test('should return active reminders when query is whitespace', () async {
    when(() => mockRepository.getActiveReminders())
        .thenAnswer((_) async => Right(tReminders));

    final result = await usecase('   ');

    expect(result.isRight(), true);
    verify(() => mockRepository.getActiveReminders()).called(1);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.searchReminders('test'))
        .thenAnswer((_) async => const Left(DatabaseFailure()));

    final result = await usecase('test');

    expect(result.isLeft(), true);
  });
}
