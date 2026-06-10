import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Resmi Google "G" logosu (4 renkli) — CustomPaint ile çizilir.
/// Asset/ağ gerektirmez; "Google ile devam et" butonunda kullanılır.
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static double _r(double deg) => deg * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final stroke = w * 0.24;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      w - stroke,
      w - stroke,
    );
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // 0° = doğu (sağ), pozitif yön saat yönü (canvas y aşağı).
    // Kırmızı (üst), Mavi (sağ), Yeşil (alt), Sarı (sol).
    p.color = const Color(0xFFEA4335); // kırmızı — üst
    canvas.drawArc(rect, _r(234), _r(72), false, p);
    p.color = const Color(0xFF4285F4); // mavi — sağ
    canvas.drawArc(rect, _r(-54), _r(108), false, p);
    p.color = const Color(0xFF34A853); // yeşil — alt
    canvas.drawArc(rect, _r(54), _r(72), false, p);
    p.color = const Color(0xFFFBBC05); // sarı — sol
    canvas.drawArc(rect, _r(126), _r(108), false, p);

    // Mavi yatay çubuk (G'nin orta çizgisi) — merkezden sağ kenara.
    final barH = stroke;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.5, (w - barH) / 2, w * 0.5 - stroke / 2, barH),
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
