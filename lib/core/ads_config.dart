import 'package:flutter/foundation.dart';

/// AdMob reklam kimlikleri.
///
/// Şu an Google'ın RESMİ TEST kimlikleri kullanılıyor — gerçek reklam değil,
/// test reklamı gösterir (güvenli, hesap gerektirmez). Yayından önce kendi
/// AdMob hesabından alacağın gerçek kimliklerle değiştireceğiz.
class AdsConfig {
  AdsConfig._();

  // Uygulama kimliği (Info.plist / AndroidManifest'e de yazılır).
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';

  static String get bannerUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-3940256099942544/2934735716'
          : 'ca-app-pub-3940256099942544/6300978111';

  static String get interstitialUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712';
}
