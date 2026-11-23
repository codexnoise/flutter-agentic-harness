/// Una entrada tal como viene en `assets/devfest_agenda.json`.
class SessionApiModel {
  const SessionApiModel({
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

  factory SessionApiModel.fromJson(Map<String, dynamic> json) {
    return SessionApiModel(
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
  final String track;
  final String time;
  final String room;
  final String level;
  final String lang;
  final bool illustrative;
}
