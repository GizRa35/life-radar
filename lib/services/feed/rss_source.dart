import 'dart:convert';
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
    // Dünya: Türkçe gazeteler + ABD/Avrupa/Orta Doğu
    EventCategory.world: [
      'https://www.aa.com.tr/tr/rss/default?cat=dunya',
      'https://www.ntv.com.tr/dunya.rss',
      'https://www.haberturk.com/rss/dunya.xml',
      'https://www.theguardian.com/world/rss',
      'https://moxie.foxnews.com/google-publisher/world.xml',
      'https://nypost.com/feed/',
      'https://www.aljazeera.com/xml/rss/all.xml',
      'https://rss.nytimes.com/services/xml/rss/nyt/World.xml',
      'https://feeds.washingtonpost.com/rss/world',
      'https://rss.politico.com/politics-news.xml',
      'https://www.reddit.com/r/worldnews/.rss',
    ],
    // Türkiye: AA + Hürriyet + Sözcü + En Son Haber + NTV + Habertürk +
    // TRT Haber + Cumhuriyet + Yeni Şafak + Halk TV + Odatv
    EventCategory.turkey: [
      'https://www.aa.com.tr/tr/rss/default?cat=guncel',
      'https://www.hurriyet.com.tr/rss/gundem',
      'https://www.sozcu.com.tr/rss/tum-haberler.xml',
      'https://www.ensonhaber.com/rss/gundem.xml',
      'https://www.ntv.com.tr/gundem.rss',
      'https://www.haberturk.com/rss/gundem.xml',
      'https://www.trthaber.com/sondakika.rss',
      'https://www.cumhuriyet.com.tr/rss/son_dakika.xml',
      'https://www.yenisafak.com/rss?xml=gundem',
      'https://halktv.com.tr/rss',
      'https://www.odatv.com/rss',
    ],
    EventCategory.economy: [
      'https://www.aa.com.tr/tr/rss/default?cat=ekonomi',
      'https://www.ntv.com.tr/ekonomi.rss',
      'https://www.haberturk.com/rss/ekonomi.xml',
      'https://www.dunya.com/rss',
      'https://www.cnbc.com/id/100003114/device/rss/rss.html',
      'https://www.forbes.com/business/feed/',
      'https://www.businessinsider.com/rss',
      'https://rss.nytimes.com/services/xml/rss/nyt/Business.xml',
    ],
    EventCategory.technology: [
      'https://www.ntv.com.tr/teknoloji.rss',
      'https://www.aa.com.tr/tr/rss/default?cat=bilim-teknoloji',
      'https://www.haberturk.com/rss/teknoloji.xml',
      'https://techcrunch.com/feed/',
      'https://news.ycombinator.com/rss',
      'https://rss.nytimes.com/services/xml/rss/nyt/Technology.xml',
      'https://www.donanimhaber.com/rss/tum/',
      'https://www.shiftdelete.net/feed',
    ],
    // Sağlık: AA + NTV + Habertürk (TR) + Healthline + WHO + MedicineNet (EN)
    EventCategory.health: [
      'https://www.aa.com.tr/tr/rss/default?cat=saglik',
      'https://www.ntv.com.tr/saglik.rss',
      'https://www.haberturk.com/rss/saglik.xml',
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
      'https://www.cnnturk.com/feed/rss/turkiye/news',
    ],
    // Afet: küresel afet uyarı sistemi (BM/AB ortaklı GDACS). Depremler ayrıca
    // USGS'ten (EarthquakeSource) gerçek zamanlı çekilir.
    EventCategory.disaster: [
      'https://www.gdacs.org/xml/rss.xml',
    ],
  };

  // Kaynak adı + dil eşlemesi (domain → görünen ad, Türkçe mi?).
  // İlk eşleşen kullanılır (sıra önemli: özel olanlar üstte).
  static const List<List<String>> _sourceMap = [
    ['aa.com.tr', 'Anadolu Ajansı', 'tr'],
    ['ntv.com.tr', 'NTV', 'tr'],
    ['hurriyet.com.tr', 'Hürriyet', 'tr'],
    ['sozcu.com.tr', 'Sözcü', 'tr'],
    ['ensonhaber.com', 'En Son Haber', 'tr'],
    ['haberturk.com', 'Habertürk', 'tr'],
    ['trthaber.com', 'TRT Haber', 'tr'],
    ['cumhuriyet.com.tr', 'Cumhuriyet', 'tr'],
    ['yenisafak.com', 'Yeni Şafak', 'tr'],
    ['dunya.com', 'Dünya', 'tr'],
    ['halktv.com.tr', 'Halk TV', 'tr'],
    ['odatv.com', 'Odatv', 'tr'],
    ['donanimhaber.com', 'DonanımHaber', 'tr'],
    ['shiftdelete.net', 'ShiftDelete', 'tr'],
    ['theguardian.com', 'The Guardian', 'en'],
    ['foxnews.com', 'Fox News', 'en'],
    ['nypost.com', 'New York Post', 'en'],
    ['aljazeera.com', 'Al Jazeera', 'en'],
    ['nytimes.com', 'The New York Times', 'en'],
    ['washingtonpost.com', 'The Washington Post', 'en'],
    ['politico.com', 'Politico', 'en'],
    ['cnbc.com', 'CNBC', 'en'],
    ['forbes.com', 'Forbes', 'en'],
    ['businessinsider.com', 'Business Insider', 'en'],
    ['techcrunch.com', 'TechCrunch', 'en'],
    ['ycombinator.com', 'Hacker News', 'en'],
    ['reddit.com', 'Reddit', 'en'],
    ['carbonbrief.org', 'Carbon Brief', 'en'],
    ['insideclimatenews.org', 'Inside Climate News', 'en'],
    ['earth.org', 'Earth.Org', 'en'],
    ['grist.org', 'Grist', 'en'],
    ['healthline.com', 'Healthline', 'en'],
    ['who.int', 'WHO', 'en'],
    ['medicinenet.com', 'MedicineNet', 'en'],
    ['gdacs.org', 'GDACS', 'en'],
  ];

  /// Uygulamada tanımlı tüm kaynak adları (Kaynak Seçimi ekranı için).
  /// Haber gelmese bile listede görünsünler diye kullanılır.
  static List<String> get configuredSourceNames {
    final set = <String>{for (final s in _sourceMap) s[1]};
    final list = set.toList()..sort();
    return list;
  }

  static ({String name, bool tr}) _srcInfo(String feed) {
    for (final s in _sourceMap) {
      if (feed.contains(s[0])) return (name: s[1], tr: s[2] == 'tr');
    }
    return (name: 'Haber Kaynağı', tr: false);
  }

  // Japonca/Çince/Korece karakter tespiti (bozuk/alakasız haberleri elemek için).
  static final RegExp _cjk = RegExp(
      '[　-〿぀-ヿ㐀-䶿一-鿿가-힯＀-￯]');
  static bool _hasCJK(String s) => _cjk.hasMatch(s);

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
    // RSS ayrıştırma worker proxy'sinde (/api/rss) yapılır; her platformda çalışır.
    if (feeds == null) return [];

    // Beslemeleri PARALEL çek (çok kaynak olsa da hız düşmesin).
    final results = await Future.wait(feeds.map((f) => _fetchFeed(f, category)));
    final all = results.expand((e) => e).toList();
    return _dedupe(all);
  }

  Future<List<RadarEvent>> _fetchFeed(String feed, EventCategory category) async {
    final info = _srcInfo(feed);
    final src = info.name;
    final isGoogle = feed.contains('news.google');
    final sourceLang = info.tr ? 'tr' : 'en';
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
      return items
          .where((raw) {
            // CJK (Japonca/Çince/Korece) içeren bozuk başlıkları ele.
            final t = ((raw as Map)['title'] ?? '').toString();
            return !_hasCJK(t);
          })
          .map<RadarEvent>((raw) {
        final m = raw as Map;
        final link = (m['link'] ?? '').toString();
        final image = (m['image'] ?? '').toString();
        final summary = (m['summary'] ?? '').toString();
        final ev = RadarEvent(
          id: link.isNotEmpty ? link : '${category.name}-$src-$i',
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
