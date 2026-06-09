import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/event_category.dart';
import '../models/radar_event.dart';
import '../services/tts.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

/// SAYFA 1 — ANA SAYFA
/// Amaç: kullanıcı 30 saniyede gündemi anlasın.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final active = state.activeTopics;
    final followed = state.followedTopics.toList();

    // Tekrarı önle: bir haber yalnızca tek bölümde görünsün.
    final shown = <String>{};
    final breaking =
        state.events.where((e) => active.contains(e.category)).take(3).toList();
    shown.addAll(breaking.map((e) => e.id));

    // Takip edilen her konu için "Öne Çıkan ..." bölümü: TEK haber + "Devamını
    // Görüntüle". Detay için Gündem'de ilgili kategoriye yönlendirir.
    final List<Widget> topicSections = [];
    for (final c in followed) {
      final list = state
          .eventsByCategory(c)
          .where((e) => !shown.contains(e.id))
          .toList();
      if (list.isEmpty) continue;
      final top = list.first;
      shown.add(top.id);
      topicSections.add(_SectionTitle('Öne Çıkan ${c.label}', icon: c.icon));
      topicSections.add(EventCard(event: top, showActions: false));
      topicSections.add(_ViewMoreButton(category: c));
    }

    return RefreshIndicator(
      color: LifeRadarColors.turquoise,
      onRefresh: () => context.read<AppState>().loadFeeds(),
      child: ListView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 90),
      children: [
        // Görsel karşılama başlığı
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LifeRadarColors.navy, Color(0xFF123A63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: LifeRadarColors.navy.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: LifeRadarColors.turquoise.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.radar,
                      color: LifeRadarColors.turquoise, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Life Radar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                      Text('Dünyayı Anla. Riskleri Gör. Hazırlıklı Ol.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.loadingFeeds)
          const LinearProgressIndicator(
            color: LifeRadarColors.turquoise,
            backgroundColor: LifeRadarColors.cardBackground,
          ),
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

        // Bugün seni ilgilendiren en önemli 3 gelişme
        if (state.topToday.isNotEmpty) ...[
          _SectionTitle('Bugün Öne Çıkanlar', icon: Icons.priority_high),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (final e in state.topToday) _TopTodayRow(event: e),
                ],
              ),
            ),
          ),
        ],

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
        _SectionTitle('Life Radar Asistan Günlük Analizi',
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

        // Sesli dinle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => speakText(state.aiDailyAnalysis),
                icon: const Icon(Icons.volume_up, size: 18),
                label: const Text('Sesli Dinle'),
              ),
              TextButton.icon(
                onPressed: stopSpeak,
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('Durdur'),
                style: TextButton.styleFrom(
                    foregroundColor: LifeRadarColors.textSecondary),
              ),
            ],
          ),
        ),

        // Son Dakika
        const SizedBox(height: 8),
        _SectionTitle('Son Dakika Gelişmeleri', icon: Icons.bolt),
        ...breaking.map((e) => EventCard(event: e, showActions: false)),

        // Takip edilen konulara göre öne çıkanlar (yoksa yönlendirme)
        if (followed.isEmpty) const _FollowHint() else ...topicSections,
        const SizedBox(height: 24),
      ],
      ),
    );
  }
}

/// "Bugün Öne Çıkanlar" kompakt satırı — risk rengi + başlık, dokununca detay.
class _TopTodayRow extends StatelessWidget {
  final RadarEvent event;
  const _TopTodayRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => EventDetailScreen(eventId: event.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: event.risk.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: LifeRadarColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: LifeRadarColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

/// "Devamını Görüntüle" — Gündem sekmesine geçip ilgili kategoriyi açar.
class _ViewMoreButton extends StatelessWidget {
  final EventCategory category;
  const _ViewMoreButton({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () =>
              context.read<AppState>().openAgendaCategory(category),
          icon: const Text('Devamını Görüntüle',
              style: TextStyle(fontWeight: FontWeight.w600)),
          label: const Icon(Icons.arrow_forward, size: 18),
          style: TextButton.styleFrom(
            foregroundColor: LifeRadarColors.turquoise,
          ),
        ),
      ),
    );
  }
}

class _FollowHint extends StatelessWidget {
  const _FollowHint();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.topic_outlined, color: LifeRadarColors.turquoise),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'İlgilendiğin konuları seçersen burada onların öne çıkan '
                'haberlerini gösteririz. Profil > Takip Edilen Konular\'dan seç.',
                style: TextStyle(color: LifeRadarColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
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
