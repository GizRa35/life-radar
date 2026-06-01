import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/event_category.dart';
import '../models/subscription.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';
import 'premium_screen.dart';
import 'vip_screen.dart';

/// SAYFA 11 — PROFİL
/// Kayıtlı Haberler · Takip Edilen Konular · Bildirim Ayarları · Dil ·
/// Gizlilik · Hesap Yönetimi (+ Claude API anahtarı).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // Profil başlığı
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: LifeRadarColors.navy,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kullanıcı',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: LifeRadarColors.navy)),
                  Text('İstanbul, Türkiye',
                      style: TextStyle(color: LifeRadarColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),

        _SectionTitle('Aboneliğiniz', icon: Icons.workspace_premium_outlined),
        const _UpgradeCards(),

        _SectionTitle('Kayıtlı Haberler', icon: Icons.bookmark_outline),
        if (state.savedEvents.isEmpty)
          const _EmptyHint('Henüz kaydedilmiş haber yok. Haberlerdeki kaydet '
              'simgesine dokunarak buraya ekleyebilirsiniz.')
        else
          ...state.savedEvents.map((e) => EventCard(event: e, showActions: false)),

        _SectionTitle('Takip Edilen Konular', icon: Icons.topic_outlined),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EventCategory.values.map((c) {
              final followed = state.isFollowed(c);
              return FilterChip(
                label: Text(c.label),
                selected: followed,
                onSelected: (_) => context.read<AppState>().toggleFollowed(c),
                avatar: Icon(c.icon,
                    size: 16,
                    color: followed ? Colors.white : LifeRadarColors.navy),
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

        _SectionTitle('Yapay Zekâ', icon: Icons.auto_awesome),
        const _ApiKeyTile(),

        _SectionTitle('Ayarlar', icon: Icons.settings_outlined),
        const _SettingTile(icon: Icons.notifications_outlined, title: 'Bildirim Ayarları'),
        const _SettingTile(icon: Icons.language, title: 'Dil Seçimi', trailing: 'Türkçe'),
        const _SettingTile(icon: Icons.lock_outline, title: 'Gizlilik'),
        const _SettingTile(icon: Icons.manage_accounts_outlined, title: 'Hesap Yönetimi'),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Dünyayı Anla. Riskleri Gör. Hazırlıklı Ol.',
            style: TextStyle(
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

class _ApiKeyTile extends StatefulWidget {
  const _ApiKeyTile();

  @override
  State<_ApiKeyTile> createState() => _ApiKeyTileState();
}

class _ApiKeyTileState extends State<_ApiKeyTile> {
  late final TextEditingController _controller;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<AppState>().apiKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Google Gemini API Anahtarı',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: LifeRadarColors.navy),
            ),
            const SizedBox(height: 4),
            const Text(
              'AI asistanı ve etki analizi için ücretsiz Gemini anahtarınızı girin. '
              'aistudio.google.com → "Get API key" (kredi kartı gerekmez). '
              'Anahtar yalnızca cihazınızda tutulur.',
              style: TextStyle(
                  color: LifeRadarColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'AIza...',
                filled: true,
                fillColor: LifeRadarColors.background,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppState>().setApiKey(_controller.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API anahtarı kaydedildi')),
                  );
                },
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined,
                  color: LifeRadarColors.navy),
              title: const Text('Mevcut Plan',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tier.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tier.label,
                  style: TextStyle(
                    color: tier.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          _UpgradeTile(
            title: 'Life Radar Premium',
            subtitle: 'Sınırsız AI, kişisel risk analizi, reklamsız.',
            icon: Icons.star,
            color: LifeRadarColors.turquoise,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            ),
          ),
          _UpgradeTile(
            title: 'Life Radar VIP',
            subtitle: 'Aile koruma, şehir risk merkezi, erken uyarı.',
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

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  const _SettingTile({required this.icon, required this.title, this.trailing});

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
            const Icon(Icons.chevron_right, color: LifeRadarColors.textSecondary),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title yakında')),
          );
        },
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
