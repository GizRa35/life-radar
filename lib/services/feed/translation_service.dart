import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../../core/api_config.dart';

/// Sunucu proxy'si (serve.ps1 /api/translate) üzerinden ücretsiz çeviri.
/// Yabancı kaynaklı haberleri kullanıcının diline çevirmek için kullanılır.
class TranslationService {
  /// [texts] listesini [to] diline ('tr' veya 'en') çevirir.
  /// Hata olursa orijinal metinleri döndürür (uygulama hep dolu kalır).
  Future<List<String>> translate(List<String> texts, String to) async {
    if (texts.isEmpty || !kIsWeb) return texts;
    try {
      final uri = Uri.parse('${ApiConfig.base}/api/translate');
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'items': texts, 'to': to}),
          )
          .timeout(const Duration(seconds: 45));
      if (res.statusCode != 200) return texts;
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final items = (data['items'] as List?)?.map((e) => e.toString()).toList();
      if (items == null || items.length != texts.length) return texts;
      return items;
    } catch (_) {
      return texts;
    }
  }

  /// Tek bir metni çevirir (makale gövdesi için).
  Future<String> translateOne(String text, String to) async {
    if (text.trim().isEmpty) return text;
    final out = await translate([text], to);
    return out.isNotEmpty ? out.first : text;
  }
}
