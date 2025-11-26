import 'package:flutter/material.dart';
import '../../../../core/skins/cyber_skin.dart';

class CyberHudDecoration extends StatefulWidget {
  const CyberHudDecoration({super.key});

  @override
  State<CyberHudDecoration> createState() => _CyberHudDecorationState();
}

class _CyberHudDecorationState extends State<CyberHudDecoration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4)
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. 在 build 方法中获取顶部安全距离 (刘海高度)
    final topPadding = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _HudPainter(
            color: CyberSkin.glitchBlue,
            opacity: 0.3 + 0.2 * _controller.value,
            topPadding: topPadding, // 2. 传入 Painter
          ),
        );
      },
    );
  }
}

class _HudPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double topPadding; // 3. 接收参数

  _HudPainter({
    required this.color,
    required this.opacity,
    required this.topPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = size.center(Offset.zero);
    final w = size.width;
    final h = size.height;

    // 4. 使用传入的 topPadding 计算位置
    final headerY = topPadding + 60;

    // 左侧刻度
    canvas.drawLine(Offset(20, headerY), Offset(100, headerY), paint);
    canvas.drawLine(Offset(20, headerY), Offset(20, headerY + 10), paint);
    // 右侧刻度
    canvas.drawLine(Offset(w - 20, headerY), Offset(w - 100, headerY), paint);
    canvas.drawLine(Offset(w - 20, headerY), Offset(w - 20, headerY + 10), paint);

    // 2. 中央十字准星
    final crossSize = w * 0.8;
    final rect = Rect.fromCenter(center: center, width: crossSize, height: crossSize);

    final cornerLen = 40.0;
    // 左上
    canvas.drawPath(Path()..moveTo(rect.left, rect.top + cornerLen)..lineTo(rect.left, rect.top)..lineTo(rect.left + cornerLen, rect.top), paint);
    // 右上
    canvas.drawPath(Path()..moveTo(rect.right, rect.top + cornerLen)..lineTo(rect.right, rect.top)..lineTo(rect.right - cornerLen, rect.top), paint);
    // 左下
    canvas.drawPath(Path()..moveTo(rect.left, rect.bottom - cornerLen)..lineTo(rect.left, rect.bottom)..lineTo(rect.left + cornerLen, rect.bottom), paint);
    // 右下
    canvas.drawPath(Path()..moveTo(rect.right, rect.bottom - cornerLen)..lineTo(rect.right, rect.bottom)..lineTo(rect.right - cornerLen, rect.bottom), paint);

    // 3. 连接线
    final thinPaint = Paint()..color = color.withOpacity(opacity * 0.5)..strokeWidth = 0.5;
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, h), thinPaint);
    canvas.drawLine(Offset(0, center.dy), Offset(w, center.dy), thinPaint);

    // 4. 数据流装饰
    for(int i=0; i<5; i++) {
      double y = rect.bottom - 40 + i * 8;
      canvas.drawLine(Offset(rect.right - 60, y), Offset(rect.right - 10, y), thinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HudPainter oldDelegate) => oldDelegate.opacity != opacity;
}