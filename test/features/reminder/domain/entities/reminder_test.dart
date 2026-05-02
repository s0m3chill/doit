import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/domain/entities/recurrence_rule.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';

void main() {
  final now = DateTime(2025, 6, 15, 10, 0);

  Reminder makeReminder({
    RecurrenceRule recurrenceRule = const RecurrenceRule(),
    bool isCompleted = false,
    DateTime? dueDate,
    bool autoSnoozeEnabled = true,
    int autoSnoozeMaxCount = 5,
    int autoSnoozeCount = 0,
  }) {
    return Reminder(
      id: '1',
      title: 'Test',
      dueDate: dueDate ?? now,
      isCompleted: isCompleted,
      recurrenceRule: recurrenceRule,
      autoSnoozeEnabled: autoSnoozeEnabled,
      autoSnoozeMaxCount: autoSnoozeMaxCount,
      autoSnoozeCount: autoSnoozeCount,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('isOverdue', () {
    test('returns true when due date is in the past and not completed', () {
      final reminder = makeReminder(dueDate: DateTime(2025, 6, 14));
      expect(reminder.isOverdue(now), true);
    });

    test('returns false when due date is in the future', () {
      final reminder = makeReminder(dueDate: DateTime(2025, 6, 16));
      expect(reminder.isOverdue(now), false);
    });

    test('returns false when completed even if overdue', () {
      final reminder = makeReminder(
        dueDate: DateTime(2025, 6, 14),
        isCompleted: true,
      );
      expect(reminder.isOverdue(now), false);
    });
  });

  group('isRecurring', () {
    test('returns false for none', () {
      expect(makeReminder().isRecurring, false);
    });

    test('returns true for daily', () {
      expect(
        makeReminder(recurrenceRule: RecurrenceRule.daily).isRecurring,
        true,
      );
    });
  });

  group('isAutoSnoozeLimitReached', () {
    test('returns false when count < max', () {
      final r = makeReminder(autoSnoozeMaxCount: 5, autoSnoozeCount: 3);
      expect(r.isAutoSnoozeLimitReached, false);
    });

    test('returns true when count >= max', () {
      final r = makeReminder(autoSnoozeMaxCount: 5, autoSnoozeCount: 5);
      expect(r.isAutoSnoozeLimitReached, true);
    });

    test('returns true when count > max', () {
      final r = makeReminder(autoSnoozeMaxCount: 5, autoSnoozeCount: 7);
      expect(r.isAutoSnoozeLimitReached, true);
    });

    test('returns false when max is 0 (indefinite)', () {
      final r = makeReminder(autoSnoozeMaxCount: 0, autoSnoozeCount: 100);
      expect(r.isAutoSnoozeLimitReached, false);
    });
  });

  group('nextOccurrence', () {
    test('returns null for non-recurring', () {
      expect(makeReminder().nextOccurrence(), isNull);
    });

    test('delegates to recurrence rule', () {
      final r = makeReminder(recurrenceRule: RecurrenceRule.daily);
      expect(r.nextOccurrence(), DateTime(2025, 6, 16, 10, 0));
    });

    test('complex rule: 3rd Wednesday', () {
      final r = makeReminder(
        recurrenceRule:
            RecurrenceRule.nthWeekdayOfMonth(3, DateTime.wednesday),
      );
      final next = r.nextOccurrence();
      // June 15 is Sunday. 3rd Wed of June = June 18.
      expect(next, DateTime(2025, 6, 18, 10, 0));
    });
  });

  group('repeatInterval legacy getter', () {
    test('returns frequency from recurrence rule', () {
      final r = makeReminder(recurrenceRule: RecurrenceRule.weekly);
      expect(r.repeatInterval, 'weekly');
    });
  });

  group('copyWith', () {
    test('preserves all fields when no arguments given', () {
      final reminder = makeReminder();
      expect(reminder.copyWith(), reminder);
    });

    test('overrides specified fields', () {
      final reminder = makeReminder();
      final updated = reminder.copyWith(
        title: 'Updated',
        autoSnoozeMaxCount: 10,
        autoSnoozeCount: 3,
      );
      expect(updated.title, 'Updated');
      expect(updated.autoSnoozeMaxCount, 10);
      expect(updated.autoSnoozeCount, 3);
      expect(updated.id, reminder.id);
    });
  });
}
