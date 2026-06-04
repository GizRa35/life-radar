import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/user_location.dart';
import 'geo/geo_locator.dart';

/// Konum tespiti.
///
/// Web'de önce tarayıcının hassas GPS konumunu dener (izin penceresi),
/// reddedilir/başarısız olursa IP tabanlı konuma düşer.
/// Tüm dış istekler aynı kökenli yerel proxy (serve.ps1) üzerinden gider.
class LocationService {
  static final String _ipProxy = '${ApiConfig.base}/api/geo';
  static final String _revGeoProxy = '${ApiConfig.base}/api/revgeo';
  static const String _ipDirect = 'https://ipapi.co/json/';

  Future<UserLocation?> detect() async {
    // 1) Tarayıcı GPS (en doğru)
    if (kIsWeb) {
      final coords = await getBrowserCoords();
      if (coords != null) {
        final precise = await _reverseGeocode(coords[0], coords[1]);
        if (precise != null) return precise;
        return UserLocation(city: 'Konumunuz', lat: coords[0], lng: coords[1]);
      }
    }
    // 2) IP tabanlı (yedek)
    return _ipGeo();
  }

  Future<UserLocation?> _reverseGeocode(double lat, double lng) async {
    final uri = Uri.parse(kIsWeb
        ? '$_revGeoProxy?lat=$lat&lng=$lng'
        : 'https://api.bigdatacloud.net/data/reverse-geocode-client'
            '?latitude=$lat&longitude=$lng&localityLanguage=tr');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return null;
      final d = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final city = (d['city'] ?? d['locality'] ?? '').toString();
      return UserLocation(
        city: city.isEmpty ? 'Konumunuz' : city,
        region: (d['region'] ?? d['principalSubdivision'] ?? '').toString(),
        country: (d['country_name'] ?? d['countryName'] ?? '').toString(),
        lat: lat,
        lng: lng,
      );
    } catch (_) {
      return null;
    }
  }

  Future<UserLocation?> _ipGeo() async {
    final uri = Uri.parse(kIsWeb ? _ipProxy : _ipDirect);
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return null;
      final d = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final city = (d['city'] ?? '').toString();
      if (city.isEmpty) return null;
      return UserLocation(
        city: city,
        region: (d['region'] ?? '').toString(),
        country: (d['country_name'] ?? '').toString(),
        lat: (d['latitude'] as num?)?.toDouble(),
        lng: (d['longitude'] as num?)?.toDouble(),
      );
    } catch (_) {
      return null;
    }
  }
}
