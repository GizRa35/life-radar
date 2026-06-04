import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_config.dart';
import '../core/media.dart';
import '../core/theme.dart';
import '../services/report_export.dart';
import '../state/app_state.dart';

/// Gizlilik — veri özeti, dışa aktarma, gizlilik kontrolleri, veri temizleme
/// ve gizlilik politikası.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bilgilendirme
          Card(
            color: LifeRadarColors.turquoise.withOpacity(0.08),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.verified_user_outlined,
                      color: LifeRadarColors.turquoise),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verilerin yalnızca bu cihazda (tarayıcı belleğinde) tutulur. '
                      'Hesabımız bunları sunucuda saklamaz.',
                      style: TextStyle(
                          fontSize: 13, color: LifeRadarColors.navy),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 1) Veri özeti + dışa aktarma
          const _SectionLabel('Verilerim', Icons.folder_outlined),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _DataRow(
                      icon: Icons.person_outline,
                      label: 'Kişisel bilgiler',
                      value: state.hasPersonalInfo ? 'Girildi' : 'Boş'),
                  _DataRow(
                      icon: Icons.bookmark_outline,
                      label: 'Kayıtlı haberler',
                      value: '${state.savedCount} adet'),
                  _DataRow(
                      icon: Icons.topic_outlined,
                      label: 'Takip edilen konular',
                      value: '${state.followedCount} adet'),
                  _DataRow(
                      icon: Icons.show_chart,
                      label: 'Risk geçmişi',
                      value: '${state.riskHistoryCount} kayıt'),
                  _DataRow(
                      icon: Icons.account_circle_outlined,
                      label: 'Hesap',
                      value: state.hasSession ? 'Giriş yapıldı' : 'Misafir'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final json =
                    const JsonEncoder.withIndent('  ').convert(state.exportData());
                final ts = DateTime.now()
                    .toIso8601String()
                    .substring(0, 19)
                    .replaceAll(':', '-');
                downloadFile(
                    'life-radar-verilerim-$ts.json', json, 'application/json');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Verilerin JSON olarak indirildi.')),
                );
              },
              icon: const Icon(Icons.download_outlined),
              label: const Text('Verilerimi indir (JSON)'),
            ),
          ),
          const SizedBox(height: 8),

          // 2) Gizlilik kontrolleri
          const _SectionLabel('Gizlilik Kontrolleri', Icons.tune),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: state.locationEnabled,
                  activeColor: LifeRadarColors.turquoise,
                  secondary: const Icon(Icons.location_on_outlined,
                      color: LifeRadarColors.navy),
                  title: const Text('Konum kullanımı',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text(
                      'Bulunduğun şehre göre afet/deprem riski hesaplanır. '
                      'Kapatırsan konum tespiti yapılmaz.'),
                  onChanged: (v) =>
                      context.read<AppState>().setLocationEnabled(v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: state.aiShareContext,
                  activeColor: LifeRadarColors.turquoise,
                  secondary: const Icon(Icons.psychology_outlined,
                      color: LifeRadarColors.navy),
                  title: const Text('Life Radar Asistan analizlerine kişisel veri gönder',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text(
                      'Açıkken yaş, meslek, sağlık gibi bilgiler Life Radar Asistan\'a gönderilip '
                      'analiz sana özel olur. Kapalıyken yalnızca genel analiz yapılır.'),
                  onChanged: (v) =>
                      context.read<AppState>().setAiShareContext(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3) Veri temizleme
          const _SectionLabel('Veri Temizleme', Icons.delete_outline),
          Card(
            child: Column(
              children: [
                _ClearTile(
                  icon: Icons.bookmark_remove_outlined,
                  title: 'Kayıtlı haberleri temizle',
                  enabled: state.savedCount > 0,
                  onConfirm: () => context.read<AppState>().clearSavedEvents(),
                  confirmText:
                      'Tüm kayıtlı haberler silinsin mi? Bu işlem geri alınamaz.',
                ),
                const Divider(height: 1),
                _ClearTile(
                  icon: Icons.timeline_outlined,
                  title: 'Risk geçmişini temizle',
                  enabled: state.riskHistoryCount > 0,
                  onConfirm: () => context.read<AppState>().clearRiskHistory(),
                  confirmText:
                      'Risk puanı geçmişin silinsin mi? Bu işlem geri alınamaz.',
                ),
                const Divider(height: 1),
                _ClearTile(
                  icon: Icons.person_off_outlined,
                  title: 'Kişisel bilgileri temizle',
                  enabled: state.hasPersonalInfo,
                  onConfirm: () => context.read<AppState>().clearPersonalInfo(),
                  confirmText:
                      'Yaş, meslek, sağlık vb. kişisel bilgilerin silinsin mi?',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: LifeRadarColors.riskHigh.withOpacity(0.06),
            child: _ClearTile(
              icon: Icons.warning_amber_rounded,
              iconColor: LifeRadarColors.riskHigh,
              title: 'Tüm verileri sıfırla (fabrika ayarı)',
              titleColor: LifeRadarColors.riskHigh,
              enabled: true,
              onConfirm: () {
                context.read<AppState>().clearAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Tüm veriler silindi. Çıkış yapıldı.')),
                );
              },
              confirmText:
                  'TÜM verilerin (kişisel bilgiler, kayıtlar, ayarlar) silinecek '
                  've çıkış yapılacak. Bu işlem geri alınamaz. Devam edilsin mi?',
            ),
          ),
          const SizedBox(height: 8),

          // 4) Gizlilik politikası
          const _SectionLabel('Gizlilik Politikası', Icons.policy_outlined),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Life Radar, gizliliğine önem verir.\n\n'
                '• Saklanan veriler: Girdiğin kişisel bilgiler, kayıtlı haberler, '
                'takip ettiğin konular, risk geçmişin ve uygulama ayarların yalnızca '
                'bu cihazın tarayıcı belleğinde (localStorage) tutulur.\n\n'
                '• Hesap: E-posta ile kayıt/giriş Firebase Authentication üzerinden '
                'yapılır; yalnızca e-posta ve oturum anahtarı işlenir.\n\n'
                '• Konum: Açıkken yaklaşık konumun IP üzerinden belirlenir ve afet '
                'riski hesabında kullanılır. İstediğin zaman kapatabilirsin.\n\n'
                '• Life Radar Asistan: Analizler için başlıklar ve (izin verdiysen) '
                'kişisel bağlamın bir hizmet sağlayıcıya (Groq) gönderilir. '
                'Bu paylaşımı "Life Radar Asistan analizlerine kişisel veri gönder" anahtarından kapatabilirsin.\n\n'
                '• Haberler: Haber içerikleri kaynak sitelerden ve çeviri servisinden '
                'alınır; bu isteklerde kişisel bilgin gönderilmez.\n\n'
                '• Hakların: Verilerini istediğin an dışa aktarabilir (JSON) veya '
                'tamamen silebilirsin. Uygulamayı sildiğinde veya tarayıcı verisini '
                'temizlediğinde tüm yerel veriler kaybolur.',
                style: TextStyle(
                    fontSize: 13, height: 1.5, color: LifeRadarColors.navy),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  Media.openUrl('${ApiConfig.base}/privacy.html'),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text(
                  'Tam yasal metin: Gizlilik · Kullanım Şartları · Sorumluluk Reddi'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DataRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: LifeRadarColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: LifeRadarColors.navy)),
          ),
          Text(value,
              style: const TextStyle(color: LifeRadarColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ClearTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Color? titleColor;
  final bool enabled;
  final VoidCallback onConfirm;
  final String confirmText;
  const _ClearTile({
    required this.icon,
    required this.title,
    required this.enabled,
    required this.onConfirm,
    required this.confirmText,
    this.iconColor,
    this.titleColor,
  });

  Future<void> _ask(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Emin misin?'),
        content: Text(confirmText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: LifeRadarColors.riskHigh),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok == true) onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final color = titleColor ?? LifeRadarColors.navy;
    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: iconColor ?? LifeRadarColors.textSecondary),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: enabled ? () => _ask(context) : null,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SectionLabel(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: LifeRadarColors.navy),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LifeRadarColors.navy)),
        ],
      ),
    );
  }
}
