import 'package:flutter/foundation.dart' show kIsWeb;

import 'api_config.dart';
import '../services/web/open_url_stub.dart'
    if (dart.library.html) '../services/web/open_url_web.dart';

/// Görsel ve link yardımcıları.
class Media {
  Media._();

  /// Web'de haber görselini CORS olmadan göstermek için yerel proxy'den geçirir.
  static String proxiedImage(String url) {
    if (kIsWeb) {
      return '${ApiConfig.base}/api/img?url=${Uri.encodeComponent(url)}';
    }
    return url;
  }

  /// Linki harici olarak açar (web'de yeni sekme).
  static void openUrl(String url) => openExternalUrl(url);

  /// İçeriği paylaşır (Web Share API ya da panoya kopyalama).
  /// Dönüş: 'shared' | 'copied' | 'failed'.
  static Future<String> share({
    required String title,
    required String text,
    String url = '',
  }) =>
      shareContentImpl(title, text, url);
}
