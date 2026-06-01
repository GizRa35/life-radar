import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/event_category.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';

/// SAYFA 1 — ANA SAYFA
/// Amaç: kullanıcı 30 saniyede gündemi anlasın.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final health = state.eventsByCategory(EventCategory.health);
    final economy = state.eventsByCategory(EventCategory.economy);
    final breaking = state.events.take(3).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // Günün Özeti
        _SectionTitle('Günün Özeti', icon: Icons.today_outlined),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              state.dailySummary,
              style: const TextStyle(height: 1.4, fontSize: 15),
            ),
          ),
        ),

        // Risk Endeksleri
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RiskIndexCard(
                title: 'Dünya Risk Endeksi',
                score: state.worldRiskIndex,
              ),
            ),
            Expanded(
              child: _RiskIndexCard(
                title: 'Türkiye Risk Endeksi',
                score: state.turkeyRiskIndex,
              ),
            ),
          ],
        ),

        // AI Günlük Analizi
        const SizedBox(height: 8),
        _SectionTitle('Yapay Zekâ Günlük Analizi',
            icon: Icons.auto_awesome),
        Card(
          color: LifeRadarColors.navy,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome,
                    color: LifeRadarColors.turquoise),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.aiDailyAnalysis,
                    style: const TextStyle(color: Colors.white, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Son Dakika
        const SizedBox(height: 8),
        _SectionTitle('Son Dakika Gelişmeleri', icon: Icons.bolt),
        ...breaking.map((e) => EventCard(event: e, showActions: false)),

        // Öne çıkan sağlık
        if (health.isNotEmpty) ...[
          _SectionTitle('Öne Çıkan Sağlık Uyarıları',
              icon: Icons.health_and_safety_outlined),
          ...health.map((e) => EventCard(event: e, showActions: false)),
        ],

        // Öne çıkan ekonomi
        if (economy.isNotEmpty) ...[
          _SectionTitle('Öne Çıkan Ekonomik Gelişmeler',
              icon: Icons.trending_up),
          ...economy.map((e) => EventCard(event: e, showActions: false)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: LifeRadarColors.navy),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: LifeRadarColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskIndexCard extends StatelessWidget {
  final String title;
  final int score;
  const _RiskIndexCard({required this.title, required this.score});

  Color get _color {
    if (score >= 70) return LifeRadarColors.riskHigh;
    if (score >= 40) return LifeRadarColors.riskMedium;
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
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: LifeRadarColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _color,
                    ),
                  ),
                  const Text(' /100',
                      style: TextStyle(color: LifeRadarColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 6,
                backgroundColor: LifeRadarColors.background,
                valueColor: AlwaysStoppedAnimation(_color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
