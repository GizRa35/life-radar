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
  await initPush(); // push bildirim (Firebase + FCM token kaydı)
  runApp(const LifeRadarApp());
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
