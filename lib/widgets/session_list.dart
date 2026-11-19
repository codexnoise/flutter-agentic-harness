import 'package:material_ui/material_ui.dart';

import '../models/session.dart';
import '../screens/session_detail_screen.dart';
import 'session_card.dart';

/// Lista de una columna de sesiones con su estrella de favorita.
class SessionList extends StatelessWidget {
  const SessionList({
    super.key,
    required this.sessions,
    required this.favorites,
    required this.onToggleFavorite,
  });

  final List<Session> sessions;
  final ValueNotifier<Set<String>> favorites;
  final ValueChanged<Session> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favorites,
      builder: (context, favoriteIds, _) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return SessionCard(
              session: session,
              isFavorite: favoriteIds.contains(session.id),
              onToggleFavorite: () => onToggleFavorite(session),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SessionDetailScreen(
                    session: session,
                    favorites: favorites,
                    onToggleFavorite: onToggleFavorite,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
