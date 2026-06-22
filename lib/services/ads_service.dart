import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
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
      // iOS: reklam motorunu başlatmadan ÖNCE ATT iznini iste. İzin verilirse
      // kişiselleştirilmiş reklam + daha yüksek dolum; reddedilse de reklam
      // çıkar (kişiselleştirilmez). SKAdNetwork Info.plist'te tanımlı.
      await _requestTrackingIfNeeded();
      await MobileAds.instance.initialize();
      _ready = true;
      _loadInterstitial();
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> _requestTrackingIfNeeded() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      final status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // iOS sistem izin penceresini gösterir (Info.plist metniyle).
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (_) {
      // İzin alınamazsa reklamlar yine non-personalized olarak gösterilir.
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
