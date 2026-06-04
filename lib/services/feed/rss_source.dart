import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../core/theme.dart';
import '../../models/event_category.dart';
import '../../models/radar_event.dart';

/// Birden çok güvenilir Türk kaynağından (Anadolu Ajansı, NTV, Google Haberler)
/// haber çeker; aynı/benzer başlıklı haberleri tekilleştirir.
/// Ayrıştırma sunucu proxy'sinde (serve.ps1 /api/rss) yapılır.
class RssSource {
  /// Kategori → besleme adresleri (çoklu kaynak).
  // Tüm kaynaklar doğrudan-linkli ve tam-metin çekilebilir (Google Haberler yok).
  static const Map<EventCategory, List<String>> _feeds = {
    // Dünya: Türkçe + ABD/Avrupa (Guardian-UK, Fox & NY Post-ABD)
    EventCategory.world: [
      'https://www.aa.com.tr/tr/rss/default?cat=dunya',
      'https://www.theguardian.com/world/rss',
      'https://moxie.foxnews.com/google-publisher/world.xml',
      'https://nypost.com/feed/',
    ],
    // Türkiye: AA + Hürriyet + Sözcü + En Son Haber
    EventCategory.turkey: [
      'https://www.aa.com.tr/tr/rss/default?cat=guncel',
      'https://www.hurriyet.com.tr/rss/gundem',
      'https://www.sozcu.com.tr/rss/tum-haberler.xml',
      'https://www.ensonhaber.com/rss/gundem.xml',
    ],
    EventCategory.economy: [
      'https://www.aa.com.tr/tr/rss/default?cat=ekonomi',
      'https://www.ntv.com.tr/ekonomi.rss',
    ],
    EventCategory.technology: [
      'https://www.ntv.com.tr/teknoloji.rss',
      'https://www.aa.com.tr/tr/rss/default?cat=bilim-teknoloji',
    ],
    // Sağlık: AA + NTV (TR) + Healthline + WHO + MedicineNet (EN, dünya devleri)
    EventCategory.health: [
      'https://www.aa.com.tr/tr/rss/default?cat=saglik',
      'https://www.ntv.com.tr/saglik.rss',
      'https://www.healthline.com/rss/health-news',
      'https://www.who.int/rss-feeds/news-english.xml',
      'https://www.medicinenet.com/rss/dailyhealth.xml',
    ],
    EventCategory.energy: [
      'https://www.hurriyet.com.tr/rss/ekonomi',
    ],
    // İklim: AA çevre (TR) + Guardian Climate + Carbon Brief + Earth.Org +
    // Grist + Inside Climate News (dünyanın en çok okunan iklim kaynakları)
    EventCategory.climate: [
      'https://www.aa.com.tr/tr/rss/default?cat=cevre',
      'https://www.theguardian.com/environment/climate-crisis/rss',
      'https://www.carbonbrief.org/feed/',
      'https://earth.org/feed/',
      'https://grist.org/feed/',
      'https://insideclimatenews.org/feed/',
    ],
    EventCategory.security: [
      'https://www.hurriyet.com.tr/rss/dunya',
    ],
    // Afet: küresel afet uyarı sistemi (BM/AB ortaklı GDACS). Depremler ayrıca
    // USGS'ten (EarthquakeSource) gerçek zamanlı çekilir.
    EventCategory.disaster: [
      'https://www.gdacs.org/xml/rss.xml',
    ],
  };

  static const Map<EventCategory, RiskLevel> _defaultRisk = {
    EventCategory.world: RiskLevel.medium,
    EventCategory.turkey: RiskLevel.medium,
    EventCategory.economy: RiskLevel.medium,
    EventCategory.technology: RiskLevel.low,
    EventCategory.health: RiskLevel.medium,
    EventCategory.energy: RiskLevel.high,
    EventCategory.climate: RiskLevel.medium,
    EventCategory.security: RiskLevel.high,
  };

  Future<List<RadarEvent>> fetchCategory(EventCategory category) async {
    final feeds = _feeds[category];
    if (feeds == null || !kIsWeb) return [];

    final all = <RadarEvent>[];
    for (final feed in feeds) {
      all.addAll(await _fetchFeed(feed, category));
    }
    return _dedupe(all);
  }

