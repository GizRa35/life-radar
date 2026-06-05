import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../core/constants.dart';
import '../../models/user_context.dart';

/// Groq (OpenAI uyumlu) ile gerçek AI yanıtları.
///
/// Ücretsiz anahtar: https://console.groq.com → API Keys (kredi kartı gerekmez).
/// Türkiye dahil her yerde çalışır.
///
/// Web'de CORS için aynı kökenli yerel proxy'ye (serve.ps1 /api/groq) gider;
/// mobilde doğrudan Groq'a bağlanır.
class GroqService {
  GroqService({this.model = 'llama-3.3-70b-versatile'});

  final String model;

  static final String _proxy = '${ApiConfig.base}/api/groq';

  Future<String> ask({
    required String apiKey,
    required String question,
    required UserContext context,
  }) {
    return _chat(apiKey: apiKey, system: _systemPrompt(context), user: question);
  }

  /// VIP araçları için serbest sistem+kullanıcı promptu.
  Future<String> custom({
    required String apiKey,
    required String system,
    required String user,
  }) {
    final guard = '$system\n\n${AppConstants.aiGuardrail}\n'
        'Yanıtı TÜRKÇE ve sade, okunaklı ver.';
    return _chat(apiKey: apiKey, system: guard, user: user);
  }

  Future<String> dailyBriefing({
    required String apiKey,
    required String headlines,
    required UserContext context,
  }) {
    final system = '''
Sen "Life Radar Asistan"sın, Life Radar uygulamasının analistisin. Kendinden söz
ederken "Life Radar Asistan" de; "yapay zeka" deme.
${AppConstants.aiGuardrail}
Kullanıcı bağlamı: Konum: ${context.location}, Meslek: ${context.profession.isEmpty ? 'belirtilmedi' : context.profession}.
Görev: Aşağıdaki güncel başlıklara bakarak kullanıcının bugün dikkat etmesi
gereken EN ÖNEMLİ noktaları 2-3 cümlede, sakin ve kişisel bir dille TÜRKÇE özetle.
Başlık/madde kullanma, tek paragraf yaz.''';
    return _chat(
      apiKey: apiKey,
      system: system,
      user: 'Güncel başlıklar:\n$headlines',
    );
  }

  String _systemPrompt(UserContext c) {
    return '''
Sen "Life Radar Asistan"sın, Life Radar uygulamasının asistanısın. Dünya gündemini, sağlık,
ekonomi, afet ve küresel riskleri kullanıcının kişisel durumuna göre değerlendir
ve "ne yapmalıyım?" sorusunu yanıtla. Kendinden söz ederken "Life Radar Asistan"
de; "yapay zeka" deme.

${AppConstants.aiGuardrail}

Kullanıcı bağlamı:
- Konum: ${c.location}
- Meslek: ${c.profession.isEmpty ? 'belirtilmedi' : c.profession}
- Sağlık: ${c.healthNotes.isEmpty ? 'belirtilmedi' : c.healthNotes}
- Finansal hassasiyet: ${c.financialSensitivity.isEmpty ? 'belirtilmedi' : c.financialSensitivity}
- Aile: ${c.familyInfo.isEmpty ? 'belirtilmedi' : c.familyInfo}

Yanıtını her zaman TÜRKÇE ve şu başlıklarla ver:
Özet:
Risk Analizi:
Öneriler:
Kaynaklar:''';
  }

  Future<String> _chat({
    required String apiKey,
    required String system,
    required String user,
  }) async {
    // Her platformda worker proxy'sinden geç — anahtar backend'de güvende.
    final uri = Uri.parse(_proxy);
    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': user},
      ],
      'temperature': 0.4,
      'max_tokens': 1024,
    });

    try {
      final res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 40));

      if (res.statusCode != 200) {
        return _errorMessage(res.statusCode, res.body);
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      final content =
          choices != null && choices.isNotEmpty
              ? (choices.first['message']?['content'])?.toString().trim()
              : null;
      return (content != null && content.isNotEmpty)
          ? content
          : 'Life Radar Asistan boş yanıt döndürdü.';
    } catch (e) {
      return 'Bağlantı hatası: $e\n\nİnternet bağlantınızı ve API anahtarınızı '
          'kontrol edin.';
    }
  }

  String _errorMessage(int code, String body) {
    if (code == 401) {
      return 'API anahtarı geçersiz (401). Profil > Groq API anahtarını kontrol edin.';
    }
    if (code == 429) {
      return 'Hız/kota limiti aşıldı (429). Kısa süre sonra tekrar deneyin.';
    }
    return 'Life Radar Asistan hatası ($code). Lütfen tekrar deneyin.';
  }
}
