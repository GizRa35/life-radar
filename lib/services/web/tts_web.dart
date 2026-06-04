import 'dart:html' as html;

void speakText(String text) {
  try {
    final synth = html.window.speechSynthesis;
    if (synth == null) return;
    synth.cancel();
    final u = html.SpeechSynthesisUtterance(text)
      ..lang = 'tr-TR'
      ..rate = 1.0
      ..pitch = 1.0;
    synth.speak(u);
  } catch (_) {}
}

void stopSpeak() {
  try {
    html.window.speechSynthesis?.cancel();
  } catch (_) {}
}
