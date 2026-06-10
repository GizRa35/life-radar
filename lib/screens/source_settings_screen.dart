import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

/// Kaynak seçimi — hangi haber kaynaklarından içerik gelsin.
class SourceSettingsScreen extends StatelessWidget {
  const SourceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final sources = state.knownSources;

    return Scaffold(
      appBar: AppBar(title: Text(t('Kaynak Seçimi'))),
      body: sources.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  t('Henüz kaynak yüklenmedi. Haberler geldikçe burada listelenir.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: LifeRadarColors.textSecondary),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LifeRadarColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune,
                          size: 18, color: LifeRadarColors.turquoise),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t('Kapattığın kaynakların haberleri akışta gösterilmez.'),
                          style: const TextStyle(
                              fontSize: 12,
                              color: LifeRadarColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...sources.map(
                  (s) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: SwitchListTile(
                      title: Text(s,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      value: state.isSourceOn(s),
                      activeColor: LifeRadarColors.turquoise,
                      secondary: const Icon(Icons.rss_feed,
                          color: LifeRadarColors.navy),
                      onChanged: (_) {
                        HapticFeedback.selectionClick();
                        context.read<AppState>().toggleSource(s);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
