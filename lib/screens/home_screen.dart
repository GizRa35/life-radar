import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/event_category.dart';
import '../models/radar_event.dart';
import '../services/tts.dart';
import '../services/weather_service.dart';
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
    final followed = state.followedTopics.toList();

    // Son Dakika = TÜM konulardan en güncel haberler (takip filtresi uygulanmaz;
    // kişiselleştirme aşağıdaki "Öne Çıkan ..." bölümlerinde yapılır).
    // Böylece ana sayfa asla boş kalmaz.
    final shown = <String>{};
    final breaking = state.events.take(3).toList();
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoş Geldin, ${state.displayName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text('Sistemler aktif. Tarama yapılıyor.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                const _ScanningRadar(size: 48),
              ],
            ),
          ),
        ),
        if (state.loadingFeeds)
          const LinearProgressIndicator(
            color: LifeRadarColors.turquoise,
            backgroundColor: LifeRadarColors.cardBackground,
          ),

        // Hava durumu + Piyasa (döviz/altın)
        if (state.weather != null || state.rates != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            // IntrinsicHeight: iki kartı eşit boyda tutar VE ListView içinde
            // "sonsuz yükseklik" hatasını önler (aksi halde altındaki içerik
            // ekran dışına itiliyordu).
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.weather != null)
                    Expanded(child: _WeatherCard(data: state.weather!)),
                  if (state.weather != null && state.rates != null)
                    const SizedBox(width: 12),
                  if (state.rates != null)
                    Expanded(child: _MarketCard(data: state.rates!)),
                ],
              ),
            ),
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

/// Dönen tarama ışıklı radar logosu — "tarama yapılıyor" hissi verir.
class _ScanningRadar extends StatefulWidget {
  final double size;
  const _ScanningRadar({required this.size});

  @override
  State<_ScanningRadar> createState() => _ScanningRadarState();
}

class _ScanningRadarState extends State<_ScanningRadar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Taban daire
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LifeRadarColors.turquoise.withOpacity(0.15),
              border: Border.all(
                  color: LifeRadarColors.turquoise.withOpacity(0.4)),
            ),
          ),
          // Dönen tarama ışını (sweep gradyan)
          RotationTransition(
            turns: _c,
            child: ClipOval(
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      LifeRadarColors.turquoise.withOpacity(0.6),
                    ],
                    stops: const [0.0, 0.72, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Icon(Icons.radar,
              color: LifeRadarColors.turquoise, size: s * 0.58),
        ],
      ),
    );
  }
}

/// Anlık hava durumu + hava kalitesi kartı.
class _WeatherCard extends StatelessWidget {
  final Map<String, double?> data;
  const _WeatherCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final temp = data['temp'];
    final code = data['code']?.toInt() ?? 0;
    final aqi = data['aqi']?.toInt();
    final desc = weatherDesc(code);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LifeRadarColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(desc.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                temp == null ? '--' : '${temp.round()}°',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: LifeRadarColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc.label,
              style: const TextStyle(
                  fontSize: 13, color: LifeRadarColors.textSecondary)),
          if (aqi != null) ...[
            const SizedBox(height: 6),
            Text('Hava kalitesi: ${aqiLabel(aqi)}',
                style: const TextStyle(
                    fontSize: 12, color: LifeRadarColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Döviz/altın (TRY) kartı — canlı, yön oklu.
class _MarketCard extends StatelessWidget {
  final Map<String, double?> data;
  const _MarketCard({required this.data});

  String _fmt(double? v) {
    if (v == null) return '--';
    return '₺${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LifeRadarColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: LifeRadarColors.turquoise),
              SizedBox(width: 6),
              Text('Piyasa',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: LifeRadarColors.navy,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          _row('Dolar', _fmt(data['usd']), state.rateDir('usd')),
          _row('Euro', _fmt(data['eur']), state.rateDir('eur')),
          _row('Gram Altın', _fmt(data['gold']), state.rateDir('gold')),
        ],
      ),
    );
  }

  Widget _row(String label, String value, int dir) {
    final (icon, color) = dir > 0
        ? (Icons.arrow_drop_up, LifeRadarColors.riskLow)
        : dir < 0
            ? (Icons.arrow_drop_down, LifeRadarColors.riskHigh)
            : (Icons.remove, LifeRadarColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: LifeRadarColors.textSecondary)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: LifeRadarColors.navy)),
            ],
          ),
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
