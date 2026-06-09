/// Türkçe uyumlu metin yardımcıları.

/// "ahMET yılmaz" → "Ahmet Yılmaz" (her kelimenin baş harfi büyük).
/// Türkçe 'i' → 'İ' kuralını gözetir. Boşsa boş döner.
String titleCaseTr(String s) {
  return s
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) {
        final first = w.substring(0, 1);
        final up = first == 'i' ? 'İ' : first.toUpperCase();
        return up + w.substring(1).toLowerCase();
      })
      .join(' ');
}
