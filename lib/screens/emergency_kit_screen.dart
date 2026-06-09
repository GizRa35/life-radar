import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';

/// İnteraktif acil durum çantası listesi — maddeleri işaretle, hazırlık yüzdeni gör.
class EmergencyKitScreen extends StatelessWidget {
  const EmergencyKitScreen({super.key});

  /// AFAD önerilerine dayalı standart acil çanta içeriği.
  static const Map<String, List<String>> _sections = {
    'Su ve Gıda': [
      'Kişi başı en az 4 litre su',
      'Konserve / kuru gıda (3 günlük)',
      'Bebek maması / özel beslenme (gerekiyorsa)',
      'Konserve açacağı',
    ],
    'Sağlık': [
      'İlk yardım çantası',
      'Düzenli kullanılan reçeteli ilaçlar',
      'Maske ve dezenfektan',
      'Hijyen malzemeleri',
    ],
    'Aydınlatma & İletişim': [
      'El feneri + yedek pil',
      'Powerbank (dolu)',
      'Pilli/şarjlı radyo',
      'Düdük (yardım çağırmak için)',
    ],
    'Belgeler & Para': [
      'Kimlik, pasaport kopyaları',
      'Tapu/sigorta belgeleri kopyası',
      'Bir miktar nakit para',
      'Önemli telefon numaraları (yazılı)',
    ],
    'Diğer': [
      'Battaniye / termal örtü',
      'Yedek kıyafet ve yağmurluk',
      'Çok amaçlı çakı',
      'Kibrit / çakmak (su geçirmez)',
    ],
  };

  int get _total =>
      _sections.values.fold(0, (sum, list) => sum + list.length);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final done = state.kitCheckedCount.clamp(0, _total);
    final pct = _total == 0 ? 0.0 : done / _total;

    return Scaffold(
      appBar: AppBar(title: const Text('Acil Durum Çantası')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Hazırlık yüzdesi kartı
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LifeRadarColors.navy, Color(0xFF123A63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.backpack, color: LifeRadarColors.turquoise),
                    const SizedBox(width: 8),
                    Text(
                      'Hazırlık: %${(pct * 100).round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text('$done / $_total',
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(
                        LifeRadarColors.turquoise),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pct >= 1.0
                      ? 'Tebrikler! Çantan tam hazır. 🎒'
                      : 'Maddeleri tamamladıkça hazırlık oranın artar.',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final entry in _sections.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LifeRadarColors.navy,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final item in entry.value)
                    _KitTile(item: item, checked: state.isKitChecked(item)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KitTile extends StatelessWidget {
  final String item;
  final bool checked;
  const _KitTile({required this.item, required this.checked});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: checked,
      onChanged: (_) {
        HapticFeedback.selectionClick();
        context.read<AppState>().toggleKit(item);
      },
      activeColor: LifeRadarColors.turquoise,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        item,
        style: TextStyle(
          decoration: checked ? TextDecoration.lineThrough : null,
          color: checked
              ? LifeRadarColors.textSecondary
              : LifeRadarColors.textPrimary,
        ),
      ),
    );
  }
}
