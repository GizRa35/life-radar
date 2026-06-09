import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';

/// [child] ekranını sarar; AppState.celebrateUpgrade true olduğunda
/// (yeni Premium/VIP satın alımında) ekranın üstünde konfeti patlatır.
class CelebrationOverlay extends StatefulWidget {
  final Widget child;
  const CelebrationOverlay({super.key, required this.child});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final celebrate = context.watch<AppState>().celebrateUpgrade;
    if (celebrate) {
      // Build sırasında durum değiştirmemek için bir sonraki kareye ertele.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _confetti.play();
        context.read<AppState>().clearCelebration();
      });
    }

    return Stack(
      children: [
        widget.child,
        // Üstten aşağı patlayan konfeti.
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            maxBlastForce: 22,
            minBlastForce: 8,
            gravity: 0.25,
            emissionFrequency: 0.05,
            colors: const [
              LifeRadarColors.turquoise,
              Color(0xFFC9A227), // altın (VIP)
              Color(0xFFE9C766),
              Colors.white,
              LifeRadarColors.navy,
            ],
          ),
        ),
      ],
    );
  }
}
