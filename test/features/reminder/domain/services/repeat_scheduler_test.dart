import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/domain/entities/recurrence_rule.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/services/repeat_scheduler.dart';

void main() {
  late RepeatScheduler scheduler;

  setUp(() {
    scheduler = RepeatScheduler();
  });

  final now = DateTime(2025, 6, 15, 10, 0);

  Reminder makeReminder({RecurrenceRule? rule}) {
    return Reminder(
      id: 'old-id',
      title: 'Recurring Task',
      dueDate: now,
      isCompleted: true,
      recurrenceRule: rule ?? RecurrenceRule.daily,
      autoSnoozeEnabled: true,
      autoSnoozeInterval: 10,
      autoSnoozeMaxCount: 5,
      autoSnoozeCount: 3,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('returns null for non-recurring reminder', () {
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(rule: RecurrenceRule.none),
      newId: 'new-id',
      now: now,
    );
    expect(result, isNull);
  });

  test('creates next daily occurrence with new id', () {
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(),
      newId: 'new-id',
      now: now,
    );

    expect(result, isNotNull);
    expect(result!.id, 'new-id');
    expect(result.title, 'Recurring Task');
    expect(result.dueDate, DateTime(2025, 6, 16, 10, 0));
    expect(result.isCompleted, false);
    expect(result.recurrenceRule, RecurrenceRule.daily);
  });

  test('resets auto-snooze count to 0 for next occurrence', () {
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(),
      newId: 'new-id',
      now: now,
    );

    expect(result!.autoSnoozeCount, 0);
    expect(result.autoSnoozeMaxCount, 5); // preserved
    expect(result.autoSnoozeEnabled, true); // preserved
  });

  test('handles complex recurrence: 3rd Wednesday', () {
    final rule = RecurrenceRule.nthWeekdayOfMonth(3, DateTime.wednesday);
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(rule: rule),
      newId: 'new-id',
      now: now,
    );

    // June 15 is Sunday. 3rd Wed of June = June 18.
    expect(result!.dueDate, DateTime(2025, 6, 18, 10, 0));
    expect(result.recurrenceRule, rule);
  });

  test('handles weekday recurrence: Mon, Wed, Fri', () {
    final rule = RecurrenceRule.onWeekdays([1, 3, 5]);
    final result = scheduler.computeNextOccurrence(
      completed: makeReminder(rule: rule),
      newId: 'new-id',
      now: now,
    );

    // June 15 is Sunday, next matching day is Monday June 16
    expect(result!.dueDate, DateTime(2025, 6, 16, 10, 0));
  });
}
