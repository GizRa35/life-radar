import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';

/// Kaynaktan çıkarılan haber içeriği.
class ArticleContent {
  final String text;
  final List<String> images;
  const ArticleContent(this.text, this.images);

  bool get isEmpty => text.isEmpty && images.isEmpty;
}

/// Haberin tam metnini ve görsellerini kaynaktan çeker (sunucu proxy üzerinden).
class ArticleService {
  Future<ArticleContent?> fetch(String url) async {
    // Çıkarma sunucu tarafında (worker) yapılır — hem web hem mobil çalışır.
    // Google Haberler yönlendirme linkleri gerçek haberi vermez (Google sayfası
    // döner) — çıkarmayı atla, özet + "tamamını oku" kullanılır.
    if (url.contains('news.google.')) return null;
    final uri = Uri.parse(
        '${ApiConfig.base}/api/article?url=${Uri.encodeComponent(url)}');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 35));
      if (res.statusCode != 200) return null;
      final d = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final text = (d['text'] ?? '').toString();
      final images =
          ((d['images'] as List?) ?? []).map((e) => e.toString()).toList();
      final content = ArticleContent(text, images);
      return content.isEmpty ? null : content;
    } catch (_) {
      return null;
    }
  }
}
