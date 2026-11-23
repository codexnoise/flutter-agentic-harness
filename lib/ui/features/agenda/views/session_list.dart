import 'package:material_ui/material_ui.dart';

import 'package:devfest_agenda/domain/models/session.dart';
import 'package:devfest_agenda/ui/core/layout/breakpoints.dart';
import 'package:devfest_agenda/ui/core/widgets/session_card.dart';
import 'package:devfest_agenda/ui/features/agenda/view_models/agenda_view_model.dart';
import 'package:devfest_agenda/ui/features/session_detail/views/session_detail_screen.dart';

/// Sesiones con su estrella de favorita. Según el ancho disponible se
/// muestran en una lista de una columna o en una grilla de 2–3 columnas.
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = sessionColumnsFor(constraints.maxWidth);
        if (columns == 1) {
          return ListView.builder(
            key: const Key('session-list'),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: sessions.length,
            itemBuilder: (context, index) =>
                _buildCard(context, sessions[index]),
          );
        }
        return _SessionGrid(
          columns: columns,
          sessions: sessions,
          cardBuilder: _buildCard,
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, Session session) {
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
  }
}

/// Grilla que se construye por filas (de forma perezosa). Cada fila toma la
/// altura de su card más alta, así los títulos largos nunca desbordan, cosa
/// que una grilla de celdas de alto fijo no garantiza.
class _SessionGrid extends StatelessWidget {
  const _SessionGrid({
    required this.columns,
    required this.sessions,
    required this.cardBuilder,
  });

  final int columns;
  final List<Session> sessions;
  final Widget Function(BuildContext, Session) cardBuilder;

  @override
  Widget build(BuildContext context) {
    final rowCount = (sessions.length / columns).ceil();
    return ListView.builder(
      key: Key('session-grid-$columns'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: rowCount,
      itemBuilder: (context, row) {
        final start = row * columns;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = start; i < start + columns; i++)
                Expanded(
                  child: i < sessions.length
                      ? cardBuilder(context, sessions[i])
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        );
      },
    );
  }
}
