import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/subscription.dart';
import '../state/app_state.dart';
import '../widgets/plan_comparison.dart';

const Color _gold = Color(0xFFC9A227);
const Color _goldLight = Color(0xFFE9C766);

/// VIP SAYFASI — Life Radar VIP (altın detaylar, özel rozet)
class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final active = state.isVip;

    return Scaffold(
      appBar: AppBar(title: const Text('Life Radar VIP')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // VIP kartı — altın detaylar, premium görünüm
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A2342), Color(0xFF1B1B2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_gold, _goldLight]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium,
                              color: Color(0xFF1B1B2F), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'VIP',
                            style: TextStyle(
                              color: Color(0xFF1B1B2F),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Life Radar VIP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  SubscriptionData.vipSubtitle,
                  style: TextStyle(
                    color: _goldLight.withOpacity(0.95),
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _GoldPriceBox(
                        label: 'Aylık',
                        price: SubscriptionData.vipMonthly,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GoldPriceBox(
                        label: 'Yıllık',
                        price: SubscriptionData.vipYearly,
                        highlight: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.card_giftcard, color: _goldLight, size: 18),
                    SizedBox(width: 8),
                    Text(
                      SubscriptionData.freeTrial,
                      style: TextStyle(
                        color: _goldLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const _SectionTitle('VIP Özellikleri'),
          ...SubscriptionData.vipFeatures.asMap().entries.map(
                (e) => _VipFeatureCard(index: e.key + 1, feature: e.value),
              ),

          const SizedBox(height: 16),
          const _SectionTitle('Planları Karşılaştır'),
          const PlanComparison(),

          const SizedBox(height: 24),
          _GoldButton(
            label: active ? 'VIP Aktif' : 'VIP\'e Yükselt — 7 Gün Ücretsiz',
            onPressed: active
                ? null
                : () {
                    context.read<AppState>().setTier(SubscriptionTier.vip);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('VIP etkinleştirildi (deneme)')),
                    );
                  },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _GoldPriceBox extends StatelessWidget {
  final String label;
  final String price;
  final bool highlight;
  const _GoldPriceBox({
    required this.label,
    required this.price,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? _gold.withOpacity(0.18) : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? _gold : Colors.white.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
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

class _VipFeatureCard extends StatelessWidget {
  final int index;
  final PlanFeature feature;
  const _VipFeatureCard({required this.index, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _gold.withOpacity(0.35)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_gold, _goldLight]),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: const TextStyle(
                    color: Color(0xFF1B1B2F),
                    fontWeight: FontWeight.w900,
                    fontSize: 13),
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
                                  color: _gold.withOpacity(0.1),
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

class _GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _GoldButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_gold, _goldLight]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: const Color(0xFF1B1B2F),
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
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
