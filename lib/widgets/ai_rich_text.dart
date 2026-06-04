import 'package:flutter/material.dart';
import '../core/theme.dart';

/// AI'nın döndürdüğü serbest metni okunaklı biçimde gösterir:
/// **başlık**, "1." numaralı maddeler, "-/•" bulletlar ve **kalın** parçalar.
class AiRichText extends StatelessWidget {
  final String text;
  final Color accent;
  const AiRichText({super.key, required this.text, this.accent = LifeRadarColors.turquoise});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildLines(),
    );
  }

  List<Widget> _buildLines() {
    final out = <Widget>[];
    for (final raw in text.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) {
        out.add(const SizedBox(height: 8));
        continue;
      }

      final header = RegExp(r'^\*\*(.+?)\*\*:?$').firstMatch(line);
      final numbered = RegExp(r'^(\d+)[\.\)]\s+(.*)$').firstMatch(line);
      final bullet = RegExp(r'^[-*•·]\s+(.*)$').firstMatch(line);
      final isShortHeader = line.endsWith(':') && line.length <= 42;

      if (header != null) {
        out.add(_header(header.group(1)!));
      } else if (isShortHeader) {
        out.add(_header(line.substring(0, line.length - 1)));
      } else if (numbered != null) {
        out.add(_numbered(numbered.group(1)!, numbered.group(2)!));
      } else if (bullet != null) {
        out.add(_bullet(bullet.group(1)!));
      } else {
        out.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: LifeRadarColors.textPrimary, fontSize: 15, height: 1.45),
              children: _spans(line),
            ),
          ),
        ));
      }
    }
    return out;
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 4, height: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: LifeRadarColors.navy),
              ),
            ),
          ],
        ),
      );

  Widget _numbered(String n, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(n,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: LifeRadarColors.textPrimary,
                      fontSize: 15,
                      height: 1.4),
                  children: _spans(body),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _bullet(String body) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Icon(Icons.check_circle, size: 16, color: accent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: LifeRadarColors.textPrimary,
                      fontSize: 15,
                      height: 1.4),
                  children: _spans(body),
                ),
              ),
            ),
          ],
        ),
      );

  /// **kalın** parçaları ayrıştırır.
  List<InlineSpan> _spans(String line) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*');
    var idx = 0;
    for (final m in re.allMatches(line)) {
      if (m.start > idx) {
        spans.add(TextSpan(text: line.substring(idx, m.start)));
      }
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
