import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/event_category.dart';
import '../models/radar_event.dart';
import '../models/risk_area.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';
import '../widgets/risk_gauge.dart';

/// Radar drill-down — tek bir risk alanı (Afet, Seyahat vb.) için detay.
/// Risk göstergesi + ilgili güncel haberler + "Ne yapmalıyım?" önerileri.
class RiskAreaDetailScreen extends StatelessWidget {
  final RiskAreaType type;
  const RiskAreaDetailScreen({super.key, required this.type});

  /// Risk tipine göre çekilecek haber kategorileri (AppState.riskAreas ile uyumlu).
  List<EventCategory> get _categories {
    switch (type) {
      case RiskAreaType.disaster:
        return const [EventCategory.disaster];
      case RiskAreaType.travel:
        return const [EventCategory.world, EventCategory.security];
      case RiskAreaType.health:
        return const [EventCategory.health];
      case RiskAreaType.economic:
        return const [EventCategory.economy];
      case RiskAreaType.energy:
        return const [EventCategory.energy];
      case RiskAreaType.cyber:
        return const [EventCategory.technology, EventCategory.security];
    }
  }

  String get _sourceText {
    switch (type) {
      case RiskAreaType.disaster:
        return 'USGS (deprem) ve GDACS (küresel afet uyarı sistemi) verileri.';
      case RiskAreaType.travel:
        return 'Dünya gündemi ve güvenlik kaynaklarından seyahatinizi '
            'etkileyebilecek gelişmeler.';
      default:
        return 'Güncel ve güvenilir kaynaklardan haberler.';
    }
  }

  /// Tipe göre "Ne yapmalıyım?" önerileri.
  List<String> get _tips {
    switch (type) {
      case RiskAreaType.disaster:
        return const [
          'Deprem çantanızı (su, ilk yardım, fener, düdük, powerbank) hazır tutun.',
          'AFAD ve Kandilli Rasathanesi bildirimlerini açık tutun.',
          'Evde toplanma noktası ve tahliye planı belirleyin.',
          'Ağır eşyaları ve dolapları duvara sabitleyin.',
          'Acil durum için aile iletişim planı oluşturun.',
        ];
      case RiskAreaType.travel:
        return const [
          'Gideceğiniz bölgenin güncel güvenlik durumunu kontrol edin.',
          'Seyahat sağlık sigortanızı ve aşı gereksinimlerini gözden geçirin.',
          'Pasaport, vize ve kimlik kopyalarını dijital olarak saklayın.',
          'Dışişleri seyahat uyarılarını takip edin.',
          'Konaklama ve dönüş biletlerinizin esnek/iptal edilebilir olmasına dikkat edin.',
        ];
      default:
        return const [
          'Resmi kurum açıklamalarını takip edin.',
          'Doğrulanmamış bilgileri paylaşmayın.',
          'Gerekiyorsa hazırlık planınızı gözden geçirin.',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // İlgili haberleri topla (kategori birleşimi, tekilleştirilmiş, güncel sırada).
    final seen = <String>{};
    final events = <RadarEvent>[];
    for (final c in _categories) {
      for (final e in state.eventsByCategory(c)) {
        if (seen.add(e.id)) events.add(e);
      }
    }
    events.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    // Bu alanın risk skoru/açıklaması.
    final area = state.riskAreas.firstWhere(
      (a) => a.type == type,
      orElse: () => RiskArea(
        type: type,
        score: 30,
        description: 'Şu an bu alanda belirgin bir gelişme görünmüyor.',
        expectedImpact: 'Düşük: şu an acil bir etki beklenmiyor.',
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(type.label)),
      body: RefreshIndicator(
        color: LifeRadarColors.turquoise,
        onRefresh: () => context.read<AppState>().loadFeeds(),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // Risk göstergesi
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  RiskGauge(score: area.score),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      area.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: LifeRadarColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SourceBanner(_sourceText),

            // Ne yapmalıyım?
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                'Ne Yapmalıyım?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LifeRadarColors.navy,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final t in _tips)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle,
                                size: 18, color: LifeRadarColors.turquoise),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(t,
                                  style: const TextStyle(height: 1.35)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // İlgili haberler
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
              child: Text(
                'İlgili Gelişmeler',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LifeRadarColors.navy,
                ),
              ),
            ),
            if (events.isEmpty && state.loadingFeeds)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                      color: LifeRadarColors.turquoise),
                ),
              )
            else if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Şu an bu alanda gelişme bulunamadı.',
                      style: TextStyle(color: LifeRadarColors.textSecondary)),
                ),
              )
            else
              ...events.take(20).map((e) => EventCard(event: e)),
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
