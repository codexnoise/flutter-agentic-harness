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

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      title: json['title'] as String,
      speaker: json['speaker'] as String,
      track: json['track'] as String,
      time: json['time'] as String,
      room: json['room'] as String,
      level: json['level'] as String,
      lang: json['lang'] as String,
      illustrative: json['illustrative'] as bool? ?? false,
    );
  }

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
