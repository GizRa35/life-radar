import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// 0–100 risk puanını dairesel gösterge olarak çizer (Radar kişisel risk puanı).
class RiskGauge extends StatelessWidget {
  final int score;
  final double size;
  final String? label;

  const RiskGauge({
    super.key,
    required this.score,
    this.size = 180,
    this.label,
  });

  Color get _color {
    if (score >= 70) return LifeRadarColors.riskHigh;
    if (score >= 40) return LifeRadarColors.riskMedium;
    return LifeRadarColors.riskLow;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(score: score, color: _color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w800,
                  color: LifeRadarColors.navy,
                ),
              ),
              Text(
                label ?? '/ 100',
                style: const TextStyle(
                  color: LifeRadarColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int score;
  final Color color;

  _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const startAngle = math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;

    final bg = Paint()
      ..color = LifeRadarColors.cardBackground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      bg,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal * (score.clamp(0, 100) / 100),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.score != score || old.color != color;
}
