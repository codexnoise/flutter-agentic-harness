import 'session.dart';

/// Orden de los niveles conocidos; los desconocidos van al final.
const knownLevelOrder = ['Intro', 'Intermedio', 'Avanzado'];

/// Filtro de la agenda por track y por nivel. `null` = sin filtro.
class SessionFilter {
  const SessionFilter({this.track, this.level});

  static const none = SessionFilter();

  final String? track;
  final String? level;

  bool get isEmpty => track == null && level == null;

  SessionFilter withTrack(String? track) =>
      SessionFilter(track: track, level: level);

  SessionFilter withLevel(String? level) =>
      SessionFilter(track: track, level: level);

  /// Una sesión con track compuesto (`"Cloud/AI"`) coincide con cada parte.
  bool matches(Session session) {
    final trackOk = track == null || session.tracks.contains(track);
    final levelOk = level == null || session.level == level;
    return trackOk && levelOk;
  }

  List<Session> apply(List<Session> sessions) =>
      sessions.where(matches).toList();
}

/// Tracks individuales presentes en [sessions], sin repetir y ordenados.
List<String> tracksOf(Iterable<Session> sessions) =>
    sessions.expand((s) => s.tracks).toSet().toList()..sort();

/// Niveles presentes en [sessions], en el orden de [knownLevelOrder].
List<String> levelsOf(Iterable<Session> sessions) {
  int rank(String level) {
    final i = knownLevelOrder.indexOf(level);
    return i == -1 ? knownLevelOrder.length : i;
  }

  return sessions.map((s) => s.level).toSet().toList()..sort((a, b) {
    final byRank = rank(a).compareTo(rank(b));
    return byRank != 0 ? byRank : a.compareTo(b);
  });
}
