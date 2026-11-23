import 'package:material_ui/material_ui.dart';

import 'package:devfest_agenda/domain/models/session.dart';
import 'package:devfest_agenda/ui/core/theme/google_colors.dart';
import 'package:devfest_agenda/ui/core/theme/track_colors.dart';
import 'package:devfest_agenda/ui/core/widgets/google_branding.dart';
import 'package:devfest_agenda/ui/features/agenda/view_models/agenda_view_model.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({
    super.key,
    required this.session,
    required this.viewModel,
  });

  final Session session;
  final AgendaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = TrackColors.of(context).colorFor(session.tracks.first);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión'),
        bottom: const GoogleColorStrip(),
        actions: [
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final isFavorite = viewModel.isFavorite(session.id);
              return IconButton(
                tooltip: isFavorite
                    ? 'Quitar de Mi agenda'
                    : 'Agregar a Mi agenda',
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                ),
                color: isFavorite
                    ? GoogleColors.yellow
                    : const Color(0xFF5F6368),
                iconSize: 28,
                onPressed: () => viewModel.toggleFavorite(session.id),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent, Color.lerp(accent, Colors.white, 0.3)!],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final label in [...session.tracks, session.level])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: GoogleColors.ink(accent),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  session.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: GoogleColors.onColor(accent),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  session.speaker,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: GoogleColors.onColor(accent),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.schedule,
                    color: GoogleColors.blue,
                    label: 'Hora',
                    value: session.time,
                  ),
                  _DetailRow(
                    icon: Icons.place_outlined,
                    color: GoogleColors.red,
                    label: 'Sala',
                    value: session.room,
                  ),
                  _DetailRow(
                    icon: Icons.label_outline,
                    color: GoogleColors.yellow,
                    label: 'Track',
                    value: session.track,
                  ),
                  _DetailRow(
                    icon: Icons.translate,
                    color: GoogleColors.green,
                    label: 'Idioma',
                    value: session.lang,
                  ),
                ],
              ),
            ),
          ),
          if (session.illustrative) ...[
            const SizedBox(height: 16),
            Text(
              'Sesión de ejemplo: puede no corresponder a la agenda oficial.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF5F6368),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: GoogleColors.tint(color),
        foregroundColor: GoogleColors.ink(color),
        child: Icon(icon, size: 20),
      ),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
