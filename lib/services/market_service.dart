import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';

/// Döviz/altın kurları (worker /api/rates → TRY cinsinden USD, EUR, gram altın).
class MarketService {
  Future<Map<String, double?>?> fetch() async {
    try {
      final uri = Uri.parse('${ApiConfig.base}/api/rates');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      double? d(dynamic v) => (v as num?)?.toDouble();
      return {
        'usd': d(j['usd']),
        'eur': d(j['eur']),
        'gold': d(j['gold']),
      };
    } catch (_) {
      return null;
    }
  }
}
