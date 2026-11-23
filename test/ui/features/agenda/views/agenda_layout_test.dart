import 'package:devfest_agenda/data/repositories/agenda_repository.dart';
import 'package:devfest_agenda/main.dart';
import 'package:devfest_agenda/ui/core/layout/breakpoints.dart';
import 'package:devfest_agenda/ui/core/widgets/session_card.dart';
import 'package:devfest_agenda/ui/features/agenda/view_models/agenda_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/fake_sessions.dart';

const _longTitle = 'Creando Agentes IA en el navegador usando JavaScript';

Future<AgendaViewModel> _pumpApp(WidgetTester tester, double width) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  addTearDown(tester.view.reset);

  final viewModel = AgendaViewModel(
    repository: AgendaRepository(
      service: FakeAgendaAssetService([
        fakeApiModel(id: 'largo', title: _longTitle, track: 'AI/Web'),
        fakeApiModel(id: 'flutter', title: 'GenUI en Flutter', time: '10:20'),
        fakeApiModel(id: 'cloud', title: 'Cloud Run', track: 'Cloud/AI'),
        fakeApiModel(id: 'data', title: 'BigQuery', track: 'Data'),
      ]),
    ),
  );
  await viewModel.load();
  await tester.pumpWidget(DevFestAgendaApp(viewModel: viewModel));
  await tester.pumpAndSettle();
  return viewModel;
}

void main() {
  group('Layout de la agenda', () {
    testWidgets('pantalla angosta: lista de una columna', (tester) async {
      await _pumpApp(tester, Breakpoints.medium - 200);

      expect(find.byKey(const Key('session-list')), findsOneWidget);
      expect(find.byKey(const Key('session-grid-2')), findsNothing);
      expect(find.byKey(const Key('session-grid-3')), findsNothing);
      // El título largo (52 caracteres) no desborda.
      expect(find.text(_longTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pantalla media: grilla de 2 columnas', (tester) async {
      await _pumpApp(tester, Breakpoints.medium + 100);

      expect(find.byKey(const Key('session-grid-2')), findsOneWidget);
      expect(find.byKey(const Key('session-list')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pantalla ancha: grilla de 3 columnas', (tester) async {
      await _pumpApp(tester, Breakpoints.expanded + 200);

      expect(find.byKey(const Key('session-grid-3')), findsOneWidget);
      expect(find.byKey(const Key('session-list')), findsNothing);

      // Las 3 primeras cards comparten fila: misma coordenada vertical.
      final tops = tester
          .widgetList<SessionCard>(find.byType(SessionCard))
          .take(3)
          .map((card) => tester.getTopLeft(find.byWidget(card)).dy)
          .toSet();
      expect(tops, hasLength(1));
      expect(tester.takeException(), isNull);
    });
  });

  group('Favoritas', () {
    testWidgets('tocar la estrella marca la favorita y aparece en Mi agenda', (
      tester,
    ) async {
      final viewModel = await _pumpApp(tester, Breakpoints.medium - 200);

      final card = find.ancestor(
        of: find.text('GenUI en Flutter'),
        matching: find.byType(SessionCard),
      );
      final star = find.descendant(
        of: card,
        matching: find.byTooltip('Agregar a Mi agenda'),
      );
      expect(star, findsOneWidget);

      await tester.tap(star);
      await tester.pump();

      expect(viewModel.isFavorite('flutter'), isTrue);
      expect(
        find.descendant(of: card, matching: find.byIcon(Icons.star_rounded)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card,
          matching: find.byTooltip('Quitar de Mi agenda'),
        ),
        findsOneWidget,
      );

      // Mi agenda muestra solo la favorita.
      await tester.tap(find.text('Mi agenda'));
      await tester.pumpAndSettle();
      final myAgendaCards = find.byType(SessionCard).hitTestable();
      expect(myAgendaCards, findsOneWidget);
      expect(
        find.descendant(
          of: myAgendaCards,
          matching: find.text('GenUI en Flutter'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tocar de nuevo la estrella la desmarca', (tester) async {
      final viewModel = await _pumpApp(tester, Breakpoints.medium - 200);

      final star = find.byTooltip('Agregar a Mi agenda').first;
      await tester.tap(star);
      await tester.pump();
      await tester.tap(find.byTooltip('Quitar de Mi agenda'));
      await tester.pump();

      expect(viewModel.favoriteSessions, isEmpty);
      expect(find.byTooltip('Quitar de Mi agenda'), findsNothing);
    });
  });
}
