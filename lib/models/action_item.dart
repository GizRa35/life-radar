/// "Ne Yapmalıyım?" (Sayfa 5) listelerindeki tek bir madde.
class ActionItem {
  final String text;

  /// true → YAPILACAKLAR, false → YAPILMAYACAKLAR
  final bool isDo;

  const ActionItem({required this.text, required this.isDo});
}
