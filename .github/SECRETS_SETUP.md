# GitHub Actions — Secret Kurulumu (ücretsiz CI)

Codemagic dakikaların bittiğinde, public repo'da **GitHub Actions ile ücretsiz**
derleme yaparsın. İki workflow var:
- **Android AAB (Google Play)** → `.github/workflows/android.yml`
- **iOS TestFlight** → `.github/workflows/ios.yml`

Aşağıdaki secret'ları **bir kez** eklemen yeterli.

## Secret'lar nereye eklenir?

GitHub'da repo → **Settings** → **Secrets and variables** → **Actions** →
**New repository secret**. Her satır için ad (Name) BİREBİR aşağıdaki gibi olmalı.

---

## Android için (5 secret)

| Secret adı | Nasıl elde edilir |
|---|---|
| `KEYSTORE_BASE64` | Komut 1 (aşağıda) — keystore'un base64'ü |
| `KEYSTORE_PASSWORD` | `android/key.properties` dosyasındaki `storePassword` değeri |
| `KEY_ALIAS` | `android/key.properties` dosyasındaki `keyAlias` değeri |
| `KEY_PASSWORD` | `android/key.properties` dosyasındaki `keyPassword` değeri |
| `GOOGLE_SERVICES_JSON` | `life/GOOGLE_SERVICES_JSON_base64.txt` dosyasının İÇERİĞİ (zaten base64) |

**Komut 1** — PowerShell'de çalıştır, base64 panoya kopyalanır, sonra secret'a yapıştır:
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$PWD\android\upload-keystore.jks")) | Set-Clipboard
```

`GOOGLE_SERVICES_JSON` için:
```powershell
Get-Content life\GOOGLE_SERVICES_JSON_base64.txt -Raw | Set-Clipboard
```

---

## iOS için (5 secret)

| Secret adı | Nasıl elde edilir |
|---|---|
| `GOOGLE_SERVICE_INFO_PLIST` | `life/GOOGLE_SERVICE_INFO_PLIST_base64.txt` dosyasının İÇERİĞİ (zaten base64) |
| `ASC_PRIVATE_KEY` | `AuthKey_AZA75TUHQL.p8` dosyasının TAM içeriği (`-----BEGIN...` dahil) |
| `ASC_KEY_ID` | `AZA75TUHQL` (anahtar dosyasının adındaki kod) |
| `ASC_ISSUER_ID` | App Store Connect → Kullanıcılar ve Erişim → Tümleştirmeler → App Store Connect API → en üstteki **Issuer ID** |
| `CERTIFICATE_PRIVATE_KEY` | Komut 2 — yeni bir imzalama özel anahtarı üret |

`GOOGLE_SERVICE_INFO_PLIST` için:
```powershell
Get-Content life\GOOGLE_SERVICE_INFO_PLIST_base64.txt -Raw | Set-Clipboard
```

`ASC_PRIVATE_KEY` için (panoya kopyalar):
```powershell
Get-Content AuthKey_AZA75TUHQL.p8 -Raw | Set-Clipboard
```

**Komut 2** — `CERTIFICATE_PRIVATE_KEY` üret (Git Bash'te çalıştır):
```bash
openssl genrsa 2048
```
Çıktının TAMAMINI (`-----BEGIN PRIVATE KEY-----` ... `-----END PRIVATE KEY-----`
veya `RSA PRIVATE KEY`) kopyalayıp secret'a yapıştır.

> Not: Bu yeni bir özel anahtar; CI ilk çalıştığında buna ait bir App Store
> dağıtım sertifikası **otomatik oluşturur**. Eğer "maximum number of
> certificates" hatası alırsan, Apple Developer portal → Certificates'ten eski
> bir "Apple Distribution" sertifikasını silip tekrar dene.

---

## Çalıştırma

Secret'lar eklendikten sonra: GitHub repo → **Actions** sekmesi → soldan
workflow'u seç (**Android AAB** veya **iOS TestFlight**) → sağda
**Run workflow** → **Run**.

- **Android:** bitince **Artifacts** altından `app-release-aab` indir →
  Google Play Console'a yükle.
- **iOS:** otomatik TestFlight'a yüklenir (ayrıca `.ipa` artifact olarak da iner).

> public repo'da macOS dahil dakikalar **ücretsiz ve sınırsız** — Codemagic
> dakikalarına bir daha takılmazsın.
