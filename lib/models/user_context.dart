/// Kullanıcı bağlamı — tüm AI analizlerinin (VIP, günlük, asistan) girdisi.
class UserContext {
  final String name;
  final String location; // şehir
  final String age;
  final String gender;
  final String profession;
  final String healthNotes; // kronik hastalık / sağlık durumu
  final String financialSensitivity; // finansal hassasiyet
  final String homeType; // ev tipi (apartman/müstakil, kat...)
  final String householdSize; // hanede yaşayan kişi sayısı
  final String familyInfo; // birlikte yaşananlar
  final String language; // tercih edilen dil: 'tr' veya 'en'

  const UserContext({
    this.name = '',
    this.location = 'İstanbul, Türkiye',
    this.age = '',
    this.gender = '',
    this.profession = '',
    this.healthNotes = '',
    this.financialSensitivity = '',
    this.homeType = '',
    this.householdSize = '',
    this.familyInfo = '',
    this.language = 'tr',
  });

  UserContext copyWith({
    String? name,
    String? location,
    String? age,
    String? gender,
    String? profession,
    String? healthNotes,
    String? financialSensitivity,
    String? homeType,
    String? householdSize,
    String? familyInfo,
    String? language,
  }) {
    return UserContext(
      name: name ?? this.name,
      location: location ?? this.location,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      profession: profession ?? this.profession,
      healthNotes: healthNotes ?? this.healthNotes,
      financialSensitivity: financialSensitivity ?? this.financialSensitivity,
      homeType: homeType ?? this.homeType,
      householdSize: householdSize ?? this.householdSize,
      familyInfo: familyInfo ?? this.familyInfo,
      language: language ?? this.language,
    );
  }

  /// Kişisel bilgi girilmiş mi? (analizin kişiselleşmesi için)
  bool get hasInfo =>
      age.isNotEmpty ||
      profession.isNotEmpty ||
      healthNotes.isNotEmpty ||
      financialSensitivity.isNotEmpty ||
      homeType.isNotEmpty ||
      householdSize.isNotEmpty ||
      familyInfo.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'age': age,
        'gender': gender,
        'profession': profession,
        'healthNotes': healthNotes,
        'financialSensitivity': financialSensitivity,
        'homeType': homeType,
        'householdSize': householdSize,
        'familyInfo': familyInfo,
        'language': language,
      };

  factory UserContext.fromJson(Map<String, dynamic> j) => UserContext(
        name: (j['name'] ?? '').toString(),
        location: (j['location'] ?? 'İstanbul, Türkiye').toString(),
        age: (j['age'] ?? '').toString(),
        gender: (j['gender'] ?? '').toString(),
        profession: (j['profession'] ?? '').toString(),
        healthNotes: (j['healthNotes'] ?? '').toString(),
        financialSensitivity: (j['financialSensitivity'] ?? '').toString(),
        homeType: (j['homeType'] ?? '').toString(),
        householdSize: (j['householdSize'] ?? '').toString(),
        familyInfo: (j['familyInfo'] ?? '').toString(),
        language: (j['language'] ?? 'tr').toString(),
      );
}
