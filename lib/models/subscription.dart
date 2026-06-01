import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Abonelik katmanları.
enum SubscriptionTier { free, premium, vip }

extension SubscriptionTierMeta on SubscriptionTier {
  String get label {
    switch (this) {
      case SubscriptionTier.free:
        return 'Ücretsiz';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.vip:
        return 'VIP';
    }
  }

  Color get color {
    switch (this) {
      case SubscriptionTier.free:
        return LifeRadarColors.textSecondary;
      case SubscriptionTier.premium:
        return LifeRadarColors.turquoise;
      case SubscriptionTier.vip:
        return const Color(0xFFC9A227); // altın
    }
  }
}

/// Tek bir abonelik özelliği (başlık + açıklama + örnekler).
class PlanFeature {
  final String title;
  final String description;
  final List<String> examples;

  const PlanFeature({
    required this.title,
    this.description = '',
    this.examples = const [],
  });
}

/// Premium / VIP içerik tanımları + karşılaştırma tablosu verisi.
class SubscriptionData {
  SubscriptionData._();

  // ---- Fiyatlandırma (örnek; mağaza entegrasyonu Faz sonrası) ----
  static const String premiumMonthly = '₺149 / ay';
  static const String premiumYearly = '₺990 / yıl';
  static const String vipMonthly = '₺399 / ay';
  static const String vipYearly = '₺2.990 / yıl';
  static const String freeTrial = '7 Gün Ücretsiz Deneme';

  static const String premiumSubtitle =
      'Dünyadaki gelişmeleri sadece takip etmeyin, size etkilerini anlayın.';
  static const String vipSubtitle =
      'Riskleri sadece takip etmeyin. Önceden hazırlanın.';

  // ---- Premium özellikleri ----
  static const List<PlanFeature> premiumFeatures = [
    PlanFeature(
      title: 'Sınırsız Yapay Zekâ Soruları',
      description: 'Kullanıcı sınırsız soru sorabilir.',
      examples: [
        'Bu savaş beni etkiler mi?',
        'Bu ekonomik gelişme ne anlama geliyor?',
        'Bu sağlık haberi önemli mi?',
      ],
    ),
    PlanFeature(
      title: 'Kişisel Risk Analizi',
      description: 'AI kullanıcıya özel analiz oluşturur.',
      examples: [
        'Sağlık Riski',
        'Ekonomik Risk',
        'Afet Riski',
        'Seyahat Riski',
        'Enerji Riski',
      ],
    ),
    PlanFeature(
      title: 'Bölgesel Uyarılar',
      description: 'Bulunduğunuz şehir için bildirilir.',
      examples: [
        'Sağlık uyarıları',
        'Hava olayları',
        'Afet riskleri',
        'Acil durumlar',
      ],
    ),
    PlanFeature(
      title: 'Ne Yapmalıyım? Plus',
      description: 'Normal öneriler yerine daha detaylı aksiyon planları.',
    ),
    PlanFeature(
      title: 'Premium Haftalık Özet',
      description: 'Haftalık özetlenir.',
      examples: [
        'Dünya gündemi',
        'Türkiye gündemi',
        'Sağlık gelişmeleri',
        'Ekonomi gelişmeleri',
      ],
    ),
    PlanFeature(
      title: 'Reklamsız Deneyim',
      description: 'Tüm reklamlar kaldırılır.',
    ),
  ];

  // ---- VIP özellikleri ----
  static const List<PlanFeature> vipFeatures = [
    PlanFeature(
      title: 'Aile Koruma Merkezi',
      description: 'Eş, çocuk, anne, baba eklenebilir; AI aile üyeleri için '
          'özel analizler oluşturur.',
    ),
    PlanFeature(
      title: 'Kişisel AI Analisti',
      description: 'Sistem her gün otomatik analiz üretir.',
      examples: ['"Bugün sizi etkileyebilecek 3 önemli gelişme bulundu."'],
    ),
    PlanFeature(
      title: 'VIP İstihbarat Raporu',
      description: 'Haftalık PDF raporu.',
      examples: [
        'Dünya Gündemi',
        'Türkiye Gündemi',
        'Sağlık Riskleri',
        'Ekonomik Riskler',
        'Bölgesel Riskler',
        'Kişisel Risk Analizi',
      ],
    ),
    PlanFeature(
      title: 'Şehir Bazlı Risk Merkezi',
      description: 'Şehre özel analizler.',
      examples: [
        'Deprem Riski',
        'Yangın Riski',
        'Hava Kalitesi',
        'Su Durumu',
        'Sağlık Uyarıları',
      ],
    ),
    PlanFeature(
      title: 'Kişisel Acil Durum Planı',
      description: 'Aile yapısı, ev tipi ve şehir bilgisiyle özel hazırlık planı.',
    ),
    PlanFeature(
      title: 'Haber Doğrulama Sistemi',
      description: 'Link, ekran görüntüsü veya haber metni yüklenir; AI '
          'doğruluk, kaynak ve manipülasyon riski analizi yapar.',
    ),
    PlanFeature(
      title: 'VIP Erken Uyarı Merkezi',
      description: 'Kritik gelişmelerde öncelikli bildirim.',
      examples: [
        'Yeni salgın',
        'Şiddetli hava olayı',
        'Bölgesel afet',
        'Kritik ekonomik gelişme',
      ],
    ),
    PlanFeature(
      title: 'Gelişmiş Risk Skoru',
      description: 'AI aşağıdaki puanları oluşturur.',
      examples: [
        'Sağlık',
        'Finans',
        'Yaşam Alanı',
        'Aile Koruması',
        'Seyahat',
        'Küresel Risk',
        'Genel Risk Endeksi',
      ],
    ),
    PlanFeature(
      title: 'Öncelikli AI Sunucusu',
      description: 'Daha hızlı yanıtlar, öncelikli işlem.',
    ),
    PlanFeature(
      title: 'Gelecek Radarı',
      description: 'AI mevcut verileri analiz ederek olası riskler, dikkat '
          'edilmesi gereken trendler ve yaklaşan gelişmeler hakkında bilgi '
          'verir. Kesin tahmin veya kehanet yapılmaz.',
    ),
  ];

  // ---- Karşılaştırma tablosu ----
  static const List<String> freePlan = [
    'Günlük Haberler',
    'Temel Risk Analizi',
    'Günde 5 AI Sorusu',
  ];

  static const List<String> premiumPlan = [
    'Sınırsız AI',
    'Kişisel Risk Analizi',
    'Bölgesel Uyarılar',
    'Haftalık Özet',
    'Reklamsız Kullanım',
  ];

  static const List<String> vipPlan = [
    'Aile Koruma Merkezi',
    'Kişisel AI Analisti',
    'VIP İstihbarat Raporu',
    'Şehir Bazlı Risk Merkezi',
    'Haber Doğrulama',
    'Kişisel Acil Durum Planı',
    'Erken Uyarı Sistemi',
    'Gelişmiş Risk Skorları',
    'Öncelikli AI',
    'Gelecek Radarı',
  ];
}
