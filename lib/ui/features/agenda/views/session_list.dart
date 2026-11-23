import 'package:material_ui/material_ui.dart';

import 'package:devfest_agenda/domain/models/session.dart';
import 'package:devfest_agenda/ui/core/widgets/session_card.dart';
import 'package:devfest_agenda/ui/features/agenda/view_models/agenda_view_model.dart';
import 'package:devfest_agenda/ui/features/session_detail/views/session_detail_screen.dart';

/// Lista de una columna de sesiones con su estrella de favorita.
class SessionList extends StatelessWidget {
  const SessionList({
    super.key,
    required this.sessions,
    required this.viewModel,
  });

  final List<Session> sessions;
  final AgendaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionCard(
          session: session,
          isFavorite: viewModel.isFavorite(session.id),
          onToggleFavorite: () => viewModel.toggleFavorite(session.id),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  SessionDetailScreen(session: session, viewModel: viewModel),
            ),
          ),
        );
      },
    );
  }
}
