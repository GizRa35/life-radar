import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/crisis_item.dart';
import '../state/app_state.dart';

/// SAYFA 7 — KRİZ RADARI (Radar > Ekonomik/Enerji/Siber risk drill-down)
class CrisisRadarScreen extends StatelessWidget {
  const CrisisRadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Kriz Radarı')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          for (final section in CrisisSection.values) ...[
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
            ...state.crisisItemsBySection(section).map(
                  (c) => _CrisisCard(item: c),
                ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CrisisCard extends StatelessWidget {
  final CrisisItem item;
  const _CrisisCard({required this.item});

  Color get _color {
    if (item.score >= 70) return LifeRadarColors.riskHigh;
    if (item.score >= 40) return LifeRadarColors.riskMedium;
    return LifeRadarColors.riskLow;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: LifeRadarColors.textPrimary,
                    ),
                  ),
                ),
                // Risk Puanı
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Risk ${item.score}',
                    style: TextStyle(
                      color: _color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Beklenen Etki
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.insights_outlined,
                    size: 16, color: LifeRadarColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Beklenen etki: ${item.expectedImpact}',
                    style: const TextStyle(
                      color: LifeRadarColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Öneriler
            const Text(
              'Öneriler',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: LifeRadarColors.turquoise,
              ),
            ),
            const SizedBox(height: 4),
            ...item.recommendations.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: LifeRadarColors.riskLow),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
