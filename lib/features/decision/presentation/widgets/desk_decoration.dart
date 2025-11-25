import 'package:flutter/material.dart';
import '../../../../core/skin_engine/skin_protocol.dart';

class DeskDecoration extends StatelessWidget {
  final AppSkin skin;

  const DeskDecoration({super.key, required this.skin});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _DeskPainter(
        lineColor: skin.textPrimary.withOpacity(0.1), // 极淡的线条
        matColor: Colors.black.withOpacity(0.2),      // 深色桌垫
        accentColor: skin.primaryAccent.withOpacity(0.3), // 强调色
      ),
    );
  }
}

class _DeskPainter extends CustomPainter {
  final Color lineColor;
  final Color matColor;
  final Color accentColor;

  _DeskPainter({
    required this.lineColor,
    required this.matColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 1. 绘制中间的"桌垫" (Mat) - 硬币的着陆区
    // 这是一个深色的圆角矩形，给硬币提供视觉锚点
    final matRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.8,
      height: size.width * 0.8, // 正方形区域
    );

    final matPaint = Paint()
      ..color = matColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(matRect, const Radius.circular(20)),
      matPaint,
    );

    // 绘制桌垫的边框
    canvas.drawRRect(
      RRect.fromRectAndRadius(matRect, const Radius.circular(20)),
      paint,
    );

    // 2. 绘制"取景框"角落装饰 (四个角)
    final cornerLen = 20.0;
    final padding = 24.0;
    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 左上
    canvas.drawLine(Offset(padding, padding), Offset(padding + cornerLen, padding), accentPaint);
    canvas.drawLine(Offset(padding, padding), Offset(padding, padding + cornerLen), accentPaint);
    // 右上
    canvas.drawLine(Offset(size.width - padding, padding), Offset(size.width - padding - cornerLen, padding), accentPaint);
    canvas.drawLine(Offset(size.width - padding, padding), Offset(size.width - padding, padding + cornerLen), accentPaint);
    // 左下
    canvas.drawLine(Offset(padding, size.height - padding), Offset(padding + cornerLen, size.height - padding), accentPaint);
    canvas.drawLine(Offset(padding, size.height - padding), Offset(padding, size.height - padding - cornerLen), accentPaint);
    // 右下
    canvas.drawLine(Offset(size.width - padding, size.height - padding), Offset(size.width - padding - cornerLen, size.height - padding), accentPaint);
    canvas.drawLine(Offset(size.width - padding, size.height - padding), Offset(size.width - padding, size.height - padding - cornerLen), accentPaint);

    // 3. 绘制中心十字准星 (极细)
    // 仅在桌垫上下方画一点点，不穿过硬币
    canvas.drawLine(Offset(center.dx, matRect.top - 20), Offset(center.dx, matRect.top - 5), paint);
    canvas.drawLine(Offset(center.dx, matRect.bottom + 5), Offset(center.dx, matRect.bottom + 20), paint);

    // 4. 侧边刻度尺 (装饰用)
    final rulerX = padding;
    for (int i = 0; i < 20; i++) {
      final y = size.height * 0.3 + (i * 15);
      // 每5个刻度长一点
      final len = (i % 5 == 0) ? 15.0 : 8.0;
      canvas.drawLine(Offset(rulerX, y), Offset(rulerX + len, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}