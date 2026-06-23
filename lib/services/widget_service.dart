import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:home_widget/home_widget.dart';

/// Ana ekran widget'ına (Android + iOS) kişisel risk puanını yazar.
/// iOS tarafı App Group ile paylaşımlı UserDefaults kullanır.
class HomeWidgetService {
  static const String _appGroupId = 'group.com.liferadar.lifeRadar';
  static const String _androidProvider = 'RiskWidgetProvider';
  static const String _iosWidget = 'RiskWidget';

  /// Risk puanı (0-100) → seviye etiketi.
  static String levelLabel(int score) {
    if (score >= 67) return 'Yüksek';
    if (score >= 34) return 'Orta';
    return 'Düşük';
  }

  static Future<void> update(int score, {String? city}) async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      await HomeWidget.saveWidgetData<int>('risk_score', score);
      await HomeWidget.saveWidgetData<String>('risk_label', levelLabel(score));
      await HomeWidget.saveWidgetData<String>('risk_city', city ?? '');
      await HomeWidget.updateWidget(
        name: _androidProvider,
        androidName: _androidProvider,
        iOSName: _iosWidget,
      );
    } catch (_) {
      // Widget yoksa / desteklenmiyorsa sessizce geç.
    }
  }
}
