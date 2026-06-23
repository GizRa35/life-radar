import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Kişisel risk puanı geçmişi — gradyan dolgulu, profesyonel çizgi grafik.
class RiskHistoryChart extends StatelessWidget {
  final List<int> data;
  const RiskHistoryChart({super.key, required this.data});

  Color _levelColor(int v) {
    if (v >= 67) return LifeRadarColors.riskHigh;
    if (v >= 34) return LifeRadarColors.riskMedium;
    return LifeRadarColors.riskLow;
  }

  String _levelLabel(int v) {
    if (v >= 67) return 'Yüksek';
    if (v >= 34) return 'Orta';
    return 'Düşük';
  }

  @override
  Widget build(BuildContext context) {
    final last = data.isNotEmpty ? data.last : 0;
    final prev = data.length >= 2 ? data[data.length - 2] : last;
    final diff = last - prev;
    final color = _levelColor(last);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Güncel değer + trend
        Row(
          children: [
            Text(
              '$last',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '/100  ·  ${_levelLabel(last)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const Spacer(),
            if (diff != 0)
              Row(
                children: [
                  Icon(
                    diff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: diff > 0
                        ? LifeRadarColors.riskHigh
                        : LifeRadarColors.riskLow,
                  ),
                  Text(
                    '${diff.abs()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: diff > 0
                          ? LifeRadarColors.riskHigh
                          : LifeRadarColors.riskLow,
                    ),
                  ),
                ],
              )
            else
              const Text('Sabit',
                  style: TextStyle(
                      fontSize: 11, color: LifeRadarColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 170,
          child: CustomPaint(
            painter: _ChartPainter(data),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Son ölçümler · sağdaki nokta bugünkü puanın',
          style: TextStyle(fontSize: 10, color: LifeRadarColors.textSecondary),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<int> data;
  _ChartPainter(this.data);

  Color _color(int v) {
    if (v >= 67) return LifeRadarColors.riskHigh;
    if (v >= 34) return LifeRadarColors.riskMedium;
    return LifeRadarColors.riskLow;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 30.0, padB = 16.0, padT = 14.0, padR = 10.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;
    if (w <= 0 || h <= 0) return;

    final gridPaint = Paint()
      ..color = LifeRadarColors.textSecondary.withOpacity(0.12)
      ..strokeWidth = 1;
    const textStyle =
        TextStyle(color: LifeRadarColors.textSecondary, fontSize: 9);

    // Izgara çizgileri + etiketler (0,25,50,75,100)
    for (final lvl in [0, 25, 50, 75, 100]) {
      final y = padT + h - (lvl / 100.0) * h;
      canvas.drawLine(Offset(padL, y), Offset(padL + w, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: '$lvl', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(padL - tp.width - 4, y - 5));
    }

    if (data.isEmpty) return;

    Offset pointFor(int i) {
      final x = data.length == 1
          ? padL + w / 2
          : padL + (i / (data.length - 1)) * w;
      final y = padT + h - (data[i].clamp(0, 100) / 100.0) * h;
      return Offset(x, y);
    }

    // Çizgi yolu
    final linePath = Path();
    for (var i = 0; i < data.length; i++) {
      final p = pointFor(i);
      if (i == 0) {
        linePath.moveTo(p.dx, p.dy);
      } else {
        linePath.lineTo(p.dx, p.dy);
      }
    }

    // Gradyan dolgu (çizginin altı)
    final fillPath = Path.from(linePath)
      ..lineTo(pointFor(data.length - 1).dx, padT + h)
      ..lineTo(pointFor(0).dx, padT + h)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          LifeRadarColors.turquoise.withOpacity(0.32),
          LifeRadarColors.turquoise.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(padL, padT, w, h));
    canvas.drawPath(fillPath, fillPaint);

    // Çizgi
    final line = Paint()
      ..color = LifeRadarColors.turquoise
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, line);

    // Noktalar (son nokta vurgulu)
    for (var i = 0; i < data.length; i++) {
      final p = pointFor(i);
      final isLast = i == data.length - 1;
      final c = _color(data[i]);
      if (isLast) {
        canvas.drawCircle(p, 8, Paint()..color = c.withOpacity(0.25));
        canvas.drawCircle(p, 5, Paint()..color = c);
        canvas.drawCircle(p, 2.5, Paint()..color = Colors.white);
      } else {
        canvas.drawCircle(p, 3.5, Paint()..color = c);
        canvas.drawCircle(p, 1.6, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.data != data;
}
