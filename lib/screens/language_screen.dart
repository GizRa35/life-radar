import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

/// Sadece dil seçimi ekranı (haber dili tercihi).
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final current = state.userContext.language == 'en' ? 'en' : 'tr';

    return Scaffold(
      appBar: AppBar(title: Text(t('Haber Dili'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LifeRadarColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.translate, color: LifeRadarColors.turquoise),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t('Seçtiğin dil arayüz dilini değil, haber dilini belirler. Yabancı kaynaklı haberler bu dile çevrilir.'),
                    style: const TextStyle(
                        fontSize: 12, color: LifeRadarColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _LangTile(
            label: 'Türkçe',
            flag: '🇹🇷',
            selected: current == 'tr',
            onTap: () => _set(context, 'tr'),
          ),
          _LangTile(
            label: 'English',
            flag: '🇬🇧',
            selected: current == 'en',
            onTap: () => _set(context, 'en'),
          ),
        ],
      ),
    );
  }

  void _set(BuildContext context, String lang) {
    final state = context.read<AppState>();
    state.updateUserContext(state.userContext.copyWith(language: lang));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(lang == 'en'
              ? 'News language: English'
              : 'Haber dili: Türkçe')),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;
  const _LangTile({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: selected
            ? const Icon(Icons.check_circle, color: LifeRadarColors.turquoise)
            : const Icon(Icons.circle_outlined,
                color: LifeRadarColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
