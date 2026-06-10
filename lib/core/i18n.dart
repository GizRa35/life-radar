/// Basit yerelleştirme (i18n).
///
/// Türkçe metni doğrudan anahtar olarak kullanır; aktif dil 'en' ise
/// karşılığını döndürür, yoksa Türkçe metni aynen verir (asla boş kalmaz).
///
/// Kullanım: Text(t('Ana Sayfa'))  →  EN'de "Home"
library;

String _lang = 'tr';

/// Aktif arayüz dilini ayarlar ('tr' | 'en'). AppState dil değişince çağrılır.
void i18nSetLang(String lang) {
  _lang = (lang == 'en') ? 'en' : 'tr';
}

String get i18nLang => _lang;

/// Türkçe metni çevirir (EN modunda). Karşılığı yoksa Türkçe döner.
String t(String tr) => _lang == 'en' ? (_en[tr] ?? tr) : tr;

/// Türkçe → İngilizce sözlük. Çeviri ekledikçe burası büyür.
const Map<String, String> _en = {
  // --- Navigasyon ---
  'Ana Sayfa': 'Home',
  'Gündem': 'Agenda',
  'Radar': 'Radar',
  'Rehber': 'Guide',
  'Profil': 'Profile',

  // --- Ortak ---
  'Ara': 'Search',
  'Bildirimler': 'Notifications',
  'Life Radar Asistan': 'Life Radar Assistant',
  'Yenile': 'Refresh',
  'Kaydet': 'Save',
  'İptal': 'Cancel',
  'Kapat': 'Close',
  'Tamam': 'OK',
  'Devam': 'Continue',
  'Başla': 'Start',
  'Atla': 'Skip',
  'Sil': 'Delete',
  'Düzenle': 'Edit',
  'Tümü': 'All',
  'Yükselt': 'Upgrade',

  // --- Ana sayfa ---
  'Hoş Geldin': 'Welcome',
  'Sistemler aktif. Tarama yapılıyor.': 'Systems active. Scanning.',
  'Günün Özeti': 'Daily Summary',
  'Bugün Öne Çıkanlar': 'Today\'s Highlights',
  'Dünya Risk Endeksi': 'World Risk Index',
  'Türkiye Risk Endeksi': 'Türkiye Risk Index',
  'Life Radar Asistan Günlük Analizi': 'Life Radar Assistant Daily Analysis',
  'Sesli Dinle': 'Listen',
  'Durdur': 'Stop',
  'Son Dakika Gelişmeleri': 'Breaking News',
  'Piyasa': 'Markets',
  'Dolar': 'Dollar',
  'Euro': 'Euro',
  'Gram Altın': 'Gram Gold',
  'Hava kalitesi:': 'Air quality:',

  // --- Giriş ---
  'Giriş Yap': 'Sign In',
  'Kayıt Ol': 'Sign Up',
  'E-posta': 'Email',
  'Şifre': 'Password',
  'Ad': 'First name',
  'Soyad': 'Last name',
  'Google ile devam et': 'Continue with Google',
  'Apple ile devam et': 'Continue with Apple',
  'veya e-posta ile': 'or with email',
  'Misafir olarak devam et': 'Continue as guest',
  'Hesabın yok mu? Kayıt ol': 'No account? Sign up',
  'Zaten hesabın var mı? Giriş yap': 'Already have an account? Sign in',

  // --- Kategoriler (EventCategory) ---
  'Dünya': 'World',
  'Türkiye': 'Türkiye',
  'Sağlık': 'Health',
  'Ekonomi': 'Economy',
  'Teknoloji': 'Technology',
  'Enerji': 'Energy',
  'Güvenlik': 'Security',
  'İklim': 'Climate',
  'Afetler': 'Disasters',

  // --- Gündem ---
  'Senin İçin': 'For You',
  'Güncel haberler yükleniyor...': 'Loading latest news...',
  'Bugünün en önemli gelişmeleri': "Today's top developments",
  'Takip ettiğin konulara göre seçildi': 'Based on your followed topics',
  'Detay Analizi': 'Detailed Analysis',
  'Haberin tamamını oku': 'Read full story',

  // --- Radar ---
  'Kişisel Risk Puanı': 'Personal Risk Score',
  'Konumunuz': 'Your location',
  'Güncelle': 'Update',
  'Risk Geçmişin': 'Your Risk History',
  'Takip Edilen Şehirler': 'Tracked Cities',
  'Sağlık Riski': 'Health Risk',
  'Ekonomik Risk': 'Economic Risk',
  'Afet Riski': 'Disaster Risk',
  'Enerji Riski': 'Energy Risk',
  'Siber Risk': 'Cyber Risk',
  'Seyahat Riski': 'Travel Risk',
  'Ne Yapmalıyım?': 'What Should I Do?',
  'İlgili Gelişmeler': 'Related Developments',
  'Yakındaki Depremleri Haritada Gör': 'See Nearby Earthquakes on Map',

  // --- Profil ---
  'Kişisel Bilgiler': 'Personal Info',
  'Kişisel Bilgilerim': 'My Personal Info',
  'Aboneliğiniz': 'Your Subscription',
  'Mevcut Plan': 'Current Plan',
  'Kayıtlı Haberler': 'Saved News',
  'Takip Edilen Konular': 'Followed Topics',
  'Ayarlar': 'Settings',
  'Hesap': 'Account',
  'Nasıl Kullanılır?': 'How to Use?',
  'Bildirim Ayarları': 'Notification Settings',
  'Kaynak Seçimi': 'Source Selection',
  'Gizlilik': 'Privacy',
  'Hesap Yönetimi': 'Account Management',
  'Açık': 'On',
  'Kapalı': 'Off',
  'Life Radar Premium': 'Life Radar Premium',
  'Life Radar VIP': 'Life Radar VIP',

  // --- Rehber ---
  'Acil Durum Rehberi': 'Emergency Guide',
  'Acil Çantam': 'My Kit',
  'Hızlı Arama': 'Quick Call',
  'Aile Acil Planı': 'Family Emergency Plan',
  'Acil Durum Çantası': 'Emergency Kit',
  'Acil Çağrı Merkezi': 'Emergency Call Center',
  'Acil Durum Kişilerim': 'My Emergency Contacts',
  'Rehberden Kişi Seç': 'Pick from Contacts',

  // --- Bildirimler ---
  'Yeni bildirim yok': 'No new notifications',

  // --- Premium / VIP ---
  'Premium Aktif': 'Premium Active',
  'VIP Merkezini Aç': 'Open VIP Center',
  "VIP'i Keşfet": 'Explore VIP',
  'Satın almaları geri yükle': 'Restore purchases',
  'Aylık': 'Monthly',
  'Yıllık': 'Yearly',
  'Premium Özellikleri': 'Premium Features',
  'VIP Özellikleri': 'VIP Features',
  'Planları Karşılaştır': 'Compare Plans',
  '7 Gün Ücretsiz Deneme': '7-Day Free Trial',

  // --- Rehber detay ---
  'Bir kategoriye dokunarak hazırlık adımlarını görün.':
      'Tap a category to see preparation steps.',
  'Deprem': 'Earthquake',
  'Sel': 'Flood',
  'Yangın': 'Fire',
  'Elektrik Kesintisi': 'Power Outage',
  'Su Kesintisi': 'Water Outage',
  'Salgın Hastalık': 'Epidemic',
  'Aşırı Hava Olayları': 'Extreme Weather',
  'Diğer': 'Other',
  'Hazırlık Listesi': 'Preparation List',
  'İlk 24 Saat': 'First 24 Hours',
  'Gerekli Malzemeler': 'Supplies',
  'İlk Yardım Bilgileri': 'First Aid',
  'Resmi Acil Hatlar': 'Official Emergency Lines',
  'Acil Çağrı': 'Emergency Call',
  'Acil durum kişisi ekle': 'Add emergency contact',
  'Hazırlık:': 'Readiness:',

  // --- Asistan ---
  'Bir soru sor...': 'Ask a question...',
  'Dinleniyor...': 'Listening...',
  'Analiz ediliyor...': 'Analyzing...',
  'Sohbeti temizle': 'Clear chat',
  'Sesli sor': 'Ask by voice',
  'Bu beni nasıl etkiler?': 'How does this affect me?',
  'Kaynak güvenilir mi?': 'Is the source reliable?',
  'Önümüzdeki günlerde ne beklenir?': 'What to expect in coming days?',
  'Merak ettiğin gelişmeyi sor.\nSana etkisini ve ne yapman gerektiğini anlatayım.':
      'Ask about any development.\nI\'ll explain its impact and what to do.',

  // --- Bildirimler ---
  'Bildirim ayarları': 'Notification Settings',

  // --- Onboarding/diğer ---
  'Misafir': 'Guest',
  'Kullanıcı': 'User',
};
