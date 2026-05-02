import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/services/repeat_scheduler.dart';

void main() {
  late RepeatScheduler scheduler;

  setUp(() {
    scheduler = RepeatScheduler();
  });

  final now = DateTime(2025, 6, 15, 10, 0);

  Reminder makeReminder({String repeatInterval = 'daily'}) {
    return Reminder(
      id: 'old-id',
      title: 'Recurring Task',
      dueDate: now,
      isCompleted: true,
      repeatInterval: repeatInterval,
      autoSnoozeEnabled: true,
      autoSnoozeInterval: 10,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('returns null for non-recurring reminder', () {
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(repeatInterval: 'none'),
      newId: 'new-id',
      now: now,
    );
    expect(result, isNull);
  });

  test('creates next daily occurrence with new id', () {
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(repeatInterval: 'daily'),
      newId: 'new-id',
      now: now,
    );

    expect(result, isNotNull);
    expect(result!.id, 'new-id');
    expect(result.title, 'Recurring Task');
    expect(result.dueDate, DateTime(2025, 6, 16, 10, 0));
    expect(result.isCompleted, false);
    expect(result.repeatInterval, 'daily');
    expect(result.autoSnoozeEnabled, true);
    expect(result.autoSnoozeInterval, 10);
  });

  test('creates next weekly occurrence', () {
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(repeatInterval: 'weekly'),
      newId: 'new-id',
      now: now,
    );

    expect(result!.dueDate, DateTime(2025, 6, 22, 10, 0));
  });

  test('creates next monthly occurrence', () {
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(repeatInterval: 'monthly'),
      newId: 'new-id',
      now: now,
    );

    expect(result!.dueDate, DateTime(2025, 7, 15, 10, 0));
  });

  test('creates next yearly occurrence', () {
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(repeatInterval: 'yearly'),
      newId: 'new-id',
      now: now,
    );

    expect(result!.dueDate, DateTime(2026, 6, 15, 10, 0));
  });

  test('preserves auto-snooze settings in next occurrence', () {
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(),
      newId: 'new-id',
      now: now,
    );

    expect(result!.autoSnoozeEnabled, true);
    expect(result.autoSnoozeInterval, 10);
  });
}
