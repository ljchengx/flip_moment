import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/ritual_theme_config.dart';

/// Unlock celebration overlay shown when cooldown completes
class UnlockCelebrationOverlay extends StatefulWidget {
  final RitualThemeConfig config;
  final VoidCallback onComplete;

  static const Duration duration = Duration(milliseconds: 1000);

  const UnlockCelebrationOverlay({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<UnlockCelebrationOverlay> createState() =>
      _UnlockCelebrationOverlayState();
}

class _UnlockCelebrationOverlayState extends State<UnlockCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: UnlockCelebrationOverlay.duration,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutExpo,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Particle burst effect
            Positioned.fill(
              child: CustomPaint(
                painter: _BurstPainter(
                  progress: _controller.value,
                  particleColor: widget.config.particleColor,
                ),
              ),
            ),

            // Ready message
            Center(
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: widget.config.orbGlowColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: widget.config.orbGlowColor.withOpacity(0.6),
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      loc.cooldownReadyMessage,
                      style: widget.config.countdownTextStyle.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: widget.config.orbGlowColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom painter for particle burst effect
class _BurstPainter extends CustomPainter {
  final double progress;
  final Color particleColor;

  static const int particleCount = 20;

  _BurstPainter({
    required this.progress,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = progress * maxRadius * 1.5;
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);

      // Fade out as particles move outward
      final opacity = (1.0 - progress) * 0.8;
      final size = 8.0 * (1.0 - progress * 0.5);

      final paint = Paint()
        ..color = particleColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), size, paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
