import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_config.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/action_plan_view.dart';
import '../widgets/ai_rich_text.dart';

/// AI sonucunu görsel başlık + kart + zengin biçimle gösteren genel ekran.
class AiResultScreen extends StatefulWidget {
  final String title;
  final Future<String> Function(AppState) run;
  final IconData icon;
  final Color accent;
  final String subtitle;
  final String? imageQuery; // Pexels görsel arama kelimesi (web)
  final bool sectionCards; // true → başlıklı kartlar + bütçe kutusu

  const AiResultScreen({
    super.key,
    required this.title,
    required this.run,
    this.icon = Icons.auto_awesome,
    this.accent = const Color(0xFFC9A227),
    this.subtitle = 'Life Radar Asistan tarafından sana özel hazırlandı',
    this.imageQuery,
    this.sectionCards = false,
  });

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  Future<String>? _future;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _future = widget.run(context.read<AppState>());
  }

  void _regen() =>
      setState(() => _future = widget.run(context.read<AppState>()));

  Widget _header(Color accent) {
    final content = Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(widget.subtitle,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 12)),
            ],
          ),
        ),
      ],
    );

    if (widget.imageQuery == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, Color.lerp(accent, Colors.black, 0.35)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, Color.lerp(accent, Colors.black, 0.35)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Image.network(
              '${ApiConfig.base}/api/pexels?q=${Uri.encodeComponent(widget.imageQuery!)}',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              loadingBuilder: (c, child, p) =>
                  p == null ? child : const SizedBox.shrink(),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Align(alignment: Alignment.bottomLeft, child: content),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(accent),
          const SizedBox(height: 16),

          FutureBuilder<String>(
            future: _future,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return _LoadingCard(accent: accent);
              }
              final text = (snap.data ?? '').trim();
              if (text.isEmpty) {
                return const _EmptyCard();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.sectionCards)
                    ActionPlanView(text: text, accent: accent)
                  else
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: AiRichText(text: text, accent: accent),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _regen,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Yeniden Üret'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 14, color: LifeRadarColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Bilgilendirme amaçlıdır; kesin tahmin değildir. '
                          'Resmi kaynakları da takip edin.',
                          style: TextStyle(
                              fontSize: 11,
                              color: LifeRadarColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final Color accent;
  const _LoadingCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            CircularProgressIndicator(color: accent),
            const SizedBox(height: 16),
            const Text('Life Radar Asistan senin için hazırlıyor...',
                style: TextStyle(
                    color: LifeRadarColors.textSecondary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('Birkaç saniye sürebilir',
                style: TextStyle(
                    color: LifeRadarColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Sonuç alınamadı. Bağlantını kontrol edip "Yeniden Üret" ile tekrar dene.',
          style: TextStyle(color: LifeRadarColors.textSecondary),
        ),
      ),
    );
  }
}
