import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:home_widget/home_widget.dart';

/// Ana ekran widget'ına (Android + iOS) özet bilgileri yazar:
/// risk puanı + seviye, son deprem, hava, günün uyarısı.
class HomeWidgetService {
  static const String _appGroupId = 'group.com.liferadar.lifeRadar';
  static const String _androidProvider = 'RiskWidgetProvider';
  static const String _iosWidget = 'RiskWidget';

  static String levelLabel(int score) {
    if (score >= 67) return 'Yüksek';
    if (score >= 34) return 'Orta';
    return 'Düşük';
  }

  static Future<void> update({
    required int score,
    String quake = '',
    String weather = '',
    String alert = '',
  }) async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      await HomeWidget.saveWidgetData<int>('risk_score', score);
      await HomeWidget.saveWidgetData<String>('risk_label', levelLabel(score));
      await HomeWidget.saveWidgetData<String>('quake', quake);
      await HomeWidget.saveWidgetData<String>('weather', weather);
      await HomeWidget.saveWidgetData<String>('alert', alert);
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
