import '../core/theme.dart';

/// Sağlık Radarı (Sayfa 6) bölümleri.
enum HealthSection { newDiseases, outbreaks, whoAlerts, cdcAlerts, vaccineNews }

extension HealthSectionMeta on HealthSection {
  String get label {
    switch (this) {
      case HealthSection.newDiseases:
        return 'Yeni Hastalıklar';
      case HealthSection.outbreaks:
        return 'Salgınlar';
      case HealthSection.whoAlerts:
        return 'WHO Uyarıları';
      case HealthSection.cdcAlerts:
        return 'CDC Uyarıları';
      case HealthSection.vaccineNews:
        return 'Aşı Haberleri';
    }
  }
}

/// Bir sağlık uyarısı kartı.
class HealthAlert {
  final String title;
  final HealthSection section;
  final String symptoms; // Belirtiler
  final String riskGroup; // Risk Grubu
  final String prevention; // Korunma Yolları
  final String sources; // Kaynaklar
  final RiskLevel risk;

  const HealthAlert({
    required this.title,
    required this.section,
    required this.symptoms,
    required this.riskGroup,
    required this.prevention,
    required this.sources,
    required this.risk,
  });
}
