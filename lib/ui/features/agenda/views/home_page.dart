import 'package:material_ui/material_ui.dart';

import 'package:devfest_agenda/ui/core/theme/google_colors.dart';
import 'package:devfest_agenda/ui/core/widgets/google_branding.dart';
import 'package:devfest_agenda/ui/features/agenda/view_models/agenda_view_model.dart';
import 'package:devfest_agenda/ui/features/agenda/views/agenda_view.dart';
import 'package:devfest_agenda/ui/features/agenda/views/my_agenda_view.dart';

/// Pantalla principal con las pestañas Agenda y Mi agenda.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.viewModel});

  final AgendaViewModel viewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return Scaffold(
      appBar: AppBar(
        title: GoogleWordmark(
          'DevFest',
          suffix: _tabIndex == 0 ? 'Agenda' : 'Mi agenda',
        ),
        flexibleSpace: const GoogleBubblesBackground(),
        bottom: const GoogleColorStrip(height: 5),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.error != null) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return IndexedStack(
            index: _tabIndex,
            children: [
              AgendaView(viewModel: viewModel),
              MyAgendaView(viewModel: viewModel),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        indicatorColor: GoogleColors.tint(
          _tabIndex == 0 ? GoogleColors.blue : GoogleColors.yellow,
        ),
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note, color: GoogleColors.blue),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline_rounded),
            selectedIcon: Icon(Icons.star_rounded, color: GoogleColors.yellow),
            label: 'Mi agenda',
          ),
        ],
      ),
    );
  }
}
