import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_config.dart';
import '../core/theme.dart';
import '../models/subscription.dart';
import '../state/app_state.dart';
import '../widgets/plan_comparison.dart';
import 'vip_screen.dart';

/// Store'dan gelen fiyatı döndürür; gelmezse yedek metni gösterir.
String _priceText(AppState state, String id, String fallback) {
  final p = state.subscriptionPrice(id);
  return p.isEmpty ? fallback : p;
}

/// PREMIUM SAYFASI — Life Radar Premium
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final active = state.isPremium;

    return Scaffold(
      appBar: AppBar(title: const Text('Life Radar Premium')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Görsel banner
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: LifeRadarColors.turquoise),
                  Image.network(
                    '${ApiConfig.base}/api/pexels?q=technology%20blue%20abstract',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    loadingBuilder: (c, ch, p) =>
                        p == null ? ch : const SizedBox.shrink(),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black54],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    bottom: 14,
                    child: Text('PREMIUM',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Üst bölüm — başlık, rozet, fiyatlar, deneme
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LifeRadarColors.navy, Color(0xFF123A63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Badge(
                  label: 'PREMIUM',
                  color: LifeRadarColors.turquoise,
                  icon: Icons.star,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Life Radar Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  SubscriptionData.premiumSubtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _PriceBox(
                        label: 'Aylık',
                        price: _priceText(state, AppState.premiumMonthlyId,
                            SubscriptionData.premiumMonthly),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PriceBox(
                        label: 'Yıllık',
                        price: _priceText(state, AppState.premiumYearlyId,
                            SubscriptionData.premiumYearly),
                        highlight: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.card_giftcard,
                        color: LifeRadarColors.turquoise, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      SubscriptionData.freeTrial,
                      style: const TextStyle(
                        color: LifeRadarColors.turquoise,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const _SectionTitle('Premium Özellikleri'),
          ...SubscriptionData.premiumFeatures.asMap().entries.map(
                (e) => _FeatureCard(index: e.key + 1, feature: e.value),
              ),

          const SizedBox(height: 16),
          const _SectionTitle('Planları Karşılaştır'),
          const PlanComparison(),

          const SizedBox(height: 24),
          if (active)
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: const Text('Premium Aktif'),
            )
          else ...[
            // Aylık abonelik
            ElevatedButton(
              onPressed: () =>
                  context.read<AppState>().buySubscription(AppState.premiumMonthlyId),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: Text(
                'Aylık  ${_priceText(state, AppState.premiumMonthlyId, SubscriptionData.premiumMonthly)}',
              ),
            ),
            const SizedBox(height: 10),
            // Yıllık abonelik (indirimli)
            OutlinedButton(
              onPressed: () =>
                  context.read<AppState>().buySubscription(AppState.premiumYearlyId),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: LifeRadarColors.turquoise),
              ),
              child: Text(
                'Yıllık  ${_priceText(state, AppState.premiumYearlyId, SubscriptionData.premiumYearly)}  ·  2 ay bedava',
                style: const TextStyle(color: LifeRadarColors.turquoise),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => context.read<AppState>().restorePurchases(),
              child: const Text('Satın almaları geri yükle'),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VipScreen()),
              );
            },
            icon: const Icon(Icons.workspace_premium, color: Color(0xFFC9A227)),
            label: const Text('VIP\'i Keşfet',
                style: TextStyle(color: Color(0xFFC9A227))),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: Color(0xFFC9A227)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _Badge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final String price;
  final bool highlight;
  const _PriceBox({
    required this.label,
    required this.price,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? LifeRadarColors.turquoise.withOpacity(0.15)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? LifeRadarColors.turquoise
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final int index;
  final PlanFeature feature;
  const _FeatureCard({required this.index, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: LifeRadarColors.turquoise,
              child: Text(
                '$index',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: LifeRadarColors.navy,
                    ),
                  ),
                  if (feature.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      feature.description,
                      style: const TextStyle(
                        color: LifeRadarColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (feature.examples.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: feature.examples
                          .map((ex) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: LifeRadarColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ex,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: LifeRadarColors.textSecondary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: LifeRadarColors.navy,
        ),
      ),
    );
  }
}
