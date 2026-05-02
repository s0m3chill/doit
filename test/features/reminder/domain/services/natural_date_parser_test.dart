import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/domain/services/natural_date_parser.dart';

void main() {
  // Fixed "now": Sunday June 15, 2025 at 10:30 AM
  final fixedNow = DateTime(2025, 6, 15, 10, 30);
  late NaturalDateParser parser;

  setUp(() {
    parser = NaturalDateParser(now: () => fixedNow);
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // English
  // ═══════════════════════════════════════════════════════════════════════════

  group('English — parse()', () {
    test('"in 30 minutes"', () {
      expect(parser.parse('in 30 minutes'), DateTime(2025, 6, 15, 11, 0));
    });

    test('"in 2 hours"', () {
      expect(parser.parse('in 2 hours'), DateTime(2025, 6, 15, 12, 30));
    });

    test('"in 3 days"', () {
      expect(parser.parse('in 3 days'), DateTime(2025, 6, 18, 9, 0));
    });

    test('"tomorrow"', () {
      expect(parser.parse('tomorrow'), DateTime(2025, 6, 16, 9, 0));
    });

    test('"tonight"', () {
      expect(parser.parse('tonight'), DateTime(2025, 6, 15, 21, 0));
    });

    test('"monday"', () {
      expect(parser.parse('monday'), DateTime(2025, 6, 16, 9, 0));
    });

    test('"next tuesday"', () {
      expect(parser.parse('next tuesday'), DateTime(2025, 6, 24, 9, 0));
    });

    test('"tomorrow at 3pm"', () {
      expect(parser.parse('tomorrow at 3pm'), DateTime(2025, 6, 16, 15, 0));
    });

    test('"friday 9am"', () {
      expect(parser.parse('friday 9am'), DateTime(2025, 6, 20, 9, 0));
    });

    test('"3pm"', () {
      expect(parser.parse('3pm'), DateTime(2025, 6, 15, 15, 0));
    });

    test('empty returns null', () {
      expect(parser.parse(''), isNull);
    });

    test('gibberish returns null', () {
      expect(parser.parse('asdfghjkl'), isNull);
    });
  });

  group('English — parseFromTitle()', () {
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

    test('"Call dentist tomorrow"', () {
      final result = parser.parseFromTitle('Call dentist tomorrow');
      expect(result, isNotNull);
      expect(result!.cleanTitle, 'Call dentist');
      expect(result.date, DateTime(2025, 6, 16, 9, 0));
    });

    test('"Buy groceries" — no date', () {
      expect(parser.parseFromTitle('Buy groceries'), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Ukrainian
  // ═══════════════════════════════════════════════════════════════════════════

  group('Ukrainian — parse()', () {
    test('"через 30 хвилин"', () {
      expect(parser.parse('через 30 хвилин'), DateTime(2025, 6, 15, 11, 0));
    });

    test('"через 2 години"', () {
      expect(parser.parse('через 2 години'), DateTime(2025, 6, 15, 12, 30));
    });

    test('"через 3 дні"', () {
      expect(parser.parse('через 3 дні'), DateTime(2025, 6, 18, 9, 0));
    });

    test('"завтра"', () {
      expect(parser.parse('завтра'), DateTime(2025, 6, 16, 9, 0));
    });

    test('"сьогодні ввечері"', () {
      expect(parser.parse('сьогодні ввечері'), DateTime(2025, 6, 15, 21, 0));
    });

    test('"ввечері"', () {
      expect(parser.parse('ввечері'), DateTime(2025, 6, 15, 21, 0));
    });

    test('"післязавтра"', () {
      expect(parser.parse('післязавтра'), DateTime(2025, 6, 17, 9, 0));
    });

    test('"понеділок"', () {
      expect(parser.parse('понеділок'), DateTime(2025, 6, 16, 9, 0));
    });

    test('"наступний вівторок"', () {
      expect(parser.parse('наступний вівторок'), DateTime(2025, 6, 24, 9, 0));
    });

    test('"завтра о 15:00"', () {
      expect(parser.parse('завтра о 15:00'), DateTime(2025, 6, 16, 15, 0));
    });

    test('"завтра о 3pm"', () {
      expect(parser.parse('завтра о 3pm'), DateTime(2025, 6, 16, 15, 0));
    });

    test('"15:00"', () {
      expect(parser.parse('15:00'), DateTime(2025, 6, 15, 15, 0));
    });
  });

  group('Ukrainian — parseFromTitle()', () {
    test('"Зателефонувати лікарю завтра"', () {
      final result = parser.parseFromTitle('Зателефонувати лікарю завтра');
      expect(result, isNotNull);
      expect(result!.cleanTitle, 'Зателефонувати лікарю');
      expect(result.date, DateTime(2025, 6, 16, 9, 0));
    });

    test('"Зустріч через 2 години"', () {
      final result = parser.parseFromTitle('Зустріч через 2 години');
      expect(result, isNotNull);
      expect(result!.cleanTitle, 'Зустріч');
      expect(result.date, DateTime(2025, 6, 15, 12, 30));
    });

    test('"Купити продукти" — no date', () {
      expect(parser.parseFromTitle('Купити продукти'), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Polish
  // ═══════════════════════════════════════════════════════════════════════════

  group('Polish — parse()', () {
    test('"za 30 minut"', () {
      expect(parser.parse('za 30 minut'), DateTime(2025, 6, 15, 11, 0));
    });

    test('"za 2 godziny"', () {
      expect(parser.parse('za 2 godziny'), DateTime(2025, 6, 15, 12, 30));
    });

    test('"za 3 dni"', () {
      expect(parser.parse('za 3 dni'), DateTime(2025, 6, 18, 9, 0));
    });

    test('"jutro"', () {
      expect(parser.parse('jutro'), DateTime(2025, 6, 16, 9, 0));
    });

    test('"pojutrze"', () {
      expect(parser.parse('pojutrze'), DateTime(2025, 6, 17, 9, 0));
    });

    test('"dzisiaj"', () {
      final result = parser.parse('dzisiaj');
      expect(result, isNotNull);
      // 9 AM has passed, so rounds up to 11:00
      expect(result, DateTime(2025, 6, 15, 11, 0));
    });

    test('"poniedziałek"', () {
      expect(parser.parse('poniedziałek'), DateTime(2025, 6, 16, 9, 0));
    });

    test('"następny wtorek"', () {
      expect(parser.parse('następny wtorek'), DateTime(2025, 6, 24, 9, 0));
    });

    test('"jutro o 15:00"', () {
      expect(parser.parse('jutro o 15:00'), DateTime(2025, 6, 16, 15, 0));
    });

    test('"15:00"', () {
      expect(parser.parse('15:00'), DateTime(2025, 6, 15, 15, 0));
    });
  });

  group('Polish — parseFromTitle()', () {
    test('"Zadzwonić do dentysty jutro"', () {
      final result = parser.parseFromTitle('Zadzwonić do dentysty jutro');
      expect(result, isNotNull);
      expect(result!.cleanTitle, 'Zadzwonić do dentysty');
      expect(result.date, DateTime(2025, 6, 16, 9, 0));
    });

    test('"Spotkanie za 2 godziny"', () {
      final result = parser.parseFromTitle('Spotkanie za 2 godziny');
      expect(result, isNotNull);
      expect(result!.cleanTitle, 'Spotkanie');
      expect(result.date, DateTime(2025, 6, 15, 12, 30));
    });

    test('"Kupić mleko" — no date', () {
      expect(parser.parseFromTitle('Kupić mleko'), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Cross-language
  // ═══════════════════════════════════════════════════════════════════════════

  group('Cross-language', () {
    test('all three languages parse "tomorrow" equivalents the same', () {
      final en = parser.parse('tomorrow');
      final uk = parser.parse('завтра');
      final pl = parser.parse('jutro');
      expect(en, DateTime(2025, 6, 16, 9, 0));
      expect(uk, en);
      expect(pl, en);
    });

    test('all three parse "in 2 hours" equivalents the same', () {
      final en = parser.parse('in 2 hours');
      final uk = parser.parse('через 2 години');
      final pl = parser.parse('za 2 godziny');
      expect(en, DateTime(2025, 6, 15, 12, 30));
      expect(uk, en);
      expect(pl, en);
    });

    test('24-hour time works regardless of language', () {
      expect(parser.parse('15:00'), DateTime(2025, 6, 15, 15, 0));
    });

    test('case insensitive across languages', () {
      expect(parser.parse('ЗАВТРА'), DateTime(2025, 6, 16, 9, 0));
      expect(parser.parse('JUTRO'), DateTime(2025, 6, 16, 9, 0));
      expect(parser.parse('TOMORROW'), DateTime(2025, 6, 16, 9, 0));
    });
  });
}
