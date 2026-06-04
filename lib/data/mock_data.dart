import '../core/theme.dart';
import '../models/action_item.dart';
import '../models/app_notification.dart';
import '../models/crisis_item.dart';
import '../models/emergency_guide.dart';
import '../models/event_category.dart';
import '../models/health_alert.dart';
import '../models/impact_analysis.dart';
import '../models/radar_event.dart';
import '../models/risk_area.dart';
import 'package:flutter/material.dart';

/// MVP için örnek (mock) veri. Faz 1+'de USGS/GDELT/Claude ile değiştirilecek.
class MockData {
  MockData._();

  static DateTime _ago(int hours) =>
      DateTime.now().subtract(Duration(hours: hours));

  // ---- Olaylar (Gündem + Ana Sayfa) ----
  static final List<RadarEvent> events = [
    RadarEvent(
      id: 'e1',
      title: 'Yeni grip varyantı birden fazla ülkede görüldü',
      summary:
          'Dünya Sağlık Örgütü, mevsimsel gripten daha hızlı yayılan yeni bir '
          'varyantı izlemeye aldığını bildirdi. Şimdilik vakalar hafif seyrediyor.',
      category: EventCategory.health,
      source: 'WHO / Reuters',
      publishedAt: _ago(2),
      risk: RiskLevel.medium,
      analysis: const ImpactAnalysis(
        probability: 45,
        affectedGroups:
            'Kronik hastalığı olanlar, 65 yaş üstü ve bağışıklığı düşük bireyler.',
        turkeyImpact:
            'Türkiye\'de henüz vaka bildirilmedi; sınır kapılarında izleme artırıldı.',
        personalImpact:
            'Profilinize göre doğrudan yüksek risk düşük; yine de temel hijyen önerilir.',
        duration: '4–8 hafta (mevsimsel seyir)',
        risk: RiskLevel.medium,
        actions: [
          ActionItem(text: 'Belirtileri öğren', isDo: true),
          ActionItem(text: 'Resmi sağlık duyurularını takip et', isDo: true),
          ActionItem(text: 'Risk grubundaysan doktora danış', isDo: true),
          ActionItem(text: 'Sosyal medya söylentilerine inanma', isDo: false),
          ActionItem(
              text: 'Doktor tavsiyesi olmadan ilaç kullanma', isDo: false),
        ],
      ),
    ),
    RadarEvent(
      id: 'e2',
      title: 'Altın fiyatları rekor seviyeye yükseldi',
      summary:
          'Küresel belirsizlik ve faiz beklentileri altının ons fiyatını tüm '
          'zamanların zirvesine taşıdı. Uzmanlar oynaklığın süreceğini söylüyor.',
      category: EventCategory.economy,
      source: 'Bloomberg / AP',
      publishedAt: _ago(5),
      risk: RiskLevel.medium,
      analysis: const ImpactAnalysis(
        probability: 60,
        affectedGroups: 'Tasarruf sahipleri, döviz/altın yatırımcıları, ithalatçılar.',
        turkeyImpact:
            'Gram altın ve döviz kurlarında dalgalanma görülebilir.',
        personalImpact:
            'Birikimlerinizin bir kısmı altında ise değer değişimi yaşayabilirsiniz.',
        duration: 'Belirsiz — haftalar sürebilir',
        risk: RiskLevel.medium,
        actions: [
          ActionItem(text: 'Bütçeni gözden geçir', isDo: true),
          ActionItem(text: 'Güvenilir finans kaynaklarını izle', isDo: true),
          ActionItem(
              text: 'Birikimini tek bir varlıkta toplama (çeşitlendir)',
              isDo: true),
          ActionItem(
              text: 'Panikle alım/satım yapma', isDo: false),
          ActionItem(
              text: '"Kesin kazandırır" iddialarına güvenme', isDo: false),
        ],
      ),
    ),
    RadarEvent(
      id: 'e3',
      title: 'Ege Denizi açıklarında 4.8 büyüklüğünde deprem',
      summary:
          'Sabah saatlerinde meydana gelen deprem çevre illerde hissedildi. '
          'İlk belirlemelere göre can veya mal kaybı bildirilmedi.',
      category: EventCategory.disaster,
      source: 'Resmi Afet Kurumu',
      publishedAt: _ago(8),
      risk: RiskLevel.low,
      analysis: const ImpactAnalysis(
        probability: 25,
        affectedGroups: 'Fay hattına yakın bölgelerde yaşayanlar.',
        turkeyImpact: 'Batı Anadolu\'da hafif hissedildi, hasar bildirilmedi.',
        personalImpact:
            'Konumunuza göre doğrudan risk düşük; deprem çantası hazırlığı önerilir.',
        duration: 'Anlık olay; artçılar birkaç gün sürebilir',
        risk: RiskLevel.low,
        actions: [
          ActionItem(text: 'Deprem çantanı kontrol et', isDo: true),
          ActionItem(text: 'Toplanma alanını öğren', isDo: true),
          ActionItem(text: 'Resmi açıklamaları bekle', isDo: true),
          ActionItem(text: 'Doğrulanmamış büyüklük iddialarını paylaşma', isDo: false),
        ],
      ),
    ),
    RadarEvent(
      id: 'e4',
      title: 'Bölgesel gerginlik enerji fiyatlarını tetikliyor',
      summary:
          'Komşu bölgelerdeki siyasi gerginlik petrol ve doğal gaz fiyatlarında '
          'artışa yol açtı. Tedarik zincirlerinde gecikme riski konuşuluyor.',
      category: EventCategory.energy,
      source: 'Reuters',
      publishedAt: _ago(12),
      risk: RiskLevel.high,
    ),
    RadarEvent(
      id: 'e5',
      title: 'Büyük teknoloji şirketinde veri sızıntısı iddiası',
      summary:
          'Milyonlarca kullanıcıyı etkilediği öne sürülen bir veri sızıntısı '
          'araştırılıyor. Şirket henüz resmi açıklama yapmadı.',
      category: EventCategory.technology,
      source: 'BBC',
      publishedAt: _ago(18),
      risk: RiskLevel.medium,
    ),
    RadarEvent(
      id: 'e6',
      title: 'Diplomatik görüşmeler yeniden başladı',
      summary:
          'Taraflar ateşkesi güçlendirmek için masaya döndü. Gözlemciler temkinli '
          'iyimser.',
      category: EventCategory.world,
      source: 'AP News',
      publishedAt: _ago(20),
      risk: RiskLevel.low,
    ),
    RadarEvent(
      id: 'e7',
      title: 'Meteoroloji aşırı sıcak uyarısı yaptı',
      summary:
          'Önümüzdeki günlerde mevsim normallerinin üzerinde sıcaklıklar bekleniyor. '
          'Kurumlar su tüketimi ve güneşten korunma konusunda uyardı.',
      category: EventCategory.climate,
      source: 'Resmi Meteoroloji',
      publishedAt: _ago(26),
      risk: RiskLevel.medium,
    ),
    RadarEvent(
      id: 'e8',
      title: 'Merkez Bankası faiz kararını açıkladı',
      summary:
          'Para Politikası Kurulu faiz oranına ilişkin kararını duyurdu. '
          'Piyasalar açıklamanın ardından dengelenme eğiliminde.',
      category: EventCategory.turkey,
      source: 'Anadolu Ajansı',
      publishedAt: _ago(3),
      risk: RiskLevel.medium,
    ),
    RadarEvent(
      id: 'e9',
      title: 'Ulaşımda yeni düzenleme yürürlüğe girdi',
      summary:
          'Şehirler arası ulaşımı etkileyen yeni düzenleme bugün itibarıyla '
          'uygulanmaya başlandı. Vatandaşların bilgilendirilmesi sürüyor.',
      category: EventCategory.turkey,
      source: 'TRT Haber',
      publishedAt: _ago(7),
      risk: RiskLevel.low,
    ),
    RadarEvent(
      id: 'e10',
      title: 'Kritik altyapıya yönelik siber saldırı girişimi engellendi',
      summary:
          'Yetkililer, kritik altyapıyı hedef alan bir siber saldırı girişiminin '
          'önlendiğini açıkladı. Kullanıcıların parolalarını güncellemesi öneriliyor.',
      category: EventCategory.security,
      source: 'Reuters',
      publishedAt: _ago(9),
      risk: RiskLevel.high,
    ),
    RadarEvent(
      id: 'e11',
      title: 'Sınır bölgesinde güvenlik önlemleri artırıldı',
      summary:
          'Bölgesel gelişmeler nedeniyle sınır hattında güvenlik tedbirleri '
          'yükseltildi. Resmi kaynaklar durumu yakından izliyor.',
      category: EventCategory.security,
      source: 'AP News',
      publishedAt: _ago(15),
      risk: RiskLevel.medium,
    ),
    RadarEvent(
      id: 'e12',
      title: 'Yapay zekâ alanında yeni model tanıtıldı',
      summary:
          'Teknoloji şirketleri, günlük hayatı etkilemesi beklenen yeni bir '
          'yapay zekâ modelini duyurdu. Uzmanlar olası etkileri değerlendiriyor.',
      category: EventCategory.technology,
      source: 'BBC',
      publishedAt: _ago(11),
      risk: RiskLevel.low,
    ),
  ];

