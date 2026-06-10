import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';

/// Aile acil durum planı — buluşma noktaları ve iletişim notu.
class FamilyPlanScreen extends StatefulWidget {
  const FamilyPlanScreen({super.key});

  @override
  State<FamilyPlanScreen> createState() => _FamilyPlanScreenState();
}

class _FamilyPlanScreenState extends State<FamilyPlanScreen> {
  late final TextEditingController _home;
  late final TextEditingController _area;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _home = TextEditingController(text: s.planHome);
    _area = TextEditingController(text: s.planArea);
    _note = TextEditingController(text: s.planNote);
  }

  @override
  void dispose() {
    _home.dispose();
    _area.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    context
        .read<AppState>()
        .setFamilyPlan(_home.text, _area.text, _note.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aile planı kaydedildi')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aile Acil Planı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LifeRadarColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.family_restroom, color: LifeRadarColors.turquoise),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Afet anında ailenizin nerede buluşacağını ve nasıl '
                    'iletişim kuracağını önceden belirleyin. Bilgiler yalnızca '
                    'cihazınızda saklanır.',
                    style: TextStyle(
                        fontSize: 12, color: LifeRadarColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _field(
            _home,
            'Ev yakını buluşma noktası',
            Icons.home_outlined,
            'Örn: Apartman önü / sokak köşesindeki park',
          ),
          _field(
            _area,
            'Bölge dışı buluşma noktası',
            Icons.location_city_outlined,
            'Örn: Mahalle meydanı / okul bahçesi',
          ),
          _field(
            _note,
            'İletişim ve toplanma notu',
            Icons.notes_outlined,
            'Örn: Şehir dışındaki ... teyzeyi arayın; herkes oraya haber versin',
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Planı Kaydet'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      String hint,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
