import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
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

  static const Map<String, IconData> _sectionIcons = {
    'Su ve Gıda': Icons.restaurant,
    'Sağlık': Icons.medical_services_outlined,
    'Aydınlatma & İletişim': Icons.flashlight_on_outlined,
    'Belgeler & Para': Icons.folder_shared_outlined,
    'Diğer': Icons.inventory_2_outlined,
  };

  int get _total =>
      _sections.values.fold(0, (sum, list) => sum + list.length);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final done = state.kitCheckedCount.clamp(0, _total);
    final pct = _total == 0 ? 0.0 : done / _total;

    return Scaffold(
      appBar: AppBar(title: Text(t('Acil Durum Çantası'))),
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
                      '${t('Hazırlık:')} %${(pct * 100).round()}',
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
                      ? t('Tebrikler! Çantan tam hazır. 🎒')
                      : t('Maddeleri tamamladıkça hazırlık oranın artar.'),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final entry in _sections.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: LifeRadarColors.turquoise.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(_sectionIcons[entry.key] ?? Icons.check,
                        size: 18, color: LifeRadarColors.turquoise),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    t(entry.key),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: LifeRadarColors.navy,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var k = 0; k < entry.value.length; k++) ...[
                    _KitTile(
                        item: entry.value[k],
                        checked: state.isKitChecked(entry.value[k])),
                    if (k < entry.value.length - 1)
                      const Divider(height: 1, indent: 56, endIndent: 12),
                  ],
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
        t(item),
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
