# Life Radar — Tasarım & Mimari Planı

> Kullanıcıların dünya gündemini, sağlık gelişmelerini, ekonomik olayları, doğal
> afetleri ve küresel riskleri tek platformda takip ettiği, yapay zekâ destekli
> kişisel etki analizi sunan Flutter uygulaması.

## 1. Ürün Özü

Amaç haber göstermek değildir. Üç soruya cevap verir:

| Soru | Uygulama karşılığı |
|------|--------------------|
| **Ne oluyor?** | Kategorize edilmiş küresel olay akışı (Radar) |
| **Beni etkiler mi?** | Kullanıcı bağlamına göre AI etki skoru (0–100) |
| **Ne yapmalıyım?** | AI eylem önerileri + hazırlık kontrol listesi |

## 2. Olay Kategorileri (Radar Eksenleri)

1. **Dünya Gündemi** — siyaset, çatışma, diplomasi
2. **Sağlık** — salgın, ilaç, gıda/su güvenliği, sağlık uyarıları
3. **Ekonomi** — enflasyon, döviz, piyasa, enerji fiyatları
4. **Doğal Afetler** — deprem, sel, yangın, fırtına
5. **Küresel Riskler** — iklim, siber, tedarik zinciri

## 3. MVP Kapsamı (kararlaştırıldı)

- **Orta kapsam**: 3–4 kategori + AI
- Veri kaynakları: önce **ücretsiz/anahtarsız** olanlar
- AI sağlayıcı: **Claude / Anthropic API** (kullanıcı kendi anahtarını profilden girer)

MVP'de aktif kategoriler: **Doğal Afet (deprem)**, **Dünya Gündemi**, **Ekonomi**.

## 4. Tasarım Dili

**Genel stil:** Modern, premium, güven veren, resmi kurum hissi, Apple kalitesinde
arayüz, minimal, sade ikonlar, yüksek okunabilirlik.

### Renk Paleti

| Rol | Renk | HEX | Kullanım |
|-----|------|-----|----------|
| Ana renk | Koyu Lacivert | `#0A2342` | Menü, başlıklar, navigasyon |
| İkincil renk | Turkuaz | `#00B8D9` | Butonlar, vurgular, AI cevapları, grafikler |
| Arka plan | Beyaz | `#FFFFFF` | Genel zemin |
| Kart arka planı | Açık Gri | `#F5F7FA` | Kartlar |
| Düşük risk | Yeşil | `#34C759` | Aciliyet: low |
| Orta risk | Sarı | `#FFB800` | Aciliyet: medium |
| Yüksek risk | Kırmızı | `#FF453A` | Aciliyet: high/critical |

## 5. Ekranlar (Bilgi Mimarisi)

> Tüm ekranların içerik detayları için `SCREENS.md`. Slogan:
> **"Dünyayı Anla. Riskleri Gör. Hazırlıklı Ol."**

11 spec ekranı, 5 sekmeli alt menü + global elemanlara şöyle bağlanır:

**Alt navigasyon (5 sekme):**

1. **Ana Sayfa** (Sayfa 1) — 30 saniyede gündem: Günün Özeti, Dünya/Türkiye Risk Endeksi, Son Dakika, AI Günlük Analizi, öne çıkan sağlık & ekonomi
2. **Gündem** (Sayfa 2) — 9 kategori sekmesi: Dünya·Türkiye·Sağlık·Ekonomi·Teknoloji·Enerji·Güvenlik·İklim·Afetler
3. **Radar** (Sayfa 3) — Kişisel Risk Puanı (0–100) + 6 risk alanı. Drill-down:
   - **Sağlık Radarı** (Sayfa 6) ← Sağlık Riski'ne tıklayınca
   - **Kriz Radarı** (Sayfa 7) ← Ekonomik/Enerji/Siber riske tıklayınca
4. **Rehber** (Sayfa 8 Acil Durum Rehberi) — Deprem/Sel/Yangın vb. hazırlık kılavuzları
5. **Profil** (Sayfa 11) — Kayıtlı haberler, takip edilen konular, bildirim ayarları, dil, gizlilik, hesap

**Global elemanlar (sekme dışı):**
- **AI Asistanı** (Sayfa 9) — her ekranda sağ altta yüzen turkuaz buton; tam ekran sohbet açar
- **Bildirimler** (Sayfa 10) — üst bardaki zil ikonundan açılan **ayrı tam ekran** (Sağlık/Ekonomi/Afet/Dünya/Sistem)
- **Olay Detayı** — bir habere tıklayınca açılır; iki bölüm içerir:
  - **Bu Beni Etkiler mi?** (Sayfa 4) — etkilenme olasılığı, kimler, Türkiye etkisi, kişisel etki, süre (grafikli)
  - **Ne Yapmalıyım?** (Sayfa 5) — YAPILACAKLAR / YAPILMAYACAKLAR listeleri

## 6. Veri Kaynakları

**Güvenilir kaynak listesi (ürün hedefi):** WHO · CDC · Reuters · AP News · BBC ·
Dünya Bankası · IMF · OECD · Resmi Meteoroloji Kurumları · Resmi Afet Kurumları.

**MVP teknik erişim** (ücretsiz/anahtarsız ara kaynaklar; GDELT zaten Reuters/AP/BBC tarar):

