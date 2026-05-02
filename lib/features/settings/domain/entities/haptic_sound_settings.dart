import 'package:equatable/equatable.dart';

/// User preferences for haptic feedback and notification sounds.
/// Pure domain entity — no framework dependencies.
class HapticSoundSettings extends Equatable {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String notificationSound; // 'default', 'gentle', 'urgent', 'none'
  final String hapticIntensity; // 'light', 'medium', 'heavy', 'none'

  const HapticSoundSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationSound = 'default',
    this.hapticIntensity = 'medium',
  });

  HapticSoundSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? notificationSound,
    String? hapticIntensity,
  }) {
    return HapticSoundSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationSound: notificationSound ?? this.notificationSound,
      hapticIntensity: hapticIntensity ?? this.hapticIntensity,
    );
  }

  @override
  List<Object?> get props => [
        soundEnabled,
        vibrationEnabled,
        notificationSound,
        hapticIntensity,
      ];
}
