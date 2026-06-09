import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/app_notification.dart';
import '../models/crisis_item.dart';
import '../models/event_category.dart';
import '../models/family_member.dart';
import '../models/health_alert.dart';
import '../models/radar_event.dart';
import '../models/risk_area.dart';
import '../models/subscription.dart';
import '../models/user_context.dart';
import '../models/user_location.dart';
import '../services/auth_service.dart';
import '../services/google_signin.dart';
import '../services/apple_signin.dart';
import '../services/review_service.dart';
import '../services/local_store.dart';
import '../services/notify.dart';
import '../services/ai/groq_service.dart';
import '../services/feed/earthquake_source.dart';
import '../services/feed/feed_service.dart';
import '../services/feed/translation_service.dart';
import '../services/location_service.dart';
import '../services/purchase_service.dart';

/// Tek merkezi uygulama durumu (Provider / ChangeNotifier).
///
/// MVP'de veriler MockData'dan gelir; Faz 1+'de USGS/GDELT/Claude servisleriyle
/// değiştirilecek.
class AppState extends ChangeNotifier {
  AppState() {
    _loadSession();
    _loadUserContext();
    _loadAvatar();
    _loadAlertSettings();
    _loadPrivacy();
    _loadRiskHistory();
    _loadSaved();
    _loadFollows();
    _loadOnboard();
    _loadTier();
    _initPurchases();
    _bumpAppOpens();
    // Açılışta gerçek haber/afet verisini çek (başlangıçta mock gösterilir).
    loadFeeds();
    // Konumu tespit et (IP tabanlı) — afet riski buna göre güncellenir.
    detectLocation();
  }

  // ---- Bildirim ayarları (eşik + kategori + tür + sessiz saatler) ----
  int _alertThreshold = 70;
  bool _alertsEnabled = false;
  int get alertThreshold => _alertThreshold;
  bool get alertsEnabled => _alertsEnabled;

  // Bildirim türleri (varsayılan: yalnızca kritik açık).
  bool _notifCritical = true;
  bool _notifDailySummary = false;
  bool _notifFollowedNews = false;
  bool _notifRiskChange = false;
  bool get notifCritical => _notifCritical;
  bool get notifDailySummary => _notifDailySummary;
  bool get notifFollowedNews => _notifFollowedNews;
  bool get notifRiskChange => _notifRiskChange;

  // Kategori bazlı bildirim (boş = ilk kurulum → hepsi açık sayılır).
  final Set<EventCategory> _notifCategories = {...EventCategory.values};
  bool isNotifCategoryOn(EventCategory c) => _notifCategories.contains(c);

  // Sessiz saatler (Rahatsız Etme).
  bool _quietEnabled = false;
  int _quietStart = 23; // saat (0-23)
  int _quietEnd = 7;
  bool get quietEnabled => _quietEnabled;
  int get quietStart => _quietStart;
  int get quietEnd => _quietEnd;

  /// Tarayıcı bildirim izni durumu: granted | denied | default | unsupported.
  String get notifPermission => notifyPermission();

  // ---- Gizlilik kontrolleri ----
  bool _locationEnabled = true;
  bool _aiShareContext = true;
  bool get locationEnabled => _locationEnabled;
  bool get aiShareContext => _aiShareContext;

  void _loadPrivacy() {
    _locationEnabled = (lsGet('lr_loc_on') ?? '1') == '1';
    _aiShareContext = (lsGet('lr_ai_share') ?? '1') == '1';
  }

  // ---- Onboarding (ilk açılış karşılama turu) ----
  bool _onboarded = false;
  bool get onboardingDone => _onboarded;

  void _loadOnboard() {
    _onboarded = lsGet('lr_onboard') == '1';
  }

  void completeOnboarding() {
    _onboarded = true;
    lsSet('lr_onboard', '1');
    notifyListeners();
  }

  // ---- Uygulama içi puan isteği ----
  int _appOpens = 0;
  bool _reviewAsked = false;

  void _bumpAppOpens() {
    _appOpens = (int.tryParse(lsGet('lr_opens') ?? '0') ?? 0) + 1;
    lsSet('lr_opens', '$_appOpens');
    _reviewAsked = lsGet('lr_reviewed') == '1';
  }

  /// Birkaç açılıştan sonra (ve yalnızca bir kez) mağaza puan diyaloğunu göster.
  /// Kullanıcıyı rahatsız etmemek için 3. açılışta tetiklenir.
  Future<void> maybeRequestReview() async {
    if (_reviewAsked || _appOpens < 3) return;
    _reviewAsked = true;
    lsSet('lr_reviewed', '1');
    await requestStoreReview();
  }

  void setLocationEnabled(bool v) {
    _locationEnabled = v;
    lsSet('lr_loc_on', v ? '1' : '0');
    notifyListeners();
    if (v) {
      detectLocation();
    } else {
      // Konum verisini bellekten temizle.
      _location = null;
      _localDisasterScore = null;
      notifyListeners();
    }
  }

  void setAiShareContext(bool v) {
    _aiShareContext = v;
    lsSet('lr_ai_share', v ? '1' : '0');
    notifyListeners();
  }

  // ---- Gizlilik: veri özeti / dışa aktarma / temizleme ----

  /// Uygulamanın cihazda tuttuğu tüm anahtarlar (fabrika sıfırlaması için).
  static const List<String> _storageKeys = [
    'lr_ctx', 'lr_token', 'lr_email', 'lr_name', 'lr_guest',
    'lr_avatar', 'lr_avatar_manual',
    'lr_alerts', 'lr_alert_thr', 'lr_alert_last',
    'lr_nt_crit', 'lr_nt_daily', 'lr_nt_follow', 'lr_nt_risk', 'lr_nt_cats',
    'lr_quiet', 'lr_quiet_s', 'lr_quiet_e',
    'lr_riskhist', 'lr_daily_last', 'lr_follow_last',
    'lr_loc_on', 'lr_ai_share',
    'lr_saved', 'lr_follows', 'lr_onboard', 'lr_tier',
    'lr_opens', 'lr_reviewed',
  ];

  int get savedCount => _savedEventIds.length;
  int get riskHistoryCount => _riskHistory.length;
  int get followedCount => _followedTopics.length;
  bool get hasSession => _idToken != null;

  /// Cihazda saklanan tüm verilerin dışa aktarılabilir özeti (JSON için).
  Map<String, dynamic> exportData() => {
        'exportedAt': DateTime.now().toIso8601String(),
        'app': 'Life Radar',
        'account': {
          'email': _authEmail,
          'name': displayName,
          'guest': _guest,
        },
        'userContext': _userContext.toJson(),
        'savedNews': savedEvents
            .map((e) => {
                  'title': e.title,
                  'url': e.url,
                  'category': e.category.name,
                })
            .toList(),
        'followedTopics': _followedTopics.map((e) => e.name).toList(),
        'riskHistory': _riskHistory,
        'notificationSettings': {
          'enabled': _alertsEnabled,
          'threshold': _alertThreshold,
          'critical': _notifCritical,
          'dailySummary': _notifDailySummary,
          'followedNews': _notifFollowedNews,
          'riskChange': _notifRiskChange,
          'categories': _notifCategories.map((e) => e.name).toList(),
          'quietHours': {
            'enabled': _quietEnabled,
            'start': _quietStart,
            'end': _quietEnd,
          },
        },
        'privacy': {
          'locationEnabled': _locationEnabled,
          'aiShareContext': _aiShareContext,
        },
      };

