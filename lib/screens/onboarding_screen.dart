import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

/// İlk açılış karşılama turu — uygulamayı 4 adımda tanıtır.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnbPage(
      icon: Icons.public,
      title: 'Ne oluyor?',
      text:
          'Dünyadan ve Türkiye\'den güvenilir kaynakların haberlerini tek yerde, '
          'aynı konu tek seferde, sade bir akışta gör.',
    ),
    _OnbPage(
      icon: Icons.person_search,
      title: 'Beni etkiler mi?',
      text:
          'Konumun ve profiline göre kişisel risk puanın hesaplanır. Bir haberin '
          'seni nasıl etkileyebileceğini Life Radar Asistan açıklar.',
    ),
    _OnbPage(
      icon: Icons.checklist_rtl,
      title: 'Ne yapmalıyım?',
      text:
          'Her gelişme için sakin, kanıta dayalı "yapılacaklar / yapılmayacaklar" '
          've hane halkına özel hazırlık önerileri sunulur.',
    ),
    _OnbPage(
      icon: Icons.verified_user_outlined,
      title: 'Gizlilik sende',
      text:
          'Verilerin cihazında tutulur; istediğin an dışa aktarır veya silersin. '
          'Bildirim ve gizlilik ayarları tamamen senin kontrolünde.',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      context.read<AppState>().completeOnboarding();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: LifeRadarColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    context.read<AppState>().completeOnboarding(),
                child: Text(t('Atla'),
                    style: TextStyle(color: Colors.white.withOpacity(0.8))),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? LifeRadarColors.turquoise
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(isLast ? t('Başla') : t('Devam')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnbPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _OnbPage(
      {required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: LifeRadarColors.turquoise.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: LifeRadarColors.turquoise),
          ),
          const SizedBox(height: 36),
          Text(
            t(title),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            t(text),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.slogan,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LifeRadarColors.turquoise.withOpacity(0.7),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
