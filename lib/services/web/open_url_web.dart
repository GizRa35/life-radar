import 'dart:html' as html;
import 'dart:js_util' as js_util;

/// Linki yeni sekmede açar (web).
void openExternalUrl(String url) {
  html.window.open(url, '_blank');
}

/// İçeriği paylaşır: Web Share API varsa onu kullanır (mobil tarayıcılarda
/// yerel paylaşım menüsü), yoksa linki panoya kopyalar.
/// Dönüş: 'shared' | 'copied' | 'failed'.
Future<String> shareContentImpl(String title, String text, String url) async {
  try {
    final nav = html.window.navigator;
    final hasShare = js_util.hasProperty(nav, 'share');
    if (hasShare) {
      final data = js_util.jsify({
        'title': title,
        'text': text,
        'url': url,
      });
      await js_util.promiseToFuture(js_util.callMethod(nav, 'share', [data]));
      return 'shared';
    }
  } catch (_) {
    // Kullanıcı iptal etti veya desteklenmiyor → kopyalamaya düş.
  }
  try {
    final clip = '$text${url.isNotEmpty ? '\n$url' : ''}';
    await html.window.navigator.clipboard?.writeText(clip);
    return 'copied';
  } catch (_) {
    return 'failed';
  }
}
