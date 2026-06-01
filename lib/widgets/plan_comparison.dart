import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/subscription.dart';

/// Ücretsiz / Premium / VIP karşılaştırma tablosu.
class PlanComparison extends StatelessWidget {
  const PlanComparison({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PlanColumn(
          tier: SubscriptionTier.free,
          features: SubscriptionData.freePlan,
        ),
        const SizedBox(height: 12),
        _PlanColumn(
          tier: SubscriptionTier.premium,
          features: SubscriptionData.premiumPlan,
        ),
        const SizedBox(height: 12),
        _PlanColumn(
          tier: SubscriptionTier.vip,
          features: SubscriptionData.vipPlan,
        ),
      ],
    );
  }
}

class _PlanColumn extends StatelessWidget {
  final SubscriptionTier tier;
  final List<String> features;
  const _PlanColumn({required this.tier, required this.features});

  @override
  Widget build(BuildContext context) {
    final color = tier.color;
    return Container(
      decoration: BoxDecoration(
        color: LifeRadarColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tier == SubscriptionTier.vip
                    ? Icons.workspace_premium
                    : tier == SubscriptionTier.premium
                        ? Icons.star
                        : Icons.check_circle_outline,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                tier.label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f, style: const TextStyle(height: 1.3))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
