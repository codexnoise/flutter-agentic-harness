import 'package:material_ui/material_ui.dart';

import '../models/session.dart';
import '../theme/google_colors.dart';
import '../widgets/google_branding.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({
    super.key,
    required this.session,
    required this.favorites,
    required this.onToggleFavorite,
  });

  final Session session;
  final ValueNotifier<Set<String>> favorites;
  final ValueChanged<Session> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = GoogleColors.forKey(session.tracks.first);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión'),
        bottom: const GoogleColorStrip(),
        actions: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: favorites,
            builder: (context, favoriteIds, _) {
              final isFavorite = favoriteIds.contains(session.id);
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
                onPressed: () => onToggleFavorite(session),
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
              color: GoogleColors.tint(accent),
              borderRadius: BorderRadius.circular(20),
              border: Border(left: BorderSide(color: accent, width: 6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final track in session.tracks)
                      ColorTag(label: track, color: GoogleColors.forKey(track)),
                    ColorTag(
                      label: session.level,
                      color: GoogleColors.forLevel(session.level),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  session.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  session.speaker,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: GoogleColors.ink(accent),
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
