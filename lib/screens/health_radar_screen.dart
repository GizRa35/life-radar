import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/health_alert.dart';
import '../state/app_state.dart';
import '../widgets/risk_badge.dart';

/// SAYFA 6 — SAĞLIK RADARI (Radar > Sağlık Riski drill-down)
class HealthRadarScreen extends StatelessWidget {
  const HealthRadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sağlık Radarı')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          for (final section in HealthSection.values) ...[
            _SectionHeader(section.label),
            ...state.healthAlertsBySection(section).map(
                  (a) => _HealthAlertCard(alert: a),
                ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: LifeRadarColors.navy,
        ),
      ),
    );
  }
}

class _HealthAlertCard extends StatelessWidget {
  final HealthAlert alert;
  const _HealthAlertCard({required this.alert});

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
                    alert.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: LifeRadarColors.textPrimary,
                    ),
                  ),
                ),
                RiskBadge(level: alert.risk, compact: true),
              ],
            ),
            const SizedBox(height: 12),
            _Field(label: 'Belirtiler', value: alert.symptoms),
            _Field(label: 'Risk Grubu', value: alert.riskGroup),
            _Field(label: 'Korunma Yolları', value: alert.prevention),
            _Field(label: 'Kaynaklar', value: alert.sources, isSource: true),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final bool isSource;
  const _Field({required this.label, required this.value, this.isSource = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSource
                  ? LifeRadarColors.turquoise
                  : LifeRadarColors.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: LifeRadarColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