  // ---- Radar (Sayfa 3) ----
  static const int personalRiskScore = 42;

  static const List<RiskArea> riskAreas = [
    RiskArea(
      type: RiskAreaType.health,
      score: 38,
      description: 'Mevsimsel hastalıklarda hafif artış izleniyor.',
      expectedImpact: 'Günlük yaşamı sınırlı etkiler; temel önlemler yeterli.',
    ),
    RiskArea(
      type: RiskAreaType.economic,
      score: 61,
      description: 'Döviz ve altında oynaklık, enflasyon baskısı sürüyor.',
      expectedImpact: 'Alım gücü ve birikimlerde dalgalanma olası.',
    ),
    RiskArea(
      type: RiskAreaType.disaster,
      score: 35,
      description: 'Bölgenizde sismik hareketlilik düşük-orta seviyede.',
      expectedImpact: 'Hazırlıklı olmak yeterli; acil tehdit yok.',
    ),
    RiskArea(
      type: RiskAreaType.energy,
      score: 72,
      description: 'Jeopolitik gerginlik enerji arzını baskılıyor.',
      expectedImpact: 'Yakıt ve faturalarda artış görülebilir.',
    ),
    RiskArea(
      type: RiskAreaType.cyber,
      score: 55,
      description: 'Büyük ölçekli veri sızıntısı haberleri artıyor.',
      expectedImpact: 'Hesap güvenliği için parola yenileme önerilir.',
    ),
    RiskArea(
      type: RiskAreaType.travel,
      score: 28,
      description: 'Başlıca güzergahlarda ciddi kısıtlama yok.',
      expectedImpact: 'Seyahat planları büyük ölçüde güvenli.',
    ),
  ];

