import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/ritual_theme_config.dart';

/// Orb state based on progress
enum OrbState { dormant, charging, nearReady }

/// Energy orb widget that fills and glows based on cooldown progress
class EnergyOrbWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final RitualThemeConfig config;
  final Animation<double> breathAnimation;

  static const double baseDiameter = 150.0;

  const EnergyOrbWidget({
    super.key,
    required this.progress,
    required this.config,
    required this.breathAnimation,
  });

  /// Calculate fill percentage (Property 1)
  static double calculateFillPercentage(double progress) => progress;

  /// Calculate glow opacity (Property 2)
  double get glowOpacity => 0.2 + (progress * 0.8);

  /// Get orb state based on progress (Property 3)
  static OrbState getState(double progress) {
    if (progress < 0.5) return OrbState.dormant;
    if (progress < 0.8) return OrbState.charging;
    return OrbState.nearReady;
  }

  OrbState get state => getState(progress);

  @override
  Widget build(BuildContext context) {
    // Breath animation scale: 0.95 to 1.05 (Property 11)
    final scale = 0.95 + (breathAnimation.value * 0.1);

    return RepaintBoundary(
      child: Transform.scale(
        scale: scale,
        child: CustomPaint(
          size: const Size(baseDiameter, baseDiameter),
          painter: _OrbPainter(
            progress: progress,
            glowColor: config.orbGlowColor,
            fillColor: config.orbFillColor,
            glowOpacity: glowOpacity,
            isPulsing: state == OrbState.nearReady,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the energy orb
class _OrbPainter extends CustomPainter {
  final double progress;
  final Color glowColor;
  final Color fillColor;
  final double glowOpacity;
  final bool isPulsing;

  _OrbPainter({
    required this.progress,
    required this.glowColor,
    required this.fillColor,
    required this.glowOpacity,
    required this.isPulsing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw glow layers
    _drawGlow(canvas, center, radius);

    // Draw fill based on progress
    _drawFill(canvas, center, radius);

    // Draw pulsing effect if near ready
    if (isPulsing) {
      _drawPulse(canvas, center, radius);
    }
  }

  void _drawGlow(Canvas canvas, Offset center, double radius) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withOpacity(glowOpacity * 0.6),
          glowColor.withOpacity(glowOpacity * 0.3),
          glowColor.withOpacity(0),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));

    canvas.drawCircle(center, radius * 1.5, glowPaint);
  }

  void _drawFill(Canvas canvas, Offset center, double radius) {
    // Background circle
    final bgPaint = Paint()
      ..color = fillColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Fill circle based on progress
    if (progress > 0) {
      final fillPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            fillColor.withOpacity(0.8),
            fillColor.withOpacity(0.4),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      // Clip to show fill from bottom to top
      final fillHeight = radius * 2 * progress;
      final clipRect = Rect.fromLTWH(
        center.dx - radius,
        center.dy + radius - fillHeight,
        radius * 2,
        fillHeight,
      );

      canvas.save();
      canvas.clipRect(clipRect);
      canvas.drawCircle(center, radius, fillPaint);
      canvas.restore();
    }

    // Border
    final borderPaint = Paint()
      ..color = glowColor.withOpacity(glowOpacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawPulse(Canvas canvas, Offset center, double radius) {
    final pulsePaint = Paint()
      ..color = glowColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius * 1.1, pulsePaint);
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowOpacity != glowOpacity ||
        oldDelegate.isPulsing != isPulsing;
  }
}
