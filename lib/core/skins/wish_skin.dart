import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../skin_engine/skin_protocol.dart';
import '../../features/decision/presentation/widgets/wish_pond.dart';

class WishSkin implements AppSkin {
  @override
  SkinMode get mode => SkinMode.wish;

  // --- 🧚‍♀️ Fairycore Palette ---
  @override
  Color get backgroundSurface => const Color(0xFFD4F1F4);
  @override
  Color get primaryAccent => const Color(0xFFFCE38A);
  @override
  Color get secondaryAccent => const Color(0xFF2B5876);
  @override
  Color get textPrimary => const Color(0xFF2B5876);

  // --- ✒️ Typography ---
  @override
  TextStyle get displayFont => GoogleFonts.alegreya(
    fontSize: 36, fontWeight: FontWeight.bold, color: textPrimary,
    fontStyle: FontStyle.italic,
  );

  @override
  TextStyle get bodyFont => GoogleFonts.cedarvilleCursive(
    fontSize: 20, color: textPrimary, fontWeight: FontWeight.w600,
  );

  @override
  TextStyle get monoFont => GoogleFonts.tenorSans(
    color: textPrimary.withOpacity(0.7),
  );

  // --- ⚡ Physics ---
  @override
  Curve get animationCurve => Curves.easeInOutSine;
  @override
  Duration get animationDuration => const Duration(milliseconds: 2000);

  // --- 🧩 Interactive Hero ---
  @override
  Widget buildInteractiveHero({
    required AnimationController controller,
    required VoidCallback onTap,
    Function(String)? onResult, // ✅ 接口匹配
  }) {
    return WishPond(
      skin: this,
      onResult: (result) {
        if (onResult != null) onResult(result);
        onTap(); // 触发通用点击逻辑（如隐藏旧结果）
      },
    );
  }

  // --- 👤 Profile Styles ---
  @override
  Gradient get profileHeaderGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD4F1F4), Color(0xFFB8E2E8)],
  );

  @override
  Color get cardBackgroundColor => Colors.white.withOpacity(0.6);
  @override
  BoxBorder get avatarBorder => Border.all(color: Colors.white, width: 4);
  @override
  double get cardBorderRadius => 30.0;
}