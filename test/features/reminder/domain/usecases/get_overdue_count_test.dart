import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:doit/features/reminder/domain/usecases/get_overdue_count.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  late GetOverdueCount usecase;
  late MockReminderRepository mockRepository;
  late DateTime fixedNow;

  setUp(() {
    mockRepository = MockReminderRepository();
    fixedNow = DateTime(2025, 6, 15, 10, 0);
    usecase = GetOverdueCount(mockRepository, now: () => fixedNow);
  });

  test('should return count of overdue reminders', () async {
    final reminders = [
      Reminder(
        id: '1',
        title: 'Overdue',
        dueDate: DateTime(2025, 6, 14), // past
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
      Reminder(
        id: '2',
        title: 'Future',
        dueDate: DateTime(2025, 6, 16), // future
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
      Reminder(
        id: '3',
        title: 'Also Overdue',
        dueDate: DateTime(2025, 6, 13), // past
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
    ];

    when(() => mockRepository.getActiveReminders())
        .thenAnswer((_) async => Right(reminders));

    final result = await usecase(const NoParams());

    expect(result, const Right(2));
  });

  test('should return 0 when no reminders are overdue', () async {
    final reminders = [
      Reminder(
        id: '1',
        title: 'Future',
        dueDate: DateTime(2025, 6, 16),
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
    ];

    when(() => mockRepository.getActiveReminders())
        .thenAnswer((_) async => Right(reminders));

    final result = await usecase(const NoParams());

    expect(result, const Right(0));
  });

  test('should return 0 when no active reminders', () async {
    when(() => mockRepository.getActiveReminders())
        .thenAnswer((_) async => const Right([]));

    final result = await usecase(const NoParams());

    expect(result, const Right(0));
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.getActiveReminders())
        .thenAnswer((_) async => const Left(DatabaseFailure()));

    final result = await usecase(const NoParams());

    expect(result.isLeft(), true);
  });
}
