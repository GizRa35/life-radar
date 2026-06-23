import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/local_store.dart';
import 'services/push_service.dart';
import 'state/app_state.dart';
import 'widgets/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lsInit(); // kalıcı depolamayı belleğe yükle (mobil/masaüstü)
  await initializeDateFormatting('tr', null);
  await initializeDateFormatting('en', null);
  await _initFirebaseAndCrashlytics(); // Firebase + çökme takibi
  await initPush(); // push bildirim (FCM token kaydı)
  runApp(const LifeRadarApp());
}

/// Firebase'i bir kez başlatır ve Crashlytics'i (çökme takibi) bağlar.
/// Mobil dışında (web/masaüstü) atlanır.
Future<void> _initFirebaseAndCrashlytics() async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.android) {
    return;
  }
  try {
    await Firebase.initializeApp();
    // Flutter çerçeve hataları + yakalanmamış asenkron hatalar → Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (_) {
    // Firebase yapılandırması yoksa sessizce geç (uygulama yine çalışır).
  }
}

class LifeRadarApp extends StatelessWidget {
  const LifeRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: LifeRadarTheme.light,
        darkTheme: LifeRadarTheme.light, // koyu modda da açık temayı kullan
        themeMode: ThemeMode.light, // sistem koyu modu metinleri bozmasın
        home: Consumer<AppState>(
          builder: (_, state, __) {
            if (!state.onboardingDone) return const OnboardingScreen();
            return state.gateOpen ? const MainScaffold() : const AuthScreen();
          },
        ),
      ),
    );
  }
}