  void clearSavedEvents() {
    _savedEventIds.clear();
    lsRemove('lr_saved');
    notifyListeners();
  }

  void clearRiskHistory() {
    _riskHistory = [];
    lsRemove('lr_riskhist');
    notifyListeners();
  }

  /// Kişisel bilgileri sıfırlar (dil tercihi korunur).
  void clearPersonalInfo() {
    final lang = _userContext.language;
    _userContext = UserContext(language: lang);
    lsSet('lr_ctx', jsonEncode(_userContext.toJson()));
    notifyListeners();
  }

  /// Fabrika sıfırlaması — tüm yerel veriyi siler ve oturumu kapatır.
  void clearAllData() {
    for (final k in _storageKeys) {
      lsRemove(k);
    }
    _savedEventIds.clear();
    _followedTopics.clear();
    _riskHistory = [];
    _userContext = const UserContext();
    _alertsEnabled = false;
    _notifCritical = true;
    _notifDailySummary = false;
    _notifFollowedNews = false;
    _notifRiskChange = false;
    _notifCategories
      ..clear()
      ..addAll(EventCategory.values);
    _quietEnabled = false;
    _locationEnabled = true;
    _aiShareContext = true;
    _location = null;
    _localDisasterScore = null;
    logout(); // oturum anahtarlarını siler + giriş ekranına döndürür
    notifyListeners();
  }

  void _loadAlertSettings() {
    _alertsEnabled = lsGet('lr_alerts') == '1';
    final t = lsGet('lr_alert_thr');
    if (t != null) _alertThreshold = int.tryParse(t) ?? 70;
    _notifCritical = (lsGet('lr_nt_crit') ?? '1') == '1';
    _notifDailySummary = lsGet('lr_nt_daily') == '1';
    _notifFollowedNews = lsGet('lr_nt_follow') == '1';
    _notifRiskChange = lsGet('lr_nt_risk') == '1';
    _quietEnabled = lsGet('lr_quiet') == '1';
    _quietStart = int.tryParse(lsGet('lr_quiet_s') ?? '23') ?? 23;
    _quietEnd = int.tryParse(lsGet('lr_quiet_e') ?? '7') ?? 7;
    final cats = lsGet('lr_nt_cats');
    if (cats != null) {
      _notifCategories
        ..clear()
        ..addAll(cats
            .split(',')
            .where((s) => s.isNotEmpty)
            .map((s) => EventCategory.values.firstWhere(
                  (c) => c.name == s,
                  orElse: () => EventCategory.world,
                )));
    }
  }

  Future<void> setAlertsEnabled(bool v) async {
    _alertsEnabled = v;
    lsSet('lr_alerts', v ? '1' : '0');
    notifyListeners();
    if (v) {
      await requestNotifyPermission();
      _checkAndAlert();
    }
  }

  void setAlertThreshold(int v) {
    _alertThreshold = v;
    lsSet('lr_alert_thr', '$v');
    notifyListeners();
  }

  void setNotifCritical(bool v) {
    _notifCritical = v;
    lsSet('lr_nt_crit', v ? '1' : '0');
    notifyListeners();
  }

  void setNotifDailySummary(bool v) {
    _notifDailySummary = v;
    lsSet('lr_nt_daily', v ? '1' : '0');
    notifyListeners();
  }

  void setNotifFollowedNews(bool v) {
    _notifFollowedNews = v;
    lsSet('lr_nt_follow', v ? '1' : '0');
    notifyListeners();
  }

  void setNotifRiskChange(bool v) {
    _notifRiskChange = v;
    lsSet('lr_nt_risk', v ? '1' : '0');
    notifyListeners();
  }

  void toggleNotifCategory(EventCategory c) {
    if (!_notifCategories.remove(c)) _notifCategories.add(c);
    lsSet('lr_nt_cats', _notifCategories.map((e) => e.name).join(','));
    notifyListeners();
  }

  void setQuietEnabled(bool v) {
    _quietEnabled = v;
    lsSet('lr_quiet', v ? '1' : '0');
    notifyListeners();
  }

  void setQuietHours(int start, int end) {
    _quietStart = start;
    _quietEnd = end;
    lsSet('lr_quiet_s', '$start');
    lsSet('lr_quiet_e', '$end');
    notifyListeners();
  }

  /// Şu an sessiz saatler içinde miyiz? (gece aşımını da destekler)
  bool get inQuietHours {
    if (!_quietEnabled) return false;
    final h = DateTime.now().hour;
    if (_quietStart == _quietEnd) return false;
    if (_quietStart < _quietEnd) {
      return h >= _quietStart && h < _quietEnd;
    }
    // Gece aşımı (örn. 23 → 7)
    return h >= _quietStart || h < _quietEnd;
  }

  /// Test bildirimi gönder (izin iste, sessiz saat baypas).
  Future<bool> sendTestNotification() async {
    final granted = await requestNotifyPermission();
    if (granted) {
      showNotify('Life Radar', 'Bu bir test bildirimidir. Bildirimler çalışıyor!');
    }
    notifyListeners();
    return granted;
  }

  /// Bildirim izni iste (ayar ekranındaki buton için).
  Future<bool> askNotifyPermission() async {
    final ok = await requestNotifyPermission();
    notifyListeners();
    return ok;
  }

