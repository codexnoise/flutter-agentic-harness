import 'package:devfest_agenda/data/models/session_api_model.dart';
import 'package:devfest_agenda/data/services/agenda_asset_service.dart';
import 'package:devfest_agenda/domain/models/session.dart';

Session fakeSession({
  required String id,
  String title = 'Charla',
  String track = 'Flutter',
  String time = '10:00',
  String level = 'Intro',
}) => Session(
  id: id,
  title: title,
  speaker: 'Speaker $id',
  track: track,
  time: time,
  room: 'Sala',
  level: level,
  lang: 'ES',
  illustrative: true,
);

SessionApiModel fakeApiModel({
  required String id,
  String title = 'Charla',
  String track = 'Flutter',
  String time = '10:00',
  String level = 'Intro',
}) => SessionApiModel(
  id: id,
  title: title,
  speaker: 'Speaker $id',
  track: track,
  time: time,
  room: 'Sala',
  level: level,
  lang: 'ES',
  illustrative: true,
);

/// Servicio falso: devuelve sesiones fijas y cuenta las llamadas.
class FakeAgendaAssetService extends AgendaAssetService {
  FakeAgendaAssetService(this.sessions);

  final List<SessionApiModel> sessions;
  int calls = 0;

  @override
  Future<List<SessionApiModel>> fetchSessions() async {
    calls++;
    return sessions;
  }
}
