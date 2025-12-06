import 'package:flutter/material.dart';
import '../../../../core/skin_engine/skin_protocol.dart';

class DeskDecoration extends StatelessWidget {
  final AppSkin skin;

  const DeskDecoration({super.key, required this.skin});

  @override
  Widget build(BuildContext context) {
    // 🔥 根据屏幕高度动态计算偏移
    final screenHeight = MediaQuery.of(context).size.height;
    final dynamicOffset = screenHeight * 0.06; // 屏幕高度的 6%

    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _DeskPainter(
          lineColor: skin.textPrimary.withOpacity(0.05), // 线条再淡一点，不抢戏
          matColor: Colors.black.withOpacity(0.25),      // 桌垫深色
          accentColor: skin.primaryAccent.withOpacity(0.4), // 强调色 (取景框)
          verticalOffset: dynamicOffset, // 使用动态计算的偏移值
        ),
      ),
    );
  }
}

class _DeskPainter extends CustomPainter {
  final Color lineColor;
  final Color matColor;
  final Color accentColor;
  final double verticalOffset; // 新增属性

  _DeskPainter({
    required this.lineColor,
    required this.matColor,
    required this.accentColor,
    required this.verticalOffset, // 新增构造函数参数
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 核心计算：基于偏移量重新定位中心点
    final center = size.center(Offset(0, verticalOffset));

    // --- 1. 计算核心区域 (桌垫) ---
    // 这是一个正方形区域，硬币会落在里面
    final matSize = size.width * 0.75; // 稍微缩小一点，留出呼吸感
    final matRect = Rect.fromCenter(
      center: center,
      width: matSize,
      height: matSize,
    );

    // --- 2. 绘制深色桌垫背景 ---
    final matPaint = Paint()
      ..color = matColor
      ..style = PaintingStyle.fill;

    // 使用平滑圆角 (Continuous Rectangle 风格)
    canvas.drawRRect(
      RRect.fromRectAndRadius(matRect, const Radius.circular(24)),
      matPaint,
    );

    // --- 3. 绘制"聚焦取景框" (Corner Accents) ---
    // 关键修改：基于 matRect (桌垫) 绘制角落，而不是基于 size (屏幕)
    // 这样就避开了顶部的 UI
    final framePadding = 20.0; // 取景框比桌垫大一圈
    final frameRect = matRect.inflate(framePadding);
    final cornerLen = 25.0; // 角落线长度

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square; // 方头笔触，更硬朗

    // 左上角 (Top-Left)
    canvas.drawLine(frameRect.topLeft, frameRect.topLeft + Offset(cornerLen, 0), accentPaint);
    canvas.drawLine(frameRect.topLeft, frameRect.topLeft + Offset(0, cornerLen), accentPaint);

    // 右上角 (Top-Right)
    canvas.drawLine(frameRect.topRight, frameRect.topRight - Offset(cornerLen, 0), accentPaint);
    canvas.drawLine(frameRect.topRight, frameRect.topRight + Offset(0, cornerLen), accentPaint);

    // 左下角 (Bottom-Left)
    canvas.drawLine(frameRect.bottomLeft, frameRect.bottomLeft + Offset(cornerLen, 0), accentPaint);
    canvas.drawLine(frameRect.bottomLeft, frameRect.bottomLeft - Offset(0, cornerLen), accentPaint);

    // 右下角 (Bottom-Right)
    canvas.drawLine(frameRect.bottomRight, frameRect.bottomRight - Offset(cornerLen, 0), accentPaint);
    canvas.drawLine(frameRect.bottomRight, frameRect.bottomRight - Offset(0, cornerLen), accentPaint);

    // --- 4. 辅助连接线 (Engineering Lines) ---
    // 用极细的线连接取景框和桌垫，增加精密感
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    // 绘制十字准星的延伸线 (上下左右)
    // 上
    canvas.drawLine(Offset(center.dx, frameRect.top), Offset(center.dx, frameRect.top - 30), linePaint);
    // 下
    canvas.drawLine(Offset(center.dx, frameRect.bottom), Offset(center.dx, frameRect.bottom + 30), linePaint);
    // 左
    canvas.drawLine(Offset(frameRect.left, center.dy), Offset(0, center.dy), linePaint); // 延伸到屏幕边缘
    // 右
    canvas.drawLine(Offset(frameRect.right, center.dy), Offset(size.width, center.dy), linePaint);

    // --- 5. 左侧刻度尺 (Ruler) ---
    // 确保刻度尺位置在桌垫旁边，不干扰顶部
    final rulerX = 16.0;
    // 只在桌垫的高度范围内绘制刻度
    final startY = matRect.top;
    final endY = matRect.bottom;

    for (double y = startY; y <= endY; y += 15) {
      // 每 4 个刻度画长一点
      final isMajor = ((y - startY) % 60 == 0);
      final len = isMajor ? 12.0 : 6.0;
      // 稍微加粗主要刻度
      linePaint.strokeWidth = isMajor ? 1.5 : 0.5;
      canvas.drawLine(Offset(rulerX, y), Offset(rulerX + len, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}