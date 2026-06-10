import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/text_utils.dart';
import '../core/theme.dart';
import '../models/user_context.dart';
import '../state/app_state.dart';

/// Kişisel Bilgiler — AI analizlerini kişiselleştirmek için kullanılır.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _profession;
  late final TextEditingController _location;
  late final TextEditingController _health;
  late final TextEditingController _household;
  late final TextEditingController _family;
  String _gender = '';
  String _financial = '';
  String _homeType = '';
  String _language = 'tr';

  @override
  void initState() {
    super.initState();
    final c = context.read<AppState>().userContext;
    _name = TextEditingController(text: titleCaseTr(c.name));
    _age = TextEditingController(text: c.age);
    _profession = TextEditingController(text: c.profession);
    _location = TextEditingController(text: c.location);
    _health = TextEditingController(text: c.healthNotes);
    _household = TextEditingController(text: c.householdSize);
    _family = TextEditingController(text: c.familyInfo);
    _gender = c.gender;
    _financial = c.financialSensitivity;
    _homeType = c.homeType;
    _language = c.language;
  }

  @override
  void dispose() {
    for (final ctrl in [
      _name, _age, _profession, _location, _health, _household, _family
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _save() {
    final ctx = UserContext(
      name: titleCaseTr(_name.text),
      age: _age.text.trim(),
      gender: _gender,
      profession: _profession.text.trim(),
      location: _location.text.trim().isEmpty
          ? 'İstanbul, Türkiye'
          : _location.text.trim(),
      healthNotes: _health.text.trim(),
      financialSensitivity: _financial,
      homeType: _homeType,
      householdSize: _household.text.trim(),
      familyInfo: _family.text.trim(),
      language: _language,
    );
    context.read<AppState>().updateUserContext(ctx);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('Kişisel bilgiler kaydedildi'))),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('Kişisel Bilgiler'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LifeRadarColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: LifeRadarColors.turquoise),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t('Bu bilgiler yalnızca cihazında tutulur ve Life Radar Asistan analizlerini sana özel hale getirmek için kullanılır.'),
                    style: const TextStyle(
                        fontSize: 12, color: LifeRadarColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _field(_name, t('Ad (opsiyonel)'), Icons.person_outline),
          _field(_age, t('Yaş'), Icons.cake_outlined,
              keyboard: TextInputType.number),
          _dropdown(
            t('Cinsiyet'),
            Icons.wc_outlined,
            _gender,
            const ['Kadın', 'Erkek', 'Belirtmek istemiyorum'],
            (v) => setState(() => _gender = v),
          ),
          _field(_profession, t('Meslek'), Icons.work_outline),
          _field(_location, t('Şehir'), Icons.location_city_outlined),
          _field(_household, t('Hanede yaşayan kişi sayısı'),
              Icons.groups_outlined, keyboard: TextInputType.number),
          _field(_health, t('Sağlık durumu / kronik hastalık'),
              Icons.favorite_border, maxLines: 2),
          _dropdown(
            t('Finansal hassasiyet'),
            Icons.account_balance_wallet_outlined,
            _financial,
            const ['Düşük', 'Orta', 'Yüksek'],
            (v) => setState(() => _financial = v),
          ),
          _dropdown(
            t('Ev tipi'),
            Icons.home_outlined,
            _homeType,
            const ['Apartman', 'Müstakil', 'Site', 'Diğer'],
            (v) => setState(() => _homeType = v),
          ),
          _field(_family, t('Birlikte yaşadıkların (eş, çocuk...)'),
              Icons.family_restroom, maxLines: 2),
          // Haber dili: yabancı kaynaklı haberler bu dile çevrilir.
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              value: _language,
              decoration: InputDecoration(
                labelText: t('Haber Dili'),
                prefixIcon: const Icon(Icons.translate_outlined),
                helperText: 'Yabancı kaynaklı haberler bu dile çevrilir',
              ),
              items: const [
                DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) => setState(() => _language = v ?? 'tr'),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: Text(t('Kaydet')),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboard, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _dropdown(String label, IconData icon, String value,
      List<String> options, void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(t(o))))
            .toList(),
        onChanged: (v) => onChanged(v ?? ''),
      ),
    );
  }
}