  Future<List<RadarEvent>> _fetchFeed(String feed, EventCategory category) async {
    final src = feed.contains('aa.com.tr')
        ? 'Anadolu Ajansı'
        : feed.contains('ntv.com.tr')
            ? 'NTV'
            : feed.contains('hurriyet.com.tr')
                ? 'Hürriyet'
                : feed.contains('sozcu.com.tr')
                    ? 'Sözcü'
                    : feed.contains('ensonhaber.com')
                        ? 'En Son Haber'
                        : feed.contains('theguardian.com')
                            ? 'The Guardian'
                            : feed.contains('foxnews.com')
                                ? 'Fox News'
                                : feed.contains('nypost.com')
                                    ? 'New York Post'
                                    : feed.contains('carbonbrief.org')
                                        ? 'Carbon Brief'
                                        : feed.contains('insideclimatenews.org')
                                            ? 'Inside Climate News'
                                            : feed.contains('earth.org')
                                                ? 'Earth.Org'
                                                : feed.contains('grist.org')
                                                    ? 'Grist'
                                                    : feed.contains('healthline.com')
                                                        ? 'Healthline'
                                                        : feed.contains('who.int')
                                                            ? 'WHO'
                                                            : feed.contains('medicinenet.com')
                                                                ? 'MedicineNet'
                                                                : feed.contains('gdacs.org')
                                                                    ? 'GDACS'
                                                                    : 'Haber Kaynağı';
    final isGoogle = feed.contains('news.google');
    // Türkçe kaynaklar yerli; geri kalan (Guardian, Fox, NY Post, Carbon Brief,
    // Earth.Org, Grist, Inside Climate, Healthline, WHO, MedicineNet, GDACS) İngilizce.
    final isTurkish = feed.contains('aa.com.tr') ||
        feed.contains('ntv.com.tr') ||
        feed.contains('hurriyet.com.tr') ||
        feed.contains('sozcu.com.tr') ||
        feed.contains('ensonhaber.com');
    final sourceLang = isTurkish ? 'tr' : 'en';
    final risk = _defaultRisk[category] ?? RiskLevel.medium;
    final uri = Uri.parse(
        '${ApiConfig.base}/api/rss?url=${Uri.encodeComponent(feed)}');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 18));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final items = (data['items'] as List?) ?? [];
      final now = DateTime.now();
      var i = 0;
      return items.map<RadarEvent>((raw) {
        final m = raw as Map;
        final link = (m['link'] ?? '').toString();
        final image = (m['image'] ?? '').toString();
        final summary = (m['summary'] ?? '').toString();
        final ev = RadarEvent(
          id: link.isNotEmpty ? link : '${category.name}-$src-${i}',
          title: (m['title'] ?? 'Başlıksız').toString(),
          summary: summary.isEmpty ? 'Detay için dokunun.' : summary,
          category: category,
          source: src,
          publishedAt: now.subtract(Duration(minutes: i)),
          risk: risk,
          url: link.isNotEmpty ? link : null,
          // Google Haberler logosunu gösterme (yönlendirme görseli).
          imageUrl:
              (!isGoogle && image.startsWith('http')) ? image : null,
          sourceLang: sourceLang,
        );
        i++;
        return ev;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ---- Tekilleştirme (aynı/benzer başlık tek kez) ----
  List<RadarEvent> _dedupe(List<RadarEvent> items) {
    final kept = <RadarEvent>[];
    final keptTokens = <Set<String>>[];
    final seenUrls = <String>{};

    for (final e in items) {
      if (e.url != null && !seenUrls.add(e.url!)) continue; // aynı link
      final tokens = _titleTokens(e.title);
      var duplicate = false;
      for (final kt in keptTokens) {
        if (_jaccard(tokens, kt) >= 0.5) {
          duplicate = true;
          break;
        }
      }
      if (duplicate) continue;
      kept.add(e);
      keptTokens.add(tokens);
    }
    // En güncelden başla, makul sayıda tut
    return kept.take(20).toList();
  }

  Set<String> _titleTokens(String title) {
    final norm = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zçğıöşü0-9 ]'), ' ');
    return norm
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 3 && !_stop.contains(w))
        .toSet();
  }

  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final inter = a.intersection(b).length;
    final uni = a.union(b).length;
    return inter / uni;
  }

  static const Set<String> _stop = {
    'için', 'ile', 'olan', 'oldu', 'daha', 'sonra', 'önce', 'bir', 'bu',
    'and', 'the', 'kişi', 'son', 'dakika',
  };
}
