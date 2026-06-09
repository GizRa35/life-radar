import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_review/in_app_review.dart';

/// Mağaza içi puan/değerlendirme isteği (App Store / Google Play yerel diyalogu).
/// Web'de devre dışı; mağaza kotası dolu/uygun değilse sessizce geçer.
Future<void> requestStoreReview() async {
  if (kIsWeb) return;
  try {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    }
  } catch (_) {
    // Diyalog gösterilemezse sessizce geç.
  }
}
