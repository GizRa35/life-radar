import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Web dışı (Android/iOS/masaüstü): gerçek link açma ve paylaşım.
void openExternalUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri != null) {
    // Hata olursa sessizce yut; UI akışını bozma.
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// İçeriği yerel paylaşım menüsüyle paylaşır. Dönüş: 'shared'.
Future<String> shareContentImpl(String title, String text, String url) async {
  final body = url.isNotEmpty ? '$text\n$url' : text;
  await Share.share(body, subject: title);
  return 'shared';
}
