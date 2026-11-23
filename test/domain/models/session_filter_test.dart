import 'package:devfest_agenda/domain/models/session_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_sessions.dart';

void main() {
  final cloudAi = fakeSession(
    id: 'cloud-ai',
    track: 'Cloud/AI',
    level: 'Avanzado',
  );
  final ai = fakeSession(id: 'ai', track: 'AI', level: 'Intro');
  final cloud = fakeSession(id: 'cloud', track: 'Cloud', level: 'Intermedio');
  final flutter = fakeSession(id: 'flutter', track: 'Flutter', level: 'Intro');
  final sessions = [cloudAi, ai, cloud, flutter];

  group('Session.tracks', () {
    test('separa un track compuesto en sus partes', () {
      expect(cloudAi.tracks, equals(['Cloud', 'AI']));
    });

    test('ignora espacios y partes vacías', () {
      expect(
        fakeSession(id: 'x', track: ' Web / Security /').tracks,
        equals(['Web', 'Security']),
      );
    });
  });

  group('SessionFilter', () {
    test('sin filtro devuelve todas las sesiones', () {
      expect(SessionFilter.none.isEmpty, isTrue);
      expect(SessionFilter.none.apply(sessions), equals(sessions));
    });

    test('un track compuesto "Cloud/AI" aparece al filtrar por AI', () {
      final result = const SessionFilter(track: 'AI').apply(sessions);
      expect(result, equals([cloudAi, ai]));
    });

    test('un track compuesto "Cloud/AI" aparece al filtrar por Cloud', () {
      final result = const SessionFilter(track: 'Cloud').apply(sessions);
      expect(result, equals([cloudAi, cloud]));
    });

    test('no confunde un track con un prefijo de otro', () {
      final result = const SessionFilter(track: 'Clo').apply(sessions);
      expect(result, isEmpty);
    });

    test('filtra por nivel', () {
      final result = const SessionFilter(level: 'Intro').apply(sessions);
      expect(result, equals([ai, flutter]));
    });

    test('combina track y nivel', () {
      final result = const SessionFilter(
        track: 'AI',
        level: 'Avanzado',
      ).apply(sessions);
      expect(result, equals([cloudAi]));
    });

    test('withTrack/withLevel conservan el otro criterio', () {
      final filter = SessionFilter.none.withTrack('AI').withLevel('Intro');
      expect(filter.track, 'AI');
      expect(filter.level, 'Intro');
      expect(filter.withTrack(null).level, 'Intro');
      expect(filter.withLevel(null).track, 'AI');
    });
  });

  group('tracksOf', () {
    test('devuelve tracks individuales, sin repetir y ordenados', () {
      expect(tracksOf(sessions), equals(['AI', 'Cloud', 'Flutter']));
    });

    test('lista vacía sin sesiones', () {
      expect(tracksOf(const []), isEmpty);
    });
  });

  group('levelsOf', () {
    test('ordena Intro, Intermedio, Avanzado', () {
      expect(levelsOf(sessions), equals(['Intro', 'Intermedio', 'Avanzado']));
    });

    test('pone niveles desconocidos al final, en orden alfabético', () {
      final withUnknown = [
        ...sessions,
        fakeSession(id: 'z', level: 'Zeta'),
        fakeSession(id: 'e', level: 'Experto'),
      ];
      expect(
        levelsOf(withUnknown),
        equals(['Intro', 'Intermedio', 'Avanzado', 'Experto', 'Zeta']),
      );
    });
  });
}
