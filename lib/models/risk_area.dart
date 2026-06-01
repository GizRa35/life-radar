import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Radar (Sayfa 3) üzerindeki bireysel risk alanları.
enum RiskAreaType { health, economic, disaster, energy, cyber, travel }

extension RiskAreaTypeMeta on RiskAreaType {
  String get label {
    switch (this) {
      case RiskAreaType.health:
        return 'Sağlık Riski';
      case RiskAreaType.economic:
        return 'Ekonomik Risk';
      case RiskAreaType.disaster:
        return 'Afet Riski';
      case RiskAreaType.energy:
        return 'Enerji Riski';
      case RiskAreaType.cyber:
        return 'Siber Risk';
      case RiskAreaType.travel:
        return 'Seyahat Riski';
    }
  }

  IconData get icon {
    switch (this) {
      case RiskAreaType.health:
        return Icons.health_and_safety_outlined;
      case RiskAreaType.economic:
        return Icons.account_balance_outlined;
      case RiskAreaType.disaster:
        return Icons.warning_amber_rounded;
      case RiskAreaType.energy:
        return Icons.bolt_outlined;
      case RiskAreaType.cyber:
        return Icons.security_outlined;
      case RiskAreaType.travel:
        return Icons.flight_takeoff_outlined;
    }
  }
}

/// Bir risk alanının skor + açıklama + beklenen etkisi.
class RiskArea {
  final RiskAreaType type;

  /// 0–100
  final int score;
  final String description;
  final String expectedImpact;

  const RiskArea({
    required this.type,
    required this.score,
    required this.description,
    required this.expectedImpact,
  });

  RiskLevel get level {
    if (score >= 70) return RiskLevel.high;
    if (score >= 40) return RiskLevel.medium;
    return RiskLevel.low;
  }
}
