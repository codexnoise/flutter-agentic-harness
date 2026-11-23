import 'package:devfest_agenda/data/repositories/agenda_repository.dart';
import 'package:devfest_agenda/ui/features/agenda/view_models/agenda_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_sessions.dart';

void main() {
  group('AgendaViewModel', () {
    late AgendaViewModel viewModel;
    late int notifications;

    setUp(() async {
      final service = FakeAgendaAssetService([
        fakeApiModel(id: 'cloud-ai', track: 'Cloud/AI', level: 'Avanzado'),
        fakeApiModel(id: 'flutter', track: 'Flutter', time: '11:00'),
      ]);
      viewModel = AgendaViewModel(
        repository: AgendaRepository(service: service),
      );
      await viewModel.load();
      notifications = 0;
      viewModel.addListener(() => notifications++);
    });

    test('load expone sesiones y facetas de filtro', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.sessions, hasLength(2));
      expect(viewModel.availableTracks, equals(['AI', 'Cloud', 'Flutter']));
      expect(viewModel.availableLevels, equals(['Intro', 'Avanzado']));
    });

    test('selectTrack filtra (track compuesto incluido) y notifica', () {
      viewModel.selectTrack('AI');
      expect(viewModel.filteredSessions.map((s) => s.id), ['cloud-ai']);
      expect(notifications, 1);

      viewModel.selectTrack(null);
      expect(viewModel.filteredSessions, hasLength(2));
    });

    test('toggleFavorite marca y desmarca una favorita', () {
      viewModel.toggleFavorite('flutter');
      expect(viewModel.isFavorite('flutter'), isTrue);
      expect(viewModel.favoriteSessions.map((s) => s.id), ['flutter']);

      viewModel.toggleFavorite('flutter');
      expect(viewModel.isFavorite('flutter'), isFalse);
      expect(viewModel.favoriteSessions, isEmpty);
      expect(notifications, 2);
    });

    test('Mi agenda respeta el orden de la agenda, no el de marcado', () {
      viewModel.toggleFavorite('flutter');
      viewModel.toggleFavorite('cloud-ai');
      expect(viewModel.favoriteSessions.map((s) => s.id), [
        'cloud-ai',
        'flutter',
      ]);
    });
  });
}
