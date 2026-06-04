import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/event_category.dart';
import '../models/health_alert.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';

/// SAYFA 6 — SAĞLIK RADARI (Radar > Sağlık Riski drill-down)
/// Gerçek sağlık haberleri (GDELT) bölümlere ayrılarak gösterilir.
class HealthRadarScreen extends StatelessWidget {
  const HealthRadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allHealth = state.eventsByCategory(EventCategory.health);

    return Scaffold(
      appBar: AppBar(title: const Text('Sağlık Radarı')),
      body: RefreshIndicator(
        color: LifeRadarColors.turquoise,
        onRefresh: () => context.read<AppState>().loadFeeds(),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            const _SourceBanner(
              'WHO, CDC ve sağlık kaynaklarından güncel haberler (GDELT).',
            ),
            if (allHealth.isEmpty && state.loadingFeeds)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                      color: LifeRadarColors.turquoise),
                ),
              )
            else if (allHealth.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('Şu an sağlık gelişmesi bulunamadı.',
                      style: TextStyle(color: LifeRadarColors.textSecondary)),
                ),
              )
            else
              for (final section in HealthSection.values)
                ..._buildSection(state, section),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSection(AppState state, HealthSection section) {
    final events = state.healthEventsBySection(section);
    if (events.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          section.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: LifeRadarColors.navy,
          ),
        ),
      ),
      ...events.map((e) => EventCard(event: e)),
    ];
  }
}

class _SourceBanner extends StatelessWidget {
  final String text;
  const _SourceBanner(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LifeRadarColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined,
              size: 18, color: LifeRadarColors.turquoise),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: LifeRadarColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
