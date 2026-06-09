import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/media.dart';
import '../core/theme.dart';
import '../models/event_category.dart';
import '../models/radar_event.dart';
import '../screens/event_detail_screen.dart';
import '../state/app_state.dart';
import 'cached_image.dart';
import 'risk_badge.dart';

/// Standart olay/haber kartı: Başlık · Özet · Kaynak · Saat · Risk · Detay/Paylaş/Kaydet.
class EventCard extends StatelessWidget {
  final RadarEvent event;

  /// Ana Sayfa'daki kompakt varyant aksiyon butonlarını gizler.
  final bool showActions;

  const EventCard({super.key, required this.event, this.showActions = true});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final saved = state.isSaved(event.id);
    final timeStr = DateFormat('d MMM, HH:mm', 'tr').format(event.publishedAt);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(event.category.icon, size: 18, color: event.category.color),
                  const SizedBox(width: 6),
                  Text(
                    event.category.label,
                    style: TextStyle(
                      color: event.category.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  RiskBadge(level: event.risk, compact: true),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: LifeRadarColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.summary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: LifeRadarColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (event.imageUrl != null) ...[
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedImage(
                        url: Media.proxiedImage(event.imageUrl!),
                        width: 86,
                        height: 86,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.verified_outlined,
                      size: 14, color: LifeRadarColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${event.source} · $timeStr',
                      style: const TextStyle(
                        color: LifeRadarColors.textSecondary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (showActions) ...[
                const Divider(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _openDetail(context),
                        icon: const Icon(Icons.insights_outlined, size: 18),
                        label: const Text('Detay Analizi'),
                        style: TextButton.styleFrom(
                          foregroundColor: LifeRadarColors.turquoise,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Paylaş',
                      onPressed: () async {
                        final res = await Media.share(
                          title: event.title,
                          text: '${event.title}\n\n${event.summary}\n\n(Life Radar)',
                          url: event.url ?? '',
                        );
                        if (!context.mounted || res == 'shared') return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res == 'copied'
                                ? 'Haber panoya kopyalandı.'
                                : 'Paylaşım yapılamadı.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_outlined,
                          color: LifeRadarColors.textSecondary),
                    ),
                    IconButton(
                      tooltip: saved ? 'Kayıttan çıkar' : 'Kaydet',
                      onPressed: () => context.read<AppState>().toggleSaved(event.id),
                      icon: Icon(
                        saved ? Icons.bookmark : Icons.bookmark_border,
                        color: saved
                            ? LifeRadarColors.turquoise
                            : LifeRadarColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
