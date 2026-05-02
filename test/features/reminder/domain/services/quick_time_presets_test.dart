import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/domain/services/quick_time_presets.dart';

void main() {
  // Fixed "now" for deterministic tests: Wednesday June 15, 2025 at 10:30 AM
  final now = DateTime(2025, 6, 15, 10, 30);

  group('QuickTimePresets.defaults', () {
    test('returns exactly 12 presets', () {
      expect(QuickTimePresets.defaults.length, 12);
    });

    test('all presets have unique IDs', () {
      final ids = QuickTimePresets.defaults.map((p) => p.id).toSet();
      expect(ids.length, 12);
    });

    test('all presets have non-empty labels', () {
      for (final preset in QuickTimePresets.defaults) {
        expect(preset.label.isNotEmpty, true,
            reason: '${preset.id} has empty label');
      }
    });
  });

  group('Relative offset presets', () {
    test('in_30_min adds 30 minutes', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'in_30_min');
      final result = preset.resolveFrom(now);
      expect(result, DateTime(2025, 6, 15, 11, 0));
    });

    test('in_1_hour adds 1 hour', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'in_1_hour');
      final result = preset.resolveFrom(now);
      expect(result, DateTime(2025, 6, 15, 11, 30));
    });

    test('in_3_hours adds 3 hours', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'in_3_hours');
      final result = preset.resolveFrom(now);
      expect(result, DateTime(2025, 6, 15, 13, 30));
    });

    test('tonight resolves to 9 PM today when before 9 PM', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'tonight');
      final result = preset.resolveFrom(now);
      expect(result, DateTime(2025, 6, 15, 21, 0));
    });

    test('tonight resolves to 9 PM tomorrow when after 9 PM', () {
      final lateNow = DateTime(2025, 6, 15, 22, 0);
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'tonight');
      final result = preset.resolveFrom(lateNow);
      expect(result, DateTime(2025, 6, 16, 21, 0));
    });

    test('tomorrow resolves to 9 AM next day', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'tomorrow');
      final result = preset.resolveFrom(now);
      expect(result, DateTime(2025, 6, 16, 9, 0));
    });

    test('in_2_days resolves to 9 AM in 2 days', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'in_2_days');
      final result = preset.resolveFrom(now);
      expect(result, DateTime(2025, 6, 17, 9, 0));
    });
  });

  group('Absolute time presets', () {
    test('next_9am resolves to tomorrow 9 AM when past 9 AM today', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'next_9am');
      final result = preset.resolveFrom(now); // 10:30 AM
      expect(result, DateTime(2025, 6, 16, 9, 0));
    });

    test('next_9am resolves to today 9 AM when before 9 AM', () {
      final earlyNow = DateTime(2025, 6, 15, 8, 0);
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'next_9am');
      final result = preset.resolveFrom(earlyNow);
      expect(result, DateTime(2025, 6, 15, 9, 0));
    });

    test('next_12pm resolves to today noon when before noon', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'next_12pm');
      final result = preset.resolveFrom(now); // 10:30 AM
      expect(result, DateTime(2025, 6, 15, 12, 0));
    });

    test('next_12pm resolves to tomorrow noon when past noon', () {
      final afternoonNow = DateTime(2025, 6, 15, 14, 0);
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'next_12pm');
      final result = preset.resolveFrom(afternoonNow);
      expect(result, DateTime(2025, 6, 16, 12, 0));
    });

    test('next_3pm resolves correctly', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'next_3pm');
      final result = preset.resolveFrom(now);
      expect(result, DateTime(2025, 6, 15, 15, 0));
    });

    test('next_6pm resolves correctly', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'next_6pm');
      final result = preset.resolveFrom(now);
      expect(result, DateTime(2025, 6, 15, 18, 0));
    });

    test('next_monday resolves to next Monday at 9 AM', () {
      // June 15, 2025 is a Sunday
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'next_monday');
      final result = preset.resolveFrom(now);
      expect(result, DateTime(2025, 6, 16, 9, 0)); // Monday June 16
      expect(result.weekday, DateTime.monday);
    });

    test('next_monday skips to following Monday when today is Monday', () {
      final mondayNow = DateTime(2025, 6, 16, 10, 0); // Monday
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'next_monday');
      final result = preset.resolveFrom(mondayNow);
      expect(result, DateTime(2025, 6, 23, 9, 0)); // Next Monday
      expect(result.weekday, DateTime.monday);
    });

    test('next_week resolves to 7 days from now at 9 AM', () {
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'next_week');
      final result = preset.resolveFrom(now);
      expect(result, DateTime(2025, 6, 22, 9, 0));
    });
  });

  group('Edge cases', () {
    test('presets at exact boundary time roll to next day', () {
      final exactNoon = DateTime(2025, 6, 15, 12, 0);
      final preset =
          QuickTimePresets.defaults.firstWhere((p) => p.id == 'next_12pm');
      final result = preset.resolveFrom(exactNoon);
      // At exactly noon, should roll to tomorrow
      expect(result, DateTime(2025, 6, 16, 12, 0));
    });

    test('all presets resolve to future dates', () {
      for (final preset in QuickTimePresets.defaults) {
        final result = preset.resolveFrom(now);
        expect(result.isAfter(now), true,
            reason: '${preset.id} resolved to $result which is not after $now');
      }
    });
  });
}
