import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../core/i18n.dart';
import '../core/theme.dart';
import '../services/ai/groq_service.dart';
import '../state/app_state.dart';
import 'premium_screen.dart';

/// SAYFA 9 — YAPAY ZEKÂ ASİSTANI
/// Soru-cevap. Yanıt yapısı: Özet · Risk Analizi · Öneriler · Kaynaklar.
/// (Gerçek Claude API bağlantısı Faz 3'te; şimdilik örnek yanıt üretir.)
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _Message {
  final String text;
  final bool isUser;
  _Message(this.text, this.isUser);
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _ai = GroqService();
  bool _loading = false;

  // Sesli soru (speech-to-text)
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechReady = false;
  bool _listening = false;

  Future<void> _toggleListen() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    if (!_speechReady) {
      _speechReady = await _speech.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') && mounted) {
            setState(() => _listening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
    }
    if (!_speechReady) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Mikrofon kullanılamıyor veya izin verilmedi.')),
        );
      }
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      localeId: 'tr_TR',
      // Sessizlikte otomatik kapan; en fazla 20 sn dinle.
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 3),
      onResult: (r) {
        setState(() => _controller.text = r.recognizedWords);
        // Konuşma bitince (final sonuç) mikrofonu kapat.
        if (r.finalResult) {
          _speech.stop();
          if (mounted) setState(() => _listening = false);
        }
      },
    );
  }

  // Habere göre önerilen takip soruları.
  static const _followUps = [
    'Bu beni nasıl etkiler?',
    'Ne yapmalıyım?',
    'Kaynak güvenilir mi?',
    'Önümüzdeki günlerde ne beklenir?',
  ];

  static const _examples = [
    'Bu savaş Türkiye\'yi etkiler mi?',
    'Bu hastalık tehlikeli mi?',
    'Altın neden yükseliyor?',
    'Bu haber hakkında ne yapmalıyım?',
  ];

  Future<void> _send(String text) async {
    final q = text.trim();
    if (q.isEmpty || _loading) return;

    final state = context.read<AppState>();
    if (!state.canAskAi) {
      _showLimitDialog();
      return;
    }
    state.registerAiQuestion();
    state.addAiMessage(q, true);
    _controller.clear();

    // Anahtar yoksa örnek yanıt; varsa gerçek Life Radar Asistan çağrısı.
    if (!state.hasApiKey) {
      state.addAiMessage(_mockAnswer(q), false);
      return;
    }

    setState(() => _loading = true);
    final answer = await _ai.ask(
      apiKey: state.apiKey,
      question: q,
      context: state.userContext,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (mounted) context.read<AppState>().addAiMessage(answer, false);
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('Günlük soru limiti doldu')),
        content: Text(
          t('Ücretsiz planda günde 5 soru sorabilirsiniz. Sınırsız soru için Premium\'a yükseltin.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('Kapat')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            child: Text(t('Premium\'a Bak')),
          ),
        ],
      ),
    );
  }

  // Faz 3'te Claude API ile değiştirilecek; guardrail'lere uygun örnek yanıt.
  String _mockAnswer(String q) {
    return 'Özet:\n'
        'Sorunuzu güvenilir kaynaklara ve profilinize göre değerlendiriyorum. '
        '(Bu bir örnek yanıttır; gerçek analiz için Profil ekranından Claude API '
        'anahtarınızı ekleyin.)\n\n'
        'Risk Analizi:\n'
        'Mevcut verilere göre doğrudan kişisel riskiniz orta-düşük seviyede '
        'görünüyor. Durum geliştikçe radar puanınız güncellenir.\n\n'
        'Öneriler:\n'
        '• Resmi kurum açıklamalarını takip edin\n'
        '• Doğrulanmamış bilgileri paylaşmayın\n'
        '• Gerekiyorsa hazırlık listenizi gözden geçirin\n\n'
        'Kaynaklar:\n'
        'WHO, Reuters, resmi afet ve meteoroloji kurumları.';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hasKey = state.hasApiKey;
    final remaining = state.remainingAiQuestions;
    final messages = state.aiMessages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: LifeRadarColors.turquoise),
            const SizedBox(width: 8),
            Text(t('Life Radar Asistan')),
          ],
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              tooltip: t('Sohbeti temizle'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(t('Sohbeti temizle')),
                    content: Text(
                        t('Tüm sohbet geçmişi silinsin mi? Bu işlem geri alınamaz.')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(t('İptal')),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AppState>().clearAiChat();
                          Navigator.pop(ctx);
                        },
                        child: Text(t('Temizle')),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!hasKey)
            Container(
              width: double.infinity,
              color: LifeRadarColors.riskMedium.withOpacity(0.15),
              padding: const EdgeInsets.all(12),
              child: Text(
                t('Gerçek Life Radar Asistan analizi için Profil > Groq API anahtarı ekleyin. Şimdilik örnek yanıt gösteriliyor.'),
                style: const TextStyle(fontSize: 12, color: LifeRadarColors.navy),
              ),
            ),
          if (remaining != null)
            Container(
              width: double.infinity,
              color: LifeRadarColors.cardBackground,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: LifeRadarColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${t('Ücretsiz plan:')} $remaining ${t('soru hakkın kaldı (bugün).')}',
                      style: const TextStyle(
                          fontSize: 12, color: LifeRadarColors.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PremiumScreen()),
                    ),
                    child: Text(t('Yükselt')),
                  ),
                ],
              ),
            ),
          Expanded(
            child: messages.isEmpty
                ? _EmptyState(examples: _examples, onPick: _send)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (_loading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_loading && i == messages.length) {
                        return const _TypingIndicator();
                      }
                      final m = messages[i];
                      return _Bubble(
                        message: _Message(
                            (m['t'] ?? '').toString(), m['u'] == true),
                      );
                    },
                  ),
          ),
          // Önerilen takip soruları (sohbet başladıysa ve yanıt bekleniyor değilse)
          if (messages.isNotEmpty && !_loading)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final s in _followUps)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(t(s)),
                        onPressed: () => _send(s),
                        backgroundColor:
                            LifeRadarColors.turquoise.withOpacity(0.1),
                        labelStyle: const TextStyle(
                            color: LifeRadarColors.navy, fontSize: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color:
                                  LifeRadarColors.turquoise.withOpacity(0.4)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          _Composer(
            controller: _controller,
            onSend: () => _send(_controller.text),
            onMic: _toggleListen,
            listening: _listening,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<String> examples;
  final void Function(String) onPick;
  const _EmptyState({required this.examples, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.auto_awesome,
            size: 56, color: LifeRadarColors.turquoise),
        const SizedBox(height: 12),
        Text(
          t('Merak ettiğin gelişmeyi sor.\nSana etkisini ve ne yapman gerektiğini anlatayım.'),
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: LifeRadarColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 24),
        ...examples.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              onPressed: () => onPick(e),
              style: OutlinedButton.styleFrom(
                foregroundColor: LifeRadarColors.navy,
                side: const BorderSide(color: LifeRadarColors.cardBackground),
                padding: const EdgeInsets.all(14),
                alignment: Alignment.centerLeft,
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(t(e))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Message message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? LifeRadarColors.turquoise
              : LifeRadarColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : LifeRadarColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: LifeRadarColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: LifeRadarColors.turquoise,
              ),
            ),
            const SizedBox(width: 10),
            Text(t('Analiz ediliyor...'),
                style: const TextStyle(color: LifeRadarColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMic;
  final bool listening;
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onMic,
    required this.listening,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: listening ? t('Dinleniyor...') : t('Bir soru sor...'),
                  filled: true,
                  fillColor: LifeRadarColors.cardBackground,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    tooltip: t('Sesli sor'),
                    onPressed: onMic,
                    icon: Icon(
                      listening ? Icons.mic : Icons.mic_none,
                      color: listening
                          ? LifeRadarColors.riskHigh
                          : LifeRadarColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: LifeRadarColors.turquoise,
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
