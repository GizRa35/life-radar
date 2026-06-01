import '../core/theme.dart';
import 'action_item.dart';

/// "Bu Beni Etkiler mi?" (Sayfa 4) + "Ne Yapmalıyım?" (Sayfa 5) analizi.
class ImpactAnalysis {
  /// Etkilenme olasılığı 0–100
  final int probability;

  /// Kimler etkilenebilir
  final String affectedGroups;

  /// Türkiye etkisi
  final String turkeyImpact;

  /// Kişisel etkiler
  final String personalImpact;

  /// Etki süresi (örn. "2-4 hafta")
  final String duration;

  final RiskLevel risk;

  /// YAPILACAKLAR / YAPILMAYACAKLAR
  final List<ActionItem> actions;

  const ImpactAnalysis({
    required this.probability,
    required this.affectedGroups,
    required this.turkeyImpact,
    required this.personalImpact,
    required this.duration,
    required this.risk,
    required this.actions,
  });

  List<ActionItem> get dos => actions.where((a) => a.isDo).toList();
  List<ActionItem> get donts => actions.where((a) => !a.isDo).toList();
}
