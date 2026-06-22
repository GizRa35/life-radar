import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform, debugPrint;
import 'package:http/http.dart' as http;

import '../core/api_config.dart';

/// Arka planda / uygulama kapalıyken gelen FCM mesajını işler.
/// Bildirim payload'ı taşıyorsa sistem zaten gösterir; burada ekstra iş yok.
@pragma('vm:entry-point')
Future<void> _firebaseBgHandler(RemoteMessage message) async {
  // Şimdilik no-op: bildirim payload'ı sistem tepsisinde otomatik görünür.
}

/// Push bildirim kurulumu — main() içinde bir kez çağrılır.
///
/// Web'de atlanır (push hedefi mobil). iOS/Android'de:
/// Firebase başlat → izin iste → FCM token al → worker'a kaydet.
Future<void> initPush() async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.android) {
    return; // masaüstünde push yok
  }
  try {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseBgHandler);

    // Kullanıcıdan bildirim izni iste (iOS sistem penceresi).
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // iOS'ta APNs token hazır olmadan FCM token null gelebilir; sorun değil,
    // onTokenRefresh ile yakalanır.
    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerToken(token);
    }
    messaging.onTokenRefresh.listen(_registerToken);
  } catch (e) {
    debugPrint('initPush hata: $e');
  }
}

/// FCM token'ı worker'a kaydeder (kritik gelişmede buraya push gider).
Future<void> _registerToken(String token) async {
  if (ApiConfig.base.contains('localhost')) return;
  try {
    final platform =
        defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    await http
        .post(
          Uri.parse('${ApiConfig.base}/api/register-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'token': token, 'platform': platform}),
        )
        .timeout(const Duration(seconds: 10));
  } catch (_) {
    // Sessizce geç; sonraki açılışta/refresh'te tekrar denenir.
  }
}
