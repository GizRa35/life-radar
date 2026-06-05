import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/api_config.dart';
import '../core/media.dart';
import '../core/theme.dart';
import 'ai_result_screen.dart';
import 'premium_screen.dart';
import '../models/action_item.dart';
import '../models/event_category.dart';
import '../models/impact_analysis.dart';
import '../models/radar_event.dart';
import '../services/article_service.dart';
import '../services/feed/translation_service.dart';
import '../state/app_state.dart';
import '../widgets/risk_badge.dart';

/// Kategoriye göre Pexels görsel arama kelimesi.
String _categoryQuery(EventCategory c) {
  switch (c) {
    case EventCategory.world:
      return 'world globe map';
    case EventCategory.turkey:
      return 'istanbul turkey';
    case EventCategory.health:
      return 'health medical hospital';
    case EventCategory.economy:
      return 'economy money market';
    case EventCategory.technology:
      return 'technology computer';
    case EventCategory.energy:
      return 'energy power plant';
    case EventCategory.security:
      return 'security cyber';
    case EventCategory.climate:
      return 'climate weather storm';
    case EventCategory.disaster:
      return 'natural disaster';
  }
}

/// SAYFA 4 (Bu Beni Etkiler mi?) + SAYFA 5 (Ne Yapmalıyım?)
/// Bir habere tıklayınca açılan tam ekran analiz.
class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ArticleService _articleService = ArticleService();
  final TranslationService _translator = TranslationService();
  Future<ArticleContent?>? _articleFuture;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final state = context.read<AppState>();
    final event = state.eventById(widget.eventId);
    final url = event?.url;
    // USGS deprem sayfaları JavaScript ile yüklenir; kazıma anlamsız "tarayıcı
    // desteği" metni döndürür. Bu kaynaklarda zengin özetimizi kullanırız.
    final isScrapeable = url != null &&
        !url.contains('earthquake.usgs.gov') &&
        !url.contains('/earthquakes/eventpage/');
    if (isScrapeable) {
      final base = _articleService.fetch(url);
      final userLang = state.userContext.language == 'en' ? 'en' : 'tr';
      // Kaynak orijinal dili kullanıcının dilinden farklıysa makale gövdesini çevir.
      if (event != null && event.sourceLang != userLang) {
        _articleFuture = base.then((c) async {
          if (c == null || c.text.isEmpty) return c;
          final t = await _translator.translateOne(c.text, userLang);
          return ArticleContent(t, c.images);
        });
      } else {
        _articleFuture = base;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final RadarEvent? event = state.eventById(widget.eventId);

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
            onPressed: () async {
              final res = await Media.share(
                title: event.title,
                text: '${event.title}\n\n${event.summary}\n\n(Life Radar)',
                url: event.url ?? '',
              );
              if (!context.mounted || res == 'shared') return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(res == 'copied'
                      ? 'Haber panoya kopyalandı.'
                      : 'Paylaşım yapılamadı.'),
                ),
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
          const SizedBox(height: 14),
          // Başlığın altında ana görsel. Habere ait görsel varsa onu, yoksa
          // kategoriye uygun bir görseli (Pexels) gösteririz.
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              event.imageUrl != null
                  ? Media.proxiedImage(event.imageUrl!)
                  : '${ApiConfig.base}/api/pexels?q=${Uri.encodeComponent(_categoryQuery(event.category))}',
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              loadingBuilder: (ctx, child, progress) => progress == null
                  ? child
                  : Container(
                      height: 210,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: LifeRadarColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const CircularProgressIndicator(
                          color: LifeRadarColors.turquoise),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // Bana özel, miktarlı aksiyon planı (AI) — haberin üstünde, Premium/VIP'e özel
          _ActionPlanButton(event: event),
          const SizedBox(height: 14),

          // Haberin tam metni + (en fazla 1 ek) görsel
          _ArticleSection(
            future: _articleFuture,
            fallbackSummary: event.summary,
            heroUrl: event.imageUrl,
          ),
          const SizedBox(height: 16),

          // Haberin tamamını kaynağında oku
          if (event.url != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Media.openUrl(event.url!),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text('Haberin tamamını oku (${event.source})'),
              ),
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

/// "Bana Özel Aksiyon Planı" — yalnızca Premium/VIP kullanıcılara açık.
/// Ücretsiz kullanıcıya kilitli görünür ve Premium ekranına yönlendirir.
class _ActionPlanButton extends StatelessWidget {
  final RadarEvent event;
  const _ActionPlanButton({required this.event});

  static const Color _gold = Color(0xFFC9A227);

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<AppState>().isPremium;

    if (premium) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AiResultScreen(
                title: 'Bana Özel Aksiyon Planı',
                icon: Icons.checklist_rtl,
                accent: LifeRadarColors.turquoise,
                subtitle: 'Hanene ve duruma özel hazırlık önerileri',
                imageQuery: _categoryQuery(event.category),
                run: (s) => s.vipActionPlan(event),
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          icon: const Icon(Icons.checklist_rtl, size: 18),
          label: const Text('Bana Özel Aksiyon Planı'),
        ),
      );
    }

    // Ücretsiz kullanıcı: kilitli premium kartı.
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [LifeRadarColors.navy, Color(0xFF123A63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gold.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock_outline, color: _gold),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.checklist_rtl,
                          color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text('Bana Özel Aksiyon Planı',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Hane halkına özel, miktarlı hazırlık önerileri. '
                    'Premium ve VIP üyelere özeldir.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Yükselt',
                  style: TextStyle(
                      color: LifeRadarColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Görsel URL'sini tekilleştirme için normalleştirir: sorgu/fragment atılır,
/// yeniden boyutlandırma varyantları (örn. -300x200, -scaled) sadeleştirilir.
/// Böylece aynı görselin farklı varyantları "aynı" sayılır.
String _imageKey(String url) {
  var s = url.toLowerCase().trim();
  final q = s.indexOf('?');
  if (q != -1) s = s.substring(0, q);
  final h = s.indexOf('#');
  if (h != -1) s = s.substring(0, h);
  s = s.replaceAll(
      RegExp(r'-\d{2,4}x\d{2,4}(?=\.(jpe?g|png|webp|gif|avif))'), '');
  s = s.replaceAll(
      RegExp(r'-(scaled|thumb|thumbnail|small|medium|large|wide)(?=\.(jpe?g|png|webp|gif|avif))'),
      '');
  return s;
}

/// Haberin tam metnini ve görsellerini gösterir; yüklenemezse özete düşer.
class _ArticleSection extends StatelessWidget {
  final Future<ArticleContent?>? future;
  final String fallbackSummary;
  final String? heroUrl;
  const _ArticleSection({
    required this.future,
    required this.fallbackSummary,
    this.heroUrl,
  });

  Widget _summary() => Text(
        fallbackSummary,
        style: const TextStyle(fontSize: 15, height: 1.45),
      );

  @override
  Widget build(BuildContext context) {
    if (future == null) return _summary();
    return FutureBuilder<ArticleContent?>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: LifeRadarColors.turquoise),
                ),
                SizedBox(width: 10),
                Text('Haberin tamamı yükleniyor...',
                    style: TextStyle(color: LifeRadarColors.textSecondary)),
              ],
            ),
          );
        }
        final c = snap.data;
        if (c == null) return _summary();
        // Aynı görsel iki kez görünmesin: hero ile ve kendi aralarında tekilleştir.
        // Toplam en fazla 2 görsel (hero + 1 ek, ya da hero yoksa 2 ek).
        final seen = <String>{};
        if (heroUrl != null && heroUrl!.isNotEmpty) {
          seen.add(_imageKey(heroUrl!));
        }
        final extra = <String>[];
        for (final u in c.images) {
          if (u.isEmpty) continue;
          if (seen.add(_imageKey(u))) extra.add(u);
        }
        final limit = heroUrl != null ? 1 : 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.text.isNotEmpty)
              Text(
                c.text,
                style: const TextStyle(fontSize: 15, height: 1.55),
              ),
            if (extra.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...extra.take(limit).map(
                    (img) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          Media.proxiedImage(img),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        );
      },
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
                'Bu olay için Life Radar Asistan etki analizi henüz hazırlanmadı. '
                'Life Radar Asistan butonundan bu haberi sorabilirsiniz.',
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
