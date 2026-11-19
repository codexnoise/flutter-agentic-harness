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
        _FilterPanel(
          children: [
            _ChipRow(
              label: 'Track',
              labelColor: GoogleColors.blue,
              options: _tracks,
              colorFor: GoogleColors.forKey,
              selected: _selectedTrack,
              onSelected: (v) => setState(() => _selectedTrack = v),
            ),
            _ChipRow(
              label: 'Nivel',
              labelColor: GoogleColors.red,
              options: _levels,
              colorFor: GoogleColors.forLevel,
              selected: _selectedLevel,
              onSelected: (v) => setState(() => _selectedLevel = v),
            ),
          ],
        ),
        const SizedBox(height: 6),
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
