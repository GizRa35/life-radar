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

void speakText(String text) async {
  if (text.trim().isEmpty) return;
  try {
    await _ensureConfigured();
    await _tts.setLanguage('tr-TR');
    await _tts.setSpeechRate(0.48); // doğal tempo
    await _tts.setPitch(1.0); // 1.05 fazla tizdi; 1.0 daha doğal
    await _tts.setVolume(1.0);
    await _tts.stop();
    await _tts.speak(text);
  } catch (_) {}
}

void stopSpeak() {
  _tts.stop();
}
