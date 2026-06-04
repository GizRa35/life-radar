/// VIP Aile Koruma Merkezi — bir aile üyesi (detaylı).
class FamilyMember {
  final String id;
  final String name;
  final String relation; // Eş, Çocuk, Anne, Baba...
  final String age;
  final String gender;
  final String health; // kronik hastalık / sürekli ilaç
  final String allergies; // alerjiler
  final String special; // özel durum: hamilelik, engellilik, vb.
  final String notes; // ek not

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    this.age = '',
    this.gender = '',
    this.health = '',
    this.allergies = '',
    this.special = '',
    this.notes = '',
  });

  /// AI promptu için özet satır.
  String get summaryLine {
    final parts = <String>['$relation: $name'];
    if (age.isNotEmpty) parts.add('$age yaş');
    if (gender.isNotEmpty) parts.add(gender);
    if (health.isNotEmpty) parts.add('sağlık: $health');
    if (allergies.isNotEmpty) parts.add('alerji: $allergies');
    if (special.isNotEmpty) parts.add('özel durum: $special');
    if (notes.isNotEmpty) parts.add('not: $notes');
    return parts.join(', ');
  }
}
