import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Bildirimler (Sayfa 10) kategorileri.
enum NotificationCategory { health, economy, disaster, world, system }

extension NotificationCategoryMeta on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.health:
        return 'Sağlık';
      case NotificationCategory.economy:
        return 'Ekonomi';
      case NotificationCategory.disaster:
        return 'Afet';
      case NotificationCategory.world:
        return 'Dünya';
      case NotificationCategory.system:
        return 'Sistem';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.health:
        return Icons.health_and_safety_outlined;
      case NotificationCategory.economy:
        return Icons.trending_up;
      case NotificationCategory.disaster:
        return Icons.warning_amber_rounded;
      case NotificationCategory.world:
        return Icons.public;
      case NotificationCategory.system:
        return Icons.settings_outlined;
    }
  }
}

class AppNotification {
  final String title;
  final String summary;
  final DateTime time;
  final NotificationCategory category;
  final RiskLevel risk;

  const AppNotification({
    required this.title,
    required this.summary,
    required this.time,
    required this.category,
    required this.risk,
  });
}
