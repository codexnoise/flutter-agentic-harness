import 'package:material_ui/material_ui.dart';

import '../models/session.dart';
import '../theme/google_colors.dart';
import '../widgets/session_list.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({
    super.key,
    required this.sessions,
    required this.favorites,
    required this.onToggleFavorite,
  });

  final List<Session> sessions;
  final ValueNotifier<Set<String>> favorites;
  final ValueChanged<Session> onToggleFavorite;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  static const _levelOrder = ['Intro', 'Intermedio', 'Avanzado'];

  String? _selectedTrack;
  String? _selectedLevel;

  List<String> get _tracks =>
      widget.sessions.expand((s) => s.tracks).toSet().toList()..sort();

  List<String> get _levels {
    final levels = widget.sessions.map((s) => s.level).toSet().toList();
    int rank(String level) {
      final i = _levelOrder.indexOf(level);
      return i == -1 ? _levelOrder.length : i;
    }

    levels.sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.compareTo(b);
    });
    return levels;
  }

  List<Session> get _filtered => widget.sessions.where((s) {
    final trackOk = _selectedTrack == null || s.tracks.contains(_selectedTrack);
    final levelOk = _selectedLevel == null || s.level == _selectedLevel;
    return trackOk && levelOk;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      children: [
        _ChipRow(
          label: 'Track',
          options: _tracks,
          colorFor: GoogleColors.forKey,
          selected: _selectedTrack,
          onSelected: (v) => setState(() => _selectedTrack = v),
        ),
        _ChipRow(
          label: 'Nivel',
          options: _levels,
          colorFor: GoogleColors.forLevel,
          selected: _selectedLevel,
          onSelected: (v) => setState(() => _selectedLevel = v),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No hay sesiones con esos filtros.'))
              : SessionList(
                  sessions: filtered,
                  favorites: widget.favorites,
                  onToggleFavorite: widget.onToggleFavorite,
                ),
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.label,
    required this.options,
    required this.colorFor,
    required this.selected,
    required this.onSelected,
  });

  final String label;
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
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
          ),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(option),
                selected: option == selected,
                selectedColor: colorFor(option),
                labelStyle: TextStyle(
                  color: option == selected
                      ? GoogleColors.onColor(colorFor(option))
                      : null,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: option == selected
                      ? colorFor(option)
                      : const Color(0xFFDADCE0),
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
