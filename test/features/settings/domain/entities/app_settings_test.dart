import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/settings/domain/entities/app_settings.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/entities/theme_settings.dart';

void main() {
  group('AppSettings', () {
    test('has sensible defaults', () {
      const settings = AppSettings();
      expect(settings.hapticSound, const HapticSoundSettings());
      expect(settings.theme, const ThemeSettings());
    });

    test('copyWith preserves all fields when no args given', () {
      const settings = AppSettings(
        hapticSound: HapticSoundSettings(soundEnabled: false),
        theme: ThemeSettings(colorName: 'blue'),
      );
      expect(settings.copyWith(), settings);
    });

    test('copyWith overrides hapticSound only', () {
      const settings = AppSettings();
      final updated = settings.copyWith(
        hapticSound: const HapticSoundSettings(vibrationEnabled: false),
      );
      expect(updated.hapticSound.vibrationEnabled, false);
      expect(updated.theme, const ThemeSettings()); // unchanged
    });

    test('copyWith overrides theme only', () {
      const settings = AppSettings();
      final updated = settings.copyWith(
        theme: const ThemeSettings(themeMode: 'dark'),
      );
      expect(updated.theme.themeMode, 'dark');
      expect(updated.hapticSound, const HapticSoundSettings()); // unchanged
    });
  });
}
