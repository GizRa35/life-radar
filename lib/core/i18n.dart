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
  'Şifremi Unuttum': 'Forgot Password',
  'Önce e-posta adresinizi girin.': 'Please enter your email first.',
  'Şifre sıfırlama bağlantısı e-postana gönderildi.':
      'A password reset link has been sent to your email.',
  'Seni daha iyi tanıyalım (isteğe bağlı)': 'Let us get to know you (optional)',
  'Bu bilgiler analizleri sana göre kişiselleştirir; istemezsen boş bırakabilirsin.':
      'This info personalizes analyses for you; you can leave it blank if you prefer.',
  'Yaş aralığı': 'Age range',
  'Yaşam durumu': 'Living situation',
  'Sağlık durumu': 'Health status',
  // Anket seçenekleri
  'Yalnız yaşıyorum': 'I live alone',
  'Eşimle': 'With my spouse',
  'Çocuklu aile': 'Family with children',
  'Ebeveynlerimle': 'With my parents',
  'Ev arkadaşıyla': 'With a roommate',
  'Belirgin bir sağlık sorunum yok': 'No notable health issues',
  'Kronik hastalığım var': 'I have a chronic illness',
  'Bağışıklığım düşük': 'I have low immunity',
  'Hamile / yeni doğum': 'Pregnant / new birth',
  '65 yaş üstü bakım': 'Over-65 care',
  'Döviz/altın takip ederim': 'I track forex/gold',
  'Kira öderim': 'I pay rent',
  'Kredi/borç ödemem var': 'I have loan/debt payments',
  'Sabit gelirli/emekli': 'Fixed income / retired',
  'Yatırımcıyım': 'I am an investor',

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
  'Senin için akış hazırlanıyor': 'Preparing your feed',
  'Profil > Takip Edilen Konular\'dan ilgi alanı seçersen akışın kişiselleşir.':
      'Pick interests from Profile > Followed Topics to personalize your feed.',
  'kategorisinde gelişme yok': 'category has no developments',
  'Aşağı çekerek veya aşağıdaki düğmeyle yenileyebilirsin.':
      'Pull down or use the button below to refresh.',

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
  'Rehberden Seç': 'Pick from Contacts',
  'Elle Ekle': 'Add Manually',

  // --- Bildirimler ---
  'Yeni bildirim yok': 'No new notifications',
  'Afet': 'Disaster',
  'Sistem': 'System',
  'Sen uygulamada değilken gelen önemli gelişmeler burada görünür. Şu an her şey güncel.':
      'Important developments that arrive while you are away appear here. Everything is up to date right now.',

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
  'Ücretsiz plan:': 'Free plan:',
  'soru hakkın kaldı (bugün).': 'questions left (today).',
  'Günlük soru limiti doldu': 'Daily question limit reached',
  'Ücretsiz planda günde 5 soru sorabilirsiniz. Sınırsız soru için Premium\'a yükseltin.':
      'You can ask 5 questions a day on the free plan. Upgrade to Premium for unlimited questions.',
  'Premium\'a Bak': 'See Premium',
  'Tüm sohbet geçmişi silinsin mi? Bu işlem geri alınamaz.':
      'Delete all chat history? This cannot be undone.',
  'Temizle': 'Clear',
  'Gerçek Life Radar Asistan analizi için Profil > Groq API anahtarı ekleyin. Şimdilik örnek yanıt gösteriliyor.':
      'For real Life Radar Assistant analysis, add your Groq API key in Profile. A sample answer is shown for now.',
  'Bu savaş Türkiye\'yi etkiler mi?': 'Will this war affect Türkiye?',
  'Bu hastalık tehlikeli mi?': 'Is this disease dangerous?',
  'Altın neden yükseliyor?': 'Why is gold rising?',
  'Bu haber hakkında ne yapmalıyım?': 'What should I do about this news?',
  'Kaynak güvenilir mi?': 'Is the source reliable?',
  'Önümüzdeki günlerde ne beklenir?': 'What to expect in coming days?',
  'Merak ettiğin gelişmeyi sor.\nSana etkisini ve ne yapman gerektiğini anlatayım.':
      'Ask about any development.\nI\'ll explain its impact and what to do.',

  // --- Bildirimler ---
  'Bildirim ayarları': 'Notification Settings',

  // --- Onboarding/diğer ---
  'Misafir': 'Guest',
  'Kullanıcı': 'User',

  // --- Kişisel Bilgiler ---
  'Ad (opsiyonel)': 'Name (optional)',
  'Yaş': 'Age',
  'Cinsiyet': 'Gender',
  'Meslek': 'Profession',
  'Şehir': 'City',
  'Hanede yaşayan kişi sayısı': 'People in household',
  'Sağlık durumu / kronik hastalık': 'Health / chronic illness',
  'Finansal hassasiyet': 'Financial sensitivity',
  'Ev tipi': 'Home type',
  'Birlikte yaşadıkların (eş, çocuk...)': 'Who you live with (spouse, kids...)',
  'Kadın': 'Female',
  'Erkek': 'Male',
  'Belirtmek istemiyorum': 'Prefer not to say',
  'Düşük': 'Low',
  'Orta': 'Medium',
  'Yüksek': 'High',
  'Apartman': 'Apartment',
  'Müstakil': 'Detached',
  'Site': 'Complex',
  'Kişisel bilgiler kaydedildi': 'Personal info saved',

  // --- Ayar ekranları ---
  'Acil durumda önce 112': 'In an emergency, call 112 first',

  // --- Bildirim Ayarları ekranı ---
  'Bildirimleri aç': 'Enable notifications',
  'Risk eşiği aşılınca, kritik gelişmede ve seçtiğin durumlarda tarayıcı bildirimi gönderir.':
      'Sends a notification when the risk threshold is crossed, on critical developments, and in cases you choose.',
  'Bildirim Türleri': 'Notification Types',
  'Kritik / acil uyarılar': 'Critical / emergency alerts',
  'Yüksek ve kritik riskli gelişmeler (deprem, afet…)':
      'High and critical risk developments (earthquake, disaster…)',
  'Günlük özet brifingi': 'Daily summary briefing',
  'Günde bir kez günün risk özeti': "Once a day, the day's risk summary",
  'Takip edilen konularda yeni haber': 'New news on followed topics',
  'Takip ettiğin kategorilerde önemli gelişme olunca':
      'When there is an important development in your followed categories',
  'Risk puanı değişimi': 'Risk score change',
  'Kişisel risk puanın eşiği aşınca uyar':
      'Alert when your personal risk score crosses the threshold',
  'Kategoriler': 'Categories',
  'Sessiz Saatler': 'Quiet Hours',
  'Test bildirimi gönder': 'Send test notification',
  'Test bildirimi gönderildi.': 'Test notification sent.',
  'Bildirim izni verilmedi. Tarayıcı ayarlarından izin ver.':
      'Notification permission not granted. Allow it in browser settings.',
  'Bildirim izni verildi': 'Notification permission granted',
  'Bildirim izni reddedildi — tarayıcı ayarlarından aç':
      'Notification permission denied — enable it in browser settings',
  'Bu platformda tarayıcı bildirimi desteklenmiyor':
      'Browser notifications are not supported on this platform',
  'Bildirim izni henüz verilmedi': 'Notification permission not granted yet',
  'İzin ver': 'Allow',
  'Kişisel risk puanın bu değeri aşarsa uyarılırsın.':
      'You will be alerted if your personal risk score exceeds this value.',
  'Hangi kategorilerde bildirim almak istersin?':
      'In which categories do you want notifications?',
  'Rahatsız etme': 'Do not disturb',
  'Belirlediğin saatlerde bildirim gönderilmez':
      'No notifications are sent during the hours you set',
  'Başlangıç': 'Start',
  'Bitiş': 'End',
  'Uyarı eşiği:': 'Alert threshold:',

  // --- Kaynak Seçimi ekranı ---
  'Henüz kaynak yüklenmedi. Haberler geldikçe burada listelenir.':
      'No sources loaded yet. They will be listed here as news arrives.',
  'Kapattığın kaynakların haberleri akışta gösterilmez.':
      'News from sources you turn off will not appear in your feed.',

  // --- Gizlilik ekranı ---
  'Verilerin yalnızca bu cihazda (tarayıcı belleğinde) tutulur. Hesabımız bunları sunucuda saklamaz.':
      'Your data is kept only on this device (in browser storage). We do not store it on a server.',
  'Verilerim': 'My Data',
  'Kişisel bilgiler': 'Personal info',
  'Girildi': 'Entered',
  'Boş': 'Empty',
  'Kayıtlı haberler': 'Saved news',
  'Takip edilen konular': 'Followed topics',
  'Risk geçmişi': 'Risk history',
  'Giriş yapıldı': 'Signed in',
  'adet': 'items',
  'kayıt': 'records',
  'Verilerin JSON olarak indirildi.': 'Your data was downloaded as JSON.',
  'Verilerimi indir (JSON)': 'Download my data (JSON)',
  'Gizlilik Kontrolleri': 'Privacy Controls',
  'Konum kullanımı': 'Location use',
  'Bulunduğun şehre göre afet/deprem riski hesaplanır. Kapatırsan konum tespiti yapılmaz.':
      'Disaster/earthquake risk is calculated based on your city. If turned off, no location is detected.',
  'Life Radar Asistan analizlerine kişisel veri gönder':
      'Send personal data to Life Radar Assistant analyses',
  'Açıkken yaş, meslek, sağlık gibi bilgiler Life Radar Asistan\'a gönderilip analiz sana özel olur. Kapalıyken yalnızca genel analiz yapılır.':
      'When on, info like age, profession and health is sent to Life Radar Assistant so analysis is personalized. When off, only general analysis is done.',
  'Veri Temizleme': 'Clear Data',
  'Kayıtlı haberleri temizle': 'Clear saved news',
  'Tüm kayıtlı haberler silinsin mi? Bu işlem geri alınamaz.':
      'Delete all saved news? This cannot be undone.',
  'Risk geçmişini temizle': 'Clear risk history',
  'Risk puanı geçmişin silinsin mi? Bu işlem geri alınamaz.':
      'Delete your risk score history? This cannot be undone.',
  'Kişisel bilgileri temizle': 'Clear personal info',
  'Yaş, meslek, sağlık vb. kişisel bilgilerin silinsin mi?':
      'Delete your personal info such as age, profession and health?',
  'Tüm verileri sıfırla (fabrika ayarı)': 'Reset all data (factory reset)',
  'Tüm veriler silindi. Çıkış yapıldı.': 'All data deleted. Signed out.',
  'TÜM verilerin (kişisel bilgiler, kayıtlar, ayarlar) silinecek ve çıkış yapılacak. Bu işlem geri alınamaz. Devam edilsin mi?':
      'ALL your data (personal info, saved items, settings) will be deleted and you will be signed out. This cannot be undone. Continue?',
  'Gizlilik Politikası': 'Privacy Policy',
  'Emin misin?': 'Are you sure?',
  'Vazgeç': 'Cancel',

  // --- Hesap Yönetimi ekranı ---
  'Hesap yönetimi için e-posta ile giriş yapmalısın. Misafir kullanıcıların verileri yalnızca bu cihazda tutulur.':
      'You must sign in with email for account management. Guest users\' data is kept only on this device.',
  'E-posta Doğrulama': 'Email Verification',
  'Google ile giriş yaptığın için şifre yönetimi Google hesabından yapılır.':
      'Since you signed in with Google, password management is handled from your Google account.',
  'Tehlikeli Bölge': 'Danger Zone',
  'Çıkış yap': 'Sign out',
  'Hesabı kalıcı olarak sil': 'Permanently delete account',
  'Hesabın ve tüm yerel verilerin silinir. Geri alınamaz.':
      'Your account and all local data are deleted. Cannot be undone.',
  'Hesabı sil': 'Delete account',
  'Hesabın Firebase\'den kalıcı olarak silinecek ve bu cihazdaki tüm verilerin temizlenecek. Bu işlem geri alınamaz. Devam edilsin mi?':
      'Your account will be permanently deleted from Firebase and all data on this device will be cleared. This cannot be undone. Continue?',
  'Hesabı Sil': 'Delete Account',
  'Hesap silindi.': 'Account deleted.',
  'Silinemedi': 'Could not delete',
  'Abonelik': 'Subscription',
  'Ücretsiz': 'Free',
  'Giriş yöntemi': 'Sign-in method',
  'E-posta / Şifre': 'Email / Password',
  'E-posta doğrulama': 'Email verification',
  'Doğrulandı': 'Verified',
  'Doğrulanmadı': 'Not verified',
  'Hesap oluşturma': 'Account created',
  'Son giriş': 'Last login',
  'Hesap bilgileri yükleniyor...': 'Loading account info...',
  'E-posta adresin doğrulanmış': 'Your email address is verified',
  'E-posta adresin henüz doğrulanmadı. Doğrulama bağlantısını gönderip e-postandaki linke tıklayabilirsin.':
      'Your email is not verified yet. You can send the verification link and click it in your email.',
  'Doğrulama e-postası gönder': 'Send verification email',
  'Doğrulama e-postası gönderildi. Gelen kutunu kontrol et.':
      'Verification email sent. Check your inbox.',
  'Yeni şifre belirle': 'Set a new password',
  'Yeni şifre': 'New password',
  'Yeni şifre (tekrar)': 'New password (repeat)',
  'Şifre en az 6 karakter olmalı.': 'Password must be at least 6 characters.',
  'Şifreler eşleşmiyor.': 'Passwords do not match.',
  'Şifren güncellendi.': 'Your password has been updated.',
  'Şifreyi değiştir': 'Change password',
  'Şifreni mi unuttun?': 'Forgot your password?',
  'Şifre sıfırlama e-postası gönderildi.': 'Password reset email sent.',
  'Şifre sıfırlama e-postası gönder': 'Send password reset email',
  'Tam yasal metin: Gizlilik · Kullanım Şartları · Sorumluluk Reddi':
      'Full legal text: Privacy · Terms of Use · Disclaimer',
  'Life Radar, gizliliğine önem verir.\n\n• Saklanan veriler: Girdiğin kişisel bilgiler, kayıtlı haberler, takip ettiğin konular, risk geçmişin ve uygulama ayarların yalnızca bu cihazın tarayıcı belleğinde (localStorage) tutulur.\n\n• Hesap: E-posta ile kayıt/giriş Firebase Authentication üzerinden yapılır; yalnızca e-posta ve oturum anahtarı işlenir.\n\n• Konum: Açıkken yaklaşık konumun IP üzerinden belirlenir ve afet riski hesabında kullanılır. İstediğin zaman kapatabilirsin.\n\n• Life Radar Asistan: Analizler için başlıklar ve (izin verdiysen) kişisel bağlamın bir hizmet sağlayıcıya (Groq) gönderilir. Bu paylaşımı "Life Radar Asistan analizlerine kişisel veri gönder" anahtarından kapatabilirsin.\n\n• Haberler: Haber içerikleri kaynak sitelerden ve çeviri servisinden alınır; bu isteklerde kişisel bilgin gönderilmez.\n\n• Hakların: Verilerini istediğin an dışa aktarabilir (JSON) veya tamamen silebilirsin. Uygulamayı sildiğinde veya tarayıcı verisini temizlediğinde tüm yerel veriler kaybolur.':
      'Life Radar values your privacy.\n\n• Stored data: The personal info you enter, saved news, followed topics, your risk history and app settings are kept only in this device\'s browser storage (localStorage).\n\n• Account: Email sign-up/sign-in is handled via Firebase Authentication; only your email and session key are processed.\n\n• Location: When on, your approximate location is determined via IP and used in disaster risk calculation. You can turn it off anytime.\n\n• Life Radar Assistant: For analyses, headlines and (if you allow it) your personal context are sent to a service provider (Groq). You can turn off this sharing from the "Send personal data to Life Radar Assistant analyses" switch.\n\n• News: News content is fetched from source sites and a translation service; no personal info is sent in these requests.\n\n• Your rights: You can export your data anytime (JSON) or delete it entirely. When you delete the app or clear browser data, all local data is lost.',

  // --- Premium/VIP içerik ---
  'Premium\'a Geç': 'Get Premium',
  'VIP\'e Geç': 'Get VIP',
  'En üst düzey koruma ve ayrıcalıklar aktif.':
      'Top-tier protection and perks active.',
  'Daha fazla koruma. Daha fazla kontrol.':
      'More protection. More control.',
  '2 ay bedava': '2 months free',

  // --- Abonelik içeriği (SubscriptionData) ---
  'Dünyadaki gelişmeleri sadece takip etmeyin, size etkilerini anlayın.':
      'Don\'t just follow world developments — understand how they affect you.',
  'Riskleri sadece takip etmeyin. Önceden hazırlanın.':
      'Don\'t just track risks. Be prepared in advance.',
  // Premium features
  'Sınırsız Life Radar Asistan Soruları': 'Unlimited Life Radar Assistant Questions',
  'Kullanıcı sınırsız soru sorabilir.': 'Ask unlimited questions.',
  'Bu savaş beni etkiler mi?': 'Will this war affect me?',
  'Bu ekonomik gelişme ne anlama geliyor?': 'What does this economic development mean?',
  'Bu sağlık haberi önemli mi?': 'Is this health news important?',
  'Kişisel Risk Analizi': 'Personal Risk Analysis',
  'Life Radar Asistan kullanıcıya özel analiz oluşturur.':
      'Life Radar Assistant creates analysis tailored to you.',
  'Bölgesel Uyarılar': 'Regional Alerts',
  'Bulunduğunuz şehir için bildirilir.': 'Notified for your city.',
  'Sağlık uyarıları': 'Health alerts',
  'Hava olayları': 'Weather events',
  'Afet riskleri': 'Disaster risks',
  'Acil durumlar': 'Emergencies',
  'Ne Yapmalıyım? Plus': 'What Should I Do? Plus',
  'Normal öneriler yerine daha detaylı aksiyon planları.':
      'More detailed action plans instead of basic suggestions.',
  'Premium Haftalık Özet': 'Premium Weekly Digest',
  'Haftalık özetlenir.': 'Summarized weekly.',
  'Dünya gündemi': 'World agenda',
  'Türkiye gündemi': 'Türkiye agenda',
  'Sağlık gelişmeleri': 'Health developments',
  'Ekonomi gelişmeleri': 'Economic developments',
  'Reklamsız Deneyim': 'Ad-Free Experience',
  'Tüm reklamlar kaldırılır.': 'All ads are removed.',
  // VIP features
  'Aile Koruma Merkezi': 'Family Protection Center',
  'Eş, çocuk, anne, baba eklenebilir; Life Radar Asistan aile üyeleri için özel analizler oluşturur.':
      'Add spouse, children and parents; Life Radar Assistant builds tailored analyses for family members.',
  'Kişisel Life Radar Asistanı': 'Personal Life Radar Assistant',
  'Sistem her gün otomatik analiz üretir.':
      'The system generates automatic analysis every day.',
  '"Bugün sizi etkileyebilecek 3 önemli gelişme bulundu."':
      '"3 important developments that could affect you today were found."',
  'VIP İstihbarat Raporu': 'VIP Intelligence Report',
  'Haftalık PDF raporu.': 'Weekly PDF report.',
  'Dünya Gündemi': 'World Agenda',
  'Türkiye Gündemi': 'Türkiye Agenda',
  'Sağlık Riskleri': 'Health Risks',
  'Ekonomik Riskler': 'Economic Risks',
  'Bölgesel Riskler': 'Regional Risks',
  'Şehir Bazlı Risk Merkezi': 'City-Based Risk Center',
  'Şehre özel analizler.': 'City-specific analyses.',
  'Deprem Riski': 'Earthquake Risk',
  'Yangın Riski': 'Fire Risk',
  'Hava Kalitesi': 'Air Quality',
  'Su Durumu': 'Water Status',
  'Sağlık Uyarıları': 'Health Alerts',
  'Kişisel Acil Durum Planı': 'Personal Emergency Plan',
  'Aile yapısı, ev tipi ve şehir bilgisiyle özel hazırlık planı.':
      'A custom preparedness plan based on family structure, home type and city.',
  'Haber Doğrulama Sistemi': 'News Verification System',
  'Link, ekran görüntüsü veya haber metni yüklenir; Life Radar Asistan doğruluk, kaynak ve manipülasyon riski analizi yapar.':
      'Upload a link, screenshot or news text; Life Radar Assistant analyzes accuracy, source and manipulation risk.',
  'VIP Erken Uyarı Merkezi': 'VIP Early Warning Center',
  'Kritik gelişmelerde öncelikli bildirim.':
      'Priority notification on critical developments.',
  'Yeni salgın': 'New epidemic',
  'Şiddetli hava olayı': 'Severe weather event',
  'Bölgesel afet': 'Regional disaster',
  'Kritik ekonomik gelişme': 'Critical economic development',
  'Gelişmiş Risk Skoru': 'Advanced Risk Score',
  'Life Radar Asistan aşağıdaki puanları oluşturur.':
      'Life Radar Assistant generates the following scores.',
  'Finans': 'Finance',
  'Yaşam Alanı': 'Living Space',
  'Aile Koruması': 'Family Protection',
  'Seyahat': 'Travel',
  'Küresel Risk': 'Global Risk',
  'Genel Risk Endeksi': 'Overall Risk Index',
  'Öncelikli Life Radar Asistan Sunucusu': 'Priority Life Radar Assistant Server',
  'Daha hızlı yanıtlar, öncelikli işlem.':
      'Faster responses, priority processing.',
  'Gelecek Radarı': 'Future Radar',
  'Life Radar Asistan mevcut verileri analiz ederek olası riskler, dikkat edilmesi gereken trendler ve yaklaşan gelişmeler hakkında bilgi verir. Kesin tahmin veya kehanet yapılmaz.':
      'Life Radar Assistant analyzes current data to inform you about possible risks, trends to watch and upcoming developments. No definitive predictions or prophecy.',
  // Comparison table
  'Günlük Haberler': 'Daily News',
  'Temel Risk Analizi': 'Basic Risk Analysis',
  'Günde 5 Life Radar Asistan Sorusu': '5 Life Radar Assistant Questions per Day',
  'Sınırsız Life Radar Asistan': 'Unlimited Life Radar Assistant',
  'Haftalık Özet': 'Weekly Digest',
  'Reklamsız Kullanım': 'Ad-Free Use',
  'Haber Doğrulama': 'News Verification',
  'Erken Uyarı Sistemi': 'Early Warning System',
  'Gelişmiş Risk Skorları': 'Advanced Risk Scores',
  'Öncelikli Life Radar Asistan': 'Priority Life Radar Assistant',
  ', sen VIP\'sin 👑': ', you are VIP 👑',
  'VIP Aylık': 'VIP Monthly',
  'VIP Yıllık': 'VIP Yearly',
  'Dokun & Başla': 'Tap & Start',
  'Aktif': 'Active',
  'Bir plana dokunarak hemen başla': 'Tap a plan to start now',
  'En avantajlı': 'Best value',
  'Planını seç': 'Choose your plan',
  'Kullanım Şartları': 'Terms of Use',
  'Abonelik otomatik yenilenir; dönem bitiminden en az 24 saat önce iptal edilmezse aynı fiyattan yenilenir. Aboneliği istediğin zaman cihaz ayarlarından yönetebilir veya iptal edebilirsin.':
      'Subscription auto-renews; unless cancelled at least 24 hours before the end of the period, it renews at the same price. You can manage or cancel anytime in your device settings.',

  // --- Form tasarımı (durum/ipucu kartları) ---
  'Çanta Hazırlık Durumu': 'Kit Readiness',
  'Tamamlandı': 'Completed',
  'Önemli İpucu': 'Important Tip',
  'Çantanızdaki gıdaların son kullanma tarihlerini her 6 ayda bir kontrol etmeyi unutmayın.':
      'Remember to check the expiry dates of the food in your kit every 6 months.',
  'Profil Tamamlama': 'Profile Completion',
  'Hazırlık Durumu': 'Readiness Status',

  // --- Satın alma mesajları ---
  'Satın alma yalnızca mobil uygulamada kullanılabilir.':
      'Purchases are only available in the mobile app.',
  'Mağaza şu an kullanılamıyor. Daha sonra deneyin.':
      'The store is currently unavailable. Please try again later.',
  'Ürün bulunamadı. Lütfen daha sonra tekrar deneyin.':
      'Product not found. Please try again later.',
  'Satın alma başlatılamadı.': 'Could not start the purchase.',
  'Aboneliğin etkinleştirildi. Teşekkürler!':
      'Your subscription is active. Thank you!',
  'Satın alma başarısız oldu.': 'The purchase failed.',

  // --- Profil ekranı (ek) ---
  'Henüz kaydedilmiş haber yok. Haberlerdeki kaydet simgesine dokunarak buraya ekleyebilirsiniz.':
      'No saved news yet. Tap the bookmark icon on a story to add it here.',
  'Avatar Seç': 'Choose Avatar',
  'Unisex': 'Unisex',
  'Sınırsız Life Radar Asistan, kişisel risk analizi, reklamsız.':
      'Unlimited Life Radar Assistant, personal risk analysis, ad-free.',
  'Aile koruma, şehir risk merkezi, erken uyarı.':
      'Family protection, city risk center, early warning.',
  'Life Radar Asistan analizleri bilgilerine göre kişiselleştiriliyor.':
      'Life Radar Assistant analyses are personalized to your info.',
  'Doldur → analizler sana özel olsun (yaş, sağlık, ev, aile...).':
      'Fill in → get tailored analyses (age, health, home, family...).',
  'Misafir kullanıcı': 'Guest user',
  'Verileriniz yalnızca bu cihazda. Giriş yapın.':
      'Your data stays only on this device. Sign in.',
  'Çıkış Yap': 'Sign Out',
  'Dünyayı Anla. Riskleri Gör. Hazırlıklı Ol.':
      'Understand the world. See the risks. Be prepared.',
  'yakında': 'coming soon',

  // --- Radar ekranı (ek) ---
  'Profilinize göre güncel genel risk seviyeniz. Aşağıdaki alanlara dokunarak detayları görün.':
      'Your current overall risk level based on your profile. Tap the areas below for details.',
  'Memleketin/ailenin şehrini ekle': 'Add your hometown / family\'s city',
  'şehir takip ediliyor': 'cities tracked',

  // --- Ana sayfa (ek) ---
  'Öne Çıkan': 'Featured',
  'Devamını Görüntüle': 'View More',
  'İlgilendiğin konuları seçersen burada onların öne çıkan haberlerini gösteririz. Profil > Takip Edilen Konular\'dan seç.':
      'Pick topics you care about and we\'ll show their featured news here. Choose from Profile > Followed Topics.',
  'Kullanım Kılavuzu': 'Usage Guide',
  'Uygulamayı en iyi şekilde kullanmak için kısa rehbere göz at.':
      'Check the short guide to get the most out of the app.',

  // --- Aile Acil Planı ---
  'Ev yakını buluşma noktası': 'Meeting point near home',
  'Bölge dışı buluşma noktası': 'Out-of-area meeting point',
  'İletişim ve toplanma notu': 'Contact & gathering note',
  'Planı Kaydet': 'Save Plan',
  'Aile planı kaydedildi': 'Family plan saved',
  'Afet anında ailenizin nerede buluşacağını ve nasıl iletişim kuracağını önceden belirleyin. Bilgiler yalnızca cihazınızda saklanır.':
      'Decide in advance where your family will meet and how to communicate during a disaster. Information is stored only on your device.',

  // --- Ayar / hesap ekranları ---
  'Bu bilgiler yalnızca cihazında tutulur ve Life Radar Asistan analizlerini sana özel hale getirmek için kullanılır.':
      'This information is kept only on your device and used to personalize Life Radar Assistant analyses for you.',

  // --- VIP Merkezi (vip_hub_screen) ---
  'VIP Merkezi': 'VIP Center',
  'Aile üyelerini ekle, her birine özel Life Radar Asistan analizi al.':
      'Add family members and get a tailored Life Radar Assistant analysis for each.',
  'Akıllı Aksiyon Danışmanı': 'Smart Action Advisor',
  'Hane halkına göre MİKTARLI hazırlık önerileri (gıda, su, enerji...).':
      'Quantified preparedness suggestions based on your household (food, water, energy...).',
  'Bugün sizi etkileyebilecek en önemli gelişmeler.':
      'The most important developments that could affect you today.',
  'Bulunduğun şehir için deprem/yangın/hava/su/sağlık değerlendirmesi.':
      'Earthquake/fire/air/water/health assessment for your city.',
  'Aile ve konumuna göre hazırlık planı.':
      'A preparedness plan based on your family and location.',
  'Bir haber linki/metni yapıştır, doğruluk ve manipülasyon analizi al.':
      'Paste a news link/text and get an accuracy and manipulation analysis.',
  'Sağlık, finans, yaşam alanı, aile, seyahat, küresel risk skorları.':
      'Health, finance, living space, family, travel and global risk scores.',
  'Yaklaşan riskler ve trendler (kehanet değil, eğilim analizi).':
      'Upcoming risks and trends (not prophecy, trend analysis).',
  'Gideceğin şehir/ülke için risk + sağlık + güvenlik brifingi.':
      'Risk + health + security briefing for your destination city/country.',
  'Kişisel risk puanının zaman içindeki değişimi.':
      'How your personal risk score changes over time.',
  'Akıllı Uyarı': 'Smart Alert',
  'Bildirim türleri, kategoriler, sessiz saatler ve risk eşiği.':
      'Notification types, categories, quiet hours and risk threshold.',
  'Kritik ve yüksek riskli güncel gelişmeler tek ekranda.':
      'Critical and high-risk current developments on a single screen.',
  'Haftalık özet rapor — PDF olarak kaydedebilirsin.':
      'Weekly summary report — you can save it as PDF.',
  'VIP araçların Life Radar Asistan ile çalışır. Aşağıdan seç.':
      'Your VIP tools run with Life Radar Assistant. Choose below.',
  'Daha kişisel analiz için bilgilerini doldur':
      'Fill in your info for more personalized analysis',
  'Yaş, sağlık, ev tipi, aile... → analizler sana özel olur.':
      'Age, health, home type, family... → analyses become tailored to you.',
  'Gideceğin şehir veya ülkeyi yaz; Life Radar Asistan güvenlik, sağlık ve afet açısından kısa bir brifing hazırlasın.':
      'Type your destination city or country; let Life Radar Assistant prepare a short briefing on security, health and disasters.',
  'Brifing Al': 'Get Briefing',
  'Geçmiş oluşması için uygulamayı birkaç kez aç/yenile. Her açılışta o anki risk puanın kaydedilir.':
      'Open/refresh the app a few times to build history. Your current risk score is saved on each launch.',
  'Şu an': 'Now',
  'En yüksek': 'Highest',
  'En düşük': 'Lowest',
  'Değişim': 'Change',
  'Şu an kritik veya yüksek riskli bir gelişme görünmüyor.':
      'No critical or high-risk developments right now.',
  'öncelikli uyarı — yüksek/kritik riskli gelişmeler.':
      'priority alerts — high/critical risk developments.',
  'Rapor hazırlanıyor...': 'Preparing report...',
  'Rapor oluşturulamadı.': 'Could not generate report.',
  'PDF olarak indir / yazdır': 'Download / print as PDF',
  'Şüphelendiğin haberin linkini veya metnini yapıştır; Life Radar Asistan doğruluk ve manipülasyon riskini değerlendirsin.':
      'Paste the link or text of the news you doubt; let Life Radar Assistant assess accuracy and manipulation risk.',
  'Haber linki veya metni...': 'News link or text...',
  'Doğrula': 'Verify',
  'Aile Üyesi Ekle': 'Add Family Member',
  'Ad *': 'Name *',
  'Yakınlık': 'Relation',
  'Eş': 'Spouse',
  'Çocuk': 'Child',
  'Anne': 'Mother',
  'Baba': 'Father',
  'Kardeş': 'Sibling',
  'Büyükanne': 'Grandmother',
  'Büyükbaba': 'Grandfather',
  'Kronik hastalık / sürekli ilaç': 'Chronic illness / regular medication',
  'Alerjiler': 'Allergies',
  'Özel durum (hamilelik, engellilik, vb.)':
      'Special condition (pregnancy, disability, etc.)',
  'Ek not (ops.)': 'Additional note (opt.)',
  'Ekle': 'Add',
  'Üye Ekle': 'Add Member',
  'Henüz aile üyesi yok. Sağ alttaki "Üye Ekle" ile başla.\nHer üye için Life Radar Asistan özel risk analizi üretebilir.':
      'No family members yet. Start with "Add Member" at the bottom right.\nLife Radar Assistant can generate a tailored risk analysis for each member.',
  'yaş': 'years',
  'Life Radar Asistan Analizi': 'Life Radar Assistant Analysis',

  // --- Acil Durum Çantası (emergency_kit_screen) ---
  'Tebrikler! Çantan tam hazır. 🎒': 'Congratulations! Your kit is fully ready. 🎒',
  'Maddeleri tamamladıkça hazırlık oranın artar.':
      'Your readiness increases as you complete items.',
  'Su ve Gıda': 'Water & Food',
  'Aydınlatma & İletişim': 'Lighting & Communication',
  'Belgeler & Para': 'Documents & Money',
  'Kişi başı en az 4 litre su': 'At least 4 litres of water per person',
  'Konserve / kuru gıda (3 günlük)': 'Canned / dry food (3 days)',
  'Bebek maması / özel beslenme (gerekiyorsa)':
      'Baby formula / special nutrition (if needed)',
  'Konserve açacağı': 'Can opener',
  'İlk yardım çantası': 'First aid kit',
  'Düzenli kullanılan reçeteli ilaçlar': 'Regularly used prescription meds',
  'Maske ve dezenfektan': 'Mask and disinfectant',
  'Hijyen malzemeleri': 'Hygiene supplies',
  'El feneri + yedek pil': 'Flashlight + spare batteries',
  'Powerbank (dolu)': 'Power bank (charged)',
  'Pilli/şarjlı radyo': 'Battery/rechargeable radio',
  'Düdük (yardım çağırmak için)': 'Whistle (to call for help)',
  'Kimlik, pasaport kopyaları': 'ID, passport copies',
  'Tapu/sigorta belgeleri kopyası': 'Copies of deed/insurance documents',
  'Bir miktar nakit para': 'Some cash',
  'Önemli telefon numaraları (yazılı)': 'Important phone numbers (written)',
  'Battaniye / termal örtü': 'Blanket / thermal cover',
  'Yedek kıyafet ve yağmurluk': 'Spare clothes and raincoat',
  'Çok amaçlı çakı': 'Multi-purpose knife',
  'Kibrit / çakmak (su geçirmez)': 'Matches / lighter (waterproof)',

  // --- Hızlı Acil Arama (emergency_call_screen) ---
  'Arama başlatılamadı.': 'Could not start the call.',
  'Acil Çağrı — dokun ve ara': 'Emergency Call — tap to call',
  'Türkiye\'de sağlık, itfaiye, polis, jandarma ve afet çağrıları tek numarada birleşti: 112. (110, 155, 156, 122 aramaları da 112\'ye yönlendirilir.)':
      'In Türkiye, health, fire, police, gendarmerie and disaster calls are unified under one number: 112. (Calls to 110, 155, 156, 122 are also routed to 112.)',
  'Acil kişi': 'Emergency contact',
  'Kaldır': 'Remove',
  'veya elle ekle': 'or add manually',
  'Gerçek acil durumda önce 112\'yi arayın. Acil kişi bilgisi yalnızca cihazınızda saklanır.':
      'In a real emergency, call 112 first. Emergency contact info is stored only on your device.',
  'Kişi seçilmedi veya seçilen kişide telefon numarası yok.':
      'No contact selected, or the selected contact has no phone number.',
  'Acil Durum Kişisi': 'Emergency Contact',
  'Telefon': 'Phone',

  // --- Takip Edilen Şehirler (cities_screen) ---
  'Şehir Ekle': 'Add City',
  'Henüz şehir eklemedin.\nMemleketini veya ailenin şehrini ekleyerek oradaki deprem riskini takip et.':
      'You haven\'t added a city yet.\nAdd your hometown or your family\'s city to track its earthquake risk.',
  'Eklediğin şehirlerdeki son 30 günün gerçek deprem aktivitesine göre afet riski.':
      'Disaster risk based on the actual earthquake activity of the last 30 days in your added cities.',
  'Risk hesaplanıyor...': 'Calculating risk...',
  'Deprem riski:': 'Earthquake risk:',
  'Şehir Ara': 'Search City',
  'Örn: İzmir, Ankara, Bursa...': 'e.g. İzmir, Ankara, Bursa...',

  // --- Olay Analizi (event_detail_screen) ---
  'Olay': 'Event',
  'Olay bulunamadı.': 'Event not found.',
  'Olay Analizi': 'Event Analysis',
  'Kayıttan çıkar': 'Remove from saved',
  'Paylaş': 'Share',
  'Haber panoya kopyalandı.': 'News copied to clipboard.',
  'Paylaşım yapılamadı.': 'Could not share.',
  'Bana Özel Aksiyon Planı': 'My Personal Action Plan',
  'Hanene ve duruma özel hazırlık önerileri':
      'Preparation suggestions tailored to your household and situation',
  'Hane halkına özel, miktarlı hazırlık önerileri. Premium ve VIP üyelere özeldir.':
      'Quantified preparation suggestions tailored to your household. Exclusive to Premium and VIP members.',
  'Haberin tamamı yükleniyor...': 'Loading the full story...',
  'Bu olay için Life Radar Asistan etki analizi henüz hazırlanmadı. Life Radar Asistan butonundan bu haberi sorabilirsiniz.':
      'A Life Radar Assistant impact analysis for this event is not ready yet. You can ask about this news from the Life Radar Assistant button.',
  'Bu Beni Etkiler mi?': 'Does This Affect Me?',
  'Etkilenme Olasılığı': 'Probability of Impact',
  'Kimler etkilenebilir': 'Who may be affected',
  'Türkiye etkisi': 'Impact on Türkiye',
  'Kişisel etkiler': 'Personal impacts',
  'Etki süresi': 'Impact duration',
  'YAPILACAKLAR': 'DO',
  'YAPILMAYACAKLAR': "DON'T",

  // --- Risk Alanı Detayı (risk_area_detail_screen) ---
  'USGS (deprem) ve GDACS (küresel afet uyarı sistemi) verileri.':
      'Data from USGS (earthquakes) and GDACS (global disaster alert system).',
  'Dünya gündemi ve güvenlik kaynaklarından seyahatinizi etkileyebilecek gelişmeler.':
      'Developments that may affect your travel from world news and security sources.',
  'Güncel ve güvenilir kaynaklardan haberler.':
      'News from current and reliable sources.',
  'Deprem çantanızı (su, ilk yardım, fener, düdük, powerbank) hazır tutun.':
      'Keep your earthquake kit (water, first aid, flashlight, whistle, power bank) ready.',
  'AFAD ve Kandilli Rasathanesi bildirimlerini açık tutun.':
      'Keep AFAD and Kandilli Observatory notifications on.',
  'Evde toplanma noktası ve tahliye planı belirleyin.':
      'Set a meeting point and evacuation plan at home.',
  'Ağır eşyaları ve dolapları duvara sabitleyin.':
      'Anchor heavy items and cabinets to the wall.',
  'Acil durum için aile iletişim planı oluşturun.':
      'Create a family communication plan for emergencies.',
  'Gideceğiniz bölgenin güncel güvenlik durumunu kontrol edin.':
      'Check the current security situation of your destination.',
  'Seyahat sağlık sigortanızı ve aşı gereksinimlerini gözden geçirin.':
      'Review your travel health insurance and vaccination requirements.',
  'Pasaport, vize ve kimlik kopyalarını dijital olarak saklayın.':
      'Keep digital copies of your passport, visa and ID.',
  'Dışişleri seyahat uyarılarını takip edin.':
      'Follow foreign ministry travel advisories.',
  'Konaklama ve dönüş biletlerinizin esnek/iptal edilebilir olmasına dikkat edin.':
      'Make sure your accommodation and return tickets are flexible/cancellable.',
  'Resmi kurum açıklamalarını takip edin.':
      'Follow official institution statements.',
  'Doğrulanmamış bilgileri paylaşmayın.': 'Do not share unverified information.',
  'Gerekiyorsa hazırlık planınızı gözden geçirin.':
      'Review your preparedness plan if needed.',
  'Şu an bu alanda belirgin bir gelişme görünmüyor.':
      'No notable developments in this area right now.',
  'Düşük: şu an acil bir etki beklenmiyor.':
      'Low: no urgent impact expected right now.',
  'Şu an bu alanda gelişme bulunamadı.':
      'No developments found in this area right now.',

  // --- AI Sonuç (ai_result_screen) ---
  'Life Radar Asistan tarafından sana özel hazırlandı':
      'Prepared just for you by Life Radar Assistant',
  'Bilgilendirme amaçlıdır; kesin tahmin değildir. Resmi kaynakları da takip edin.':
      'For information only; not a definitive prediction. Also follow official sources.',
  'Life Radar Asistan senin için hazırlıyor...':
      'Life Radar Assistant is preparing for you...',
  'Birkaç saniye sürebilir': 'This may take a few seconds',
  'Sonuç alınamadı. Bağlantını kontrol edip "Yeniden Üret" ile tekrar dene.':
      'Could not get a result. Check your connection and try again with "Regenerate".',

  // --- Arama (search_screen) ---
  'Haberlerde ara...': 'Search news...',
  'Bir kelime yaz; başlık, özet ve kaynaklarda ararım.':
      'Type a word; I\'ll search titles, summaries and sources.',
  'Eşleşen haber bulunamadı. Farklı bir kelime dene.':
      'No matching news found. Try a different word.',
  'sonuç': 'results',

  // --- Haber Dili (language_screen) ---
  'Haber Dili': 'News Language',
  'Seçtiğin dil arayüz dilini değil, haber dilini belirler. Yabancı kaynaklı haberler bu dile çevrilir.':
      'The language you choose sets the news language, not the interface language. Foreign-source news is translated into this language.',

  // --- Nasıl Kullanılır? (usage_guide_screen) ---
  'Premium & VIP': 'Premium & VIP',
  'Life Radar 3 soruyu yanıtlar: Ne oluyor? Beni etkiler mi? Ne yapmalıyım?':
      'Life Radar answers 3 questions: What is happening? Does it affect me? What should I do?',
  'İpucu: Bilgiler cihazında saklanır ve sadece sana özel analiz için kullanılır. İstediğin an Profil > Gizlilik\'ten yönetebilirsin.':
      'Tip: Your info is stored on your device and used only for your personalized analysis. You can manage it anytime from Profile > Privacy.',
  'Günün özeti, hava durumu, döviz/altın kurları ve "Bugün Öne Çıkanlar" tek bakışta. Aşağı çekerek yenileyebilirsin.':
      'The daily summary, weather, currency/gold rates and "Today\'s Highlights" at a glance. Pull down to refresh.',
  '"Senin İçin" akışı ve kategorilere göre haberler. Bir habere dokun → detayını, sana etkisini ve "Ne yapmalıyım?" önerilerini gör.':
      'A "For You" feed and news by category. Tap a news item → see its detail, its impact on you and "What should I do?" suggestions.',
  'Konumuna ve profiline göre kişisel risk puanın. Sağlık, ekonomi, afet, seyahat risklerini incele. Memleketini de "şehir takibi"ne ekle.':
      'Your personal risk score based on your location and profile. Explore health, economy, disaster and travel risks. Add your hometown to "city tracking" too.',
  'Sağ alttaki ✨ butonu. Merak ettiğini sor (yazarak veya mikrofonla); sana özel, sade bir analiz alırsın.':
      'The ✨ button at the bottom right. Ask what you wonder (by typing or microphone); you get a simple, personalized analysis.',
  'Acil durum çantanı hazırla, 112\'yi tek dokunuşla ara, aile acil planını oluştur ve deprem/sel/yangın rehberlerini incele.':
      'Prepare your emergency kit, call 112 with a single tap, create a family emergency plan and review earthquake/flood/fire guides.',
  'Kişisel bilgilerini gir (analizler kişiselleşir), haber dili ve kaynakları seç, bildirim/gizlilik ayarlarını yönet.':
      'Enter your personal info (analyses get personalized), choose news language and sources, and manage notification/privacy settings.',
  'Sınırsız asistan, kişisel risk analizi, aile koruma merkezi ve reklamsız kullanım. VIP en üst düzey koruma sunar.':
      'Unlimited assistant, personal risk analysis, family protection center and ad-free use. VIP offers top-tier protection.',

  // --- Karşılama (onboarding_screen) ---
  'Ne oluyor?': 'What is happening?',
  'Dünyadan ve Türkiye\'den güvenilir kaynakların haberlerini tek yerde, aynı konu tek seferde, sade bir akışta gör.':
      'See news from reliable sources in Türkiye and the world in one place, each topic once, in a clean feed.',
  'Beni etkiler mi?': 'Does it affect me?',
  'Konumun ve profiline göre kişisel risk puanın hesaplanır. Bir haberin seni nasıl etkileyebileceğini Life Radar Asistan açıklar.':
      'Your personal risk score is calculated based on your location and profile. Life Radar Assistant explains how a news item could affect you.',
  'Ne yapmalıyım?': 'What should I do?',
  'Her gelişme için sakin, kanıta dayalı "yapılacaklar / yapılmayacaklar" ve hane halkına özel hazırlık önerileri sunulur.':
      'For each development, calm, evidence-based "do / don\'t" lists and household-specific preparation suggestions are offered.',
  'Gizlilik sende': 'Privacy is yours',
  'Verilerin cihazında tutulur; istediğin an dışa aktarır veya silersin. Bildirim ve gizlilik ayarları tamamen senin kontrolünde.':
      'Your data is kept on your device; you can export or delete it anytime. Notification and privacy settings are entirely in your control.',

  // --- Kriz Radarı (crisis_radar_screen) ---
  'Kriz Radarı': 'Crisis Radar',
  'Ekonomi, enerji, gıda, su, jeopolitik ve siber kaynaklı güncel riskler (GDELT).':
      'Current risks from economic, energy, food, water, geopolitical and cyber sources (GDELT).',
  'Şu an kriz sinyali bulunamadı.': 'No crisis signals found right now.',
  'Enerji Krizleri': 'Energy Crises',
  'Gıda Krizleri': 'Food Crises',
  'Su Krizleri': 'Water Crises',
  'Jeopolitik Riskler': 'Geopolitical Risks',
  'Siber Güvenlik Riskleri': 'Cyber Security Risks',

  // --- Sağlık Radarı (health_radar_screen) ---
  'Sağlık Radarı': 'Health Radar',
  'WHO, CDC ve sağlık kaynaklarından güncel haberler (GDELT).':
      'Current news from WHO, CDC and health sources (GDELT).',
  'Şu an sağlık gelişmesi bulunamadı.':
      'No health developments found right now.',
  'Yeni Hastalıklar': 'New Diseases',
  'Salgınlar': 'Outbreaks',
  'WHO Uyarıları': 'WHO Alerts',
  'CDC Uyarıları': 'CDC Alerts',
  'Aşı Haberleri': 'Vaccine News',

  // --- Deprem Haritası (earthquake_map_screen) ---
  'Yakındaki Depremler': 'Nearby Earthquakes',
  'Depremler yükleniyor...': 'Loading earthquakes...',
  'Son 30 günde çevredeki': 'In the last 30 days, nearby',
  'deprem (USGS). Bir işarete dokunarak detayını gör.':
      'earthquakes (USGS). Tap a marker to see details.',
  'Bilinmeyen konum': 'Unknown location',
};
