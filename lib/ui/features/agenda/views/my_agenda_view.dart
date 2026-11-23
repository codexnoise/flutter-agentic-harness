import 'package:material_ui/material_ui.dart';

import 'package:devfest_agenda/ui/core/theme/google_colors.dart';
import 'package:devfest_agenda/ui/features/agenda/view_models/agenda_view_model.dart';
import 'package:devfest_agenda/ui/features/agenda/views/session_list.dart';

/// "Mi agenda": solo las sesiones marcadas como favoritas.
class MyAgendaView extends StatelessWidget {
  const MyAgendaView({super.key, required this.viewModel});

  final AgendaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final mine = viewModel.favoriteSessions;
        if (mine.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_outline_rounded,
                    size: 64,
                    color: GoogleColors.yellow,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Todavía no tienes sesiones favoritas.\n'
                    'Toca la estrella de una sesión para agregarla.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return SessionList(sessions: mine, viewModel: viewModel);
      },
    );
  }
}
