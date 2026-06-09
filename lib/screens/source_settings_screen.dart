import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
      appBar: AppBar(title: const Text('Kaynak Seçimi')),
      body: sources.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Henüz kaynak yüklenmedi. Haberler geldikçe burada listelenir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: LifeRadarColors.textSecondary),
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
                  child: const Row(
                    children: [
                      Icon(Icons.tune,
                          size: 18, color: LifeRadarColors.turquoise),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kapattığın kaynakların haberleri akışta gösterilmez.',
                          style: TextStyle(
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
