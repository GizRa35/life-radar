import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../services/contacts_service.dart';
import '../state/app_state.dart';

/// Hızlı acil arama — resmi acil hatlar + kişisel acil durum kişisi.
class EmergencyCallScreen extends StatelessWidget {
  const EmergencyCallScreen({super.key});

  // Türkiye'de tüm acil hizmetler (sağlık, itfaiye, polis, jandarma, afet)
  // 2021'den beri TEK numarada birleşti: 112 Acil Çağrı Merkezi.

  Future<void> _call(BuildContext context, String number) async {
    HapticFeedback.mediumImpact();
    final uri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arama başlatılamadı.')),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arama başlatılamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Hızlı Acil Arama')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          const Text(
            'Acil Çağrı Merkezi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: LifeRadarColors.navy,
            ),
          ),
          const SizedBox(height: 10),
          // Tek acil numara: 112
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _call(context, '112'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF453A), Color(0xFFC0392B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF453A).withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.emergency, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('112',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.0)),
                        SizedBox(height: 2),
                        Text('Acil Çağrı — dokun ve ara',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LifeRadarColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: LifeRadarColors.turquoise),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Türkiye\'de sağlık, itfaiye, polis, jandarma ve afet '
                    'çağrıları tek numarada birleşti: 112. (110, 155, 156, 122 '
                    'aramaları da 112\'ye yönlendirilir.)',
                    style: TextStyle(
                        fontSize: 12, color: LifeRadarColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Acil Durum Kişilerim',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LifeRadarColors.navy,
                ),
              ),
              const Spacer(),
              Text(
                '${state.emergencyContacts.length}/2',
                style: const TextStyle(
                    color: LifeRadarColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Mevcut kişiler (en fazla 2)
          ...state.emergencyContacts.asMap().entries.map((e) {
            final c = e.value;
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: LifeRadarColors.turquoise,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  (c['name'] ?? '').isEmpty ? 'Acil kişi' : c['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(c['phone'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Kaldır',
                      onPressed: () =>
                          context.read<AppState>().removeEmergencyContact(e.key),
                      icon: const Icon(Icons.delete_outline),
                    ),
                    FilledButton.icon(
                      onPressed: () => _call(context, c['phone'] ?? ''),
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text('Ara'),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (state.canAddEmergencyContact) ...[
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => _addFromContacts(context),
              icon: const Icon(Icons.contacts_outlined),
              label: const Text('Rehberden Kişi Seç'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            TextButton(
              onPressed: () => _addManually(context),
              child: const Text('veya elle ekle'),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LifeRadarColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: LifeRadarColors.textSecondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gerçek acil durumda önce 112\'yi arayın. Acil kişi bilgisi '
                    'yalnızca cihazınızda saklanır.',
                    style: TextStyle(
                        fontSize: 12, color: LifeRadarColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Rehberden kişi seç (sistem seçicisi açılır).
  Future<void> _addFromContacts(BuildContext context) async {
    final picked = await pickPhoneContact();
    if (!context.mounted) return;
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Kişi seçilmedi veya seçilen kişide telefon numarası yok.')),
      );
      return;
    }
    context.read<AppState>().addEmergencyContact(picked.name, picked.phone);
  }

  /// Elle ekleme (rehber kullanılamazsa).
  void _addManually(BuildContext context) {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Acil Durum Kişisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Ad',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneC,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '05XX XXX XX XX',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<AppState>()
                  .addEmergencyContact(nameC.text, phoneC.text);
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
