import '../core/theme.dart';
import 'event_category.dart';
import 'impact_analysis.dart';

/// Tek bir haber / olay (Gündem ve Ana Sayfa kartları).
class RadarEvent {
  final String id;
  final String title;
  final String summary;
  final EventCategory category;
  final String source;
  final DateTime publishedAt;
  final RiskLevel risk;

  /// İsteğe bağlı kaynak linki.
  final String? url;

  /// AI etki analizi (Olay Detayı'nda gösterilir).
  final ImpactAnalysis? analysis;

  const RadarEvent({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.source,
    required this.publishedAt,
    required this.risk,
    this.url,
    this.analysis,
  });
}
