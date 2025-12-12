import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 统一的高斯模糊背景遮罩
/// 适用于结果卡片、冷却提示等需要背景模糊的场景
class BlurredOverlay extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final bool animate;

  /// 模糊强度 (默认 15，舒适的模糊效果)
  final double blurSigma;

  /// 遮罩透明度 (默认 0.3，轻柔不压抑)
  final double overlayOpacity;

  /// 是否使用深色遮罩 (深色主题用深色，浅色主题用浅色)
  final bool isDark;

  const BlurredOverlay({
    super.key,
    this.child,
    this.onTap,
    this.animate = true,
    this.blurSigma = 15.0,
    this.overlayOpacity = 0.3,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    // 根据主题选择遮罩颜色
    final overlayColor = isDark
        ? Colors.black.withValues(alpha: overlayOpacity)
        : Colors.white.withValues(alpha: overlayOpacity);

    Widget content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          color: overlayColor,
          child: child,
        ),
      ),
    );

    if (animate) {
      content = content.animate().fadeIn(duration: 300.ms);
    }

    return content;
  }
}
