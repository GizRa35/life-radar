# Life Radar — Yol Haritası ve Yapılacaklar

Bu dosya, unutmamak için tutulur. Tamamlananları ve kalanları gösterir.

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

## 🔜 Uygulama içi yeni özellikler (partiler halinde)

### Parti 1 — Acil Durum/Hazırlık
- [ ] İnteraktif acil çanta listesi (işaretle, % hazırlık)
- [ ] Hızlı acil arama (AFAD/112 + kişisel acil kişiler)

### Parti 2 — Acil + Asistan
- [ ] Aile acil planı (buluşma noktası, iletişim)
- [ ] Asistan: önerilen sorular
- [ ] Asistan: sohbet geçmişi (kalıcı)

### Parti 3 — Haber/İçerik
- [ ] "Senin İçin" akışı (takip + profil)
- [ ] Günün özeti kartı ("Bugün seni ilgilendiren 3 gelişme")
- [ ] Kayıt klasörleri (konuya göre grupla)
- [ ] Kaynak seçimi (AA/NTV/Guardian...)

### Parti 4 — Risk Radarı
- [ ] Risk geçmişi grafiğini ekrana koy
- [ ] Çoklu şehir takibi (kendi + memleket/aile şehri)

### Parti 5 — Dış veri (worker endpoint'leri)
- [ ] Döviz/altın widget'ı (USD/EUR/gram altın)
- [ ] Hava durumu + hava kalitesi (konuma göre)

### Parti 6 — Büyük işler
- [ ] Harita görünümü (yakındaki depremler)
- [ ] Sesli soru sorma (mikrofon, speech-to-text)
- [ ] Ana ekran widget'ı (native WidgetKit/Android)

## 🔜 Diğer (opsiyonel, sonra)
- Google Play tam yayını (mağaza listesi + 14 günlük kapalı test + production)
- Karanlık mod
- Daha fazla haber kaynağı / kategori
