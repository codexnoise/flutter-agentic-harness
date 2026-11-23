import 'package:material_ui/material_ui.dart';

/// Los 4 colores de Google.
abstract final class GoogleColors {
  static const blue = Color(0xFF4285F4);
  static const red = Color(0xFFEA4335);
  static const yellow = Color(0xFFFBBC05);
  static const green = Color(0xFF34A853);

  static const all = [blue, red, yellow, green];

  /// Color estable por hash para cualquier texto.
  static Color forKey(String key) {
    var hash = 0;
    for (final unit in key.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return all[hash % all.length];
  }

  /// Color por nivel de la sesión; azul para niveles desconocidos.
  static Color forLevel(String level) => switch (level) {
    'Intro' => green,
    'Intermedio' => yellow,
    'Avanzado' => red,
    _ => blue,
  };

  /// Color de texto legible encima de [color].
  static Color onColor(Color color) =>
      color == yellow ? const Color(0xFF202124) : Colors.white;

  /// Variante oscura para usar como texto sobre fondos claros.
  static Color ink(Color color) => Color.lerp(color, Colors.black, 0.4)!;

  /// Variante clara para fondos de etiquetas.
  static Color tint(Color color) => color.withValues(alpha: 0.14);

  /// Fondo muy suave (opaco) del color, para superficies grandes.
  static Color wash(Color color, [double amount = 0.08]) =>
      Color.lerp(Colors.white, color, amount)!;
}
