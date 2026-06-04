import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../core/theme.dart';
import '../../models/event_category.dart';
import '../../models/radar_event.dart';

/// GDELT 2.0 Document API — küresel + Türkçe haber taraması (anahtarsız).
/// Reuters, AP, BBC ve binlerce kaynağı tarar.
/// https://api.gdeltproject.org/api/v2/doc/doc
///
/// Not: Web'de CORS engeline takılabilir; mobilde sorunsuz çalışır.
class GdeltSource {
  /// Her kategori için Türkçe arama sorgusu (Türk kaynaklarına odaklı).
  static const Map<EventCategory, String> _queries = {
    EventCategory.world: 'dünya gündem sourcelang:turkish',
    EventCategory.turkey: 'türkiye sourcelang:turkish',
    EventCategory.health: 'sağlık sourcelang:turkish',
    EventCategory.economy: 'ekonomi sourcelang:turkish',
    EventCategory.technology: 'teknoloji sourcelang:turkish',
    EventCategory.energy: 'enerji sourcelang:turkish',
    EventCategory.security: 'güvenlik sourcelang:turkish',
    EventCategory.climate: 'iklim sourcelang:turkish',
  };

  /// Kategori için varsayılan risk (haber metninde risk verisi yok).
  static const Map<EventCategory, RiskLevel> _defaultRisk = {
    EventCategory.world: RiskLevel.medium,
    EventCategory.turkey: RiskLevel.medium,
    EventCategory.health: RiskLevel.medium,
    EventCategory.economy: RiskLevel.medium,
    EventCategory.technology: RiskLevel.low,
    EventCategory.energy: RiskLevel.high,
    EventCategory.security: RiskLevel.high,
    EventCategory.climate: RiskLevel.medium,
  };

  Future<List<RadarEvent>> fetchCategory(EventCategory category) async {
    final query = _queries[category];
    if (query == null) return [];

    // İki noktayı (sourcelang:turkish operatörü) koru; Uri.https bunu %3A'ya
    // çevirip GDELT sorgusunu bozuyordu.
    final encQuery = Uri.encodeComponent(query).replaceAll('%3A', ':');
    final gdeltUri = Uri.parse(
      'https://api.gdeltproject.org/api/v2/doc/doc'
      '?query=$encQuery&mode=artlist&format=json&maxrecords=12&sort=datedesc',
    );

    // Web'de CORS engelini aşmak için aynı kökenli (localhost:5151) yerel
    // proxy'ye git (serve.ps1 içindeki /api/gdelt). Mobilde doğrudan GDELT.
    final uri = kIsWeb
        ? Uri.parse(
            '${ApiConfig.base}/api/gdelt?query=${Uri.encodeComponent(query)}')
        : gdeltUri;

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 25));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final articles = (data['articles'] as List?) ?? [];
      final risk = _defaultRisk[category] ?? RiskLevel.medium;

      return articles.map<RadarEvent>((a) {
        final m = a as Map;
        final title = m['title']?.toString() ?? 'Başlıksız';
        final domain = m['domain']?.toString() ?? 'kaynak';
        final url = m['url']?.toString();
        final country = m['sourcecountry']?.toString() ?? '';
        final image = m['socialimage']?.toString();
        return RadarEvent(
          id: url ?? '$domain-$title',
          title: title,
          summary: 'Kaynak: $domain${country.isNotEmpty ? ' · $country' : ''}. '
              'Haberin tamamını okumak için dokunun.',
          category: category,
          source: domain,
          publishedAt: _parseGdeltDate(m['seendate']?.toString()),
          risk: risk,
          url: url,
          imageUrl: (image != null && image.startsWith('http')) ? image : null,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// GDELT tarihi: "20240601T120000Z" → DateTime.
  DateTime _parseGdeltDate(String? raw) {
    if (raw == null || raw.length < 15) return DateTime.now();
    try {
      final iso = '${raw.substring(0, 4)}-${raw.substring(4, 6)}-'
          '${raw.substring(6, 8)}T${raw.substring(9, 11)}:'
          '${raw.substring(11, 13)}:${raw.substring(13, 15)}Z';
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}
