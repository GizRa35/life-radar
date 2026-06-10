import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/ads_config.dart';
import '../models/subscription.dart';

/// AdMob reklam yönetimi — kademeli (ücretsiz çok / premium az / VIP hiç).
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool _ready = false;
  InterstitialAd? _interstitial;
  int _openCount = 0;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _ready = true;
      _loadInterstitial();
    } catch (_) {
      _ready = false;
    }
  }

  void _loadInterstitial() {
    if (kIsWeb || !_ready) return;
    InterstitialAd.load(
      adUnitId: AdsConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Tier'a göre tam ekran reklam sıklığı (kaç içerik açılışında bir).
  /// 0 = hiç gösterme.
  int _frequency(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.vip:
      case SubscriptionTier.premium:
        return 0; // Premium ve VIP: HİÇ reklam yok
      case SubscriptionTier.free:
        return 3; // Yalnızca ücretsiz: reklam
    }
  }

  /// İçerik açılışında çağrılır; sıklığa göre tam ekran reklam gösterir.
  void maybeShowInterstitial(SubscriptionTier tier) {
    if (kIsWeb) return;
    final freq = _frequency(tier);
    if (freq == 0) return; // VIP
    _openCount++;
    if (_openCount % freq != 0) return;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
    );
    ad.show();
    _interstitial = null;
  }
}
