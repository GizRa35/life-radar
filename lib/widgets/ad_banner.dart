import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:provider/provider.dart';

import '../core/ads_config.dart';
import '../models/subscription.dart';
import '../state/app_state.dart';

/// Alt banner reklam — yalnızca ÜCRETSİZ kullanıcıya gösterilir.
/// Premium ve VIP'te hiç banner yoktur (boş alan kaplamaz).
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _maybeLoad();
  }

  void _maybeLoad() {
    if (kIsWeb) return;
    // Yalnızca ücretsiz kullanıcıya banner.
    if (context.read<AppState>().tier != SubscriptionTier.free) return;
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: AdsConfig.bannerUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tier = context.watch<AppState>().tier;
    if (kIsWeb ||
        tier != SubscriptionTier.free ||
        !_loaded ||
        _ad == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: double.infinity,
      height: _ad!.size.height.toDouble(),
      child: Center(
        child: SizedBox(
          width: _ad!.size.width.toDouble(),
          height: _ad!.size.height.toDouble(),
          child: AdWidget(ad: _ad!),
        ),
      ),
    );
  }
}
