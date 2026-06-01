import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/emergency_guide.dart';

/// SAYFA 8 — ACİL DURUM REHBERİ
/// Kategori kartları → detayda Hazırlık / İlk 24 Saat / Malzemeler / İlk Yardım.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guides = MockData.guides;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Acil Durum Rehberi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: LifeRadarColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bir kategoriye dokunarak hazırlık adımlarını görün.',
          style: TextStyle(color: LifeRadarColors.textSecondary),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: guides
              .map((g) => _GuideCategoryCard(guide: g))
              .toList(),
        ),
      ],
    );
  }
}

class _GuideCategoryCard extends StatelessWidget {
  final EmergencyGuide guide;
  const _GuideCategoryCard({required this.guide});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _GuideDetailScreen(guide: guide)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: LifeRadarColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: LifeRadarColors.turquoise.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(guide.icon,
                  color: LifeRadarColors.turquoise, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              guide.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: LifeRadarColors.navy,
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
    return Scaffold(
      appBar: AppBar(title: Text(guide.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GuideBlock(
            title: 'Hazırlık Listesi',
            icon: Icons.fact_check_outlined,
            items: guide.preparation,
          ),
          _GuideBlock(
            title: 'İlk 24 Saat',
            icon: Icons.timer_outlined,
            items: guide.first24Hours,
          ),
          _GuideBlock(
            title: 'Gerekli Malzemeler',
            icon: Icons.inventory_2_outlined,
            items: guide.supplies,
          ),
          _GuideBlock(
            title: 'İlk Yardım Bilgileri',
            icon: Icons.medical_services_outlined,
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
  final List<String> items;
  const _GuideBlock({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: LifeRadarColors.turquoise, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: LifeRadarColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle,
                          size: 6, color: LifeRadarColors.turquoise),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(i, style: const TextStyle(height: 1.35))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