  // ---- Sağlık Radarı (Sayfa 6) ----
  static const List<HealthAlert> healthAlerts = [
    HealthAlert(
      title: 'Yeni Grip Varyantı',
      section: HealthSection.newDiseases,
      symptoms: 'Ateş, boğaz ağrısı, halsizlik, kuru öksürük.',
      riskGroup: '65+ yaş, kronik hastalık, gebeler, bağışıklığı düşük olanlar.',
      prevention: 'El hijyeni, kalabalıkta maske, aşı, iyi havalandırma.',
      sources: 'WHO, CDC',
      risk: RiskLevel.medium,
    ),
    HealthAlert(
      title: 'Bölgesel Kızamık Salgını',
      section: HealthSection.outbreaks,
      symptoms: 'Yüksek ateş, döküntü, kızarık gözler.',
      riskGroup: 'Aşısız çocuklar ve yetişkinler.',
      prevention: 'KKK aşısı, vaka temasından kaçınma.',
      sources: 'WHO',
      risk: RiskLevel.high,
    ),
    HealthAlert(
      title: 'WHO Gıda Güvenliği Uyarısı',
      section: HealthSection.whoAlerts,
      symptoms: 'Bulantı, ishal, karın ağrısı.',
      riskGroup: 'Genel nüfus; özellikle çocuklar ve yaşlılar.',
      prevention: 'Gıdaları iyi pişir, sular için güvenilir kaynak kullan.',
      sources: 'WHO',
      risk: RiskLevel.low,
    ),
    HealthAlert(
      title: 'CDC Seyahat Sağlığı Notu',
      section: HealthSection.cdcAlerts,
      symptoms: 'Bölgeye özgü değişken.',
      riskGroup: 'Belirli bölgelere seyahat edenler.',
      prevention: 'Seyahat öncesi aşılar, sivrisinek koruması.',
      sources: 'CDC',
      risk: RiskLevel.low,
    ),
    HealthAlert(
      title: 'Güncellenmiş Aşı Önerisi',
      section: HealthSection.vaccineNews,
      symptoms: '—',
      riskGroup: 'Risk gruplarına güncel doz önerildi.',
      prevention: 'Resmi takvime göre aşı ol.',
      sources: 'Sağlık Bakanlığı, WHO',
      risk: RiskLevel.low,
    ),
  ];

