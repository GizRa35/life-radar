import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../../models/user_context.dart';

/// Google Gemini (Generative Language API) ile gerçek AI yanıtları.
///
/// Ücretsiz anahtar: https://aistudio.google.com → "Get API key".
/// Kredi kartı gerekmez.
class GeminiService {
  GeminiService({this.model = 'gemini-2.0-flash'});

  /// Model adı. Erişim sorununda 'gemini-1.5-flash-latest' ile değiştirilebilir.
  final String model;

  static const String _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Asistan sohbeti için serbest soru-cevap.
  Future<String> ask({
    required String apiKey,
    required String question,
    required UserContext context,
  }) async {
    final system = _systemPrompt(context);
    return _generate(apiKey: apiKey, system: system, userText: question);
  }

  /// Sistem prompt'u: guardrail + kullanıcı bağlamı + yanıt formatı.
  String _systemPrompt(UserContext c) {
    return '''
Sen "Life Radar" uygulamasının yapay zekâ asistanısın. Görevin: dünya gündemini,
sağlık, ekonomi, afet ve küresel riskleri kullanıcının kişisel durumuna göre
değerlendirmek ve "ne yapmalıyım?" sorusunu yanıtlamak.

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
Kaynaklar:
''';
  }

  Future<String> _generate({
    required String apiKey,
    required String system,
    required String userText,
  }) async {
    final uri = Uri.parse('$_base/$model:generateContent?key=$apiKey');
    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': system}
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': userText}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 1024,
      },
    });

    try {
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode != 200) {
        return _errorMessage(res.statusCode, res.body);
      }

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        return 'AI yanıt üretemedi (güvenlik filtresi veya boş yanıt). '
            'Lütfen sorunuzu farklı ifade edin.';
      }
      final parts = (candidates.first['content']?['parts'] as List?) ?? [];
      final text = parts
          .map((p) => (p as Map)['text']?.toString() ?? '')
          .join('\n')
          .trim();
      return text.isEmpty ? 'AI boş yanıt döndürdü.' : text;
    } catch (e) {
      return 'Bağlantı hatası: $e\n\nİnternet bağlantınızı ve API anahtarınızı '
          'kontrol edin.';
    }
  }

  String _errorMessage(int code, String body) {
    if (code == 400 && body.contains('API_KEY_INVALID')) {
      return 'API anahtarı geçersiz. Profil > Gemini API anahtarını kontrol edin.';
    }
    if (code == 429) {
      return 'Ücretsiz kota aşıldı (429). Bir süre sonra tekrar deneyin.';
    }
    if (code == 403) {
      return 'Erişim reddedildi (403). Anahtarın Generative Language API için '
          'etkin olduğundan emin olun.';
    }
    return 'AI hatası ($code). Lütfen tekrar deneyin.';
  }
}
