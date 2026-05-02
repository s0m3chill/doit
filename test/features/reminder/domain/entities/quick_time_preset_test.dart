import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/domain/entities/quick_time_preset.dart';

void main() {
  group('QuickTimePreset', () {
    test('resolveFrom delegates to the resolve function', () {
      final preset = QuickTimePreset(
        id: 'test',
        label: 'Test',
        icon: '⏰',
        resolve: (now) => now.add(const Duration(hours: 2)),
      );

      final now = DateTime(2025, 6, 15, 10, 0);
      final result = preset.resolveFrom(now);

      expect(result, DateTime(2025, 6, 15, 12, 0));
    });

    test('equality is based on id, label, and icon', () {
      final a = QuickTimePreset(
        id: 'test',
        label: 'Test',
        icon: '⏰',
        resolve: (now) => now,
      );
      final b = QuickTimePreset(
        id: 'test',
        label: 'Test',
        icon: '⏰',
        resolve: (now) => now.add(const Duration(days: 1)),
      );

      // Same id/label/icon — equal (resolve function is not in props)
      expect(a, b);
    });

    test('different IDs are not equal', () {
      final a = QuickTimePreset(
        id: 'a',
        label: 'Test',
        icon: '⏰',
        resolve: (now) => now,
      );
      final b = QuickTimePreset(
        id: 'b',
        label: 'Test',
        icon: '⏰',
        resolve: (now) => now,
      );

      expect(a, isNot(b));
    });
  });
}
