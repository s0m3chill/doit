import 'package:equatable/equatable.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/entities/theme_settings.dart';

/// Aggregate of all user settings.
/// Keeps the BLoC state flat — one object, one source of truth.
class AppSettings extends Equatable {
  final HapticSoundSettings hapticSound;
  final ThemeSettings theme;

  const AppSettings({
    this.hapticSound = const HapticSoundSettings(),
    this.theme = const ThemeSettings(),
  });

  AppSettings copyWith({
    HapticSoundSettings? hapticSound,
    ThemeSettings? theme,
  }) {
    return AppSettings(
      hapticSound: hapticSound ?? this.hapticSound,
      theme: theme ?? this.theme,
    );
  }

  @override
  List<Object?> get props => [hapticSound, theme];
}