  // ---- Kriz Radarı (Sayfa 7) ----
  static const List<CrisisItem> crisisItems = [
    CrisisItem(
      title: 'Enflasyon ve Kur Baskısı',
      section: CrisisSection.economic,
      score: 64,
      expectedImpact: 'Alım gücünde azalma, fiyatlarda dalgalanma.',
      recommendations: [
        'Bütçeni gözden geçir',
        'Gereksiz borçlanmadan kaçın',
        'Birikimini çeşitlendir',
      ],
    ),
    CrisisItem(
      title: 'Enerji Arz Riski',
      section: CrisisSection.energy,
      score: 71,
      expectedImpact: 'Yakıt ve elektrik maliyetlerinde artış.',
      recommendations: [
        'Enerji tüketimini optimize et',
        'Alternatif ısınma planı yap',
      ],
    ),
    CrisisItem(
      title: 'Tahıl Tedarik Sıkıntısı',
      section: CrisisSection.food,
      score: 48,
      expectedImpact: 'Bazı temel gıdalarda fiyat artışı olası.',
      recommendations: ['Temel gıda stoğunu makul tut', 'İsrafı azalt'],
    ),
    CrisisItem(
      title: 'Kuraklık ve Su Stresi',
      section: CrisisSection.water,
      score: 52,
      expectedImpact: 'Bazı bölgelerde su kısıtlaması riski.',
      recommendations: ['Su tasarrufu yap', 'Yerel uyarıları takip et'],
    ),
    CrisisItem(
      title: 'Bölgesel Jeopolitik Gerginlik',
      section: CrisisSection.geopolitical,
      score: 58,
      expectedImpact: 'Piyasa oynaklığı ve seyahat riskleri.',
      recommendations: ['Resmi seyahat uyarılarını izle'],
    ),
    CrisisItem(
      title: 'Artan Siber Saldırılar',
      section: CrisisSection.cyber,
      score: 60,
      expectedImpact: 'Hesap ve veri güvenliği riski.',
      recommendations: [
        'Parolalarını güçlendir',
        'İki adımlı doğrulama aç',
        'Şüpheli linklere tıklama',
      ],
    ),
  ];

