import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';

/// Anlık hava durumu + hava kalitesi (worker /api/weather, Open-Meteo).
class WeatherService {
  Future<Map<String, double?>?> fetch(double lat, double lng) async {
    try {
      final uri = Uri.parse(
          '${ApiConfig.base}/api/weather?lat=$lat&lon=$lng');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      double? d(dynamic v) => (v as num?)?.toDouble();
      return {
        'temp': d(j['temp']),
        'code': d(j['code']),
        'wind': d(j['wind']),
        'humidity': d(j['humidity']),
        'aqi': d(j['aqi']),
        'pm25': d(j['pm25']),
      };
    } catch (_) {
      return null;
    }
  }
}

/// WMO hava kodu → Türkçe açıklama + ikon.
({String label, String emoji}) weatherDesc(int code) {
  if (code == 0) return (label: 'Açık', emoji: '☀️');
  if (code <= 2) return (label: 'Az bulutlu', emoji: '🌤️');
  if (code == 3) return (label: 'Bulutlu', emoji: '☁️');
  if (code <= 48) return (label: 'Sisli', emoji: '🌫️');
  if (code <= 57) return (label: 'Çiseleme', emoji: '🌦️');
  if (code <= 67) return (label: 'Yağmurlu', emoji: '🌧️');
  if (code <= 77) return (label: 'Karlı', emoji: '🌨️');
  if (code <= 82) return (label: 'Sağanak', emoji: '🌧️');
  if (code <= 86) return (label: 'Kar sağanağı', emoji: '🌨️');
  if (code <= 99) return (label: 'Gök gürültülü', emoji: '⛈️');
  return (label: 'Bilinmiyor', emoji: '🌡️');
}

/// Avrupa AQI → Türkçe seviye etiketi.
String aqiLabel(int aqi) {
  if (aqi <= 20) return 'Çok iyi';
  if (aqi <= 40) return 'İyi';
  if (aqi <= 60) return 'Orta';
  if (aqi <= 80) return 'Hassas';
  if (aqi <= 100) return 'Kötü';
  return 'Çok kötü';
}