| Kategori | Kaynak | Anahtar | Not |
|----------|--------|---------|-----|
| Deprem | USGS Earthquake API | Hayır | Gerçek zamanlı, GeoJSON |
| Dünya / Ekonomi haber | GDELT 2.0 Doc API | Hayır | Reuters/AP/BBC dahil küresel tarama |
| Döviz / ekonomi | Açık döviz API | Hayır (ücretsiz katman) | Faz 2 |
| Sağlık uyarıları | WHO / CDC RSS feed | Hayır | Faz 2+ |
| AI analiz | Anthropic Claude API | Evet (kullanıcı) | Etki + eylem motoru |

## 7. Teknik Mimari (Flutter)

Katmanlı yapı (Glow Rituals'taki "tek dosya / untyped map" yaklaşımından kaçınılır;
tipli modeller kullanılır):

```
lib/
├── main.dart                  # App girişi, routing, tema
├── core/
│   ├── theme.dart             # Renk paleti, aciliyet renkleri
│   └── constants.dart
├── models/                    # Tipli modeller
│   ├── radar_event.dart
│   ├── impact_analysis.dart
│   ├── action_item.dart
│   ├── event_category.dart    # enum + meta
│   └── user_context.dart
├── services/
│   ├── feed/
│   │   ├── feed_source.dart            # ortak arayüz
│   │   ├── earthquake_source.dart      # USGS
│   │   ├── news_source.dart            # GDELT
│   │   └── feed_aggregator.dart
│   ├── ai/
│   │   └── impact_engine.dart          # Anthropic Claude
│   └── storage_service.dart            # SharedPreferences + cache
├── state/
│   └── app_state.dart         # Provider (ChangeNotifier)
├── screens/
│   ├── home_screen.dart            # Sayfa 1 — Ana Sayfa
│   ├── agenda_screen.dart          # Sayfa 2 — Gündem (9 kategori)
│   ├── radar_screen.dart           # Sayfa 3 — Radar (kişisel risk puanı)
│   ├── health_radar_screen.dart    # Sayfa 6 — Sağlık Radarı (drill-down)
│   ├── crisis_radar_screen.dart    # Sayfa 7 — Kriz Radarı (drill-down)
│   ├── guide_screen.dart           # Sayfa 8 — Acil Durum Rehberi
│   ├── profile_screen.dart         # Sayfa 11 — Profil
│   ├── notifications_screen.dart   # Sayfa 10 — Bildirimler (tam ekran)
│   ├── ai_assistant_screen.dart    # Sayfa 9 — AI Asistanı (yüzen butondan)
│   └── event_detail_screen.dart    # Sayfa 4 + 5 — Etki + Ne Yapmalıyım
└── widgets/
    ├── main_scaffold.dart          # 5 sekmeli alt nav + AI yüzen buton + zil
    ├── event_card.dart             # Başlık·Özet·Risk·Kaynak·Detay
    ├── risk_badge.dart
    └── risk_gauge.dart             # 0–100 kişisel risk puanı göstergesi
```

- **State:** Provider (`ChangeNotifierProvider`, tek `AppState`)
- **Persistence:** `shared_preferences` + olay/analiz cache
- **Modeller:** tipli Dart sınıfları (JSON serileştirme ile)

## 8. AI Etki Motoru

Akış:

```
RadarEvent + UserContext
        │
        ▼
   Anthropic Claude API  (yapılandırılmış JSON çıktı)
        │
        ▼
ImpactAnalysis {
  impactScore: 0–100,
  urgency: low | medium | high | critical,
  reasoning: String,
  actions: List<ActionItem>
}
```

- Kullanıcı bağlamı (konum, meslek, sağlık, finans, aile) prompt'a girer
- Çıktı cache'lenir → her açılışta token harcanmaz
- API anahtarı yoksa AI özellikleri pasif, radar yine çalışır

### Guardrail (sistem prompt'una sabit kısıt)

AI çıktısı **kesinlikle** şunları içermez:
komplo teorileri · korku yayma · kehanet/fal · kesin yatırım tavsiyesi ·
kesin sağlık teşhisi · siyasi propaganda · doğrulanmamış haberler.

Ton: sakin, kanıta dayalı, güven veren, resmi kurum üslubu. Belirsizlikte
kullanıcıyı **resmi kaynaklara** yönlendirir.

## 9. Veri Modelleri (taslak)

- **RadarEvent**: id, title, summary, category, source, url, publishedAt, location?, severity
- **EventCategory** (enum): worldAgenda, health, economy, naturalDisaster, globalRisk
- **ImpactAnalysis**: eventId, impactScore, urgency, reasoning, actions, generatedAt
- **ActionItem**: id, text, done, priority
- **UserContext**: location, profession, healthNotes, financialSensitivity, familyInfo

## 10. Yol Haritası (Fazlar)

- **Faz 0** — İskelet: tema, modeller, navigasyon, AppState (✅ flutter create yapıldı)
- **Faz 1** — Radar ekranı + USGS deprem kaynağı (anahtarsız, hızlı sonuç)
- **Faz 2** — GDELT haber/ekonomi kaynağı + Profil/Bağlam ekranı
- **Faz 3** — AI etki motoru (Claude) + Olay Detayı analizi
- **Faz 4** — Beni Etkileyenler feed + Eylem Merkezi
- **Faz 5** — Bildirimler, cache, ince ayar, tema

## 11. Bağımlılıklar (planlanan)

- `provider` — state yönetimi
- `http` — API çağrıları (USGS, GDELT, Anthropic)
- `shared_preferences` — yerel kalıcılık
- `intl` — tarih/format
- `url_launcher` — kaynak linkleri
- (Faz 5) `flutter_local_notifications` — uyarılar
