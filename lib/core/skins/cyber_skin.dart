import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../skin_engine/skin_protocol.dart';
import '../../features/decision/presentation/widgets/cyber_hud_decoration.dart';
import '../../features/decision/presentation/widgets/liquid_metal_ball.dart';

class CyberSkin implements AppSkin {
  @override
  SkinMode get mode => SkinMode.cyber;

  // --- 🧪 赛博酸性配色 (Acid & Cyber Palette) ---
  @override
  Color get backgroundSurface => const Color(0xFF050505); // Void Black
  @override
  Color get primaryAccent => const Color(0xFFCCFF00);     // Acid Green
  @override
  Color get secondaryAccent => const Color(0xFFBC13FE);   // Electric Purple
  @override
  Color get textPrimary => const Color(0xFFE6E8EA);       // Liquid Chrome

  // 辅助色：故障蓝 (用于数据/边框)
  static const Color glitchBlue = Color(0xFF00F0FF);

  // --- 👽 字体排印 (Typography) ---
  @override
  TextStyle get displayFont => GoogleFonts.syne( // 宽体无衬线
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: primaryAccent, // 默认用酸性绿
    letterSpacing: -1.0,
  );

  @override
  TextStyle get bodyFont => GoogleFonts.vt323( // 像素风格
    fontSize: 18,
    color: textPrimary,
    letterSpacing: 1.5,
  );

  @override
  TextStyle get monoFont => GoogleFonts.vt323( // 像素风格用于数据
    color: glitchBlue,
    fontSize: 16,
  );

  // --- ⚡ 物理参数 ---
  @override
  Curve get animationCurve => Curves.easeInOutExpo; // 极速响应
  @override
  Duration get animationDuration => const Duration(milliseconds: 400); // 瞬间完成

  // --- 🧩 组件工厂 ---

  // 1. 背景装饰：HUD 抬头显示
  // 注意：我们需要修改 DecisionScreen 让它调用这个方法，或者在 DecisionScreen 里判断
  // 这里我建议在 DecisionScreen 的 Stack 底层加入:
  // if (skin is CyberSkin) (skin as CyberSkin).buildBackground(context)
  Widget buildBackground(BuildContext context) {
    return const CyberHudDecoration();
  }

  // 2. 核心交互：液态金属球
  @override
  Widget buildInteractiveHero({
    required AnimationController controller,
    required VoidCallback onTap,
    // 注意：我们需要 DecisionScreen 传递一个 onResult 回调
    // 如果接口还没改，我们这里先暂时自己处理，或者你需要在 skin_protocol.dart 里加上这个参数
    Function(String)? onResult,
  }) {
    return LiquidMetalBall(
      skin: this,
      onResult: onResult,
    );
  }

  // --- 👤 个人主页专用 ---
  @override
  Gradient get profileHeaderGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFF1A0033), // 深紫
      backgroundSurface,
    ],
  );

  @override
  Color get cardBackgroundColor => const Color(0xFF111111);

  @override
  BoxBorder get avatarBorder => Border.all(color: glitchBlue, width: 2);

  @override
  double get cardBorderRadius => 0.0; // 赛博风格要直角，或者极小的切角
}