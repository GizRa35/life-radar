/// Kullanıcı bağlamı — AI etki analizinin girdisi (Profil ekranı).
class UserContext {
  final String location; // konum (örn. İstanbul)
  final String profession; // meslek
  final String healthNotes; // sağlık durumu
  final String financialSensitivity; // finansal hassasiyet
  final String familyInfo; // aile

  const UserContext({
    this.location = 'İstanbul, Türkiye',
    this.profession = '',
    this.healthNotes = '',
    this.financialSensitivity = '',
    this.familyInfo = '',
  });

  UserContext copyWith({
    String? location,
    String? profession,
    String? healthNotes,
    String? financialSensitivity,
    String? familyInfo,
  }) {
    return UserContext(
      location: location ?? this.location,
      profession: profession ?? this.profession,
      healthNotes: healthNotes ?? this.healthNotes,
      financialSensitivity: financialSensitivity ?? this.financialSensitivity,
      familyInfo: familyInfo ?? this.familyInfo,
    );
  }
}