  void _checkAndAlert() {
    if (!_alertsEnabled) return;
    if (inQuietHours) return; // sessiz saatlerde gönderme
    final score = personalRiskScore;
    // Kritik: yalnızca bildirimi açık kategorilerdeki yüksek/kritik gelişmeler.
    final criticalEvents = earlyWarnings
        .where((e) => _notifCategories.contains(e.category))
        .toList();
    final critical = _notifCritical && criticalEvents.isNotEmpty;
    final riskAlert = _notifRiskChange && score >= _alertThreshold;
    if (!critical && !riskAlert) return;
    // 30 dk içinde tekrar uyarma
    final last = int.tryParse(lsGet('lr_alert_last') ?? '0') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - last < 30 * 60 * 1000) return;
    lsSet('lr_alert_last', '$now');
    final body = critical
        ? 'Yüksek/kritik riskli ${criticalEvents.length} gelişme var.'
        : 'Kişisel risk puanın $score (eşik: $_alertThreshold).';
    showNotify('Life Radar Uyarı', body);
  }

  /// Veri yüklendikten sonra: günlük özet + takip edilen konuda yeni haber.
  void _postFeedNotifications() {
    if (!_alertsEnabled || inQuietHours) return;

    // Günlük özet — günde bir kez.
    if (_notifDailySummary) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (lsGet('lr_daily_last') != today) {
        lsSet('lr_daily_last', today);
        showNotify('Life Radar — Günün Özeti', dailySummary);
      }
    }

    // Takip edilen konularda yeni haber — en güncel takip edilen olay değişince.
    if (_notifFollowedNews && _followedTopics.isNotEmpty) {
      final latest = _events
          .where((e) => _followedTopics.contains(e.category) &&
              _notifCategories.contains(e.category))
          .toList();
      if (latest.isNotEmpty) {
        final top = latest.first;
        if (lsGet('lr_follow_last') != top.id) {
          lsSet('lr_follow_last', top.id);
          showNotify('${top.category.label} — yeni gelişme', top.title);
        }
      }
    }
  }

  // ---- VIP: Risk geçmişi ----
  List<int> _riskHistory = [];
  List<int> get riskHistory => List.unmodifiable(_riskHistory);

  void _loadRiskHistory() {
    final raw = lsGet('lr_riskhist');
    if (raw != null) {
      try {
        _riskHistory =
            (jsonDecode(raw) as List).map((e) => (e as num).toInt()).toList();
      } catch (_) {}
    }
  }

  void _recordRiskPoint() {
    _riskHistory.add(personalRiskScore);
    if (_riskHistory.length > 30) {
      _riskHistory = _riskHistory.sublist(_riskHistory.length - 30);
    }
    lsSet('lr_riskhist', jsonEncode(_riskHistory));
  }

  // ---- VIP: Seyahat modu brifingi ----
  Future<String> vipTravelBrief(String destination) => _vip(
        'Sen bir seyahat güvenliği danışmanısın. Verilen hedef için şu '
        'başlıklarla kısa brifing ver: 1) Genel durum 2) Güvenlik 3) Sağlık '
        '(aşı/su/hastalık) 4) Doğal afet riski 5) Pratik öneriler. Korku/kehanet '
        'yok, sakin ve kanıta dayalı. Bağlam: $_ctxLine',
        'Seyahat hedefi: $destination',
      );

  // ---- Kimlik doğrulama (Firebase REST) ----
  final AuthService _auth = AuthService();
  String? _idToken;
  String? _authEmail;
  String? _authName;
  bool _guest = false;

  bool get isLoggedIn => _idToken != null;
  bool get isGuest => _guest;
  String? get authEmail => _authEmail;

  /// Uygulamaya erişim: giriş yapılmış veya misafir.
  bool get gateOpen => isLoggedIn || _guest;

  void _loadSession() {
    final t = lsGet('lr_token');
    final e = lsGet('lr_email');
    if (t != null && t.isNotEmpty) {
      _idToken = t;
      _authEmail = e;
      _authName = lsGet('lr_name');
    }
    // Misafirlik kalıcı değil — eski kaydı temizle ki giriş ekranı gelsin.
    lsRemove('lr_guest');
  }

  void _setSession(String token, String email, [String? name]) {
    _idToken = token;
    _authEmail = email;
    if (name != null && name.trim().isNotEmpty) {
      _authName = name.trim();
      lsSet('lr_name', name.trim());
    }
    _guest = false;
    lsSet('lr_token', token);
    lsSet('lr_email', email);
    lsRemove('lr_guest');
    notifyListeners();
  }

  /// Başarılıysa null, hata varsa Türkçe mesaj döner.
  Future<String?> register(String email, String password) async {
    final r = await _auth.register(email, password);
    if (r.success && r.idToken != null) {
      _setSession(r.idToken!, r.email ?? email, r.displayName);
      return null;
    }
    return r.error ?? 'Kayıt başarısız.';
  }

  Future<String?> login(String email, String password) async {
    final r = await _auth.login(email, password);
    if (r.success && r.idToken != null) {
      _setSession(r.idToken!, r.email ?? email, r.displayName);
      return null;
    }
    return r.error ?? 'Giriş başarısız.';
  }

  /// Google ile giriş (web). Başarılıysa null, hata varsa Türkçe mesaj.
  Future<String?> loginWithGoogle() async {
    final token = await googleAccessToken();
    if (token == null || token.isEmpty) {
      return 'Google girişi iptal edildi veya başarısız.';
    }
    final r = await _auth.signInWithGoogle(token);
    if (r.success && r.idToken != null) {
      _setSession(r.idToken!, r.email ?? 'Google kullanıcısı', r.displayName);
      return null;
    }
    return r.error ?? 'Google girişi başarısız.';
  }

  /// Apple ile giriş (iOS). Başarılıysa null, hata varsa Türkçe mesaj.
  Future<String?> loginWithApple() async {
    final cred = await appleSignIn();
    if (cred == null) {
      return 'Apple girişi iptal edildi veya başarısız.';
    }
    final r = await _auth.signInWithApple(cred.idToken, cred.rawNonce);
    if (r.success && r.idToken != null) {
      _setSession(r.idToken!, r.email ?? 'Apple kullanıcısı', r.displayName);
      return null;
    }
    return r.error ?? 'Apple girişi başarısız.';
  }

  void continueAsGuest() {
    // Yalnızca bu oturum için — kalıcı değil (yenileyince giriş ekranı gelir).
    _guest = true;
    notifyListeners();
  }

  void logout() {
    _idToken = null;
    _authEmail = null;
    _authName = null;
    _guest = false;
    // Abonelik cihaza değil mağaza hesabına bağlıdır: çıkışta sıfırla.
    // Gerçek bir abonelik varsa yeni girişte restorePurchases ile geri gelir.
    _tier = SubscriptionTier.free;
    lsRemove('lr_tier');
    lsRemove('lr_token');
    lsRemove('lr_email');
    lsRemove('lr_name');
    lsRemove('lr_guest');
    notifyListeners();
  }

  // ---- Hesap yönetimi (Firebase REST) ----

  /// Hesap bilgisini getir (doğrulama durumu, tarihler, giriş yöntemi).
  Future<AccountInfo?> fetchAccountInfo() async {
    if (_idToken == null) return null;
    return _auth.getAccountInfo(_idToken!);
  }

  /// Şifre değiştir — başarılıysa null, hata varsa Türkçe mesaj.
  Future<String?> changePassword(String newPassword) async {
    if (_idToken == null) return 'Önce giriş yapın.';
    final r = await _auth.changePassword(_idToken!, newPassword);
    if (r.success) {
      // Yeni idToken ile oturumu güncelle.
      if (r.idToken != null && r.idToken!.isNotEmpty) {
        _idToken = r.idToken;
        lsSet('lr_token', _idToken!);
      }
      notifyListeners();
      return null;
    }
    return r.error ?? 'Şifre değiştirilemedi.';
  }

  /// Şifre sıfırlama e-postası gönder — başarılıysa null, hata varsa mesaj.
  Future<String?> sendPasswordReset() async {
    final email = _authEmail;
    if (email == null || email.isEmpty) return 'Hesaba bağlı e-posta yok.';
    return _auth.sendPasswordReset(email);
  }

  /// E-posta doğrulama bağlantısı gönder — başarılıysa null, hata varsa mesaj.
  Future<String?> sendVerifyEmail() async {
    if (_idToken == null) return 'Önce giriş yapın.';
    return _auth.sendVerifyEmail(_idToken!);
  }

  /// Hesabı kalıcı sil + tüm yerel veriyi temizle.
  /// Başarılıysa null döner ve oturum kapatılır; hata varsa mesaj.
  Future<String?> deleteAccount() async {
    if (_idToken == null) return 'Önce giriş yapın.';
    final err = await _auth.deleteAccount(_idToken!);
    if (err != null) return err;
    clearAllData(); // yerel veriyi sıfırlar + logout
    return null;
  }

  // ---- Konum ----
  final LocationService _locationService = LocationService();
  final EarthquakeSource _eqSource = EarthquakeSource();

  UserLocation? _location;
  UserLocation? get location => _location;
  bool _locating = false;
  bool get locating => _locating;

  /// Konuma göre yerel afet (deprem) risk skoru (0-100). Konum yoksa null.
  int? _localDisasterScore;

  String get locationLabel =>
      _location?.label ?? (_locating ? 'Konum belirleniyor...' : 'Konum belirlenmedi');

  Future<void> detectLocation() async {
    if (!_locationEnabled) return; // gizlilik: konum kapalıysa tespit etme
    _locating = true;
    notifyListeners();
    try {
      final loc = await _locationService.detect();
      if (loc != null) {
        _location = loc;
        _userContext = _userContext.copyWith(location: loc.label);
        if (loc.lat != null && loc.lng != null) {
          _localDisasterScore =
              await _eqSource.nearbyRiskScore(loc.lat!, loc.lng!);
        }
      }
    } catch (_) {
      // konum alınamadı
    } finally {
      _locating = false;
      notifyListeners();
      _checkAndAlert();
    }
  }

  // ---- Veri akışı (gerçek kaynaklar) ----
  final FeedService _feedService = FeedService();
  final GroqService _ai = GroqService();
  final TranslationService _translator = TranslationService();

  /// Başlangıçta mock; gerçek veri gelince güncellenir.
  List<RadarEvent> _events = MockData.events;
  bool _loadingFeeds = false;
  bool get loadingFeeds => _loadingFeeds;

  Future<void> loadFeeds() async {
    _loadingFeeds = true;
    _aiDailyAnalysis = null; // yeni veride yeniden üretilecek
    notifyListeners();
    try {
      final fetched = await _feedService.loadEvents();
      if (fetched.isNotEmpty) _events = fetched;
    } catch (_) {
      // mock veride kal
    } finally {
      _loadingFeeds = false;
      notifyListeners();
    }
    // Yabancı kaynaklı haberleri kullanıcının diline çevir (arka planda).
    await _translateEventsIfNeeded();
    // Gerçek başlıklardan AI günlük analizi (anahtar varsa)
    _generateDailyAnalysis();
    _recordRiskPoint();
    _checkAndAlert();
    _postFeedNotifications();
  }

  /// Kaynağı kullanıcının dilinden farklı olan olayların başlık+özetini çevirir.
  /// Çeviri sunucu proxy'sinde (Google Translate, anahtarsız) yapılır; hata
  /// olursa olaylar orijinal haliyle kalır.
  Future<void> _translateEventsIfNeeded() async {
    // Çeviri worker proxy'sinde yapılır; her platformda çalışır.
    final target = _userContext.language == 'en' ? 'en' : 'tr';
    final indices = <int>[];
    final texts = <String>[];
    for (var i = 0; i < _events.length; i++) {
      final e = _events[i];
      if (e.sourceLang != target) {
        if (indices.length >= 60) break; // makul sınır (hız için)
        indices.add(i);
        texts.add(e.title);
        texts.add(e.summary);
      }
    }
    if (texts.isEmpty) return;
    final translated = await _translator.translate(texts, target);
    if (translated.length != texts.length) return;
    final updated = List<RadarEvent>.from(_events);
    for (var k = 0; k < indices.length; k++) {
      final idx = indices[k];
      // Not: sourceLang ORİJİNAL dilde bırakılır; böylece olay detayında makale
      // gövdesinin de çevrilmesi gerektiği anlaşılır.
      updated[idx] = updated[idx].copyWith(
        title: translated[k * 2],
        summary: translated[k * 2 + 1],
      );
    }
    _events = updated;
    notifyListeners();
  }

  // ---- AI günlük analizi ----
  String? _aiDailyAnalysis;

  Future<void> _generateDailyAnalysis() async {
    if (!hasApiKey || _events.isEmpty) return;
    final headlines = _events.take(8).map((e) => '- ${e.title}').join('\n');
    try {
      final text = await _ai.dailyBriefing(
        apiKey: _apiKey,
        headlines: headlines,
        context: _userContext,
      );
      _aiDailyAnalysis = text;
      notifyListeners();
    } catch (_) {
      // sessizce geç
    }
  }

  // ================= VIP MERKEZİ =================

  // ---- Aile Koruma Merkezi ----
  final List<FamilyMember> _family = [];
  List<FamilyMember> get family => List.unmodifiable(_family);

  void addFamilyMember(FamilyMember m) {
    _family.add(m);
    notifyListeners();
  }

  void removeFamilyMember(String id) {
    _family.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  String get _topHeadlines =>
      _events.take(12).map((e) => '- ${e.title}').join('\n');

  String get _ctxLine {
    // Gizlilik: kullanıcı kişisel veri paylaşımını kapattıysa AI'ya bağlam verme.
    if (!_aiShareContext) {
      return 'Kullanıcı kişisel verilerini paylaşmamayı seçti; genel bir '
          'değerlendirme yap.';
    }
    final c = _userContext;
    final loc = _location?.label ?? c.location;
    final parts = <String>['Konum: $loc'];
    if (c.age.isNotEmpty) parts.add('Yaş: ${c.age}');
    if (c.gender.isNotEmpty) parts.add('Cinsiyet: ${c.gender}');
    if (c.profession.isNotEmpty) parts.add('Meslek: ${c.profession}');
    if (c.healthNotes.isNotEmpty) parts.add('Sağlık: ${c.healthNotes}');
    if (c.financialSensitivity.isNotEmpty) {
      parts.add('Finansal durum: ${c.financialSensitivity}');
    }
    if (c.homeType.isNotEmpty) parts.add('Ev tipi: ${c.homeType}');
    if (c.householdSize.isNotEmpty) parts.add('Hane: ${c.householdSize} kişi');
    if (c.familyInfo.isNotEmpty) parts.add('Aile: ${c.familyInfo}');
    return '${parts.join(', ')}.';
  }

  /// Hane halkı sayısı (kişisel bilgi yoksa aile üyesi + 1, o da yoksa boş).
  String get _householdDesc {
    final h = _userContext.householdSize;
    if (h.isNotEmpty) return h;
    if (_family.isNotEmpty) return '${_family.length + 1}';
    return 'belirtilmedi';
  }

  Future<String> _vip(String system, String user) =>
      _ai.custom(apiKey: _apiKey, system: system, user: user);

  /// 2 — Kişisel AI Analisti: günün en önemli 3 gelişmesi.
  Future<String> vipDailyAnalyst() => _vip(
        'Sen Life Radar Asistan\'sın, kişisel bir analistsin. Kullanıcı bağlamı: $_ctxLine '
        'Güncel başlıklara bakıp kullanıcıyı bugün etkileyebilecek EN ÖNEMLİ '
        '3 gelişmeyi madde madde, her biri için kısa "neden önemli" notuyla ver.',
        'Güncel başlıklar:\n$_topHeadlines',
      );

  /// 4 — Şehir Bazlı Risk Merkezi.
  Future<String> vipCityRisk() {
    final city = _location?.city ?? _userContext.location;
    return _vip(
      'Sen bir şehir risk analistisin. $city şehri için şu başlıkları '
      'değerlendir: Deprem Riski, Yangın Riski, Hava Kalitesi, Su Durumu, '
      'Sağlık Uyarıları. Her başlık için 1-2 cümle ve düşük/orta/yüksek seviye ver. '
      'Kesin tahmin yapma, genel değerlendirme sun.',
      'Şehir: $city. Bağlam: $_ctxLine Güncel başlıklar:\n$_topHeadlines',
    );
  }

  /// 3 — VIP İstihbarat Raporu (haftalık).
  Future<String> vipIntelReport() => _vip(
        'Sen bir istihbarat analistisin. Kullanıcıya HAFTALIK İSTİHBARAT RAPORU '
        'hazırla. Şu başlıklarla, her biri kısa paragraf: 1) Dünya Gündemi '
        '2) Türkiye Gündemi 3) Sağlık Riskleri 4) Ekonomik Riskler '
        '5) Bölgesel Riskler 6) Kişisel Risk Analizi. Resmi, sakin, kanıta '
        'dayalı dil kullan. Bağlam: $_ctxLine',
        'Güncel başlıklar:\n$_topHeadlines',
      );

  /// Akıllı Aksiyon Danışmanı — belirli bir habere göre MİKTARLI, haneye özel
  /// somut hazırlık/aksiyon önerileri.
  Future<String> vipActionPlan(RadarEvent event) {
    return _vip(
      'Sen kişisel hazırlık ve aksiyon danışmanısın. Verilen habere göre, '
      'kullanıcının HANE HALKI SAYISINA ve durumuna ölçeklenmiş SOMUT, MİKTARLI '
      've BÜTÇEYE UYGUN öneriler ver. '
      'Örnek tarz: "4 kişilik hane için ~1 aylık: 20 kg pirinç, 10 kg mercimek, '
      '5 L sıvı yağ" gibi net miktarlar. Konu gıda değilse (iklim/enerji/sağlık/'
      'afet/ekonomi) o konuya uygun somut hazırlık öner (örn. enerji: powerbank, '
      'yakıt; iklim/sıcak: su miktarı, klima bakımı; sağlık: maske/ilaç stoğu). '
      'KESİN TAHMİN/KEHANET YOK, panik YOK; "olası senaryo" dilini kullan ve '
      'gerçekçi, abartısız ol. Hane halkı: $_householdDesc kişi. Bağlam: $_ctxLine '
      'Yanıtı kısa başlıklar + madde madde ver.',
      'Haber başlığı: ${event.title}\nÖzet: ${event.summary}\nKategori: ${event.category.label}',
    );
  }

  /// Genel durumdan (güncel başlıklar) haneye özel miktarlı aksiyon önerileri.
  Future<String> vipSmartActions() {
    return _vip(
      'Sen kişisel hazırlık danışmanısın. Güncel başlıklara ve kullanıcının '
      'hane halkı sayısına göre, önümüzdeki dönem için SOMUT ve MİKTARLI '
      'hazırlık önerileri ver (gıda, su, enerji, sağlık, finans vb. — hangi '
      'konular öne çıkıyorsa). Miktarları haneye ölçekle (örn. "$_householdDesc '
      'kişi için ..."). Kehanet yok, panik yok, gerçekçi ol. Hane: $_householdDesc kişi. '
      'Bağlam: $_ctxLine',
      'Güncel başlıklar:\n$_topHeadlines',
    );
  }

  /// 7 — Erken uyarılar: yüksek/kritik riskli güncel gelişmeler.
  List<RadarEvent> get earlyWarnings => _events
      .where((e) => e.risk == RiskLevel.high || e.risk == RiskLevel.critical)
      .toList();

  /// 5 — Kişisel Acil Durum Planı.
  Future<String> vipEmergencyPlan() {
    final fam = _family.isEmpty
        ? 'aile bilgisi girilmedi'
        : _family.map((m) => m.summaryLine).join('; ');
    return _vip(
      'Sen bir acil durum hazırlık uzmanısın. Kullanıcının aile yapısı, '
      'konumu ve durumuna göre kişiselleştirilmiş bir acil durum hazırlık '
      'planı oluştur (deprem/yangın/sel öncelikli). Maddeler halinde, uygulanabilir.',
      'Aile: $fam. $_ctxLine',
    );
  }

  /// 6 — Haber Doğrulama Sistemi.
  Future<String> vipVerifyNews(String input) => _vip(
        'Sen bir haber doğrulama uzmanısın. Verilen haber metni/linki için: '
        '1) Konunun özeti, 2) Doğruluk değerlendirmesi (kesin hüküm verme, '
        'işaretlere bak), 3) Olası manipülasyon/yanıltma riski, 4) Resmi/güvenilir '
        'kaynak önerisi. Komplo veya kesin yargı yok.',
        'İncelenecek haber:\n$input',
      );

  /// 8 — Gelişmiş Risk Skoru (çok boyutlu).
  Future<String> vipAdvancedScores() => _vip(
        'Kullanıcı için 0-100 arası tahmini risk skorları üret ve her birine '
        'tek cümle gerekçe yaz: Sağlık, Finans, Yaşam Alanı, Aile Koruması, '
        'Seyahat, Küresel Risk, Genel Risk Endeksi. Skorları "Alan: XX/100" '
        'biçiminde ver.',
        'Bağlam: $_ctxLine Güncel başlıklar:\n$_topHeadlines',
      );

  /// 10 — Gelecek Radarı (trend/öngörü, kehanet değil).
  Future<String> vipFutureRadar() => _vip(
        'Sen bir trend analistisin. Güncel başlıklara dayanarak yaklaşan olası '
        'riskleri, dikkat edilmesi gereken trendleri ve gelişmeleri madde madde '
        'özetle. KESİN TAHMİN veya KEHANET YAPMA; "olasılık/eğilim" dilini kullan.',
        'Güncel başlıklar:\n$_topHeadlines',
      );

  /// 1 — Aile üyesine özel analiz.
  Future<String> vipFamilyAnalysis(FamilyMember m) => _vip(
        'Sen bir aile koruma danışmanısın. Belirtilen aile üyesinin yaşı ve '
        'durumuna göre, güncel gelişmeler ışığında ona özel dikkat edilmesi '
        'gereken riskleri ve önerileri kısa maddelerle ver.',
        'Üye bilgileri: ${m.summaryLine}. '
        '$_ctxLine Güncel başlıklar:\n$_topHeadlines',
      );

  // ---- Risk seviyesi → 0-100 değeri ----
  int _riskValue(RiskLevel r) {
    switch (r) {
      case RiskLevel.low:
        return 25;
      case RiskLevel.medium:
        return 55;
      case RiskLevel.high:
        return 82;
      case RiskLevel.critical:
        return 95;
    }
  }

  int _avgRisk(Iterable<RadarEvent> list) {
    if (list.isEmpty) return 50;
    final sum = list.map((e) => _riskValue(e.risk)).reduce((a, b) => a + b);
    return (sum / list.length).round();
  }

  // ---- Bağlam ----
  UserContext _userContext = const UserContext();
  UserContext get userContext => _userContext;

  void updateUserContext(UserContext ctx) {
    final oldGender = _userContext.gender;
    final oldLang = _userContext.language;
    _userContext = ctx;
    lsSet('lr_ctx', jsonEncode(ctx.toJson()));
    if (ctx.gender != oldGender) _applyGenderAvatar(ctx.gender);
    notifyListeners();
    // Dil değiştiyse haberleri yeni dile göre yeniden yükle/çevir.
    if (ctx.language != oldLang) loadFeeds();
  }

  void _loadUserContext() {
    final raw = lsGet('lr_ctx');
    if (raw != null && raw.isNotEmpty) {
      try {
        _userContext =
            UserContext.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
  }

  /// Kişisel bilgi girilmiş mi? (analizlerin kişiselleşmesi için)
  bool get hasPersonalInfo => _userContext.hasInfo;

  // ---- Profil avatarı (DiceBear görsel URL'i) ----
  static const String _defaultAvatar =
      'https://api.dicebear.com/9.x/avataaars/png?seed=LifeRadar';
  static const String _womanAvatar =
      'https://api.dicebear.com/9.x/avataaars/png?seed=Zoe&top=straight01,bob,bun,curvy,longButNotTooLong,miaWallace,bigHair&facialHairProbability=0';
  static const String _manAvatar =
      'https://api.dicebear.com/9.x/avataaars/png?seed=Can&top=shortFlat,shortRound,theCaesar,shortCurly&facialHair=beardLight,beardMedium&facialHairProbability=100';

  String _avatar = _defaultAvatar;
  bool _avatarManual = false;
  String get avatar => _avatar;

  void setAvatar(String a) {
    _avatar = a;
    _avatarManual = true;
    lsSet('lr_avatar', a);
    lsSet('lr_avatar_manual', '1');
    notifyListeners();
  }

  void _loadAvatar() {
    final a = lsGet('lr_avatar');
    if (a != null && a.isNotEmpty) _avatar = a;
    _avatarManual = lsGet('lr_avatar_manual') == '1';
  }

  /// Kullanıcı manuel seçmediyse cinsiyete göre avatarı ayarla.
  void _applyGenderAvatar(String gender) {
    if (_avatarManual) return;
    if (gender == 'Kadın') {
      _avatar = _womanAvatar;
    } else if (gender == 'Erkek') {
      _avatar = _manAvatar;
    }
  }

  /// Profilde gösterilecek ad: kişisel bilgi adı > hesap adı > e-posta > "Kullanıcı".
  String get displayName {
    if (_userContext.name.trim().isNotEmpty) return _userContext.name.trim();
    if (_authName != null && _authName!.trim().isNotEmpty) {
      return _authName!.trim();
    }
    final e = _authEmail;
    if (e != null && e.contains('@')) {
      final u = e.split('@').first;
      if (u.isEmpty) return 'Kullanıcı';
      return u[0].toUpperCase() + u.substring(1);
    }
    return 'Kullanıcı';
  }

  // ---- Abonelik ----
  SubscriptionTier _tier = SubscriptionTier.free;
  SubscriptionTier get tier => _tier;
  bool get isPremium => _tier == SubscriptionTier.premium || _tier == SubscriptionTier.vip;
  bool get isVip => _tier == SubscriptionTier.vip;

  void setTier(SubscriptionTier tier) {
    _tier = tier;
    lsSet('lr_tier', tier.name);
    notifyListeners();
  }

  void _loadTier() {
    final t = lsGet('lr_tier');
    if (t == 'vip') {
      _tier = SubscriptionTier.vip;
    } else if (t == 'premium') {
      _tier = SubscriptionTier.premium;
    }
  }

  // ---- Abonelik satın alma (App Store / Google Play) ----
  final PurchaseService _purchases = PurchaseService();
  String? _purchaseMessage;
  String? get purchaseMessage => _purchaseMessage;
  void clearPurchaseMessage() => _purchaseMessage = null;

  void _initPurchases() {
    _purchases.init(
      onTier: (t) {
        // Satın alınan tier mevcut olandan düşükse yükseltme (VIP > Premium).
        if (t == SubscriptionTier.vip ||
            (_tier == SubscriptionTier.free)) {
          setTier(t);
        } else if (t == SubscriptionTier.premium && _tier != SubscriptionTier.vip) {
          setTier(t);
        }
      },
      onMsg: (m) {
        _purchaseMessage = m;
        notifyListeners();
      },
    );
  }

  /// Satın alınabilir ürün kimlikleri (UI için).
  static const String premiumMonthlyId = PurchaseService.premiumMonthly;
  static const String premiumYearlyId = PurchaseService.premiumYearly;
  static const String vipMonthlyId = PurchaseService.vipMonthly;
  static const String vipYearlyId = PurchaseService.vipYearly;

  /// Ürünün store fiyatı (ör. "₺49,99"); store'dan gelmezse boş.
  String subscriptionPrice(String productId) => _purchases.priceOf(productId);

  Future<void> buySubscription(String productId) =>
      _purchases.buy(productId);

  Future<void> restorePurchases() => _purchases.restore();

  // Ücretsiz katmanda günlük AI soru limiti (5).
  static const int freeAiQuestionLimit = 5;
  int _aiQuestionsAsked = 0;
  int get aiQuestionsAsked => _aiQuestionsAsked;
  int? get remainingAiQuestions =>
      isPremium ? null : (freeAiQuestionLimit - _aiQuestionsAsked).clamp(0, freeAiQuestionLimit);
  bool get canAskAi => isPremium || _aiQuestionsAsked < freeAiQuestionLimit;
  void registerAiQuestion() {
    if (!isPremium) {
      _aiQuestionsAsked++;
      notifyListeners();
    }
  }

  // ---- Groq API anahtarı ----
  // Anahtar artık backend (Cloudflare Worker / serve.ps1) tarafında, güvende.
  // İstemci yalnızca bir yer tutucu gönderir; backend kendi gizli anahtarını kullanır.
  String _apiKey = 'managed-by-backend';
  String get apiKey => _apiKey;
  bool get hasApiKey => _apiKey.trim().isNotEmpty;
  void setApiKey(String key) {
    _apiKey = key;
    notifyListeners();
    // Anahtar girilir girilmez günün AI analizini üret.
    _generateDailyAnalysis();
  }

  // ---- Olaylar ----
  List<RadarEvent> get events => _events;

  List<RadarEvent> eventsByCategory(EventCategory category) =>
      _events.where((e) => e.category == category).toList();

  /// Başlık + özet + kaynakta arama (Türkçe karakter duyarsız).
  List<RadarEvent> searchEvents(String query) {
    final q = _norm(query.trim());
    if (q.isEmpty) return const [];
    return _events.where((e) {
      final hay = _norm('${e.title} ${e.summary} ${e.source}');
      return hay.contains(q);
    }).toList();
  }

  String _norm(String s) => s
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c');

  RadarEvent? eventById(String id) {
    for (final e in _events) {
      if (e.id == id) return e;
    }
    return null;
  }

  // ---- Kaydedilen haberler (Profil) — localStorage'da kalıcı ----
  final Set<String> _savedEventIds = {};
  bool isSaved(String id) => _savedEventIds.contains(id);
  List<RadarEvent> get savedEvents =>
      _events.where((e) => _savedEventIds.contains(e.id)).toList();

  void toggleSaved(String id) {
    if (!_savedEventIds.remove(id)) {
      _savedEventIds.add(id);
    }
    lsSet('lr_saved', jsonEncode(_savedEventIds.toList()));
    notifyListeners();
  }

  void _loadSaved() {
    final raw = lsGet('lr_saved');
    if (raw != null && raw.isNotEmpty) {
      try {
        _savedEventIds
          ..clear()
          ..addAll((jsonDecode(raw) as List).map((e) => e.toString()));
      } catch (_) {}
    }
  }

  // ---- Takip edilen konular (Profil) — varsayılan boş; localStorage'da kalıcı ----
  final Set<EventCategory> _followedTopics = {};
  Set<EventCategory> get followedTopics => _followedTopics;
  bool isFollowed(EventCategory c) => _followedTopics.contains(c);
  void toggleFollowed(EventCategory c) {
    if (!_followedTopics.remove(c)) {
      _followedTopics.add(c);
    }
    lsSet('lr_follows', _followedTopics.map((e) => e.name).join(','));
    notifyListeners();
  }

  void _loadFollows() {
    final raw = lsGet('lr_follows');
    if (raw != null && raw.isNotEmpty) {
      try {
        _followedTopics
          ..clear()
          ..addAll(raw.split(',').where((s) => s.isNotEmpty).map((s) =>
              EventCategory.values.firstWhere((c) => c.name == s,
                  orElse: () => EventCategory.world)));
      } catch (_) {}
    }
  }

  /// Aktif konular: kullanıcı seçtiyse onlar, seçmediyse tüm kategoriler.
  List<EventCategory> get activeTopics => _followedTopics.isEmpty
      ? EventCategory.values.toList()
      : EventCategory.values.where(_followedTopics.contains).toList();

  // ---- Sekme navigasyonu (Ana Sayfa → Gündem yönlendirmesi) ----
  int _navIndex = 0;
  int get navIndex => _navIndex;

  /// İstenen Gündem kategorisi (Ana Sayfa'daki "Devamını Görüntüle" için).
  /// Gündem ekranı bu kategoriye geçtikten sonra [clearAgendaCategory] ile temizler.
  EventCategory? _agendaCategory;
  EventCategory? get agendaCategory => _agendaCategory;

  void goToTab(int i) {
    if (_navIndex == i) return;
    _navIndex = i;
    notifyListeners();
  }

  /// Gündem sekmesine geç ve ilgili kategoriyi seç.
  void openAgendaCategory(EventCategory c) {
    _agendaCategory = c;
    _navIndex = 1; // Gündem sekmesi
    notifyListeners();
  }

  /// Gündem kategorisi tüketildi (tekrar tetiklenmesin diye sessizce temizle).
  void clearAgendaCategory() {
    _agendaCategory = null;
  }

  // ---- Radar (gerçek olaylardan hesaplanır) ----
  List<RiskArea> get riskAreas => [
        _riskArea(RiskAreaType.health, [EventCategory.health]),
        _riskArea(RiskAreaType.economic, [EventCategory.economy]),
        _riskArea(RiskAreaType.disaster, [EventCategory.disaster]),
        _riskArea(RiskAreaType.energy, [EventCategory.energy]),
        _riskArea(
            RiskAreaType.cyber, [EventCategory.technology, EventCategory.security]),
        _riskArea(
            RiskAreaType.travel, [EventCategory.world, EventCategory.security]),
      ];

  RiskArea _riskArea(RiskAreaType type, List<EventCategory> cats) {
    final evs = _events.where((e) => cats.contains(e.category)).toList();

    // Afet riski: konum varsa çevredeki gerçek depremlerden hesaplanan skor.
    if (type == RiskAreaType.disaster && _localDisasterScore != null) {
      final s = _localDisasterScore!;
      final city = _location?.city ?? 'bölgeniz';
      final desc =
          '$city çevresinde son 30 gündeki gerçek deprem aktivitesine göre hesaplandı.';
      final impact = s >= 70
          ? 'Yüksek: deprem hazırlığınızı gözden geçirin.'
          : s >= 40
              ? 'Orta: deprem çantası ve plan hazır olsun.'
              : 'Düşük: çevrede belirgin sismik hareketlilik yok.';
      return RiskArea(
          type: type, score: s, description: desc, expectedImpact: impact);
    }

    final score = evs.isEmpty ? 30 : _avgRisk(evs);
    final desc = evs.isEmpty
        ? 'Şu an bu alanda belirgin bir gelişme görünmüyor.'
        : '${evs.length} güncel gelişme izleniyor. En güncel: "${evs.first.title}".';
    final impact = score >= 70
        ? 'Yüksek: yakından takip edin ve önlem alın.'
        : score >= 40
            ? 'Orta: gelişmeleri izlemekte fayda var.'
            : 'Düşük: şu an acil bir etki beklenmiyor.';
    return RiskArea(
        type: type, score: score, description: desc, expectedImpact: impact);
  }

  /// Kişisel Risk Puanı — tüm risk alanlarının ortalaması.
  int get personalRiskScore {
    final areas = riskAreas;
    final sum = areas.map((a) => a.score).reduce((a, b) => a + b);
    return (sum / areas.length).round();
  }

  // ---- Sağlık Radarı (gerçek sağlık haberleri bölümlere ayrılır) ----
  bool _titleHas(RadarEvent e, List<String> kws) {
    final t = e.title.toLowerCase();
    return kws.any((k) => t.contains(k));
  }

  /// Sağlık haberlerini her birini TEK bölüme atayarak grupla (tekrar yok).
  Map<HealthSection, List<RadarEvent>> _bucketHealth() {
    final health = eventsByCategory(EventCategory.health);
    final used = <String>{};
    final map = {for (final s in HealthSection.values) s: <RadarEvent>[]};

    void assign(HealthSection s, List<String> kws) {
      for (final e in health) {
        if (used.contains(e.id)) continue;
        if (_titleHas(e, kws)) {
          map[s]!.add(e);
          used.add(e.id);
        }
      }
    }

    assign(HealthSection.whoAlerts, ['who', 'dünya sağlık']);
    assign(HealthSection.cdcAlerts, ['cdc']);
    assign(HealthSection.vaccineNews, ['aşı', 'vaccine']);
    assign(HealthSection.outbreaks, ['salgın', 'vaka', 'virüs', 'grip', 'outbreak']);
    // Kalan her şey "Yeni Hastalıklar"
    for (final e in health) {
      if (!used.contains(e.id)) {
        map[HealthSection.newDiseases]!.add(e);
        used.add(e.id);
      }
    }
    return map;
  }

  List<RadarEvent> healthEventsBySection(HealthSection s) =>
      _bucketHealth()[s] ?? const [];

  // ---- Kriz Radarı (her haber tek bölüme; tekrar yok) ----
  Map<CrisisSection, List<RadarEvent>> _bucketCrisis() {
    final used = <String>{};
    final map = {for (final s in CrisisSection.values) s: <RadarEvent>[]};

    void assign(CrisisSection s, List<RadarEvent> pool, List<String>? kws) {
      for (final e in pool) {
        if (used.contains(e.id)) continue;
        if (kws == null || _titleHas(e, kws)) {
          map[s]!.add(e);
          used.add(e.id);
        }
      }
    }

    // Önce anahtar kelimeye dayalı özel bölümler, sonra geniş kategoriler.
    assign(CrisisSection.cyber, [
      ...eventsByCategory(EventCategory.security),
      ...eventsByCategory(EventCategory.technology),
    ], ['siber', 'hack', 'veri', 'cyber']);
    assign(CrisisSection.food, _events,
        ['gıda', 'tahıl', 'buğday', 'açlık', 'food']);
    assign(CrisisSection.water, _events,
        ['kurak', 'baraj', 'içme suyu', 'su kesint', 'water']);
    assign(CrisisSection.geopolitical, [
      ...eventsByCategory(EventCategory.world),
      ...eventsByCategory(EventCategory.security),
    ], ['savaş', 'gerginlik', 'çatışma', 'kriz', 'jeopolit', 'asker']);
    assign(CrisisSection.economic, eventsByCategory(EventCategory.economy), null);
    assign(CrisisSection.energy, eventsByCategory(EventCategory.energy), null);
    return map;
  }

  List<RadarEvent> crisisEventsBySection(CrisisSection s) =>
      _bucketCrisis()[s] ?? const [];

  // ---- Bildirimler (gerçek olaylardan üretilir) ----
  NotificationCategory _notifCategory(EventCategory c) {
    switch (c) {
      case EventCategory.health:
        return NotificationCategory.health;
      case EventCategory.economy:
        return NotificationCategory.economy;
      case EventCategory.disaster:
        return NotificationCategory.disaster;
      default:
        return NotificationCategory.world;
    }
  }

  List<AppNotification> get notifications {
    final list = _events
        .take(25)
        .map((e) => AppNotification(
              title: e.title,
              summary: e.summary,
              time: e.publishedAt,
              category: _notifCategory(e.category),
              risk: e.risk,
              eventId: e.id,
            ))
        .toList();
    // Bir sistem bildirimi ekle
    list.add(AppNotification(
      title: 'Life Radar güncel',
      summary: 'Haberler ve risk analizi en son verilerle güncellendi.',
      time: DateTime.now(),
      category: NotificationCategory.system,
      risk: RiskLevel.low,
    ));
    return list;
  }

  /// Zil rozeti: yüksek/kritik riskli güncel olay sayısı.
  int get unreadNotificationCount => _events
      .take(25)
      .where((e) => e.risk == RiskLevel.high || e.risk == RiskLevel.critical)
      .length;

  // ---- Ana Sayfa metinleri (gerçek verilerden hesaplanır) ----

  /// Dünya Risk Endeksi — tüm olayların ortalama risk değeri.
  int get worldRiskIndex => _avgRisk(_events);

  /// Türkiye Risk Endeksi — Türkiye + afet olaylarına odaklı.
  int get turkeyRiskIndex {
    final tr = _events.where((e) =>
        e.category == EventCategory.turkey ||
        e.category == EventCategory.disaster);
    return _avgRisk(tr.isEmpty ? _events : tr);
  }

  /// Günün Özeti — o anki gerçek manşetlerden otomatik üretilir.
  String get dailySummary {
    if (_events.isEmpty) return 'Güncel veriler yükleniyor...';
    final high = _events
        .where((e) =>
            e.risk == RiskLevel.high || e.risk == RiskLevel.critical)
        .length;

    final byCat = <EventCategory, int>{};
    for (final e in _events) {
      byCat[e.category] = (byCat[e.category] ?? 0) + 1;
    }
    final topCats = (byCat.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => e.key.label)
        .join(', ');

    final latest = _events.first.title;
    final highPart = high > 0
        ? 'Bunlardan $high tanesi yüksek riskli. '
        : 'Şu an yüksek riskli acil bir gelişme görünmüyor. ';

    return 'Bugün ${_events.length} güncel gelişme izleniyor. $highPart'
        'Öne çıkan alanlar: $topCats. En güncel başlık: "$latest".';
  }

  /// Yapay Zekâ Günlük Analizi — Gemini ile (anahtar varsa).
  String get aiDailyAnalysis {
    if (_aiDailyAnalysis != null) return _aiDailyAnalysis!;
    if (!hasApiKey) {
      return 'Kişiselleştirilmiş Life Radar Asistan günlük analizi için Profil\'den '
          'ücretsiz Groq API anahtarınızı girin. Anahtar girilince günün '
          'gerçek başlıkları sizin için analiz edilir.';
    }
    return _loadingFeeds
        ? 'Günün başlıkları analiz ediliyor...'
        : 'Analiz hazırlanıyor...';
  }
}
