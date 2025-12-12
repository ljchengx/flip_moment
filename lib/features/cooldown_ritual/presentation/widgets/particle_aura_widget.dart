import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/ritual_theme_config.dart';

/// Particle data model
class _Particle {
  final double angle; // Orbital angle in radians
  final double radius; // Distance from center
  final double size;
  final double speed; // Angular speed multiplier

  _Particle({
    required this.angle,
    required this.radius,
    required this.size,
    required this.speed,
  });
}

/// Particle aura widget with floating particles around the energy orb
class ParticleAuraWidget extends StatefulWidget {
  final RitualThemeConfig config;
  final double progress;
  final Animation<double> animation;
  final bool isCelebrating;

  const ParticleAuraWidget({
    super.key,
    required this.config,
    required this.progress,
    required this.animation,
    this.isCelebrating = false,
  });

  /// Generate particle count (Property 4)
  static int generateParticleCount(math.Random random) {
    return 8 + random.nextInt(8); // 8-15 particles
  }

  @override
  State<ParticleAuraWidget> createState() => _ParticleAuraWidgetState();
}

class _ParticleAuraWidgetState extends State<ParticleAuraWidget> {
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _generateParticles();
  }

  void _generateParticles() {
    final random = math.Random();
    final count = ParticleAuraWidget.generateParticleCount(random);

    _particles = List.generate(count, (index) {
      return _Particle(
        angle: (index / count) * 2 * math.pi,
        radius: 100 + random.nextDouble() * 30, // 100-130px from center
        size: 6 + random.nextDouble() * 8, // 6-14px
        speed: 0.8 + random.nextDouble() * 0.4, // 0.8-1.2x speed
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(300, 300),
            painter: _ParticlePainter(
              particles: _particles,
              animationValue: widget.animation.value,
              progress: widget.progress,
              particleColor: widget.config.particleColor,
              particleShape: widget.config.particleShape,
              isCelebrating: widget.isCelebrating,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for particles
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;
  final double progress;
  final Color particleColor;
  final ParticleShape particleShape;
  final bool isCelebrating;

  _ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.progress,
    required this.particleColor,
    required this.particleShape,
    required this.isCelebrating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      // Calculate orbital position
      final angle = particle.angle + (animationValue * 2 * math.pi * particle.speed);
      final x = center.dx + particle.radius * math.cos(angle);
      final y = center.dy + particle.radius * math.sin(angle);
      final position = Offset(x, y);

      // Brightness increases with progress
      final brightness = 0.3 + (progress * 0.7);
      final opacity = brightness * (isCelebrating ? 1.0 : 0.8);

      // Draw particle based on shape
      _drawParticle(canvas, position, particle.size, opacity);
    }
  }

  void _drawParticle(Canvas canvas, Offset position, double size, double opacity) {
    final paint = Paint()
      ..color = particleColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    switch (particleShape) {
      case ParticleShape.heart:
        _drawHeart(canvas, position, size, paint);
        break;
      case ParticleShape.star:
        _drawStar(canvas, position, size, paint);
        break;
      case ParticleShape.diamond:
        _drawDiamond(canvas, position, size, paint);
        break;
      case ParticleShape.sparkle:
        _drawSparkle(canvas, position, size, paint);
        break;
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final s = size / 2;

    path.moveTo(center.dx, center.dy + s * 0.3);
    path.cubicTo(
      center.dx - s, center.dy - s * 0.5,
      center.dx - s * 1.5, center.dy + s * 0.3,
      center.dx, center.dy + s * 1.2,
    );
    path.cubicTo(
      center.dx + s * 1.5, center.dy + s * 0.3,
      center.dx + s, center.dy - s * 0.5,
      center.dx, center.dy + s * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 2 * math.pi / 5) - math.pi / 2;
      final innerAngle = outerAngle + math.pi / 5;

      final outerX = center.dx + outerRadius * math.cos(outerAngle);
      final outerY = center.dy + outerRadius * math.sin(outerAngle);
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final s = size / 2;

    path.moveTo(center.dx, center.dy - s);
    path.lineTo(center.dx + s, center.dy);
    path.lineTo(center.dx, center.dy + s);
    path.lineTo(center.dx - s, center.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final s = size / 2;

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - s),
      Offset(center.dx, center.dy + s),
      paint..strokeWidth = 2.0,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - s, center.dy),
      Offset(center.dx + s, center.dy),
      paint,
    );

    // Diagonal lines
    final d = s * 0.7;
    canvas.drawLine(
      Offset(center.dx - d, center.dy - d),
      Offset(center.dx + d, center.dy + d),
      paint..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(center.dx + d, center.dy - d),
      Offset(center.dx - d, center.dy + d),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.progress != progress ||
        oldDelegate.isCelebrating != isCelebrating;
  }
}
