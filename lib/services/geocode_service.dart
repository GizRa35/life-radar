import 'dart:convert';
import 'package:http/http.dart' as http;

/// Şehir arama sonucu (ad + koordinat).
class CityResult {
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lng;
  const CityResult({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lng,
  });

  String get label =>
      [name, if (region.isNotEmpty && region != name) region, country]
          .where((s) => s.isNotEmpty)
          .join(', ');
}

/// Şehir adından koordinat bulur (Open-Meteo Geocoding — ücretsiz, anahtarsız).
class GeocodeService {
  Future<List<CityResult>> search(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];
    final uri = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(q)}&count=8&language=tr&format=json',
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? [];
      return results
          .map((r) {
            final m = r as Map;
            return CityResult(
              name: (m['name'] ?? '').toString(),
              region: (m['admin1'] ?? '').toString(),
              country: (m['country'] ?? '').toString(),
              lat: (m['latitude'] as num?)?.toDouble() ?? 0,
              lng: (m['longitude'] as num?)?.toDouble() ?? 0,
            );
          })
          .where((c) => c.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
