import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/form_widgets.dart';

/// İnteraktif acil durum çantası — maddeleri işaretle, hazırlık yüzdeni gör.
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

  static const Map<String, Color> _sectionColors = {
    'Su ve Gıda': Color(0xFF2E86DE),
    'Sağlık': Color(0xFFE74C3C),
    'Aydınlatma & İletişim': Color(0xFFF5A623),
    'Belgeler & Para': Color(0xFF27AE60),
    'Diğer': Color(0xFF8E44AD),
  };

  int get _total => _sections.values.fold(0, (sum, list) => sum + list.length);

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
          // Gradyan hazırlık başlığı
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LifeRadarColors.navy, LifeRadarColors.turquoise],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: LifeRadarColors.turquoise.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.backpack, color: Colors.white, size: 34),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('Çanta Hazırlık Durumu'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$done / $_total ${t('madde')}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '%${(pct * 100).round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pct >= 1.0
                      ? t('Harika! Çantan tam hazır. 🎒')
                      : t('Eksikleri tamamla, hazırlıklı ol.'),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          for (final entry in _sections.entries) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: entry.key,
              icon: _sectionIcons[entry.key] ?? Icons.check,
              color: _sectionColors[entry.key] ?? LifeRadarColors.turquoise,
              items: entry.value,
              doneCount:
                  entry.value.where((i) => state.isKitChecked(i)).length,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  final int doneCount;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.doneCount,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Renkli bölüm başlığı + bölüm ilerlemesi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: color.withOpacity(0.10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withOpacity(0.18),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t(title),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: color,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$doneCount/${items.length}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var k = 0; k < items.length; k++) ...[
            CheckboxListTile(
              value: state.isKitChecked(items[k]),
              onChanged: (_) {
                HapticFeedback.selectionClick();
                context.read<AppState>().toggleKit(items[k]);
              },
              activeColor: color,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              title: Text(
                t(items[k]),
                style: TextStyle(
                  decoration: state.isKitChecked(items[k])
                      ? TextDecoration.lineThrough
                      : null,
                  color: state.isKitChecked(items[k])
                      ? LifeRadarColors.textSecondary
                      : LifeRadarColors.textPrimary,
                ),
              ),
            ),
            if (k < items.length - 1)
              const Divider(height: 1, indent: 56, endIndent: 12),
          ],
        ],
      ),
    );
  }
}
