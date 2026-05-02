import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

// ── Haptic / Sound ──

class ToggleSound extends SettingsEvent {
  final bool enabled;
  const ToggleSound({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class ToggleVibration extends SettingsEvent {
  final bool enabled;
  const ToggleVibration({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class ChangeNotificationSound extends SettingsEvent {
  final String sound;
  const ChangeNotificationSound({required this.sound});

  @override
  List<Object?> get props => [sound];
}

class ChangeHapticIntensity extends SettingsEvent {
  final String intensity;
  const ChangeHapticIntensity({required this.intensity});

  @override
  List<Object?> get props => [intensity];
}

// ── Theme ──

class ChangeThemeMode extends SettingsEvent {
  final String mode; // 'system', 'light', 'dark'
  const ChangeThemeMode({required this.mode});

  @override
  List<Object?> get props => [mode];
}

class ChangeThemeColor extends SettingsEvent {
  final String colorName;
  const ChangeThemeColor({required this.colorName});

  @override
  List<Object?> get props => [colorName];
}

// ── Language ──

class ChangeLanguage extends SettingsEvent {
  final String language; // 'system', 'en', 'uk', 'pl'
  const ChangeLanguage({required this.language});

  @override
  List<Object?> get props => [language];
}
