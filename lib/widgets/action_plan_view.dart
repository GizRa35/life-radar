import 'package:flutter/material.dart';
import '../core/i18n.dart';
import '../core/theme.dart';

/// "Bana Özel Aksiyon Planı" çıktısını başlıklı kartlar + bütçe kutusu olarak
/// gösterir. AI metnini bölümlere ayırır:
///   **Başlık**  → kart başlığı
///   - madde     → kartın içinde işaretli madde
///   **Tahmini Bütçe:** ₺X – ₺Y → en altta vurgulu bütçe kutusu
class ActionPlanView extends StatelessWidget {
  final String text;
  final Color accent;
  const ActionPlanView(
      {super.key, required this.text, this.accent = const Color(0xFFC9A227)});

  @override
  Widget build(BuildContext context) {
    final sections = <_Section>[];
    String? budgetLine;
    _Section? current;

    final headerRe = RegExp(r'^\*\*(.+?)\*\*:?\s*(.*)$');
    final bulletRe = RegExp(r'^[-*•·]\s+(.*)$');

    for (final raw in text.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      // Bütçe satırı (başlık biçiminde de gelse) ayrı tutulur.
      if (RegExp(r'bütçe', caseSensitive: false).hasMatch(line) &&
          line.contains('₺')) {
        budgetLine = line.replaceAll('*', '').trim();
        continue;
      }

      final h = headerRe.firstMatch(line);
      final b = bulletRe.firstMatch(line);
      final shortHeader = h == null && line.endsWith(':') && line.length <= 42;

      if (h != null || shortHeader) {
        final title = h != null
            ? h.group(1)!.trim()
            : line.substring(0, line.length - 1).trim();
        current = _Section(title);
        sections.add(current);
        // Başlık aynı satırda devam metni içeriyorsa madde olarak ekle.
        final rest = h?.group(2)?.trim() ?? '';
        if (rest.isNotEmpty) current.items.add(rest);
      } else if (b != null) {
        (current ??= _ensure(sections)).items.add(b.group(1)!.trim());
      } else {
        (current ??= _ensure(sections)).items.add(line);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in sections) _card(s),
        if (budgetLine != null) _budgetBox(budgetLine),
      ],
    );
  }

  _Section _ensure(List<_Section> sections) {
    if (sections.isEmpty) sections.add(_Section(t('Öneriler')));
    return sections.last;
  }

  Widget _card(_Section s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              s.title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color.lerp(accent, Colors.black, 0.45),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in s.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child:
                              Icon(Icons.check_circle, size: 16, color: accent),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  color: LifeRadarColors.textPrimary,
                                  fontSize: 14.5,
                                  height: 1.4),
                              children: _spans(item),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _budgetBox(String budget) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, Color.lerp(accent, Colors.black, 0.3)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              budget,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **kalın** parçaları ayrıştırır.
  List<InlineSpan> _spans(String line) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*');
    var idx = 0;
    for (final m in re.allMatches(line)) {
      if (m.start > idx) spans.add(TextSpan(text: line.substring(idx, m.start)));
      spans.add(TextSpan(
        text: m.group(1),
        style: const TextStyle(
            fontWeight: FontWeight.w800, color: LifeRadarColors.navy),
      ));
      idx = m.end;
    }
    if (idx < line.length) spans.add(TextSpan(text: line.substring(idx)));
    return spans;
  }
}

class _Section {
  final String title;
  final List<String> items = [];
  _Section(this.title);
}
