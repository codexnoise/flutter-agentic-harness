import 'package:devfest_agenda/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('La app arranca y muestra la agenda', (tester) async {
    await tester.pumpWidget(const DevFestAgendaApp());
    await tester.pumpAndSettle();

    expect(find.text('DevFest Agenda', findRichText: true), findsOneWidget);
    expect(find.text('Mi agenda'), findsOneWidget);
  });
}
