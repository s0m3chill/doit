import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/settings/domain/services/theme_color_palette.dart';

void main() {
  group('ThemeColorPalette', () {
    test('has exactly 12 colors', () {
      expect(ThemeColorPalette.colors.length, 12);
    });

    test('all colors have unique IDs', () {
      final ids = ThemeColorPalette.colors.map((c) => c.id).toSet();
      expect(ids.length, 12);
    });

    test('all colors have non-empty labels', () {
      for (final color in ThemeColorPalette.colors) {
        expect(color.label.isNotEmpty, true,
            reason: '${color.id} has empty label');
      }
    });

    test('hexForName returns correct hex for known color', () {
      expect(ThemeColorPalette.hexForName('blue'), 0xFF2196F3);
      expect(ThemeColorPalette.hexForName('red'), 0xFFF44336);
      expect(ThemeColorPalette.hexForName('deepPurple'), 0xFF673AB7);
    });

    test('hexForName falls back to deepPurple for unknown color', () {
      expect(ThemeColorPalette.hexForName('nonexistent'), 0xFF673AB7);
    });
  });
}
