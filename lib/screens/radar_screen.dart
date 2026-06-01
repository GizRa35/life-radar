import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/risk_area.dart';
import '../state/app_state.dart';
import '../widgets/risk_gauge.dart';
import 'crisis_radar_screen.dart';
import 'health_radar_screen.dart';

/// SAYFA 3 — RADAR (uygulamanın en önemli ekranı)
/// Üstte kişisel risk puanı (0–100), altında 6 risk alanı.
/// Sağlık/Ekonomik/Enerji/Siber riskler ilgili drill-down ekranlarına gider.
class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  void _openDrillDown(BuildContext context, RiskAreaType type) {
    switch (type) {
      case RiskAreaType.health:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HealthRadarScreen()),
        );
        break;
      case RiskAreaType.economic:
      case RiskAreaType.energy:
      case RiskAreaType.cyber:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CrisisRadarScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type.label} detayı yakında')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Kişisel Risk Puanı
        Center(
          child: Column(
            children: [
              const Text(
                'Kişisel Risk Puanı',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: LifeRadarColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              RiskGauge(score: state.personalRiskScore),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Profilinize göre güncel genel risk seviyeniz. '
                  'Aşağıdaki alanlara dokunarak detayları görün.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: LifeRadarColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final area in state.riskAreas)
          _RiskAreaCard(
            area: area,
            onTap: () => _openDrillDown(context, area.type),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _RiskAreaCard extends StatelessWidget {
  final RiskArea area;
  final VoidCallback onTap;
  const _RiskAreaCard({required this.area, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = area.level.color;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(area.type.icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            area.type.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: LifeRadarColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${area.score}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: color,
                          ),
                        ),
                        const Text('/100',
                            style: TextStyle(
                                color: LifeRadarColors.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      area.description,
                      style: const TextStyle(
                        color: LifeRadarColors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.trending_flat,
                            size: 16, color: LifeRadarColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            area.expectedImpact,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: LifeRadarColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: LifeRadarColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
