import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/risk_area.dart';
import '../state/app_state.dart';
import '../widgets/risk_gauge.dart';
import '../widgets/risk_history_chart.dart';
import 'cities_screen.dart';
import 'crisis_radar_screen.dart';
import 'health_radar_screen.dart';
import 'risk_area_detail_screen.dart';

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
      case RiskAreaType.disaster:
      case RiskAreaType.travel:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RiskAreaDetailScreen(type: type),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Konum çubuğu — risk skoru bu konuma göre hesaplanır
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: LifeRadarColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: LifeRadarColors.turquoise, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Konumunuz',
                          style: TextStyle(
                              fontSize: 11,
                              color: LifeRadarColors.textSecondary)),
                      Text(
                        state.locationLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: LifeRadarColors.navy),
                      ),
                    ],
                  ),
                ),
                if (state.locating)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: LifeRadarColors.turquoise),
                  )
                else
                  TextButton.icon(
                    onPressed: () => context.read<AppState>().detectLocation(),
                    icon: const Icon(Icons.my_location, size: 16),
                    label: const Text('Güncelle'),
                    style: TextButton.styleFrom(
                        foregroundColor: LifeRadarColors.turquoise),
                  ),
              ],
            ),
          ),
        ),
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

        // Risk geçmişi grafiği (yeterli veri varsa)
        if (state.riskHistory.length >= 2) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'Risk Geçmişin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: LifeRadarColors.navy,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: RiskHistoryChart(data: state.riskHistory),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Takip edilen şehirler girişi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CitiesScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LifeRadarColors.turquoise.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: LifeRadarColors.turquoise.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city,
                      color: LifeRadarColors.turquoise),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Takip Edilen Şehirler',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: LifeRadarColors.navy,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          state.trackedCities.isEmpty
                              ? 'Memleketin/ailenin şehrini ekle'
                              : '${state.trackedCities.length} şehir takip ediliyor',
                          style: const TextStyle(
                              fontSize: 12,
                              color: LifeRadarColors.textSecondary),
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
