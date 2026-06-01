import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Gündem (Sayfa 2) kategori sekmeleri.
enum EventCategory {
  world,
  turkey,
  health,
  economy,
  technology,
  energy,
  security,
  climate,
  disaster,
}

extension EventCategoryMeta on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.world:
        return 'Dünya';
      case EventCategory.turkey:
        return 'Türkiye';
      case EventCategory.health:
        return 'Sağlık';
      case EventCategory.economy:
        return 'Ekonomi';
      case EventCategory.technology:
        return 'Teknoloji';
      case EventCategory.energy:
        return 'Enerji';
      case EventCategory.security:
        return 'Güvenlik';
      case EventCategory.climate:
        return 'İklim';
      case EventCategory.disaster:
        return 'Afetler';
    }
  }

  IconData get icon {
    switch (this) {
      case EventCategory.world:
        return Icons.public;
      case EventCategory.turkey:
        return Icons.flag_outlined;
      case EventCategory.health:
        return Icons.health_and_safety_outlined;
      case EventCategory.economy:
        return Icons.trending_up;
      case EventCategory.technology:
        return Icons.memory;
      case EventCategory.energy:
        return Icons.bolt_outlined;
      case EventCategory.security:
        return Icons.shield_outlined;
      case EventCategory.climate:
        return Icons.thermostat_outlined;
      case EventCategory.disaster:
        return Icons.warning_amber_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.world:
        return LifeRadarColors.navy;
      case EventCategory.turkey:
        return const Color(0xFFC62828);
      case EventCategory.health:
        return LifeRadarColors.riskLow;
      case EventCategory.economy:
        return LifeRadarColors.turquoise;
      case EventCategory.technology:
        return const Color(0xFF5E35B1);
      case EventCategory.energy:
        return LifeRadarColors.riskMedium;
      case EventCategory.security:
        return const Color(0xFF455A64);
      case EventCategory.climate:
        return const Color(0xFF00897B);
      case EventCategory.disaster:
        return LifeRadarColors.riskHigh;
    }
  }
}
