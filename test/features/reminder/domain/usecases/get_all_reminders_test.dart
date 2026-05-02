import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:doit/features/reminder/domain/usecases/get_all_reminders.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  late GetAllReminders usecase;
  late MockReminderRepository mockRepository;

  setUp(() {
    mockRepository = MockReminderRepository();
    usecase = GetAllReminders(mockRepository);
  });

  final now = DateTime(2025, 1, 1);
  final tReminders = [
    Reminder(
      id: '1',
      title: 'Test Reminder',
      dueDate: now,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  test('should get all reminders from the repository', () async {
    when(() => mockRepository.getAllReminders())
        .thenAnswer((_) async => Right(tReminders));

    final result = await usecase(const NoParams());

    expect(result, Right(tReminders));
    verify(() => mockRepository.getAllReminders()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.getAllReminders())
        .thenAnswer((_) async => const Left(DatabaseFailure()));

    final result = await usecase(const NoParams());

    expect(result, const Left(DatabaseFailure()));
  });
}
