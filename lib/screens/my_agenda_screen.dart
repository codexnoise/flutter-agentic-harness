import 'package:material_ui/material_ui.dart';

import '../models/session.dart';
import '../widgets/session_list.dart';

class MyAgendaScreen extends StatelessWidget {
  const MyAgendaScreen({
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
        final mine = sessions.where((s) => favoriteIds.contains(s.id)).toList();
        if (mine.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Todavía no tienes sesiones favoritas.\n'
                'Toca la estrella de una sesión para agregarla.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return SessionList(
          sessions: mine,
          favorites: favorites,
          onToggleFavorite: onToggleFavorite,
        );
      },
    );
  }
}
