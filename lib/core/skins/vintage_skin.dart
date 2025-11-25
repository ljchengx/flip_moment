import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../skin_engine/skin_protocol.dart';

class VintageSkin implements AppSkin {
  @override
  SkinMode get mode => SkinMode.vintage;

  @override
  Color get backgroundSurface => const Color(0xFF1A1C1E);
  @override
  Color get primaryAccent => const Color(0xFFC6A664);
  @override
  Color get secondaryAccent => const Color(0xFF8F3B35);
  @override
  Color get textPrimary => const Color(0xFFF2EFE5);

  @override
  TextStyle get displayFont => GoogleFonts.playfairDisplay(
      fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary);

  @override
  TextStyle get bodyFont => GoogleFonts.lato(color: textPrimary);

  @override
  TextStyle get monoFont => GoogleFonts.courierPrime(color: primaryAccent);

  @override
  Curve get animationCurve => Curves.easeInOutCubic; // 机械感

  @override
  Duration get animationDuration => const Duration(milliseconds: 1200);

  @override
  Widget buildInteractiveHero({
    required AnimationController controller,
    required VoidCallback onTap,
  }) {
    // TODO: 这里之后会连接具体的 CoinFlipper 组件
    return Container(
      width: 200, height: 200,
      color: Colors.transparent,
      child: Center(child: Text("🪙", style: TextStyle(fontSize: 80))),
    );
  }

  // 👇 使用原生 HapticFeedback，不要用 Vibration 库
  Future<void> performTapHaptic() async {
    await HapticFeedback.heavyImpact(); // 机械感重击
  }

  Future<void> performResultHaptic() async {
    await HapticFeedback.mediumImpact();
  }


  @override
  Gradient get profileHeaderGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2C2F33), // 深炭色
      Color(0xFF1A1C1E), // 复古黑
    ],
  );

  @override
  Color get cardBackgroundColor => const Color(0xFF25282B); // 略浅于背景，形成层级

  @override
  BoxBorder get avatarBorder => Border.all(color: primaryAccent, width: 3); // 金色硬边框

  @override
  double get cardBorderRadius => 4.0; // 锐利的圆角
}