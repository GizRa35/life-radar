import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../state/app_state.dart';
import '../widgets/form_widgets.dart';

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
      SnackBar(content: Text(t('Aile planı kaydedildi'))),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('Aile Acil Planı'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FormTipCard(
            icon: Icons.family_restroom,
            text: t('Afet anında ailenizin nerede buluşacağını ve nasıl iletişim kuracağını önceden belirleyin. Bilgiler yalnızca cihazınızda saklanır.'),
          ),
          const SizedBox(height: 18),
          FormFieldLabel(t('Ev yakını buluşma noktası')),
          _field(
            _home,
            Icons.home_outlined,
            t('Örn: Apartman önü / sokak köşesindeki park'),
          ),
          FormFieldLabel(t('Bölge dışı buluşma noktası')),
          _field(
            _area,
            Icons.location_city_outlined,
            t('Örn: Mahalle meydanı / okul bahçesi'),
          ),
          FormFieldLabel(t('İletişim ve toplanma notu')),
          _field(
            _note,
            Icons.notes_outlined,
            t('Örn: Şehir dışındaki ... teyzeyi arayın; herkes oraya haber versin'),
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: Text(t('Planı Kaydet')),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, IconData icon, String hint,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
