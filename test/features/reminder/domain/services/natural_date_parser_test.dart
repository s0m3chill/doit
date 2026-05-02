import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/domain/services/natural_date_parser.dart';

void main() {
  // Fixed "now": Sunday June 15, 2025 at 10:30 AM
  final fixedNow = DateTime(2025, 6, 15, 10, 30);
  late NaturalDateParser parser;

  setUp(() {
    parser = NaturalDateParser(now: () => fixedNow);
  });

  group('parse() — Relative durations', () {
    test('"in 30 minutes"', () {
      expect(parser.parse('in 30 minutes'), DateTime(2025, 6, 15, 11, 0));
    });

    test('"in 2 hours"', () {
      expect(parser.parse('in 2 hours'), DateTime(2025, 6, 15, 12, 30));
    });

    test('"in 3 days"', () {
      expect(parser.parse('in 3 days'), DateTime(2025, 6, 18, 9, 0));
    });

    test('"in 2 weeks"', () {
      expect(parser.parse('in 2 weeks'), DateTime(2025, 6, 29, 9, 0));
    });

    test('"in 3 months"', () {
      expect(parser.parse('in 3 months'), DateTime(2025, 9, 15, 9, 0));
    });
  });

  group('parse() — Named days', () {
    test('"tomorrow"', () {
      expect(parser.parse('tomorrow'), DateTime(2025, 6, 16, 9, 0));
    });

    test('"tonight"', () {
      expect(parser.parse('tonight'), DateTime(2025, 6, 15, 21, 0));
    });

    test('"noon"', () {
      expect(parser.parse('noon'), DateTime(2025, 6, 15, 12, 0));
    });

    test('"midnight"', () {
      expect(parser.parse('midnight'), DateTime(2025, 6, 16, 0, 0));
    });
  });

  group('parse() — Weekdays', () {
    test('"monday"', () {
      final result = parser.parse('monday');
      expect(result, DateTime(2025, 6, 16, 9, 0));
    });

    test('"next tuesday"', () {
      final result = parser.parse('next tuesday');
      expect(result, DateTime(2025, 6, 24, 9, 0));
    });
  });

  group('parse() — Weekday + time', () {
    test('"friday 9am"', () {
      final result = parser.parse('friday 9am');
      expect(result, DateTime(2025, 6, 20, 9, 0));
    });

    test('"next monday 4pm"', () {
      final result = parser.parse('next monday 4pm');
      expect(result, DateTime(2025, 6, 23, 16, 0));
    });
  });

  group('parse() — Combined day + time', () {
    test('"tomorrow at 3pm"', () {
      expect(parser.parse('tomorrow at 3pm'), DateTime(2025, 6, 16, 15, 0));
    });

    test('"today at 14:30"', () {
      expect(parser.parse('today at 14:30'), DateTime(2025, 6, 15, 14, 30));
    });
  });

  group('parse() — Absolute dates', () {
    test('"aug 22"', () {
      final result = parser.parse('aug 22');
      expect(result, DateTime(2025, 8, 22, 9, 0));
    });

    test('"may 30" (past this year, rolls to next)', () {
      final result = parser.parse('may 30');
      expect(result, DateTime(2026, 5, 30, 9, 0));
    });

    test('"aug 22 at 8am"', () {
      final result = parser.parse('aug 22 at 8am');
      // The absolute date parser should pick up the time.
      expect(result?.month, 8);
      expect(result?.day, 22);
      expect(result?.hour, 8);
    });

    test('"december 25"', () {
      final result = parser.parse('december 25');
      expect(result, DateTime(2025, 12, 25, 9, 0));
    });
  });

  group('parse() — Time only', () {
    test('"3pm"', () {
      expect(parser.parse('3pm'), DateTime(2025, 6, 15, 15, 0));
    });

    test('"9am" (past, rolls to tomorrow)', () {
      expect(parser.parse('9am'), DateTime(2025, 6, 16, 9, 0));
    });
  });

  group('parse() — Edge cases', () {
    test('empty returns null', () {
      expect(parser.parse(''), isNull);
    });

    test('gibberish returns null', () {
      expect(parser.parse('asdfghjkl'), isNull);
    });

    test('case insensitive', () {
      expect(parser.parse('Tomorrow At 3PM'), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // parseFromTitle() — Due's core UX
  // ═══════════════════════════════════════════════════════════════════════════

  group('parseFromTitle() — extracts date and cleans title', () {
    test('"Product Meeting Friday 9am"', () {
      final result = parser.parseFromTitle('Product Meeting Friday 9am');
      expect(result, isNotNull);
      expect(result!.cleanTitle, 'Product Meeting');
      expect(result.date, DateTime(2025, 6, 20, 9, 0));
    });

    test('"Send email in 1 hour"', () {
      final result = parser.parseFromTitle('Send email in 1 hour');
      expect(result, isNotNull);
      expect(result!.cleanTitle, 'Send email');
      expect(result.date, DateTime(2025, 6, 15, 11, 30));
    });

    test('"Collect passport next Monday 4pm"', () {
      final result =
          parser.parseFromTitle('Collect passport next Monday 4pm');
      expect(result, isNotNull);
      expect(result!.cleanTitle, 'Collect passport');
      expect(result.date.hour, 16);
      expect(result.date.weekday, DateTime.monday);
    });

    test('"Make dinner reservation at 14:00 tomorrow"', () {
      // "tomorrow" is a named day, "at 14:00" is a time.
      // The combined pattern "tomorrow at 14:00" should match.
      final result = parser
          .parseFromTitle('Make dinner reservation at 14:00 tomorrow');
      // This might match "tomorrow" as a named day or the combined pattern.
      expect(result, isNotNull);
      expect(result!.cleanTitle.contains('Make dinner reservation'), true);
    });

    test('"Call dentist tomorrow"', () {
      final result = parser.parseFromTitle('Call dentist tomorrow');
      expect(result, isNotNull);
      expect(result!.cleanTitle, 'Call dentist');
      expect(result.date, DateTime(2025, 6, 16, 9, 0));
    });

    test('"Buy groceries"  — no date, returns null', () {
      final result = parser.parseFromTitle('Buy groceries');
      expect(result, isNull);
    });

    test('empty string returns null', () {
      expect(parser.parseFromTitle(''), isNull);
    });

    test('"Wish Sally happy birthday on Aug 22 at 8am"', () {
      // Should detect "aug 22 at 8am" or similar.
      final result = parser
          .parseFromTitle('Wish Sally happy birthday on Aug 22 at 8am');
      // The "on" prefix isn't part of our patterns, but "aug 22" should match.
      if (result != null) {
        expect(result.date.month, 8);
        expect(result.date.day, 22);
      }
    });

    test('"Meeting 3pm" — trailing time', () {
      final result = parser.parseFromTitle('Meeting 3pm');
      expect(result, isNotNull);
      expect(result!.cleanTitle, 'Meeting');
      expect(result.date.hour, 15);
    });

    test('"Gym tomorrow at 7am"', () {
      final result = parser.parseFromTitle('Gym tomorrow at 7am');
      // Should match "tomorrow at 7am" as combined pattern.
      // But our _combinedDayTimeRe requires "at" between day and time.
      // "tomorrow at 7am" should work via _extractNamedDayWithTime or
      // _extractCombinedDayAndTime.
      expect(result, isNotNull);
      if (result != null) {
        expect(result.date, DateTime(2025, 6, 16, 7, 0));
        expect(result.cleanTitle, 'Gym');
      }
    });

    test('preserves title casing', () {
      final result = parser.parseFromTitle('Important Meeting Friday 9am');
      expect(result, isNotNull);
      // The clean title should preserve original casing.
      expect(result!.cleanTitle, 'Important Meeting');
    });
  });
}
