import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/app_notification.dart';
import '../models/crisis_item.dart';
import '../models/event_category.dart';
import '../models/health_alert.dart';
import '../models/radar_event.dart';
import '../models/risk_area.dart';
import '../models/subscription.dart';
import '../models/user_context.dart';

/// Tek merkezi uygulama durumu (Provider / ChangeNotifier).
///
/// MVP'de veriler MockData'dan gelir; Faz 1+'de USGS/GDELT/Claude servisleriyle
/// değiştirilecek.
class AppState extends ChangeNotifier {
  // ---- Bağlam ----
  UserContext _userContext = const UserContext();
  UserContext get userContext => _userContext;

  void updateUserContext(UserContext ctx) {
    _userContext = ctx;
    notifyListeners();
  }

  // ---- Abonelik ----
  SubscriptionTier _tier = SubscriptionTier.free;
  SubscriptionTier get tier => _tier;
  bool get isPremium => _tier == SubscriptionTier.premium || _tier == SubscriptionTier.vip;
  bool get isVip => _tier == SubscriptionTier.vip;

  void setTier(SubscriptionTier tier) {
    _tier = tier;
    notifyListeners();
  }

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

  // ---- Claude API anahtarı (Profil'de girilir) ----
  String _apiKey = '';
  String get apiKey => _apiKey;
  bool get hasApiKey => _apiKey.trim().isNotEmpty;
  void setApiKey(String key) {
    _apiKey = key;
    notifyListeners();
  }

  // ---- Olaylar ----
  List<RadarEvent> get events => MockData.events;

  List<RadarEvent> eventsByCategory(EventCategory category) =>
      MockData.events.where((e) => e.category == category).toList();

  RadarEvent? eventById(String id) {
    for (final e in MockData.events) {
      if (e.id == id) return e;
    }
    return null;
  }

  // ---- Kaydedilen haberler (Profil) ----
  final Set<String> _savedEventIds = {};
  bool isSaved(String id) => _savedEventIds.contains(id);
  List<RadarEvent> get savedEvents =>
      MockData.events.where((e) => _savedEventIds.contains(e.id)).toList();

  void toggleSaved(String id) {
    if (!_savedEventIds.remove(id)) {
      _savedEventIds.add(id);
    }
    notifyListeners();
  }

  // ---- Takip edilen konular (Profil) ----
  final Set<EventCategory> _followedTopics = {
    EventCategory.turkey,
    EventCategory.economy,
    EventCategory.disaster,
  };
  Set<EventCategory> get followedTopics => _followedTopics;
  bool isFollowed(EventCategory c) => _followedTopics.contains(c);
  void toggleFollowed(EventCategory c) {
    if (!_followedTopics.remove(c)) {
      _followedTopics.add(c);
    }
    notifyListeners();
  }

  // ---- Radar ----
  int get personalRiskScore => MockData.personalRiskScore;
  List<RiskArea> get riskAreas => MockData.riskAreas;

  // ---- Sağlık / Kriz radarı ----
  List<HealthAlert> healthAlertsBySection(HealthSection s) =>
      MockData.healthAlerts.where((a) => a.section == s).toList();
  List<CrisisItem> crisisItemsBySection(CrisisSection s) =>
      MockData.crisisItems.where((c) => c.section == s).toList();

  // ---- Bildirimler ----
  List<AppNotification> get notifications => MockData.notifications;
  int get unreadNotificationCount => MockData.notifications.length;

  // ---- Ana Sayfa metinleri ----
  String get dailySummary => MockData.dailySummary;
  String get aiDailyAnalysis => MockData.aiDailyAnalysis;
  int get worldRiskIndex => MockData.worldRiskIndex;
  int get turkeyRiskIndex => MockData.turkeyRiskIndex;
}
