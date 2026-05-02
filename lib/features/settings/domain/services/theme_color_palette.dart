/// Available theme colors for the app.
/// Maps a color name (persisted as a string) to its hex seed value.
/// Pure domain — no Flutter Color dependency. The presentation layer
/// converts these to Color objects.
class ThemeColorPalette {
  ThemeColorPalette._();

  /// All available theme colors as (id, label, hex) tuples.
  static const List<({String id, String label, int hex})> colors = [
    (id: 'deepPurple', label: 'Purple', hex: 0xFF673AB7),
    (id: 'blue', label: 'Blue', hex: 0xFF2196F3),
    (id: 'teal', label: 'Teal', hex: 0xFF009688),
    (id: 'green', label: 'Green', hex: 0xFF4CAF50),
    (id: 'orange', label: 'Orange', hex: 0xFFFF9800),
    (id: 'red', label: 'Red', hex: 0xFFF44336),
    (id: 'pink', label: 'Pink', hex: 0xFFE91E63),
    (id: 'indigo', label: 'Indigo', hex: 0xFF3F51B5),
    (id: 'cyan', label: 'Cyan', hex: 0xFF00BCD4),
    (id: 'amber', label: 'Amber', hex: 0xFFFFC107),
    (id: 'brown', label: 'Brown', hex: 0xFF795548),
    (id: 'blueGrey', label: 'Slate', hex: 0xFF607D8B),
  ];

  /// Look up the hex value for a color name. Falls back to deepPurple.
  static int hexForName(String name) {
    return colors
        .firstWhere(
          (c) => c.id == name,
          orElse: () => colors.first,
        )
        .hex;
  }
}
