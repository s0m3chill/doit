import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/settings/domain/entities/theme_settings.dart';

void main() {
  group('ThemeSettings', () {
    test('has sensible defaults', () {
      const settings = ThemeSettings();
      expect(settings.themeMode, 'system');
      expect(settings.colorName, 'deepPurple');
    });

    test('copyWith preserves all fields when no args given', () {
      const settings = ThemeSettings(themeMode: 'dark', colorName: 'blue');
      expect(settings.copyWith(), settings);
    });

    test('copyWith overrides specified fields', () {
      const settings = ThemeSettings();
      final updated = settings.copyWith(themeMode: 'dark', colorName: 'red');
      expect(updated.themeMode, 'dark');
      expect(updated.colorName, 'red');
    });

    test('equality works correctly', () {
      const a = ThemeSettings(themeMode: 'light', colorName: 'teal');
      const b = ThemeSettings(themeMode: 'light', colorName: 'teal');
      expect(a, b);
    });

    test('inequality when fields differ', () {
      const a = ThemeSettings(colorName: 'blue');
      const b = ThemeSettings(colorName: 'red');
      expect(a, isNot(b));
    });
  });
}
