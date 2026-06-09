import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../services/geocode_service.dart';
import '../state/app_state.dart';

/// Takip edilen şehirler — kendi şehrin + memleket/aile şehri için deprem riski.
class CitiesScreen extends StatelessWidget {
  const CitiesScreen({super.key});

  Color _scoreColor(int s) {
    if (s >= 70) return LifeRadarColors.riskHigh;
    if (s >= 40) return LifeRadarColors.riskMedium;
    return LifeRadarColors.riskLow;
  }

  String _scoreLabel(int s) {
    if (s >= 70) return 'Yüksek';
    if (s >= 40) return 'Orta';
    return 'Düşük';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cities = state.trackedCities;

    return Scaffold(
      appBar: AppBar(title: const Text('Takip Edilen Şehirler')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCity(context),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Şehir Ekle'),
        backgroundColor: LifeRadarColors.turquoise,
      ),
      body: cities.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_city,
                        size: 56, color: LifeRadarColors.textSecondary),
                    SizedBox(height: 12),
                    Text(
                      'Henüz şehir eklemedin.\nMemleketini veya ailenin şehrini '
                      'ekleyerek oradaki deprem riskini takip et.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: LifeRadarColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              children: [
                const Text(
                  'Eklediğin şehirlerdeki son 30 günün gerçek deprem '
                  'aktivitesine göre afet riski.',
                  style: TextStyle(
                      fontSize: 12, color: LifeRadarColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ...cities.map((c) {
                  final score = c['score'] as int?;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on,
                          color: LifeRadarColors.turquoise),
                      title: Text(c['name'].toString(),
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(score == null
                          ? 'Risk hesaplanıyor...'
                          : 'Deprem riski: ${_scoreLabel(score)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (score != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _scoreColor(score).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$score',
                                style: TextStyle(
                                  color: _scoreColor(score),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          IconButton(
                            tooltip: 'Kaldır',
                            onPressed: () => context
                                .read<AppState>()
                                .removeTrackedCity(c['name'].toString()),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Future<void> _addCity(BuildContext context) async {
    final result = await showModalBottomSheet<CityResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CitySearchSheet(),
    );
    if (result != null && context.mounted) {
      context
          .read<AppState>()
          .addTrackedCity(result.name, result.lat, result.lng);
    }
  }
}

/// Şehir arama alt sayfası (Open-Meteo geocoding).
class _CitySearchSheet extends StatefulWidget {
  const _CitySearchSheet();

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  final _geo = GeocodeService();
  final _controller = TextEditingController();
  List<CityResult> _results = [];
  bool _loading = false;

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    final r = await _geo.search(q);
    if (!mounted) return;
    setState(() {
      _results = r;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Şehir Ara',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: LifeRadarColors.navy)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (v) {
              if (v.trim().length >= 2) _search(v);
            },
            decoration: const InputDecoration(
              hintText: 'Örn: İzmir, Ankara, Bursa...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                  color: LifeRadarColors.turquoise),
            )
          else
            SizedBox(
              height: 280,
              child: ListView(
                children: _results
                    .map((c) => ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: Text(c.name),
                          subtitle: Text(c.label),
                          onTap: () => Navigator.pop(context, c),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
