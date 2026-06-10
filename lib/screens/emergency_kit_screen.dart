import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/form_widgets.dart';

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
          // Hazırlık durumu kartı (açık tema + dairesel halka)
          CircularStatusCard(
            icon: Icons.backpack,
            title: t('Çanta Hazırlık Durumu'),
            subtitle: '%${(pct * 100).round()} ${t('Tamamlandı')}',
            percent: pct,
          ),
          for (final entry in _sections.entries) ...[
            FormSectionHeader(
              icon: _sectionIcons[entry.key] ?? Icons.check,
              title: t(entry.key),
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
          const SizedBox(height: 18),
          FormTipCard(
            title: t('Önemli İpucu'),
            text: t(
                'Çantanızdaki gıdaların son kullanma tarihlerini her 6 ayda bir kontrol etmeyi unutmayın.'),
          ),
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
