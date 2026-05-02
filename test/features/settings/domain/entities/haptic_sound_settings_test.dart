import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';

void main() {
  group('HapticSoundSettings', () {
    test('has sensible defaults', () {
      const settings = HapticSoundSettings();
      expect(settings.soundEnabled, true);
      expect(settings.vibrationEnabled, true);
      expect(settings.notificationSound, 'default');
      expect(settings.hapticIntensity, 'medium');
    });

    test('copyWith preserves all fields when no args given', () {
      const settings = HapticSoundSettings(
        soundEnabled: false,
        vibrationEnabled: false,
        notificationSound: 'gentle',
        hapticIntensity: 'heavy',
      );
      expect(settings.copyWith(), settings);
    });

    test('copyWith overrides specified fields', () {
      const settings = HapticSoundSettings();
      final updated = settings.copyWith(
        soundEnabled: false,
        hapticIntensity: 'light',
      );
      expect(updated.soundEnabled, false);
      expect(updated.hapticIntensity, 'light');
      expect(updated.vibrationEnabled, true); // unchanged
      expect(updated.notificationSound, 'default'); // unchanged
    });

    test('equality works correctly', () {
      const a = HapticSoundSettings(
        soundEnabled: true,
        vibrationEnabled: false,
        notificationSound: 'urgent',
        hapticIntensity: 'heavy',
      );
      const b = HapticSoundSettings(
        soundEnabled: true,
        vibrationEnabled: false,
        notificationSound: 'urgent',
        hapticIntensity: 'heavy',
      );
      expect(a, b);
    });

    test('inequality when fields differ', () {
      const a = HapticSoundSettings(soundEnabled: true);
      const b = HapticSoundSettings(soundEnabled: false);
      expect(a, isNot(b));
    });
  });
}
