/// Sesión de la agenda (modelo de dominio, inmutable).
class Session {
  const Session({
    required this.id,
    required this.title,
    required this.speaker,
    required this.track,
    required this.time,
    required this.room,
    required this.level,
    required this.lang,
    required this.illustrative,
  });

  final String id;
  final String title;
  final String speaker;

  /// Puede ser compuesto, por ejemplo `"Cloud/AI"`.
  final String track;

  /// Hora de inicio en formato `HH:mm`.
  final String time;
  final String room;
  final String level;
  final String lang;
  final bool illustrative;

  /// Tracks individuales: `"Cloud/AI"` -> `["Cloud", "AI"]`.
  List<String> get tracks =>
      track.split('/').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
}
