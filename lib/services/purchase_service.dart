import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/subscription.dart';

/// App Store / Google Play abonelik satın alma servisi (Premium / VIP).
///
/// Ürün kimlikleri App Store Connect ve Google Play Console'da BİREBİR aynı
/// oluşturulmalıdır.
class PurchaseService {
  // ---- Ürün kimlikleri (store'da aynısı oluşturulacak) ----
  static const String premiumMonthly = 'liferadar_premium_monthly';
  static const String premiumYearly = 'liferadar_premium_yearly';
  static const String vipMonthly = 'liferadar_vip_monthly';
  static const String vipYearly = 'liferadar_vip_yearly';

  static const Set<String> _ids = {
    premiumMonthly,
    premiumYearly,
    vipMonthly,
    vipYearly,
  };

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  List<ProductDetails> products = [];
  bool available = false;

  /// Satın alma başarılı olunca çağrılır (tier'ı açmak için).
  void Function(SubscriptionTier tier)? onTierUnlocked;

  /// Bilgi/hata mesajı (UI'da göstermek için).
  void Function(String message)? onMessage;

  Future<void> init({
    required void Function(SubscriptionTier) onTier,
    void Function(String)? onMsg,
  }) async {
    onTierUnlocked = onTier;
    onMessage = onMsg;
    if (kIsWeb) return; // IAP yalnızca mobilde
    try {
      available = await _iap.isAvailable();
      if (!available) return;
      _sub = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (_) {},
      );
      await loadProducts();
      // Mevcut (aktif) abonelikleri geri yükle → tier'ı belirle.
      await _iap.restorePurchases();
    } catch (_) {
      available = false;
    }
  }

  Future<void> loadProducts() async {
    if (kIsWeb || !available) return;
    try {
      final resp = await _iap.queryProductDetails(_ids);
      products = resp.productDetails;
    } catch (_) {}
  }

  ProductDetails? product(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Fiyat metni (ör. "₺49,99") — store'dan gelir; yoksa boş.
  String priceOf(String id) => product(id)?.price ?? '';

  Future<void> buy(String id) async {
    if (kIsWeb) {
      onMessage?.call('Satın alma yalnızca mobil uygulamada kullanılabilir.');
      return;
    }
    if (!available) {
      onMessage?.call('Mağaza şu an kullanılamıyor. Daha sonra deneyin.');
      return;
    }
    final p = product(id);
    if (p == null) {
      onMessage?.call('Ürün bulunamadı. Lütfen daha sonra tekrar deneyin.');
      return;
    }
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: p),
      );
    } catch (e) {
      onMessage?.call('Satın alma başlatılamadı.');
    }
  }

  Future<void> restore() async {
    if (kIsWeb || !available) return;
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final pd in purchases) {
      switch (pd.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final tier = (pd.productID == vipMonthly || pd.productID == vipYearly)
              ? SubscriptionTier.vip
              : SubscriptionTier.premium;
          onTierUnlocked?.call(tier);
          if (pd.status == PurchaseStatus.purchased) {
            onMessage?.call('Aboneliğin etkinleştirildi. Teşekkürler!');
          }
          break;
        case PurchaseStatus.error:
          onMessage?.call('Satın alma başarısız oldu.');
          break;
        case PurchaseStatus.canceled:
          break;
        case PurchaseStatus.pending:
          break;
      }
      if (pd.pendingCompletePurchase) {
        _iap.completePurchase(pd);
      }
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
