import 'package:flutter_tts/flutter_tts.dart';

/// Web dışı (Android/iOS/masaüstü) sesli okuma — flutter_tts ile.
/// Web'de bu dosya yerine tts_web.dart (tarayıcı sesi) kullanılır.
final FlutterTts _tts = FlutterTts();
bool _configured = false;

/// iOS'ta sessiz modda bile ses çıkması için ses oturumunu hazırlar ve
/// mevcut en kaliteli Türkçe sesi seçer.
Future<void> _ensureConfigured() async {
  if (_configured) return;
  _configured = true;
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
  // En kaliteli Türkçe sesi seç (varsa "enhanced/premium/neural").
  try {
    final voices = (await _tts.getVoices) as List?;
    if (voices != null) {
      final tr = voices
          .map((v) => Map<String, dynamic>.from(v as Map))
          .where((v) =>
              (v['locale'] ?? '').toString().toLowerCase().startsWith('tr'))
          .toList();
      if (tr.isNotEmpty) {
        Map<String, dynamic> best = tr.first;
        for (final v in tr) {
          final n = (v['name'] ?? '').toString().toLowerCase();
          if (n.contains('enhanced') ||
              n.contains('premium') ||
              n.contains('neural') ||
              n.contains('siri')) {
            best = v;
            break;
          }
        }
        await _tts.setVoice({
          'name': (best['name'] ?? '').toString(),
          'locale': (best['locale'] ?? 'tr-TR').toString(),
        });
      }
    }
  } catch (_) {}
}

void speakText(String text) async {
  if (text.trim().isEmpty) return;
  try {
    await _ensureConfigured();
    await _tts.setLanguage('tr-TR');
    await _tts.setSpeechRate(0.46); // biraz daha yavaş = daha doğal
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
    await _tts.stop();
    await _tts.speak(text);
  } catch (_) {}
}

void stopSpeak() {
  _tts.stop();
}
