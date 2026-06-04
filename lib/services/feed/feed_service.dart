import '../../data/mock_data.dart';
import '../../models/event_category.dart';
import '../../models/radar_event.dart';
import 'earthquake_source.dart';
import 'rss_source.dart';

/// Tüm gerçek veri kaynaklarını toplayan servis.
///
/// - Afetler → USGS (gerçek zamanlı deprem)
/// - Diğer kategoriler → GDELT (Reuters/AP/BBC + Türkçe kaynaklar)
///
/// Herhangi bir kaynak başarısız olursa o kategori için mock veriye düşer
/// (uygulama her zaman dolu görünür).
class FeedService {
  final EarthquakeSource _earthquakes = EarthquakeSource();
  final RssSource _rss = RssSource();

  /// Tüm kategorileri çeker, tek liste döndürür.
  ///
  /// USGS eşzamanlı; GDELT istekleri ise hız limitine (429) takılmamak için
  /// kısa aralıklarla SIRAYLA yapılır.
  Future<List<RadarEvent>> loadEvents() async {
    final all = <RadarEvent>[];

    // Afetler — USGS (anlık başlat)
    final eqFuture = _earthquakes.fetch();

    // Haberler — doğrudan linkli kaynaklar (tam metin için): AA/NTV (RSS) +
    // GDELT (enerji/güvenlik). Tümü tekilleştirilmiş.
    for (final c in _newsCategories) {
      final list = await _rss.fetchCategory(c);
      all.addAll(_orFallback(list, c));
    }

    // Afet — USGS depremleri + GDACS küresel afet uyarıları (birleşik).
    final quakes = await eqFuture;
    final gdacs = await _rss.fetchCategory(EventCategory.disaster);
    final disaster = <RadarEvent>[...quakes, ...gdacs];
    all.addAll(_orFallback(disaster, EventCategory.disaster));

    all.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return all.isEmpty ? MockData.events : all;
  }

  static const List<EventCategory> _newsCategories = [
    EventCategory.world,
    EventCategory.turkey,
    EventCategory.health,
    EventCategory.economy,
    EventCategory.technology,
    EventCategory.energy,
    EventCategory.security,
    EventCategory.climate,
  ];

  /// Gerçek veri boşsa o kategoriye ait mock veriyle doldur.
  List<RadarEvent> _orFallback(List<RadarEvent> real, EventCategory category) {
    if (real.isNotEmpty) return real;
    return MockData.events.where((e) => e.category == category).toList();
  }
}
