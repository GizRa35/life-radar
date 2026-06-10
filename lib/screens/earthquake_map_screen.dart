import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/theme.dart';
import '../services/feed/earthquake_source.dart';
import '../state/app_state.dart';

/// Yakındaki depremler haritası (OpenStreetMap, anahtarsız).
class EarthquakeMapScreen extends StatefulWidget {
  const EarthquakeMapScreen({super.key});

  @override
  State<EarthquakeMapScreen> createState() => _EarthquakeMapScreenState();
}

class _EarthquakeMapScreenState extends State<EarthquakeMapScreen> {
  final _eq = EarthquakeSource();
  List<Map<String, dynamic>> _quakes = [];
  bool _loading = true;
  late final LatLng _center;

  @override
  void initState() {
    super.initState();
    final loc = context.read<AppState>().location;
    _center = (loc?.lat != null && loc?.lng != null)
        ? LatLng(loc!.lat!, loc.lng!)
        : const LatLng(39.0, 35.0); // Türkiye merkezi
    _load();
  }

  Future<void> _load() async {
    final q = await _eq.nearbyQuakes(_center.latitude, _center.longitude);
    if (!mounted) return;
    setState(() {
      _quakes = q;
      _loading = false;
    });
  }

  Color _magColor(double m) {
    if (m >= 5) return LifeRadarColors.riskHigh;
    if (m >= 4) return LifeRadarColors.riskMedium;
    return LifeRadarColors.riskLow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('Yakındaki Depremler'))),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 6,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.liferadar.lifeRadar',
              ),
              MarkerLayer(
                markers: [
                  for (final q in _quakes)
                    Marker(
                      point: LatLng(
                          (q['lat'] as num).toDouble(), (q['lng'] as num).toDouble()),
                      width: 36,
                      height: 36,
                      child: _QuakeDot(
                        mag: (q['mag'] as num).toDouble(),
                        color: _magColor((q['mag'] as num).toDouble()),
                        onTap: () => _showQuake(q),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                  color: LifeRadarColors.turquoise),
            ),
          // Bilgi şeridi
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15), blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: LifeRadarColors.turquoise),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _loading
                          ? t('Depremler yükleniyor...')
                          : '${t('Son 30 günde çevredeki')} ${_quakes.length} ${t('deprem (USGS). Bir işarete dokunarak detayını gör.')}',
                      style: const TextStyle(
                          fontSize: 12, color: LifeRadarColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuake(Map<String, dynamic> q) {
    final mag = (q['mag'] as num).toDouble();
    final place = q['place']?.toString() ?? t('Bilinmeyen konum');
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _magColor(mag).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'M${mag.toStringAsFixed(1)}',
                    style: TextStyle(
                        color: _magColor(mag),
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(place,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: LifeRadarColors.navy)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _QuakeDot extends StatelessWidget {
  final double mag;
  final Color color;
  final VoidCallback onTap;
  const _QuakeDot(
      {required this.mag, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Büyüklüğe göre boyut (3.0 → ~16px, 6.0 → ~34px).
    final size = (10 + mag * 4).clamp(14.0, 36.0);
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.55),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
      ),
    );
  }
}
