import 'package:flutter/material.dart';

import '../core/api_config.dart';
import '../core/i18n.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/emergency_guide.dart';
import 'emergency_call_screen.dart';
import 'emergency_kit_screen.dart';
import 'family_plan_screen.dart';

/// SAYFA 8 — ACİL DURUM REHBERİ
/// Kategori kartları → detayda görsel başlık + renk kodlu listeler.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guides = MockData.guides;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          t('Acil Durum Rehberi'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: LifeRadarColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t('Bir kategoriye dokunarak hazırlık adımlarını görün.'),
          style: const TextStyle(color: LifeRadarColors.textSecondary),
        ),
        const SizedBox(height: 16),
        // Hızlı erişim: acil çanta + hızlı arama
        Row(
          children: [
            Expanded(
              child: _QuickCard(
                icon: Icons.backpack,
                label: t('Acil Çantam'),
                color: LifeRadarColors.turquoise,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EmergencyKitScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickCard(
                icon: Icons.call,
                label: t('Hızlı Arama'),
                color: const Color(0xFFFF453A),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EmergencyCallScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Aile acil planı (tam genişlik)
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FamilyPlanScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LifeRadarColors.navy.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LifeRadarColors.navy.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.family_restroom, color: LifeRadarColors.navy),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t('Aile Acil Planı'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: LifeRadarColors.navy,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: LifeRadarColors.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05,
          children:
              guides.map((g) => _GuideCategoryCard(guide: g)).toList(),
        ),
      ],
    );
  }
}

/// Rehber üstündeki hızlı erişim kartı (Acil Çanta / Hızlı Arama).
class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kategoriye göre Pexels arama kelimesi (gerçek fotoğraf için).
String guideQuery(String title) {
  switch (title) {
    case 'Deprem':
      return 'earthquake collapsed building rubble';
    case 'Sel':
      return 'flooded street city disaster';
    case 'Yangın':
      return 'forest fire flames night';
    case 'Elektrik Kesintisi':
      return 'electricity power lines sunset';
    case 'Su Kesintisi':
      return 'cracked dry earth drought';
    case 'Salgın Hastalık':
      return 'person wearing face mask';
    case 'Aşırı Hava Olayları':
      return 'lightning thunderstorm sky';
    default:
      return 'emergency';
  }
}

/// Kategoriye göre tema rengi.
Color guideColor(String title) {
  switch (title) {
    case 'Deprem':
      return const Color(0xFFC0392B);
    case 'Sel':
      return const Color(0xFF2980B9);
    case 'Yangın':
      return const Color(0xFFE67E22);
    case 'Elektrik Kesintisi':
      return const Color(0xFF8E44AD);
    case 'Su Kesintisi':
      return const Color(0xFF16A085);
    case 'Salgın Hastalık':
      return const Color(0xFF27AE60);
    case 'Aşırı Hava Olayları':
      return const Color(0xFF2C3E50);
    default:
      return LifeRadarColors.turquoise;
  }
}

class _GuideCategoryCard extends StatelessWidget {
  final EmergencyGuide guide;
  const _GuideCategoryCard({required this.guide});

  @override
  Widget build(BuildContext context) {
    final color = guideColor(guide.title);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _GuideDetailScreen(guide: guide)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, Color.lerp(color, Colors.black, 0.25)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(guide.icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              t(guide.title),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideDetailScreen extends StatelessWidget {
  final EmergencyGuide guide;
  const _GuideDetailScreen({required this.guide});

  @override
  Widget build(BuildContext context) {
    final color = guideColor(guide.title);

    return Scaffold(
      appBar: AppBar(title: Text(t(guide.title))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          // Görsel başlık (Pexels fotoğrafı + gradyan kaplama)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Arka plan: önce renkli gradyan (fallback)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, Color.lerp(color, Colors.black, 0.3)!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Pexels fotoğrafı (yüklenince gradyanın üstüne biner)
                  Image.network(
                    '${ApiConfig.base}/api/pexels?q=${Uri.encodeComponent(guideQuery(guide.title))}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    loadingBuilder: (ctx, child, progress) =>
                        progress == null ? child : const SizedBox.shrink(),
                  ),
                  // Okunabilirlik için koyu gradyan kaplama
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(guide.icon, color: Colors.white, size: 34),
                        const SizedBox(height: 6),
                        Text(
                          t(guide.title),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Hazırlık ve acil durum rehberi',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          _GuideBlock(
            title: t('Hazırlık Listesi'),
            icon: Icons.fact_check_outlined,
            accent: LifeRadarColors.turquoise,
            items: guide.preparation,
          ),
          _GuideBlock(
            title: t('İlk 24 Saat'),
            icon: Icons.timer_outlined,
            accent: LifeRadarColors.riskMedium,
            items: guide.first24Hours,
          ),
          _GuideBlock(
            title: t('Gerekli Malzemeler'),
            icon: Icons.inventory_2_outlined,
            accent: LifeRadarColors.navy,
            items: guide.supplies,
          ),
          _GuideBlock(
            title: t('İlk Yardım Bilgileri'),
            icon: Icons.medical_services_outlined,
            accent: LifeRadarColors.riskHigh,
            items: guide.firstAid,
          ),
        ],
      ),
    );
  }
}

class _GuideBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final List<String> items;
  const _GuideBlock({
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık şeridi
          Container(
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, size: 18, color: accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(i,
                                style: const TextStyle(
                                    height: 1.35, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
