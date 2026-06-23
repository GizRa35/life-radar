import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/media.dart';
import '../core/theme.dart';
import '../models/event_category.dart';
import '../models/subscription.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';
import 'account_management_screen.dart';
import 'notification_settings_screen.dart';
import 'personal_info_screen.dart';
import 'privacy_screen.dart';
import 'premium_screen.dart';
import 'language_screen.dart';
import 'source_settings_screen.dart';
import 'usage_guide_screen.dart';
import 'vip_screen.dart';

/// SAYFA 11 — PROFİL
/// Renkli başlık + açılır bölümler (Abonelik / Kayıtlı / Takip / Ayarlar).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        // Renkli profil başlığı (abonelik tonuna göre gradyan)
        const _ProfileHeader(),

        _SectionTitle(t('Kişisel Bilgiler'), icon: Icons.badge_outlined),
        const _PersonalInfoTile(),

        _ExpandSection(
          title: t('Aboneliğiniz'),
          icon: Icons.workspace_premium_outlined,
          children: const [_UpgradeCards()],
        ),

        _ExpandSection(
          title: '${t('Kayıtlı Haberler')} (${state.savedEvents.length})',
          icon: Icons.bookmark_outline,
          children: [
            if (state.savedEvents.isEmpty)
              _EmptyHint(t('Henüz kaydedilmiş haber yok. Haberlerdeki kaydet simgesine dokunarak buraya ekleyebilirsiniz.'))
            else
              ...state.savedByCategory.entries.expand((entry) => [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Icon(entry.key.icon,
                              size: 16, color: entry.key.color),
                          const SizedBox(width: 6),
                          Text(
                            '${t(entry.key.label)} (${entry.value.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: entry.key.color,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...entry.value
                        .map((e) => EventCard(event: e, showActions: false)),
                  ]),
          ],
        ),

        _ExpandSection(
          title: t('Takip Edilen Konular'),
          icon: Icons.topic_outlined,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EventCategory.values.map((c) {
                  final followed = state.isFollowed(c);
                  return FilterChip(
                    label: Text(t(c.label)),
                    selected: followed,
                    onSelected: (_) =>
                        context.read<AppState>().toggleFollowed(c),
                    avatar: Icon(c.icon,
                        size: 16,
                        color:
                            followed ? Colors.white : LifeRadarColors.navy),
                    selectedColor: LifeRadarColors.turquoise,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: followed ? Colors.white : LifeRadarColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: LifeRadarColors.cardBackground,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        _ExpandSection(
          title: t('Ayarlar'),
          icon: Icons.settings_outlined,
          children: [
            _SettingTile(
              icon: Icons.help_outline,
              title: t('Nasıl Kullanılır?'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UsageGuideScreen()),
              ),
            ),
            _SettingTile(
              icon: Icons.notifications_outlined,
              title: t('Bildirim Ayarları'),
              trailing: state.alertsEnabled ? t('Açık') : t('Kapalı'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen()),
              ),
            ),
            _SettingTile(
              icon: Icons.language,
              title: t('Haber Dili'),
              trailing:
                  state.userContext.language == 'en' ? 'English' : t('Türkçe'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              ),
            ),
            _SettingTile(
              icon: Icons.rss_feed,
              title: t('Kaynak Seçimi'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SourceSettingsScreen()),
              ),
            ),
            _SettingTile(
              icon: Icons.lock_outline,
              title: t('Gizlilik'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              ),
            ),
            _SettingTile(
              icon: Icons.manage_accounts_outlined,
              title: t('Hesap Yönetimi'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AccountManagementScreen()),
              ),
            ),
          ],
        ),

        _SectionTitle(t('Hesap'), icon: Icons.account_circle_outlined),
        const _AccountTile(),

        const SizedBox(height: 24),
        Center(
          child: Text(
            t('Dünyayı Anla. Riskleri Gör. Hazırlıklı Ol.'),
            style: const TextStyle(
              color: LifeRadarColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Abonelik tonuna göre çerçeve rengi.
Color _tierRingColor(SubscriptionTier tier) {
  switch (tier) {
    case SubscriptionTier.vip:
      return const Color(0xFFC9A227); // altın
    case SubscriptionTier.premium:
      return LifeRadarColors.turquoise;
    case SubscriptionTier.free:
      return LifeRadarColors.navy;
  }
}

/// Başlık gradyanı (abonelik tonuna göre).
List<Color> _headerGradient(SubscriptionTier tier) {
  switch (tier) {
    case SubscriptionTier.vip:
      return const [Color(0xFFB8901C), Color(0xFFE9C766)];
    case SubscriptionTier.premium:
      return const [LifeRadarColors.navy, LifeRadarColors.turquoise];
    case SubscriptionTier.free:
      return const [LifeRadarColors.navy, Color(0xFF1B4F72)];
  }
}

/// Seçilebilir avatarlar — DiceBear "avataaars" (canlı, renkli), net cinsiyetli.
const String _avBase = 'https://api.dicebear.com/9.x/avataaars/png?seed=';

String _avWoman(String seed) =>
    '$_avBase$seed&top=straight01,straight02,bob,bun,curvy,longButNotTooLong,miaWallace,bigHair'
    '&facialHairProbability=0&accessoriesProbability=10';

String _avMan(String seed) =>
    '$_avBase$seed&top=shortFlat,shortRound,theCaesar,shortCurly,shortWaved,dreads01'
    '&facialHair=beardLight,beardMedium,beardMajestic&facialHairProbability=100';

String _avUnisex(String seed) => '$_avBase$seed';

final Map<String, List<String>> _avatarGroups = {
  'Kadın': [
    for (final s in ['Zoe', 'Mia', 'Aria', 'Luna', 'Defne']) _avWoman(s),
  ],
  'Erkek': [
    for (final s in ['Can', 'Emir', 'Ali', 'Mert', 'Efe']) _avMan(s),
  ],
  'Unisex': [
    for (final s in ['Sky', 'River', 'Robin', 'Alex', 'Sam']) _avUnisex(s),
  ],
};

/// Profil resmine tıklayınca açılan avatar seçim modalı.
void showAvatarSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetCtx) {
      final ring = _tierRingColor(sheetCtx.read<AppState>().tier);
      final current = sheetCtx.watch<AppState>().avatar;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: LifeRadarColors.cardBackground,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              t('Avatar Seç'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: LifeRadarColors.navy),
            ),
            const SizedBox(height: 8),
            for (final group in _avatarGroups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 14, 0, 8),
                child: Text(
                  t(group.key),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LifeRadarColors.textSecondary,
                  ),
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: group.value.map((url) {
                  final selected = current == url;
                  return GestureDetector(
                    onTap: () {
                      sheetCtx.read<AppState>().setAvatar(url);
                      Navigator.of(sheetCtx).pop();
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: LifeRadarColors.cardBackground,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? ring : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          Media.proxiedImage(url),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person,
                              color: LifeRadarColors.navy),
                          loadingBuilder: (c, child, p) => p == null
                              ? child
                              : const Center(
                                  child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tier = state.tier;
    final ring = _tierRingColor(tier);
    final loc = state.location?.label ?? state.userContext.location;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _headerGradient(tier),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _headerGradient(tier).last.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar — tıklayınca avatar seçimi açılır
          GestureDetector(
            onTap: () => showAvatarSheet(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: SizedBox(
                        width: 54,
                        height: 54,
                        child: Image.network(
                          Media.proxiedImage(state.avatar),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person,
                              size: 30, color: LifeRadarColors.navy),
                          loadingBuilder: (c, child, p) => p == null
                              ? child
                              : const Center(
                                  child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: ring,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.edit, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(state.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                    if (tier != SubscriptionTier.free) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.6)),
                        ),
                        child: Text(
                          t(tier.label),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(loc,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeCards extends StatelessWidget {
  const _UpgradeCards();

  @override
  Widget build(BuildContext context) {
    final tier = context.watch<AppState>().tier;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined,
                  color: LifeRadarColors.navy),
              title: Text(t('Mevcut Plan'),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tier.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t(tier.label),
                  style: TextStyle(
                    color: tier.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          _UpgradeTile(
            title: t('Life Radar Premium'),
            subtitle: t(
                'Sınırsız Life Radar Asistan, kişisel risk analizi, reklamsız.'),
            icon: Icons.star,
            color: LifeRadarColors.turquoise,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            ),
          ),
          _UpgradeTile(
            title: t('Life Radar VIP'),
            subtitle: t('Aile koruma, şehir risk merkezi, erken uyarı.'),
            icon: Icons.workspace_premium,
            color: const Color(0xFFC9A227),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VipScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _UpgradeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right,
            color: LifeRadarColors.textSecondary),
      ),
    );
  }
}

class _PersonalInfoTile extends StatelessWidget {
  const _PersonalInfoTile();

  @override
  Widget build(BuildContext context) {
    final filled = context.watch<AppState>().hasPersonalInfo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          leading: Icon(
            filled ? Icons.badge : Icons.badge_outlined,
            color: filled ? LifeRadarColors.turquoise : LifeRadarColors.navy,
          ),
          title: Text(t('Kişisel Bilgilerim'),
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(filled
              ? t('Life Radar Asistan analizleri bilgilerine göre kişiselleştiriliyor.')
              : t('Doldur → analizler sana özel olsun (yaş, sağlık, ev, aile...).')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final loggedIn = state.isLoggedIn;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          leading: Icon(
            loggedIn ? Icons.verified_user : Icons.person_outline,
            color: loggedIn ? LifeRadarColors.turquoise : LifeRadarColors.navy,
          ),
          title: Text(
            loggedIn ? (state.authEmail ?? t('Hesap')) : t('Misafir kullanıcı'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(loggedIn
              ? t('Giriş yapıldı')
              : t('Verileriniz yalnızca bu cihazda. Giriş yapın.')),
          trailing: TextButton(
            onPressed: () => state.logout(),
            child: Text(loggedIn ? t('Çıkış Yap') : t('Giriş Yap')),
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;
  const _SettingTile(
      {required this.icon, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: LifeRadarColors.navy),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(trailing!,
                  style: const TextStyle(color: LifeRadarColors.textSecondary)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: LifeRadarColors.textSecondary),
          ],
        ),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title ${t('yakında')}')),
              );
            },
      ),
    );
  }
}

/// Açılır/kapanır bölüm — başlığa dokununca içerik açılır (sayfa sadeleşir).
class _ExpandSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;
  const _ExpandSection({
    required this.title,
    required this.icon,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(icon, color: LifeRadarColors.navy),
            iconColor: LifeRadarColors.turquoise,
            collapsedIconColor: LifeRadarColors.navy,
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: LifeRadarColors.navy,
              ),
            ),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            children: children,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: LifeRadarColors.navy),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: LifeRadarColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            text,
            style: const TextStyle(color: LifeRadarColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
