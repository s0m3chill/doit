import 'package:equatable/equatable.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/entities/theme_settings.dart';

/// Aggregate of all user settings.
/// Keeps the BLoC state flat — one object, one source of truth.
class AppSettings extends Equatable {
  final HapticSoundSettings hapticSound;
  final ThemeSettings theme;
  /// Language code: 'system', 'en', 'uk', 'pl'
  final String language;

  const AppSettings({
    this.hapticSound = const HapticSoundSettings(),
    this.theme = const ThemeSettings(),
    this.language = 'system',
  });

  AppSettings copyWith({
    HapticSoundSettings? hapticSound,
    ThemeSettings? theme,
    String? language,
  }) {
    return AppSettings(
      hapticSound: hapticSound ?? this.hapticSound,
      theme: theme ?? this.theme,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [hapticSound, theme, language];
}
