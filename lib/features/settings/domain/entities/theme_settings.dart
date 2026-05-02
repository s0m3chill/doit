import 'package:equatable/equatable.dart';

/// User preferences for app theming.
/// [themeMode]: 'system', 'light', 'dark'
/// [colorName]: key into the available color palette (e.g., 'deepPurple', 'blue')
class ThemeSettings extends Equatable {
  final String themeMode;
  final String colorName;

  const ThemeSettings({
    this.themeMode = 'system',
    this.colorName = 'deepPurple',
  });

  ThemeSettings copyWith({
    String? themeMode,
    String? colorName,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      colorName: colorName ?? this.colorName,
    );
  }

  @override
  List<Object?> get props => [themeMode, colorName];
}
