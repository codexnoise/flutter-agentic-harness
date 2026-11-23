import 'package:material_ui/material_ui.dart';

import 'package:devfest_agenda/domain/models/session.dart';
import 'package:devfest_agenda/ui/core/theme/google_colors.dart';
import 'package:devfest_agenda/ui/core/theme/track_colors.dart';
import 'package:devfest_agenda/ui/core/widgets/google_branding.dart';

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
    final trackColors = TrackColors.of(context);
    final accent = trackColors.colorFor(session.tracks.first);
    return Card(
      clipBehavior: Clip.antiAlias,
      color: GoogleColors.wash(accent, 0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(color: accent, child: const SizedBox(width: 8)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 4, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _TimeBadge(time: session.time, color: accent),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.place_rounded,
                            size: 16,
                            color: GoogleColors.ink(accent),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              session.room,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: GoogleColors.ink(accent),
                                fontWeight: FontWeight.w600,
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
                                : accent.withValues(alpha: 0.6),
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
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: GoogleColors.ink(accent),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              session.speaker,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF3C4043),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final track in session.tracks)
                            ColorTag(
                              label: track,
                              color: trackColors.colorFor(track),
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
  const _TimeBadge({required this.time, required this.color});

  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        time,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: GoogleColors.onColor(color),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
