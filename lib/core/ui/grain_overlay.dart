import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// 移除 Scheduler 绑定，不再需要 Ticker
class GrainOverlay extends StatefulWidget {
  final Widget child;
  final double opacity;

  const GrainOverlay({
    super.key,
    required this.child,
    this.opacity = 0.05,
  });

  @override
  State<GrainOverlay> createState() => _GrainOverlayState();
}

class _GrainOverlayState extends State<GrainOverlay> {
  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    final program = await ui.FragmentProgram.fromAsset('shaders/noise.frag');
    if (mounted) {
      setState(() => _program = program);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) return widget.child;

    return CustomPaint(
      foregroundPainter: _GrainPainter(
        shaderProgram: _program!,
        // 核心修改：不再传入动态时间，传入固定值 (比如 1.0)
        // 这样噪点就是静止的，像一张贴在屏幕上的磨砂膜
        time: 1.0,
        strength: widget.opacity,
        // 获取屏幕像素密度，解决"模糊"问题
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      ),
      child: widget.child,
    );
  }
}

class _GrainPainter extends CustomPainter {
  final ui.FragmentProgram shaderProgram;
  final double time;
  final double strength;
  final double pixelRatio; // 新增：像素密度

  _GrainPainter({
    required this.shaderProgram,
    required this.time,
    required this.strength,
    required this.pixelRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = shaderProgram.fragmentShader();

    // 传入物理像素分辨率，确保噪点在高清屏上足够细腻，不再模糊
    shader.setFloat(0, size.width * pixelRatio);
    shader.setFloat(1, size.height * pixelRatio);
    shader.setFloat(2, time);
    shader.setFloat(3, strength);

    final paint = Paint()
      ..shader = shader
    // 核心修改：改用 softLight (柔光) 或 screen (滤色)
    // overlay (叠加) 对黑色背景太强烈了，导致看起来脏
      ..blendMode = BlendMode.screen;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) {
    // 只有当强度变化时才重绘，极大提升性能
    return oldDelegate.strength != strength;
  }
}