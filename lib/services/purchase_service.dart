import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/api_config.dart';
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
  /// [isNew] true ise yeni satın alma, false ise geri yükleme.
  void Function(SubscriptionTier tier, bool isNew)? onTierUnlocked;

  /// Bilgi/hata mesajı (UI'da göstermek için).
  void Function(String message)? onMessage;

  /// Mevcut kullanıcı kimliği (e-posta) — sunucu doğrulamasında kim abone
  /// bilgisini eşlemek için. app_state güncel e-postayı döndürür.
  String Function()? identity;

  Future<void> init({
    required void Function(SubscriptionTier, bool) onTier,
    void Function(String)? onMsg,
    String Function()? userIdentity,
  }) async {
    onTierUnlocked = onTier;
    onMessage = onMsg;
    identity = userIdentity;
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
          _handleValidPurchase(pd);
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

  Future<void> _handleValidPurchase(PurchaseDetails pd) async {
    final tier = (pd.productID == vipMonthly || pd.productID == vipYearly)
        ? SubscriptionTier.vip
        : SubscriptionTier.premium;
    final isNew = pd.status == PurchaseStatus.purchased;
    // Sunucu doğrulaması: makbuz/token'ı worker'a gönder. Açıkça GEÇERSİZ
    // dönerse (sahte) tier'ı AÇMA. Sunucuya ulaşılamazsa ödeme yapan
    // kullanıcıyı mağdur etmemek için yine açılır (sunucu sonradan teyit eder).
    final verdict = await _verifyOnServer(pd);
    if (verdict == false) {
      onMessage?.call('Satın alma doğrulanamadı. Destekle iletişime geç.');
      return;
    }
    onTierUnlocked?.call(tier, isNew);
    if (isNew) {
      onMessage?.call('Aboneliğin etkinleştirildi. Teşekkürler!');
    }
  }

  /// Worker'a satın almayı doğrulat. true=geçerli, false=GEÇERSİZ (sahte),
  /// null=sunucuya ulaşılamadı/karar yok (tier yine açılır).
  Future<bool?> _verifyOnServer(PurchaseDetails pd) async {
    if (ApiConfig.base.contains('localhost')) return null;
    try {
      final platform =
          defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      final res = await http
          .post(
            Uri.parse('${ApiConfig.base}/api/verify-purchase'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'platform': platform,
              'productId': pd.productID,
              'verificationData': pd.verificationData.serverVerificationData,
              'userId': identity?.call() ?? 'anon',
              'email': identity?.call() ?? '',
            }),
          )
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null; // karar yok
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return j['valid'] == true; // true/false net karar
    } catch (_) {
      return null; // ağ hatası → engelleme
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
