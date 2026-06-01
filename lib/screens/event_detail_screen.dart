import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/action_item.dart';
import '../models/event_category.dart';
import '../models/impact_analysis.dart';
import '../models/radar_event.dart';
import '../state/app_state.dart';
import '../widgets/risk_badge.dart';

/// SAYFA 4 (Bu Beni Etkiler mi?) + SAYFA 5 (Ne Yapmalıyım?)
/// Bir habere tıklayınca açılan tam ekran analiz.
class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final RadarEvent? event = state.eventById(eventId);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Olay')),
        body: const Center(child: Text('Olay bulunamadı.')),
      );
    }

    final saved = state.isSaved(event.id);
    final timeStr = DateFormat('d MMMM yyyy, HH:mm', 'tr').format(event.publishedAt);
    final analysis = event.analysis;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Olay Analizi'),
        actions: [
          IconButton(
            tooltip: saved ? 'Kayıttan çıkar' : 'Kaydet',
            onPressed: () => context.read<AppState>().toggleSaved(event.id),
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
          ),
          IconButton(
            tooltip: 'Paylaş',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paylaşım yakında')),
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                ),
              ),
              const Spacer(),
              RiskBadge(level: event.risk),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: LifeRadarColors.navy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${event.source} · $timeStr',
            style: const TextStyle(
              color: LifeRadarColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            event.summary,
            style: const TextStyle(fontSize: 15, height: 1.45),
          ),
          const SizedBox(height: 24),

          if (analysis == null)
            _NoAnalysisCard()
          else ...[
            _ImpactSection(analysis: analysis),
            const SizedBox(height: 24),
            _ActionSection(analysis: analysis),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NoAnalysisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: LifeRadarColors.turquoise),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Bu olay için yapay zekâ etki analizi henüz hazırlanmadı. '
                'AI Asistanı butonundan bu haberi sorabilirsiniz.',
                style: TextStyle(color: LifeRadarColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// SAYFA 4 — Bu Beni Etkiler mi? (grafikli görünüm)
class _ImpactSection extends StatelessWidget {
  final ImpactAnalysis analysis;
  const _ImpactSection({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Bu Beni Etkiler mi?', icon: Icons.person_search),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etkilenme olasılığı (grafik)
                const Text(
                  'Etkilenme Olasılığı',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LifeRadarColors.navy,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: analysis.probability / 100,
                          minHeight: 12,
                          backgroundColor: LifeRadarColors.background,
                          valueColor:
                              AlwaysStoppedAnimation(analysis.risk.color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '%${analysis.probability}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: analysis.risk.color,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                _InfoRow(
                  icon: Icons.groups_outlined,
                  label: 'Kimler etkilenebilir',
                  value: analysis.affectedGroups,
                ),
                _InfoRow(
                  icon: Icons.flag_outlined,
                  label: 'Türkiye etkisi',
                  value: analysis.turkeyImpact,
                ),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Kişisel etkiler',
                  value: analysis.personalImpact,
                ),
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Etki süresi',
                  value: analysis.duration,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// SAYFA 5 — Ne Yapmalıyım? (Yapılacaklar / Yapılmayacaklar)
class _ActionSection extends StatelessWidget {
  final ImpactAnalysis analysis;
  const _ActionSection({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Ne Yapmalıyım?', icon: Icons.checklist_rtl),
        if (analysis.dos.isNotEmpty)
          _ActionList(
            title: 'YAPILACAKLAR',
            items: analysis.dos,
            color: LifeRadarColors.riskLow,
            icon: Icons.check_circle,
          ),
        if (analysis.donts.isNotEmpty)
          _ActionList(
            title: 'YAPILMAYACAKLAR',
            items: analysis.donts,
            color: LifeRadarColors.riskHigh,
            icon: Icons.cancel,
          ),
      ],
    );
  }
}

class _ActionList extends StatelessWidget {
  final String title;
  final List<ActionItem> items;
  final Color color;
  final IconData icon;
  const _ActionList({
    required this.title,
    required this.items,
    required this.color,
    required this.icon,
  });

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
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            ...items.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(a.text, style: const TextStyle(height: 1.3)),
                    ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: LifeRadarColors.turquoise),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: LifeRadarColors.navy,
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
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: LifeRadarColors.navy),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: LifeRadarColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
