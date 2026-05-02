import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';

void main() {
  final now = DateTime(2025, 6, 15, 10, 0);

  Reminder makeReminder({
    String repeatInterval = 'none',
    bool isCompleted = false,
    DateTime? dueDate,
    bool autoSnoozeEnabled = true,
  }) {
    return Reminder(
      id: '1',
      title: 'Test',
      dueDate: dueDate ?? now,
      isCompleted: isCompleted,
      repeatInterval: repeatInterval,
      autoSnoozeEnabled: autoSnoozeEnabled,
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
      expect(makeReminder(repeatInterval: 'none').isRecurring, false);
    });

    test('returns true for daily', () {
      expect(makeReminder(repeatInterval: 'daily').isRecurring, true);
    });

    test('returns true for weekly', () {
      expect(makeReminder(repeatInterval: 'weekly').isRecurring, true);
    });

    test('returns true for monthly', () {
      expect(makeReminder(repeatInterval: 'monthly').isRecurring, true);
    });

    test('returns true for yearly', () {
      expect(makeReminder(repeatInterval: 'yearly').isRecurring, true);
    });
  });

  group('nextOccurrence', () {
    test('returns null for non-recurring', () {
      expect(makeReminder(repeatInterval: 'none').nextOccurrence(), isNull);
    });

    test('returns next day for daily', () {
      final reminder = makeReminder(repeatInterval: 'daily');
      expect(reminder.nextOccurrence(), DateTime(2025, 6, 16, 10, 0));
    });

    test('returns next week for weekly', () {
      final reminder = makeReminder(repeatInterval: 'weekly');
      expect(reminder.nextOccurrence(), DateTime(2025, 6, 22, 10, 0));
    });

    test('returns next month for monthly', () {
      final reminder = makeReminder(repeatInterval: 'monthly');
      expect(reminder.nextOccurrence(), DateTime(2025, 7, 15, 10, 0));
    });

    test('returns next year for yearly', () {
      final reminder = makeReminder(repeatInterval: 'yearly');
      expect(reminder.nextOccurrence(), DateTime(2026, 6, 15, 10, 0));
    });

    test('returns null for unknown interval', () {
      final reminder = makeReminder(repeatInterval: 'biweekly');
      expect(reminder.nextOccurrence(), isNull);
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
        autoSnoozeEnabled: false,
        autoSnoozeInterval: 15,
      );
      expect(updated.title, 'Updated');
      expect(updated.autoSnoozeEnabled, false);
      expect(updated.autoSnoozeInterval, 15);
      expect(updated.id, reminder.id); // unchanged
    });
  });
}
