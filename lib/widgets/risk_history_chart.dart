import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Kişisel risk puanı geçmişini çizen basit çizgi grafik (0-100).
class RiskHistoryChart extends StatelessWidget {
  final List<int> data;
  const RiskHistoryChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: _ChartPainter(data),
        size: Size.infinite,
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<int> data;
  _ChartPainter(this.data);

  Color _color(int v) {
    if (v >= 70) return LifeRadarColors.riskHigh;
    if (v >= 40) return LifeRadarColors.riskMedium;
    return LifeRadarColors.riskLow;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 28.0, padB = 18.0, padT = 8.0, padR = 8.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;

    final grid = Paint()
      ..color = LifeRadarColors.cardBackground
      ..strokeWidth = 1;
    final textStyle = const TextStyle(
        color: LifeRadarColors.textSecondary, fontSize: 10);

    // Izgara çizgileri (0, 50, 100)
    for (final lvl in [0, 50, 100]) {
      final y = padT + h - (lvl / 100.0) * h;
      canvas.drawLine(Offset(padL, y), Offset(padL + w, y), grid);
      final tp = TextPainter(
        text: TextSpan(text: '$lvl', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, y - 6));
    }

    if (data.isEmpty) return;

    Offset pointFor(int i) {
      final x = data.length == 1
          ? padL + w / 2
          : padL + (i / (data.length - 1)) * w;
      final y = padT + h - (data[i].clamp(0, 100) / 100.0) * h;
      return Offset(x, y);
    }

    // Çizgi
    final line = Paint()
      ..color = LifeRadarColors.turquoise
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final p = pointFor(i);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, line);

    // Noktalar
    for (var i = 0; i < data.length; i++) {
      final p = pointFor(i);
      canvas.drawCircle(p, 4, Paint()..color = _color(data[i]));
      canvas.drawCircle(p, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.data != data;
}
