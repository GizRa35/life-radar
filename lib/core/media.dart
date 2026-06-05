import 'api_config.dart';
import '../services/web/open_url_stub.dart'
    if (dart.library.html) '../services/web/open_url_web.dart';

/// Görsel ve link yardımcıları.
class Media {
  Media._();

  /// Haber görselini her platformda worker proxy'sinden geçirir.
  /// (Web'de CORS'u, mobilde "hotlink" engelini aşar + önbellekler.)
  static String proxiedImage(String url) {
    if (url.isEmpty) return url;
    return '${ApiConfig.base}/api/img?url=${Uri.encodeComponent(url)}';
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
