import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/domain/entities/recurrence_rule.dart';

void main() {
  // Fixed base date: Sunday June 15, 2025 at 10:00 AM (weekday=7)
  final base = DateTime(2025, 6, 15, 10, 0);

  group('Simple recurrence', () {
    test('none returns null', () {
      expect(RecurrenceRule.none.nextOccurrence(base), isNull);
    });

    test('daily returns next day', () {
      expect(RecurrenceRule.daily.nextOccurrence(base),
          DateTime(2025, 6, 16, 10, 0));
    });

    test('every 3 days', () {
      final rule = RecurrenceRule.everyNDays(3);
      expect(rule.nextOccurrence(base), DateTime(2025, 6, 18, 10, 0));
    });

    test('weekly returns next week', () {
      expect(RecurrenceRule.weekly.nextOccurrence(base),
          DateTime(2025, 6, 22, 10, 0));
    });

    test('every 2 weeks', () {
      final rule = RecurrenceRule.everyNWeeks(2);
      expect(rule.nextOccurrence(base), DateTime(2025, 6, 29, 10, 0));
    });

    test('monthly returns next month', () {
      expect(RecurrenceRule.monthly.nextOccurrence(base),
          DateTime(2025, 7, 15, 10, 0));
    });

    test('yearly returns next year', () {
      expect(RecurrenceRule.yearly.nextOccurrence(base),
          DateTime(2026, 6, 15, 10, 0));
    });
  });

  group('Specific weekdays', () {
    test('Mon, Wed, Fri from Sunday returns Monday', () {
      // base is Sunday (7), next weekday > 7 doesn't exist in [1,3,5]
      // so it wraps to next week's first match: Monday
      final rule = RecurrenceRule.onWeekdays([1, 3, 5]);
      final next = rule.nextOccurrence(base);
      expect(next, DateTime(2025, 6, 16, 10, 0)); // Monday
      expect(next!.weekday, DateTime.monday);
    });

    test('Mon, Wed, Fri from Monday returns Wednesday', () {
      final monday = DateTime(2025, 6, 16, 10, 0);
      final rule = RecurrenceRule.onWeekdays([1, 3, 5]);
      final next = rule.nextOccurrence(monday);
      expect(next, DateTime(2025, 6, 18, 10, 0)); // Wednesday
      expect(next!.weekday, DateTime.wednesday);
    });

    test('Mon, Wed, Fri from Friday returns next Monday', () {
      final friday = DateTime(2025, 6, 20, 10, 0);
      final rule = RecurrenceRule.onWeekdays([1, 3, 5]);
      final next = rule.nextOccurrence(friday);
      expect(next, DateTime(2025, 6, 23, 10, 0)); // Next Monday
      expect(next!.weekday, DateTime.monday);
    });

    test('Tue, Thu from Wednesday returns Thursday', () {
      final wednesday = DateTime(2025, 6, 18, 10, 0);
      final rule = RecurrenceRule.onWeekdays([2, 4]);
      final next = rule.nextOccurrence(wednesday);
      expect(next, DateTime(2025, 6, 19, 10, 0)); // Thursday
      expect(next!.weekday, DateTime.thursday);
    });
  });

  group('Nth weekday of month', () {
    test('3rd Wednesday from June 15 (Sunday)', () {
      // June 2025: 1st Wed = June 4, 2nd = June 11, 3rd = June 18
      final rule = RecurrenceRule.nthWeekdayOfMonth(3, DateTime.wednesday);
      final next = rule.nextOccurrence(base);
      expect(next, DateTime(2025, 6, 18, 10, 0)); // 3rd Wed of June
      expect(next!.weekday, DateTime.wednesday);
    });

    test('1st Monday from June 15 (past 1st Mon) goes to July', () {
      // June 1st Monday = June 2. Already past June 15.
      final rule = RecurrenceRule.nthWeekdayOfMonth(1, DateTime.monday);
      final next = rule.nextOccurrence(base);
      // July 1st Monday = July 7
      expect(next, DateTime(2025, 7, 7, 10, 0));
      expect(next!.weekday, DateTime.monday);
    });

    test('2nd Friday from June 15', () {
      // June: 1st Fri = June 6, 2nd Fri = June 13. Already past.
      final rule = RecurrenceRule.nthWeekdayOfMonth(2, DateTime.friday);
      final next = rule.nextOccurrence(base);
      // July: 1st Fri = July 4, 2nd Fri = July 11
      expect(next, DateTime(2025, 7, 11, 10, 0));
      expect(next!.weekday, DateTime.friday);
    });

    test('4th Thursday from early in the month', () {
      final earlyJune = DateTime(2025, 6, 1, 10, 0);
      final rule = RecurrenceRule.nthWeekdayOfMonth(4, DateTime.thursday);
      // June: 1st Thu = June 5, 4th Thu = June 26
      final next = rule.nextOccurrence(earlyJune);
      expect(next, DateTime(2025, 6, 26, 10, 0));
      expect(next!.weekday, DateTime.thursday);
    });

    test('every 2 months, 1st Tuesday from June 15', () {
      final rule = RecurrenceRule.nthWeekdayOfMonth(
          1, DateTime.tuesday, interval: 2);
      final next = rule.nextOccurrence(base);
      // June 1st Tue = June 3 (past). Next interval = August.
      // August 1st Tue = Aug 5.
      expect(next, DateTime(2025, 8, 5, 10, 0));
      expect(next!.weekday, DateTime.tuesday);
    });
  });

  group('Specific days of month', () {
    test('1st and 15th from June 15 returns July 1', () {
      final rule = RecurrenceRule.onMonthDays([1, 15]);
      final next = rule.nextOccurrence(base);
      expect(next, DateTime(2025, 7, 1, 10, 0));
    });

    test('1st and 15th from June 10 returns June 15', () {
      final june10 = DateTime(2025, 6, 10, 10, 0);
      final rule = RecurrenceRule.onMonthDays([1, 15]);
      final next = rule.nextOccurrence(june10);
      expect(next, DateTime(2025, 6, 15, 10, 0));
    });

    test('5th and 20th from June 15 returns June 20', () {
      final rule = RecurrenceRule.onMonthDays([5, 20]);
      final next = rule.nextOccurrence(base);
      expect(next, DateTime(2025, 6, 20, 10, 0));
    });

    test('every 2 months on the 10th from June 15', () {
      final rule = RecurrenceRule.onMonthDays([10], interval: 2);
      final next = rule.nextOccurrence(base);
      expect(next, DateTime(2025, 8, 10, 10, 0));
    });
  });

  group('Serialization', () {
    test('roundtrip preserves data', () {
      final rule = RecurrenceRule.nthWeekdayOfMonth(3, DateTime.wednesday,
          interval: 2);
      final restored = RecurrenceRule.fromMap(rule.toMap());
      expect(restored, rule);
    });

    test('roundtrip with weekdays', () {
      final rule = RecurrenceRule.onWeekdays([1, 3, 5], interval: 2);
      final restored = RecurrenceRule.fromMap(rule.toMap());
      expect(restored, rule);
    });

    test('roundtrip with monthDays', () {
      final rule = RecurrenceRule.onMonthDays([1, 15]);
      final restored = RecurrenceRule.fromMap(rule.toMap());
      expect(restored, rule);
    });

    test('fromMap handles missing fields', () {
      final rule = RecurrenceRule.fromMap({});
      expect(rule.frequency, 'none');
      expect(rule.interval, 1);
      expect(rule.weekdays, isEmpty);
    });
  });

  group('Description', () {
    test('none', () {
      expect(RecurrenceRule.none.description, 'Does not repeat');
    });

    test('daily', () {
      expect(RecurrenceRule.daily.description, 'Daily');
    });

    test('every 3 days', () {
      expect(RecurrenceRule.everyNDays(3).description, 'Every 3 days');
    });

    test('weekly on specific days', () {
      final rule = RecurrenceRule.onWeekdays([1, 3, 5]);
      expect(rule.description, 'Weekly on Mon, Wed, Fri');
    });

    test('3rd Wednesday', () {
      final rule = RecurrenceRule.nthWeekdayOfMonth(3, DateTime.wednesday);
      expect(rule.description, 'Monthly on the 3rd Wed');
    });

    test('1st and 15th', () {
      final rule = RecurrenceRule.onMonthDays([1, 15]);
      expect(rule.description, 'Monthly on the 1st and 15th');
    });

    test('yearly', () {
      expect(RecurrenceRule.yearly.description, 'Yearly');
    });
  });

  group('Properties', () {
    test('isNone / isRecurring', () {
      expect(RecurrenceRule.none.isNone, true);
      expect(RecurrenceRule.none.isRecurring, false);
      expect(RecurrenceRule.daily.isNone, false);
      expect(RecurrenceRule.daily.isRecurring, true);
    });

    test('isOrdinalWeekday', () {
      expect(RecurrenceRule.monthly.isOrdinalWeekday, false);
      expect(
        RecurrenceRule.nthWeekdayOfMonth(3, 3).isOrdinalWeekday,
        true,
      );
    });
  });
}
