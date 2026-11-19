import 'package:material_ui/material_ui.dart';

import '../models/session.dart';
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
          selected: _selectedTrack,
          onSelected: (v) => setState(() => _selectedTrack = v),
        ),
        _ChipRow(
          label: 'Nivel',
          options: _levels,
          selected: _selectedLevel,
          onSelected: (v) => setState(() => _selectedLevel = v),
        ),
        const Divider(height: 1),
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
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
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
                onSelected: (isSelected) =>
                    onSelected(isSelected ? option : null),
              ),
            ),
        ],
      ),
    );
  }
}
