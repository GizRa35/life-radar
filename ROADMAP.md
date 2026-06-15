# Life Radar — Yol Haritası ve Yapılacaklar

Bu dosya, unutmamak için tutulur. Tamamlananları ve kalanları gösterir.

---

## ✅ DURUM (14 Haz 2026)
- 🍎 **iOS:** App Store incelemesinde (Waiting for Review). Banka/sözleşme/vergi
  Active; ilk red (IAP hatası + veri sorusu) düzeltilip yeniden gönderildi.
  Manuel yayın seçili → onay gelince "Release"e basılacak.
  ⚠️ Gönderilen build 1781168282 ESKİ — 1.0.1'de güncellenecek (aşağıda).
- 🤖 **Android:** Kapalı test (Closed testing - Alpha) incelemede. AAB build 69
  (en güncel kod). Üretim için: 12 testçi opt-in (şu an ~3) + 14 gün şart.
- 💰 **AdMob:** entegre + çalışıyor (istek geliyor). Gerçek gelir yayın sonrası.
  Banka/vergi: gelir birikince Google açacak (şu an kilitli, normal).

---

## 🔜 1.1 YOL HARİTASI (sonraki sürüm)

### A) iOS'u Android ile eşitle (1.0.1 — öncelikli)
- [ ] Resmi 4 renkli Google logosu (giriş)
- [ ] 4 ölü kaynak düzeltmesi (Sözcü Çevre / AA Yaşam / NTV Türkiye)
- [ ] Gündem + AI asistan kalan Türkçe metinler (EN modunda)
- [ ] in_app_review kaldırma (Android'de yapıldı; iOS'a da yansısın)

### B) Yeni özellikler
- [ ] Push bildirim (firebase_messaging + worker FCM; APNs Firebase'de hazır)
- [ ] Ana ekran widget'ı (iOS + Android)
- [ ] Daha iyi AI sesi (Miso One değerlendirilecek veya bulut TTS)
- [ ] in_app_review'i uyumlu sürümle geri ekle

### C) Gelir / güvenlik
- [ ] ATT + SKAdNetwork (iOS — kişiselleştirilmiş reklam, daha yüksek gelir)
- [ ] Sunucu tarafı abonelik doğrulama (sahte premium engeli)
- [ ] AdMob banka/vergi (gelir ₺200'e yaklaşınca)

### D) Android tamamlama
- [ ] Google ile giriş (Android) → google-services.json + SHA-1
- [ ] 14 gün test bitince → "Apply for production"

### E) Opsiyonel
- [ ] Mediastack / GNews API → BBC/CNN/Reuters gibi RSS'siz kaynaklar
- [ ] Play feature graphic'i daha şık tasarla

---

## 🚀 YAYIN İÇİN KALANLAR (eski liste — büyük kısmı TAMAMLANDI ✅)

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

### 1.5) Reklam — gerçek AdMob kimlikleri (yayından önce)
- [ ] AdMob hesabı aç (admob.google.com) → 2 uygulama ekle (iOS + Android)
- [ ] App ID'leri al → ios/Info.plist GADApplicationIdentifier +
      Android meta-data APPLICATION_ID güncelle
- [ ] Banner + Interstitial reklam birimleri oluştur (iOS+Android) →
      lib/core/ads_config.dart içindeki TEST kimliklerini gerçekleriyle değiştir
- [ ] iOS: Info.plist'e SKAdNetworkItems + NSUserTrackingUsageDescription (ATT)
- NOT: Şu an TEST reklamları çalışıyor; gerçek gelir için yukarıdakiler gerekir.
      Gerçek kimlik gelmeden gerçek reklamlara TIKLAMA (hesap kapanır).

### 2) Android — Google Play (sonra)
- [ ] Android Google girişi için: Firebase'e google-services.json + SHA-1 ekle
- [ ] Mağaza listesi + feature graphic (1024x500)
- [ ] İçerik derecelendirme + Veri güvenliği formları
- [ ] Abonelik fiyatları (4 ürün, ₺)
- [ ] 14 günlük kapalı test (12 test kullanıcısı) → production

## ⭐ YARIN YAPILACAK — Sunucu tarafı abonelik doğrulama

Amaç: (1) hangi HESABIN abone olduğunu görebilmek, (2) sahte/yerel tier'ı
engellemek (gerçek satın alma kanıtı). ~Yarım gün, backend ağırlıklı.

### Hazırlık (paneller)
- [ ] App Store Connect → App-Specific **Shared Secret** al (veya App Store
      Server API anahtarı) — Apple makbuz doğrulama için
- [ ] Google Play → **service account** + Play Developer API erişimi
      (purchases.subscriptions.get için)
- [ ] Cloudflare → token/abone kaydı için **KV namespace** oluştur

### Worker (backend)
- [ ] `/api/verify-purchase` endpoint: {platform, productId, receipt/token,
      firebaseIdToken} alır
- [ ] Apple: verifyReceipt / App Store Server API ile makbuzu doğrula
- [ ] Google: purchases.subscriptions.get ile token'ı doğrula
- [ ] Geçerliyse: Firebase kullanıcısını (localId) KV'ye "premium/vip" olarak yaz
      (+ ürün, bitiş tarihi)
- [ ] (Ops.) Apple/Google sunucu bildirimleri (yenileme/iptal) için webhook

### Uygulama (client)
- [ ] Satın alma sonrası makbuzu + Firebase idToken'ı `/api/verify-purchase`'a
      gönder; tier'ı SUNUCU onayından sonra aç
- [ ] Açılışta tier'ı sunucudan da teyit et (yerel + sunucu)

### Sahibi için (sen)
- [ ] Basit korumalı admin endpoint / liste: hangi hesaplar abone (KV'den)

---

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
1. [x] Push Notifications capability açıldı (App ID)
2. [x] APNs Auth Key hazır — Key ID: TR253424GC, Team ID: 7K8SDL5G3Q
3. [x] Firebase Cloud Messaging'e .p8 YÜKLENDİ
4. [ ] Firebase'den GoogleService-Info.plist (iOS) + google-services.json (Android) indir

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
- TAM İNGİLİZCE ARAYÜZ (i18n): tüm ekranlardaki metinleri .arb ile çevir —
  büyük iş; şu an "Haber Dili" sadece haberleri çevirir, arayüz Türkçe
- BULUT TTS (yüksek kaliteli ses): worker → Google/Azure TTS → MP3 → just_audio
  ile oynat. Cihaz sesinden çok daha doğal; ücretli/anahtar gerekir
