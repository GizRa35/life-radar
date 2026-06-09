import 'package:flutter/foundation.dart';

/// AdMob reklam kimlikleri (GERÇEK — pub-5548072655592841 / Gizem Kiraz Kaya).
class AdsConfig {
  AdsConfig._();

  // Uygulama kimlikleri (Info.plist / AndroidManifest ile aynı olmalı).
  static const String androidAppId = 'ca-app-pub-5548072655592841~8455003848';
  static const String iosAppId = 'ca-app-pub-5548072655592841~2806552347';

  static String get bannerUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-5548072655592841/8797245628'
          : 'ca-app-pub-5548072655592841/4515758838';

  static String get interstitialUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-5548072655592841/3161775564'
          : 'ca-app-pub-5548072655592841/4623570046';
}
