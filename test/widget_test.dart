// Life Radar temel smoke test.

import 'package:flutter_test/flutter_test.dart';

import 'package:life_radar/main.dart';

void main() {
  testWidgets('Uygulama başlar ve 5 sekme görünür', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeRadarApp());
    await tester.pumpAndSettle();

    // Alt navigasyon etiketleri görünmeli.
    expect(find.text('Ana Sayfa'), findsWidgets);
    expect(find.text('Gündem'), findsWidgets);
    expect(find.text('Radar'), findsWidgets);
    expect(find.text('Rehber'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
  });
}
