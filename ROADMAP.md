# Life Radar — Yol Haritası ve Yapılacaklar

Bu dosya, unutmamak için tutulur. Tamamlananları ve kalanları gösterir.

## 🚀 YAYIN İÇİN KALANLAR (önce bunlar)

### 0) TEST (göndermeden önce şart)
- [ ] Codemagic'te yeni build al → TestFlight'a düşür
- [ ] Telefonda 10 dk test: açılış (çökme yok), e-posta/Google/Apple giriş,
      haberler+görsel+çeviri, asistan (yazılı+sesli), harita, rehber seçici,
      acil çanta/arama, premium/vip konfeti, kur/hava kartları

### 1) iOS — App Store (yayını engelleyenler)
- [ ] Build'i sürüme bağla
- [ ] Abonelik fiyatları (4 ürün): Premium ₺49,99/₺499,99 · VIP ₺99,99/₺999,99
- [ ] App Privacy formu (e-posta+konum+anket; izleme YOK)
- [ ] Yaş derecelendirme anketi
- [ ] Copyright: 2026 Life Radar + App Review iletişim bilgisi
- [ ] Support URL: .../support · Privacy URL: .../privacy (App Privacy bölümü)
- [ ] Submit for Review
- Ekran görüntüleri ✅ · Açıklama/anahtar kelime ✅ (hazır)

### 2) Android — Google Play (sonra)
- [ ] Android Google girişi için: Firebase'e google-services.json + SHA-1 ekle
- [ ] Mağaza listesi + feature graphic (1024x500)
- [ ] İçerik derecelendirme + Veri güvenliği formları
- [ ] Abonelik fiyatları (4 ürün, ₺)
- [ ] 14 günlük kapalı test (12 test kullanıcısı) → production

## ✅ Tamamlandı (1.0)

- Gerçek haberler (TR + yabancı kaynaklar), tam metin, görseller, çeviri
- Deprem/afet (USGS + GDACS), zengin içerik + harita
- Life Radar Asistan (Groq), her yerde "Life Radar Asistan" adı
- Google + Apple ile giriş
- Premium/VIP ekranları, mağaza fiyatı tutarlılığı
- Abonelik durumu çıkışta sıfırlanır
- Bildirim/Gizlilik/Hesap yönetimi ekranları
- Radar: Sağlık/Ekonomi/Enerji/Siber/Afet/Seyahat detayları
- Kayıt anketi (yaş, yaşam, sağlık, finans) → kişisel AI
- Sesli okuma (flutter_tts, iOS ses oturumu)
- Onboarding turu (4 adım)
- Görsel önbellekleme (cached_network_image)
- Uygulama içi puan isteği (3. açılış)
- Destek sayfası + gizlilik politikası (worker'da canlı)
- App Store metinleri + ekran görüntüleri (1290x2796, 1284x2778, 2048x2732)
- Codemagic otomatik benzersiz build numarası

## 🔜 1.1 Güncellemesi — Gerçek Push Bildirimleri (app kapalıyken)

> Yarım günlük, ayrı bir iş. Birçok panel adımı var. 1.0 yayınlandıktan sonra
> aşağıdaki sırayla yapılacak.

### Aşama 1 — Apple/Firebase panel hazırlığı
1. Apple Developer → Identifiers → `com.liferadar.lifeRadar` → **Push Notifications** capability'yi aç
2. Apple Developer → Keys → yeni **APNs Auth Key (.p8)** oluştur (Key ID + Team ID not al)
3. Firebase Console → Project Settings → Cloud Messaging → iOS app → **APNs key (.p8)** yükle (Key ID + Team ID gir)
4. Firebase'den **GoogleService-Info.plist** (iOS) ve **google-services.json** (Android) indir

### Aşama 2 — Kod (client)
5. `firebase_core` + `firebase_messaging` paketleri
6. iOS: GoogleService-Info.plist'i Runner'a ekle; Push + Background Modes
   (remote notification) capability; `aps-environment` entitlement
7. Android: google-services.json + google-services gradle eklentisi
8. Uygulamada: bildirim izni iste, FCM token al, token'ı worker'a kaydet
9. Ön planda/arka planda mesaj işleme

### Aşama 3 — Sunucu (worker)
10. Worker'a `/api/register-token` (token'ları KV'de sakla)
11. Worker'a FCM HTTP v1 ile gönderim (Firebase **service account** JSON → OAuth)
12. Cron tetikleyici: feed'i tara, kritik gelişmede ilgili token'lara push gönder

## ✅ Eklenen uygulama içi özellikler (Parti 1-6)

### Parti 1 — Acil Durum/Hazırlık
- [x] İnteraktif acil çanta listesi (işaretle, % hazırlık)
- [x] Hızlı acil arama (tek numara 112 + 2 kişisel kişi, rehberden seç)

### Parti 2 — Acil + Asistan
- [x] Aile acil planı (buluşma noktası, iletişim)
- [x] Asistan: önerilen sorular
- [x] Asistan: sohbet geçmişi (kalıcı)

### Parti 3 — Haber/İçerik
- [x] "Senin İçin" akışı (takip + profil)
- [x] Günün özeti kartı ("Bugün Öne Çıkanlar")
- [x] Kayıt klasörleri (konuya göre grupla)
- [x] Kaynak seçimi (AA/NTV/Guardian...)

### Parti 4 — Risk Radarı
- [x] Risk geçmişi grafiği (Radar ekranında)
- [x] Çoklu şehir takibi (kendi + memleket/aile şehri)

### Parti 5 — Dış veri (worker endpoint'leri)
- [x] Döviz/altın kartı (USD/EUR/gram altın)
- [x] Hava durumu + hava kalitesi (konuma göre)

### Parti 6 — Büyük işler
- [x] Harita görünümü (yakındaki depremler — flutter_map/OSM)
- [x] Sesli soru sorma (mikrofon, speech_to_text)
- [ ] Ana ekran widget'ı — ERTELENDİ: iOS'ta ayrı "Widget Extension" hedefi
      gerektirir (Xcode'da native kurulum). Mac/Xcode ortamında yapılacak.

## 🔜 Diğer (opsiyonel, sonra)
- Google Play tam yayını (mağaza listesi + 14 günlük kapalı test + production)
- Karanlık mod
- Daha fazla haber kaynağı / kategori
