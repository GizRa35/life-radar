/// Kriz Radarı (Sayfa 7) bölümleri.
enum CrisisSection {
  economic,
  energy,
  food,
  water,
  geopolitical,
  cyber,
}

extension CrisisSectionMeta on CrisisSection {
  String get label {
    switch (this) {
      case CrisisSection.economic:
        return 'Ekonomik Riskler';
      case CrisisSection.energy:
        return 'Enerji Krizleri';
      case CrisisSection.food:
        return 'Gıda Krizleri';
      case CrisisSection.water:
        return 'Su Krizleri';
      case CrisisSection.geopolitical:
        return 'Jeopolitik Riskler';
      case CrisisSection.cyber:
        return 'Siber Güvenlik Riskleri';
    }
  }
}

/// Bir kriz kartı: Risk Puanı + Beklenen Etki + Öneriler.
class CrisisItem {
  final String title;
  final CrisisSection section;
  final int score; // 0–100
  final String expectedImpact;
  final List<String> recommendations;

  const CrisisItem({
    required this.title,
    required this.section,
    required this.score,
    required this.expectedImpact,
    required this.recommendations,
  });
}