  // ---- Acil Durum Rehberi (Sayfa 8) ----
  static const List<EmergencyGuide> guides = [
    EmergencyGuide(
      title: 'Deprem',
      icon: Icons.crisis_alert,
      preparation: [
        'Deprem çantası hazırla',
        'Eşyaları sabitle',
        'Toplanma alanını belirle',
        'Aile iletişim planı yap',
      ],
      first24Hours: [
        'Sarsıntıda çök-kapan-tutun',
        'Güvenliyse binadan çık',
        'Gaz ve elektriği kapat',
        'Resmi açıklamaları dinle',
      ],
      supplies: ['Su', 'Konserve gıda', 'İlk yardım çantası', 'El feneri', 'Düdük'],
      firstAid: [
        'Kanamayı baskı ile durdur',
        'Kırık şüphesinde hareket ettirme',
        'Bilinci kontrol et, gerekirse 112',
      ],
    ),
    EmergencyGuide(
      title: 'Sel',
      icon: Icons.water,
      preparation: [
        'Riskli bölgeyi öğren',
        'Değerli evrakları yükselt',
        'Tahliye rotası belirle',
      ],
      first24Hours: [
        'Yüksek yere çık',
        'Sel sularına girme',
        'Elektrikten uzak dur',
      ],
      supplies: ['Temiz su', 'Powerbank', 'Su geçirmez kılıf', 'İlk yardım'],
      firstAid: ['Hipotermiye dikkat', 'Yaraları temiz tut'],
    ),
    EmergencyGuide(
      title: 'Yangın',
      icon: Icons.local_fire_department_outlined,
      preparation: [
        'Duman dedektörü tak',
        'Yangın söndürücü bulundur',
        'Kaçış planı yap',
      ],
      first24Hours: [
        'Eğilerek dumandan kaç',
        'Kapı sıcaksa açma',
        '110\'u ara',
      ],
      supplies: ['Yangın söndürücü', 'Islak bez', 'El feneri'],
      firstAid: ['Yanığı soğuk suyla yıka', 'Su toplamış yanığı patlatma'],
    ),
    EmergencyGuide(
      title: 'Elektrik Kesintisi',
      icon: Icons.power_off_outlined,
      preparation: ['El feneri ve powerbank hazırla', 'Önemli cihazları şarj et'],
      first24Hours: ['Buzdolabını az aç', 'Mum yerine fener kullan'],
      supplies: ['Powerbank', 'Piller', 'El feneri', 'Radyo'],
      firstAid: ['Tıbbi cihaz kullananlar için yedek güç planı'],
    ),
    EmergencyGuide(
      title: 'Su Kesintisi',
      icon: Icons.water_drop_outlined,
      preparation: ['Birkaç günlük içme suyu depola', 'Su tasarrufu alışkanlığı'],
      first24Hours: ['Suyu önceliklendir (içme/temizlik)', 'Resmi duyuruyu izle'],
      supplies: ['Şişe su', 'Islak mendil', 'Dezenfektan'],
      firstAid: ['Dehidrasyon belirtilerine dikkat'],
    ),
    EmergencyGuide(
      title: 'Salgın Hastalık',
      icon: Icons.coronavirus_outlined,
      preparation: ['Maske ve dezenfektan bulundur', 'Aşıları güncel tut'],
      first24Hours: ['Belirti varsa izole ol', 'Resmi rehbere uy'],
      supplies: ['Maske', 'Dezenfektan', 'Ateş ölçer', 'Temel ilaçlar'],
      firstAid: ['Ateş ve nefes darlığında sağlık kuruluşuna başvur'],
    ),
    EmergencyGuide(
      title: 'Aşırı Hava Olayları',
      icon: Icons.thunderstorm_outlined,
      preparation: ['Uyarıları takip et', 'Dış mekan eşyalarını sabitle'],
      first24Hours: ['Kapalı alanda kal', 'Seyahati ertele'],
      supplies: ['Battaniye', 'El feneri', 'Radyo', 'Su'],
      firstAid: ['Hipotermi/sıcak çarpması belirtilerine dikkat'],
    ),
  ];

  // ---- Bildirimler (Sayfa 10) ----
  static final List<AppNotification> notifications = [
    AppNotification(
      title: 'Sağlık uyarısı: yeni grip varyantı',
      summary: 'WHO yeni bir varyantı izlemeye aldı.',
      time: _ago(1),
      category: NotificationCategory.health,
      risk: RiskLevel.medium,
    ),
    AppNotification(
      title: 'Altın rekor kırdı',
      summary: 'Ons altın yeni zirvede.',
      time: _ago(4),
      category: NotificationCategory.economy,
      risk: RiskLevel.medium,
    ),
    AppNotification(
      title: 'Ege\'de 4.8 deprem',
      summary: 'Hasar bildirilmedi.',
      time: _ago(8),
      category: NotificationCategory.disaster,
      risk: RiskLevel.low,
    ),
    AppNotification(
      title: 'Diplomatik görüşmeler başladı',
      summary: 'Taraflar masaya döndü.',
      time: _ago(20),
      category: NotificationCategory.world,
      risk: RiskLevel.low,
    ),
    AppNotification(
      title: 'Life Radar güncellendi',
      summary: 'Yeni risk analizi özellikleri eklendi.',
      time: _ago(30),
      category: NotificationCategory.system,
      risk: RiskLevel.low,
    ),
  ];

  // ---- Ana Sayfa metinleri ----
  static const String dailySummary =
      'Bugün gündemde ekonomik oynaklık ve bölgesel enerji riski öne çıkıyor. '
      'Sağlık tarafında izlenen yeni bir grip varyantı var ancak Türkiye için '
      'acil bir tehdit bulunmuyor.';

  static const String aiDailyAnalysis =
      'Profilinize göre bugün en dikkat etmeniz gereken alan ekonomik oynaklık. '
      'Birikimlerinizi çeşitlendirmek ve panik alım/satımdan kaçınmak makul. '
      'Sağlık ve afet riskleri şu an düşük seviyede.';

  static const int worldRiskIndex = 58; // Dünya Risk Endeksi
  static const int turkeyRiskIndex = 46; // Türkiye Risk Endeksi
}
