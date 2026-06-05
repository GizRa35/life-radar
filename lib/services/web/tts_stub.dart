import 'package:flutter_tts/flutter_tts.dart';

/// Web dışı (Android/iOS/masaüstü) sesli okuma — flutter_tts ile.
/// Web'de bu dosya yerine tts_web.dart (tarayıcı sesi) kullanılır.
final FlutterTts _tts = FlutterTts();

void speakText(String text) async {
  if (text.trim().isEmpty) return;
  try {
    await _tts.setLanguage('tr-TR');
    await _tts.setSpeechRate(0.5); // doğal okuma hızı
    await _tts.setPitch(1.0);
    await _tts.stop(); // önce varsa süreni durdur
    await _tts.speak(text);
  } catch (_) {
    // ses motoru yoksa sessizce geç
  }
}

void stopSpeak() {
  _tts.stop();
}
