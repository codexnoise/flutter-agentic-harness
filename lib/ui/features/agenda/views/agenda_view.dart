import 'package:material_ui/material_ui.dart';

import 'package:devfest_agenda/ui/core/theme/google_colors.dart';
import 'package:devfest_agenda/ui/core/theme/track_colors.dart';
import 'package:devfest_agenda/ui/features/agenda/view_models/agenda_view_model.dart';
import 'package:devfest_agenda/ui/features/agenda/views/session_list.dart';

/// Agenda completa con los filtros por track y por nivel.
class AgendaView extends StatelessWidget {
  const AgendaView({super.key, required this.viewModel});

  final AgendaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final trackColors = TrackColors.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final sessions = viewModel.filteredSessions;
        return Column(
          children: [
            _FilterPanel(
              children: [
                _ChipRow(
                  label: 'Track',
                  labelColor: GoogleColors.blue,
                  options: viewModel.availableTracks,
                  colorFor: trackColors.colorFor,
                  selected: viewModel.filter.track,
                  onSelected: viewModel.selectTrack,
                ),
                _ChipRow(
                  label: 'Nivel',
                  labelColor: GoogleColors.red,
                  options: viewModel.availableLevels,
                  colorFor: GoogleColors.forLevel,
                  selected: viewModel.filter.level,
                  onSelected: viewModel.selectLevel,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: sessions.isEmpty
                  ? const Center(
                      child: Text('No hay sesiones con esos filtros.'),
                    )
                  : SessionList(sessions: sessions, viewModel: viewModel),
            ),
          ],
        );
      },
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.label,
    required this.labelColor,
    required this.options,
    required this.colorFor,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Color labelColor;
  final List<String> options;
  final Color Function(String option) colorFor;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: GoogleColors.ink(labelColor),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(option),
                selected: option == selected,
                selectedColor: colorFor(option),
                backgroundColor: GoogleColors.wash(colorFor(option), 0.12),
                labelStyle: TextStyle(
                  color: option == selected
                      ? GoogleColors.onColor(colorFor(option))
                      : GoogleColors.ink(colorFor(option)),
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(
                  color: colorFor(option)
                      .withValues(alpha: option == selected ? 1 : 0.45),
                ),
                onSelected: (isSelected) =>
                    onSelected(isSelected ? option : null),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        child: Column(children: children),
      ),
    );
  }
}
