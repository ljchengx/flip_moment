import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/decision/presentation/widgets/mochi_character.dart';
import '../skin_engine/skin_protocol.dart';

class HealingSkin implements AppSkin {
  @override
  SkinMode get mode => SkinMode.healing;

  // --- 🎨 莫兰迪色板 (Morandi Palette) ---
  @override
  Color get backgroundSurface => const Color(0xFFFDFBF7); // 燕麦奶 (Oatmeal Milk)

  @override
  Color get primaryAccent => const Color(0xFFB5C99A); // 抹茶慕斯 (Matcha Mousse)

  @override
  Color get secondaryAccent => const Color(0xFFE0BBE4); // 烟粉豆沙 (Dusty Rose)

  @override
  Color get textPrimary => const Color(0xFF5C5C5C); // 暖炭灰 (Warm Charcoal)

  // --- ✒️ 圆润字体系统 ---
  @override
  TextStyle get displayFont => GoogleFonts.varelaRound(
    color: textPrimary,
    fontWeight: FontWeight.bold,
  );

  @override
  TextStyle get bodyFont => GoogleFonts.quicksand( // Quicksand 非常适合可爱风格
    color: textPrimary,
    fontWeight: FontWeight.w600,
  );

  @override
  TextStyle get monoFont => GoogleFonts.spaceMono( // 稍微带点科技萌
    color: textPrimary.withOpacity(0.6),
  );

  // --- ⚡ 软体物理参数 ---
  @override
  Curve get animationCurve => Curves.elasticOut; // 核心：弹性曲线！

  @override
  Duration get animationDuration => const Duration(milliseconds: 800); // 短促轻快

  @override
  Widget buildInteractiveHero({
    required AnimationController controller,
    required VoidCallback onTap,
    Function(String)? onResult,
  }) {
    // 返回治愈团子组件
    return MochiCharacter(
      skin: this,
      onTap: onTap,         // 团子的点击
      onResult: onResult,   // 团子的结果
    );
  }

  @override
  Gradient get profileHeaderGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFDFBF7), // 燕麦奶
      Color(0xFFF0EFE9), // 稍微加深
    ],
  );

  @override
  Color get cardBackgroundColor => Colors.white; // 纯白卡片

  @override
  BoxBorder get avatarBorder => Border.all(color: primaryAccent, width: 6); // 肥厚的绿色边框

  @override
  double get cardBorderRadius => 24.0; // 极致圆润
}