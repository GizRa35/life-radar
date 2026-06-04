import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/theme.dart';
import '../../models/event_category.dart';
import '../../models/radar_event.dart';

/// USGS Earthquake API — gerçek zamanlı deprem verisi (anahtarsız, CORS uyumlu).
/// https://earthquake.usgs.gov/fdsnws/event/1/
class EarthquakeSource {
  static final Uri _uri = Uri.parse(
    'https://earthquake.usgs.gov/fdsnws/event/1/query'
    '?format=geojson&orderby=time&minmagnitude=4&limit=15',
  );

  Future<List<RadarEvent>> fetch() async {
    try {
      final res = await http.get(_uri).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (data['features'] as List?) ?? [];
      final events = <RadarEvent>[];
      for (final f in features) {
        final props = (f as Map)['properties'] as Map?;
        if (props == null) continue;
        final mag = (props['mag'] as num?)?.toDouble() ?? 0;
        final place = props['place']?.toString() ?? 'Bilinmeyen konum';
        final time = props['time'] as int?;
        final url = props['url']?.toString();
        events.add(RadarEvent(
          id: f['id']?.toString() ?? url ?? place,
          title: 'M${mag.toStringAsFixed(1)} deprem — $place',
          summary: 'USGS verisine göre $place bölgesinde büyüklüğü '
              '${mag.toStringAsFixed(1)} olan bir deprem kaydedildi.',
          category: EventCategory.disaster,
          source: 'USGS',
          publishedAt: time != null
              ? DateTime.fromMillisecondsSinceEpoch(time)
              : DateTime.now(),
          risk: _riskFromMagnitude(mag),
          url: url,
        ));
      }
      return events;
    } catch (_) {
      return [];
    }
  }

  RiskLevel _riskFromMagnitude(double mag) {
    if (mag >= 6) return RiskLevel.critical;
    if (mag >= 5) return RiskLevel.high;
    if (mag >= 4.5) return RiskLevel.medium;
    return RiskLevel.low;
  }

  /// Kullanıcının çevresindeki (300 km, son 30 gün) gerçek depremlerden
  /// 0-100 afet risk skoru üretir. Şehir değiştikçe skor değişir.
  Future<int> nearbyRiskScore(double lat, double lng) async {
    final start = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String()
        .split('T')
        .first;
    final uri = Uri.parse(
      'https://earthquake.usgs.gov/fdsnws/event/1/query'
      '?format=geojson&latitude=$lat&longitude=$lng&maxradiuskm=300'
      '&minmagnitude=2.5&starttime=$start&orderby=magnitude&limit=200',
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return 30;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (data['features'] as List?) ?? [];
      if (features.isEmpty) return 18; // çevrede son 30 günde belirgin deprem yok
      double maxMag = 0;
      for (final f in features) {
        final mag = ((f as Map)['properties']?['mag'] as num?)?.toDouble() ?? 0;
        if (mag > maxMag) maxMag = mag;
      }
      final count = features.length;
      // Maks. büyüklük ağırlıklı (0-70) + sıklık (0-30)
      final magPart = (maxMag / 7.0 * 70).clamp(0, 70);
      final countPart = (count.clamp(0, 60) / 60.0 * 30).clamp(0, 30);
      return (magPart + countPart).round().clamp(0, 100);
    } catch (_) {
      return 30;
    }
  }
}
