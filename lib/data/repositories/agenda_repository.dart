import '../../domain/models/session.dart';
import '../models/session_api_model.dart';
import '../services/agenda_asset_service.dart';

/// Fuente única de verdad de la agenda: devuelve sesiones de dominio
/// ordenadas por hora (y por título si coinciden) y las guarda en caché.
class AgendaRepository {
  AgendaRepository({required this._service});

  final AgendaAssetService _service;
  List<Session>? _cache;

  Future<List<Session>> getSessions() async {
    final cached = _cache;
    if (cached != null) return cached;

    final apiModels = await _service.fetchSessions();
    final sessions = apiModels.map(_toDomain).toList()
      ..sort((a, b) {
        final byTime = a.time.compareTo(b.time);
        return byTime != 0 ? byTime : a.title.compareTo(b.title);
      });
    return _cache = List.unmodifiable(sessions);
  }

  Session _toDomain(SessionApiModel m) => Session(
    id: m.id,
    title: m.title,
    speaker: m.speaker,
    track: m.track,
    time: m.time,
    room: m.room,
    level: m.level,
    lang: m.lang,
    illustrative: m.illustrative,
  );
}
