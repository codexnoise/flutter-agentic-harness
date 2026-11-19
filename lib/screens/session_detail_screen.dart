import 'package:material_ui/material_ui.dart';

import '../models/session.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión'),
        actions: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: favorites,
            builder: (context, favoriteIds, _) {
              final isFavorite = favoriteIds.contains(session.id);
              return IconButton(
                tooltip: isFavorite
                    ? 'Quitar de Mi agenda'
                    : 'Agregar a Mi agenda',
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                color: isFavorite ? Colors.amber.shade700 : null,
                onPressed: () => onToggleFavorite(session),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(session.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(session.speaker, style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          _DetailRow(icon: Icons.schedule, label: 'Hora', value: session.time),
          _DetailRow(
            icon: Icons.place_outlined,
            label: 'Sala',
            value: session.room,
          ),
          _DetailRow(
            icon: Icons.label_outline,
            label: 'Track',
            value: session.track,
          ),
          _DetailRow(
            icon: Icons.signal_cellular_alt,
            label: 'Nivel',
            value: session.level,
          ),
          _DetailRow(
            icon: Icons.translate,
            label: 'Idioma',
            value: session.lang,
          ),
          if (session.illustrative) ...[
            const SizedBox(height: 24),
            Text(
              'Sesión de ejemplo: puede no corresponder a la agenda oficial.',
              style: theme.textTheme.bodySmall,
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
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
