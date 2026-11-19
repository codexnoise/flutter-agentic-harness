import 'package:material_ui/material_ui.dart';

import '../models/session.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final Session session;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.time,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(session.speaker, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${session.room} · ${session.track} · ${session.level}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Quitar de Mi agenda'
                    : 'Agregar a Mi agenda',
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                color: isFavorite ? Colors.amber.shade700 : null,
                onPressed: onToggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
