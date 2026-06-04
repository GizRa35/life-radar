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

  /// İsteğe bağlı haber görseli (GDELT socialimage).
  final String? imageUrl;

  /// AI etki analizi (Olay Detayı'nda gösterilir).
  final ImpactAnalysis? analysis;

  /// Kaynağın orijinal dili ('tr' veya 'en'). Çeviri kararı için kullanılır.
  final String sourceLang;

  const RadarEvent({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.source,
    required this.publishedAt,
    required this.risk,
    this.url,
    this.imageUrl,
    this.analysis,
    this.sourceLang = 'tr',
  });

  RadarEvent copyWith({
    String? title,
    String? summary,
    ImpactAnalysis? analysis,
    String? sourceLang,
  }) {
    return RadarEvent(
      id: id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      category: category,
      source: source,
      publishedAt: publishedAt,
      risk: risk,
      url: url,
      imageUrl: imageUrl,
      analysis: analysis ?? this.analysis,
      sourceLang: sourceLang ?? this.sourceLang,
    );
  }
}
