import 'package:devfest_agenda/data/repositories/agenda_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_sessions.dart';

void main() {
  group('AgendaRepository', () {
    late FakeAgendaAssetService service;
    late AgendaRepository repository;

    setUp(() {
      service = FakeAgendaAssetService([
        fakeApiModel(id: 'tarde', time: '15:00'),
        fakeApiModel(id: 'b', title: 'B', time: '09:25'),
        fakeApiModel(id: 'a', title: 'A', time: '09:25'),
        fakeApiModel(id: 'apertura', time: '09:00', track: 'Cloud/AI'),
      ]);
      repository = AgendaRepository(service: service);
    });

    test('ordena por hora y, si coincide, por título', () async {
      final sessions = await repository.getSessions();
      expect(
        sessions.map((s) => s.id),
        equals(['apertura', 'a', 'b', 'tarde']),
      );
    });

    test(
      'transforma al modelo de dominio conservando el track compuesto',
      () async {
        final first = (await repository.getSessions()).first;
        expect(first.track, 'Cloud/AI');
        expect(first.tracks, equals(['Cloud', 'AI']));
      },
    );

    test('guarda en caché: el servicio se consulta una sola vez', () async {
      await repository.getSessions();
      await repository.getSessions();
      expect(service.calls, 1);
    });
  });
}
