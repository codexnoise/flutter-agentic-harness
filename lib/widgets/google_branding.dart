import 'package:material_ui/material_ui.dart';

import '../theme/google_colors.dart';

/// Texto con cada letra en uno de los 4 colores de Google.
class GoogleWordmark extends StatelessWidget {
  const GoogleWordmark(this.text, {super.key, this.suffix});

  final String text;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.titleLarge
        ?.copyWith(fontWeight: FontWeight.w700);
    var colorIndex = 0;
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final char in text.characters)
            TextSpan(
              text: char,
              style: TextStyle(
                color: char.trim().isEmpty
                    ? null
                    : GoogleColors.all[colorIndex++ % GoogleColors.all.length],
              ),
            ),
          if (suffix != null)
            TextSpan(
              text: ' $suffix',
              style: const TextStyle(
                color: Color(0xFF5F6368),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

/// Franja con los 4 colores de Google, para debajo del AppBar.
class GoogleColorStrip extends StatelessWidget implements PreferredSizeWidget {
  const GoogleColorStrip({super.key, this.height = 4});

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final color in GoogleColors.all)
            Expanded(child: ColoredBox(color: color)),
        ],
      ),
    );
  }
}

/// Etiqueta redondeada con fondo suave del color dado.
class ColorTag extends StatelessWidget {
  const ColorTag({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: GoogleColors.tint(color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: GoogleColors.ink(color),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
