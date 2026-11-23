/// Breakpoints de ancho disponible (en píxeles lógicos), con nombre.
///
/// Se comparan contra las constraints de un `LayoutBuilder`, nunca contra el
/// tamaño de la pantalla ni el tipo de dispositivo.
abstract final class Breakpoints {
  /// Desde este ancho la agenda pasa de lista a grilla de 2 columnas.
  static const double medium = 600;

  /// Desde este ancho la grilla usa 3 columnas.
  static const double expanded = 840;
}

/// Ancho máximo cómodo para leer contenido de una sola columna.
const double maxReadableContentWidth = 720;

/// Columnas de la agenda para un ancho disponible.
int sessionColumnsFor(double availableWidth) {
  if (availableWidth >= Breakpoints.expanded) return 3;
  if (availableWidth >= Breakpoints.medium) return 2;
  return 1;
}
