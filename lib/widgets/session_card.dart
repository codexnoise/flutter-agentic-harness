import 'package:material_ui/material_ui.dart';

import '../models/session.dart';
import '../theme/google_colors.dart';
import 'google_branding.dart';

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
    final accent = GoogleColors.forKey(session.tracks.first);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(color: accent, child: const SizedBox(width: 6)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 4, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _TimeBadge(time: session.time),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: Color(0xFF5F6368),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              session.room,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF5F6368),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: isFavorite
                                ? 'Quitar de Mi agenda'
                                : 'Agregar a Mi agenda',
                            icon: Icon(
                              isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                            ),
                            color: isFavorite
                                ? GoogleColors.yellow
                                : const Color(0xFF9AA0A6),
                            onPressed: onToggleFavorite,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          session.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF202124),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.speaker,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5F6368),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final track in session.tracks)
                            ColorTag(
                              label: track,
                              color: GoogleColors.forKey(track),
                            ),
                          ColorTag(
                            label: session.level,
                            color: GoogleColors.forLevel(session.level),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: GoogleColors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        time,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
