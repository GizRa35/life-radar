import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/theme.dart';
import '../models/crisis_item.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';

/// SAYFA 7 — KRİZ RADARI (Radar > Ekonomik/Enerji/Siber risk drill-down)
/// Gerçek haberler (GDELT) kriz bölümlerine ayrılarak gösterilir.
class CrisisRadarScreen extends StatelessWidget {
  const CrisisRadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final sections = [
      for (final s in CrisisSection.values)
        MapEntry(s, state.crisisEventsBySection(s)),
    ];
    final hasAny = sections.any((e) => e.value.isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: Text(t('Kriz Radarı'))),
      body: RefreshIndicator(
        color: LifeRadarColors.turquoise,
        onRefresh: () => context.read<AppState>().loadFeeds(),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            _SourceBanner(
              t('Ekonomi, enerji, gıda, su, jeopolitik ve siber kaynaklı güncel riskler (GDELT).'),
            ),
            if (!hasAny && state.loadingFeeds)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                      color: LifeRadarColors.turquoise),
                ),
              )
            else if (!hasAny)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(t('Şu an kriz sinyali bulunamadı.'),
                      style: const TextStyle(color: LifeRadarColors.textSecondary)),
                ),
              )
            else
              for (final entry in sections)
                if (entry.value.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                    child: Text(
                      t(entry.key.label),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: LifeRadarColors.navy,
                      ),
                    ),
                  ),
                  ...entry.value.map((e) => EventCard(event: e)),
                ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
