import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/api_config.dart';
import '../core/i18n.dart';
import '../core/theme.dart';
import '../models/subscription.dart';
import '../state/app_state.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/plan_comparison.dart';
import '../widgets/subscription_legal.dart';
import 'vip_screen.dart';

/// Fiyatı TL olarak gösterir. Mağaza TL fiyatı döndürürse onu, aksi halde
/// (örn. test hesabı USD veriyorsa) TL yedeğini gösterir.
String _priceText(AppState state, String id, String fallback) {
  final p = state.subscriptionPrice(id);
  if (p.isEmpty) return fallback;
  final up = p.toUpperCase();
  final isTl = p.contains('₺') || up.contains('TRY') || up.contains('TL');
  return isTl ? p : fallback;
}

/// PREMIUM SAYFASI — Life Radar Premium
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final active = state.isPremium;

    // Satın alma sonucu / hata mesajını kullanıcıya göster.
    final msg = state.purchaseMessage;
    if (msg != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(t(msg))));
        context.read<AppState>().clearPurchaseMessage();
      });
    }

    return CelebrationOverlay(
      child: Scaffold(
      appBar: AppBar(title: Text(t('Life Radar Premium'))),
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
                const _Badge(
                  label: 'PREMIUM',
                  color: LifeRadarColors.turquoise,
                  icon: Icons.star,
                ),
                const SizedBox(height: 14),
                Text(
                  t('Life Radar Premium'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t(SubscriptionData.premiumSubtitle),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PriceBox(
                        label: t('Aylık'),
                        price: _priceText(state, AppState.premiumMonthlyId,
                            SubscriptionData.premiumMonthly),
                        active: active,
                        onTap: active
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                context
                                    .read<AppState>()
                                    .buySubscription(AppState.premiumMonthlyId);
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PriceBox(
                        label: t('Yıllık'),
                        price: _priceText(state, AppState.premiumYearlyId,
                            SubscriptionData.premiumYearly),
                        highlight: true,
                        badge: t('2 ay bedava'),
                        active: active,
                        onTap: active
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                context
                                    .read<AppState>()
                                    .buySubscription(AppState.premiumYearlyId);
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.card_giftcard,
                        color: LifeRadarColors.turquoise, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t(SubscriptionData.freeTrial),
                        style: const TextStyle(
                          color: LifeRadarColors.turquoise,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!active) ...[
                  const SizedBox(height: 6),
                  Text(
                    t('Bir plana dokunarak hemen başla'),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                ],
                const SizedBox(height: 14),
                SubscriptionLegal(
                  textColor: Colors.white.withOpacity(0.6),
                  linkColor: LifeRadarColors.turquoise,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _SectionTitle(t('Premium Özellikleri')),
          ...SubscriptionData.premiumFeatures.asMap().entries.map(
                (e) => _FeatureCard(index: e.key + 1, feature: e.value),
              ),

          const SizedBox(height: 16),
          _SectionTitle(t('Planları Karşılaştır')),
          const PlanComparison(),

          const SizedBox(height: 20),
          if (active)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: LifeRadarColors.riskLow.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: LifeRadarColors.riskLow.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                      color: LifeRadarColors.riskLow),
                  const SizedBox(width: 8),
                  Text(t('Premium Aktif'),
                      style: const TextStyle(
                          color: LifeRadarColors.riskLow,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                ],
              ),
            )
          else
            Center(
              child: TextButton(
                onPressed: () => context.read<AppState>().restorePurchases(),
                child: Text(t('Satın almaları geri yükle')),
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VipScreen()),
              );
            },
            icon: const Icon(Icons.workspace_premium, color: Color(0xFFC9A227)),
            label: Text(t('VIP\'i Keşfet'),
                style: const TextStyle(color: Color(0xFFC9A227))),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: Color(0xFFC9A227)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
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
  final bool active;
  final String? badge;
  final VoidCallback? onTap;
  const _PriceBox({
    required this.label,
    required this.price,
    this.highlight = false,
    this.active = false,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ctaColor = active
        ? LifeRadarColors.riskLow
        : (highlight ? LifeRadarColors.turquoise : Colors.white70);
    final box = Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 13),
      decoration: BoxDecoration(
        color: highlight
            ? LifeRadarColors.turquoise.withOpacity(0.18)
            : Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? LifeRadarColors.turquoise
              : Colors.white.withOpacity(0.22),
          width: highlight ? 1.8 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(active ? Icons.check_circle : Icons.touch_app_outlined,
                  size: 15, color: ctaColor),
              const SizedBox(width: 5),
              Text(active ? t('Aktif') : t('Dokun & Başla'),
                  style: TextStyle(
                      color: ctaColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            box,
            if (badge != null)
              Positioned(
                top: -9,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: LifeRadarColors.turquoise,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge!.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5)),
                ),
              ),
          ],
        ),
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
                    t(feature.title),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: LifeRadarColors.navy,
                    ),
                  ),
                  if (feature.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      t(feature.description),
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
                                  t(ex),
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
