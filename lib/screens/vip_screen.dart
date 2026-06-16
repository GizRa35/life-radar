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
import 'vip_hub_screen.dart';

/// Fiyatı TL olarak gösterir. Mağaza TL döndürmezse (örn. test USD) TL yedeği.
String _vipPrice(AppState state, String id, String fallback) {
  final p = state.subscriptionPrice(id);
  if (p.isEmpty) return fallback;
  final up = p.toUpperCase();
  final isTl = p.contains('₺') || up.contains('TRY') || up.contains('TL');
  return isTl ? p : fallback;
}

const Color _gold = Color(0xFFC9A227);
const Color _goldLight = Color(0xFFE9C766);

/// VIP SAYFASI — Life Radar VIP (altın detaylar, özel rozet)
class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final active = state.isVip;

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
      appBar: AppBar(title: Text(t('Life Radar VIP'))),
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
                  const ColoredBox(color: _gold),
                  Image.network(
                    '${ApiConfig.base}/api/pexels?q=luxury%20gold%20abstract',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    loadingBuilder: (c, ch, p) =>
                        p == null ? ch : const SizedBox.shrink(),
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
                  const Positioned(
                    left: 16,
                    bottom: 14,
                    child: Row(
                      children: [
                        Icon(Icons.workspace_premium, color: _gold, size: 26),
                        SizedBox(width: 8),
                        Text('VIP',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Aktif VIP kullanıcıya özel "Sen VIP'sin" karşılaması
          if (active) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_gold, _goldLight]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium,
                      color: Color(0xFF1B1B2F), size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.read<AppState>().displayName}${t(', sen VIP\'sin 👑')}',
                          style: const TextStyle(
                            color: Color(0xFF1B1B2F),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t('En üst düzey koruma ve ayrıcalıklar aktif.'),
                          style: const TextStyle(
                              color: Color(0xFF1B1B2F), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _GoldButton(
              label: t('VIP Merkezini Aç'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VipHubScreen()),
              ),
            ),
            const SizedBox(height: 16),
          ],
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
                Text(
                  t('Life Radar VIP'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t(SubscriptionData.vipSubtitle),
                  style: TextStyle(
                    color: _goldLight.withOpacity(0.95),
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _GoldPriceBox(
                        label: t('Aylık'),
                        price: _vipPrice(state, AppState.vipMonthlyId,
                            SubscriptionData.vipMonthly),
                        active: active,
                        onTap: active
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                context
                                    .read<AppState>()
                                    .buySubscription(AppState.vipMonthlyId);
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GoldPriceBox(
                        label: t('Yıllık'),
                        price: _vipPrice(state, AppState.vipYearlyId,
                            SubscriptionData.vipYearly),
                        highlight: true,
                        badge: t('2 ay bedava'),
                        active: active,
                        onTap: active
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                context
                                    .read<AppState>()
                                    .buySubscription(AppState.vipYearlyId);
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: _goldLight, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t(SubscriptionData.freeTrial),
                        style: const TextStyle(
                          color: _goldLight,
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
                  textColor: Colors.white.withOpacity(0.65),
                  linkColor: _goldLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _SectionTitle(t('VIP Özellikleri')),
          ...SubscriptionData.vipFeatures.asMap().entries.map(
                (e) => _VipFeatureCard(index: e.key + 1, feature: e.value),
              ),

          const SizedBox(height: 16),
          _SectionTitle(t('Planları Karşılaştır')),
          const PlanComparison(),

          const SizedBox(height: 16),
          // Satın alma artık fiyat kutularına dokunarak yapılır.
          // VIP olmayanlara yalnızca "geri yükle" bağlantısı gösterilir.
          if (!active)
            Center(
              child: TextButton(
                onPressed: () => context.read<AppState>().restorePurchases(),
                child: Text(t('Satın almaları geri yükle')),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }
}

class _GoldPriceBox extends StatelessWidget {
  final String label;
  final String price;
  final bool highlight;
  final bool active;
  final String? badge;
  final VoidCallback? onTap;
  const _GoldPriceBox({
    required this.label,
    required this.price,
    this.highlight = false,
    this.active = false,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ctaColor = active ? LifeRadarColors.riskLow : _goldLight;
    final box = Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 13),
      decoration: BoxDecoration(
        color: highlight ? _gold.withOpacity(0.18) : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? _gold : Colors.white.withOpacity(0.2),
          width: highlight ? 1.8 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
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
                    gradient: const LinearGradient(colors: [_gold, _goldLight]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge!.toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF1B1B2F),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5)),
                ),
              ),
          ],
        ),
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
                                  color: _gold.withOpacity(0.1),
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
