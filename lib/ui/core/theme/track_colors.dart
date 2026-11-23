import 'package:material_ui/material_ui.dart';

import 'package:devfest_agenda/ui/core/theme/google_colors.dart';

/// Reparte los 4 colores de Google en orden entre los tracks conocidos, para
/// que tracks distintos no terminen con el mismo color.
class TrackColors {
  TrackColors(List<String> tracks)
    : _byTrack = {
        for (var i = 0; i < tracks.length; i++)
          tracks[i]: GoogleColors.all[i % GoogleColors.all.length],
      };

  final Map<String, Color> _byTrack;

  /// El color asignado o, para un track desconocido, uno estable por hash.
  Color colorFor(String track) => _byTrack[track] ?? GoogleColors.forKey(track);

  static TrackColors of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<TrackColorsScope>();
    return scope?.colors ?? TrackColors(const []);
  }
}

class TrackColorsScope extends InheritedWidget {
  const TrackColorsScope({
    super.key,
    required this.colors,
    required super.child,
  });

  final TrackColors colors;

  @override
  bool updateShouldNotify(TrackColorsScope oldWidget) =>
      colors != oldWidget.colors;
}
