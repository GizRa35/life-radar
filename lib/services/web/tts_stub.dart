import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

import '../../core/api_config.dart';

/// Web dışı (Android/iOS/masaüstü) sesli okuma.
///
/// 1) ÖNCE bulut TTS (Google Cloud Text-to-Speech, worker üzerinden) denenir —
///    doğal Wavenet Türkçe ses.
/// 2) Ağ/anahtar yoksa veya hata olursa cihazın kendi sesine (flutter_tts) düşer.
final FlutterTts _tts = FlutterTts();
final AudioPlayer _player = AudioPlayer();
bool _deviceConfigured = false;
bool _playerConfigured = false;

Future<void> _ensurePlayerConfigured() async {
  if (_playerConfigured) return;
  _playerConfigured = true;
  // iOS: sessiz modda bile çalsın, hoparlöre yönlensin.
  try {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.media,
        ),
      ),
    );
  } catch (_) {}
}

/// Buluttan doğal sesli MP3 al ve çal. Başarılıysa true döner.
Future<bool> _speakCloud(String text) async {
  // Lokal geliştirme adresinde TTS yok; sadece gerçek backend'de dene.
  if (ApiConfig.base.contains('localhost')) return false;
  try {
    await _ensurePlayerConfigured();
    final res = await http
        .post(
          Uri.parse('${ApiConfig.base}/api/tts'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': text}),
        )
        .timeout(const Duration(seconds: 12));
    final ct = (res.headers['content-type'] ?? '').toLowerCase();
    if (res.statusCode != 200 || !ct.contains('audio')) return false;
    await _tts.stop();
    await _player.stop();
    await _player.play(BytesSource(res.bodyBytes, mimeType: 'audio/mpeg'));
    return true;
  } catch (_) {
    return false;
  }
}

/// iOS'ta sessiz modda bile ses çıkması için ses oturumunu hazırlar ve
/// mevcut en kaliteli (robotik olmayan) Türkçe cihaz sesini seçer.
Future<void> _ensureDeviceConfigured() async {
  if (_deviceConfigured) return;
  _deviceConfigured = true;
  try {
    await _tts.setSharedInstance(true);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
      ],
    );
  } catch (_) {}
  // En kaliteli Türkçe sesi seç. iOS/Android'de varsayılan ses çoğu zaman
  // robotik "compact" sürümdür; "enhanced/premium/neural/siri" varsa onu,
  // yoksa en azından "compact" OLMAYAN bir sesi tercih et.
  try {
    final voices = (await _tts.getVoices) as List?;
    if (voices != null) {
      final tr = voices
          .map((v) => Map<String, dynamic>.from(v as Map))
          .where((v) =>
              (v['locale'] ?? '').toString().toLowerCase().startsWith('tr'))
          .toList();
      if (tr.isNotEmpty) {
        int score(Map<String, dynamic> v) {
          final n = (v['name'] ?? '').toString().toLowerCase();
          if (n.contains('neural') || n.contains('premium')) return 4;
          if (n.contains('enhanced') || n.contains('siri')) return 3;
          if (n.contains('compact')) return 0; // robotik — en son tercih
          return 1;
        }

        tr.sort((a, b) => score(b).compareTo(score(a)));
        final best = tr.first;
        await _tts.setVoice({
          'name': (best['name'] ?? '').toString(),
          'locale': (best['locale'] ?? 'tr-TR').toString(),
        });
      }
    }
  } catch (_) {}
}

Future<void> _speakDevice(String text) async {
  try {
    await _ensureDeviceConfigured();
    await _tts.setLanguage('tr-TR');
    await _tts.setSpeechRate(0.48); // doğal tempo
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.stop();
    await _tts.speak(text);
  } catch (_) {}
}

void speakText(String text) async {
  if (text.trim().isEmpty) return;
  // 1) Önce bulut (doğal ses).
  final ok = await _speakCloud(text);
  if (ok) return;
  // 2) Olmadıysa cihaz sesi.
  await _speakDevice(text);
}

void stopSpeak() {
  try {
    _player.stop();
  } catch (_) {}
  try {
    _tts.stop();
  } catch (_) {}
}
