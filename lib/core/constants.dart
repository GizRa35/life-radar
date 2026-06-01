/// Uygulama geneli sabitler.
class AppConstants {
  AppConstants._();

  static const String appName = 'Life Radar';
  static const String slogan = 'Dünyayı Anla. Riskleri Gör. Hazırlıklı Ol.';
  static const String tagline = 'Haberi Değil, Sana Etkisini Gösterir.';

  /// AI guardrail — sistem prompt'una sabit kısıt olarak eklenir.
  static const String aiGuardrail =
      'Asla şunları yapma: komplo teorileri, korku yayma, kehanet/fal, '
      'kesin yatırım tavsiyesi, kesin sağlık teşhisi, siyasi propaganda, '
      'doğrulanmamış haber. Sakin, kanıta dayalı ve resmi kurum üslubuyla yanıt ver. '
      'Belirsizlikte kullanıcıyı resmi kaynaklara yönlendir.';
}
