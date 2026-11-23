import 'package:devfest_agenda/data/repositories/agenda_repository.dart';
import 'package:devfest_agenda/data/services/agenda_asset_service.dart';
import 'package:devfest_agenda/main.dart';
import 'package:devfest_agenda/ui/features/agenda/view_models/agenda_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('La app arranca y muestra la agenda', (tester) async {
    final viewModel = AgendaViewModel(
      repository: AgendaRepository(service: AgendaAssetService()),
    );
    await tester.pumpWidget(DevFestAgendaApp(viewModel: viewModel));
    await viewModel.load();
    await tester.pumpAndSettle();

    expect(find.text('DevFest Agenda', findRichText: true), findsOneWidget);
    expect(find.text('Mi agenda'), findsOneWidget);
  });
}
