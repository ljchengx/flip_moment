import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 治愈系漂浮粒子类型
enum HealingParticleType { star, heart, sparkle }

/// 粒子数据模型
class HealingParticleData {
  final double startX;      // X位置 (0.0-1.0 相对值)
  final double startY;      // Y位置 (0.0-1.0 相对值)
  final double size;        // 粒子大小 (px)
  final int durationMs;     // 动画周期 (ms)
  final double delayMs;     // 启动延迟 (ms)
  final HealingParticleType type;
  final double driftX;      // 水平漂移量
  final double driftY;      // 垂直漂移量

  const HealingParticleData({
    required this.startX,
    required this.startY,
    required this.size,
    required this.durationMs,
    required this.delayMs,
    required this.type,
    required this.driftX,
    required this.driftY,
  });

  /// 随机生成粒子数据
  factory HealingParticleData.random(bool isYes, math.Random rnd) {
    // YES模式包含爱心，NO模式不包含
    final types = isYes
        ? [HealingParticleType.star, HealingParticleType.heart, HealingParticleType.sparkle]
        : [HealingParticleType.star, HealingParticleType.sparkle];
    return HealingParticleData(
      startX: rnd.nextDouble(),
      startY: rnd.nextDouble(),
      size: 8 + rnd.nextDouble() * 16,          // 8-24px
      durationMs: 2000 + rnd.nextInt(2000),     // 2-4秒
      delayMs: rnd.nextDouble() * 1500,         // 0-1.5秒延迟
      type: types[rnd.nextInt(types.length)],
      driftX: (rnd.nextDouble() - 0.5) * 30,    // -15 ~ +15px
      driftY: -20 - rnd.nextDouble() * 30,      // -20 ~ -50px (上浮)
    );
  }
}

/// 漂浮粒子覆盖层 - 使用 CustomPainter 实现，性能更好
class FloatingParticlesOverlay extends StatefulWidget {
  final bool isYes;
  final Color tintColor;
  final int particleCount;

  const FloatingParticlesOverlay({
    super.key,
    required this.isYes,
    required this.tintColor,
    this.particleCount = 10,
  });

  @override
  State<FloatingParticlesOverlay> createState() => _FloatingParticlesOverlayState();
}

class _FloatingParticlesOverlayState extends State<FloatingParticlesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<HealingParticleData> _particles;

  @override
  void initState() {
    super.initState();

    // 使用固定种子确保稳定性
    final rnd = math.Random();
    _particles = List.generate(
      widget.particleCount,
      (_) => HealingParticleData.random(widget.isYes, rnd),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticlesPainter(
              particles: _particles,
              progress: _controller.value,
              tintColor: widget.tintColor,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

/// 粒子绘制器
class _ParticlesPainter extends CustomPainter {
  final List<HealingParticleData> particles;
  final double progress;
  final Color tintColor;

  _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.tintColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // 计算每个粒子的独立进度（考虑延迟）
      final delay = particle.delayMs / 4000; // 转换为 0-1 的比例
      final duration = particle.durationMs / 4000;

      // 计算粒子的循环进度
      double particleProgress = (progress - delay) % 1.0;
      if (particleProgress < 0) particleProgress += 1.0;
      particleProgress = (particleProgress / duration).clamp(0.0, 1.0);

      // 计算透明度：淡入 → 保持 → 淡出
      double opacity;
      if (particleProgress < 0.15) {
        opacity = particleProgress / 0.15 * 0.6;
      } else if (particleProgress < 0.7) {
        opacity = 0.6;
      } else {
        opacity = (1.0 - particleProgress) / 0.3 * 0.6;
      }
      opacity = opacity.clamp(0.0, 0.6);

      // 计算位置
      final baseX = particle.startX * size.width;
      final baseY = particle.startY * size.height;
      final driftX = particle.driftX * math.sin(particleProgress * math.pi);
      final driftY = particle.driftY * particleProgress;

      final x = baseX + driftX;
      final y = baseY + driftY;

      // 计算缩放
      final scale = 0.8 + 0.3 * math.sin(particleProgress * math.pi);

      // 绘制粒子
      _drawParticle(canvas, Offset(x, y), particle, opacity, scale);
    }
  }

  void _drawParticle(Canvas canvas, Offset center, HealingParticleData particle, double opacity, double scale) {
    final paint = Paint()
      ..color = tintColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final actualSize = particle.size * scale;

    switch (particle.type) {
      case HealingParticleType.star:
        _drawStar(canvas, center, actualSize, paint);
        break;
      case HealingParticleType.heart:
        _drawHeart(canvas, center, actualSize, paint);
        break;
      case HealingParticleType.sparkle:
        _drawSparkle(canvas, center, actualSize, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = size / 4;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;

      final outerPoint = Offset(
        center.dx + outerRadius * math.cos(outerAngle),
        center.dy + outerRadius * math.sin(outerAngle),
      );
      final innerPoint = Offset(
        center.dx + innerRadius * math.cos(innerAngle),
        center.dy + innerRadius * math.sin(innerAngle),
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final width = size;
    final height = size;

    path.moveTo(center.dx, center.dy + height * 0.3);
    path.cubicTo(
      center.dx - width * 0.5, center.dy - height * 0.1,
      center.dx - width * 0.5, center.dy - height * 0.4,
      center.dx, center.dy - height * 0.15,
    );
    path.cubicTo(
      center.dx + width * 0.5, center.dy - height * 0.4,
      center.dx + width * 0.5, center.dy - height * 0.1,
      center.dx, center.dy + height * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final radius = size / 2;
    // 画一个简单的四角星/菱形
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius * 0.3, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius * 0.3, center.dy)
      ..close();
    canvas.drawPath(path, paint);

    // 水平方向的短线
    final path2 = Path()
      ..moveTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - radius * 0.3, center.dy)
      ..moveTo(center.dx + radius * 0.3, center.dy)
      ..lineTo(center.dx + radius, center.dy);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
