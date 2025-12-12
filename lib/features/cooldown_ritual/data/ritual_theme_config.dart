import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/skin_engine/skin_protocol.dart';

/// Particle shapes for different skin modes
enum ParticleShape { heart, star, diamond, sparkle }

/// Ritual theme configuration for each skin mode
class RitualThemeConfig {
  final List<Color> backgroundGradient;
  final Color orbGlowColor;
  final Color orbFillColor;
  final ParticleShape particleShape;
  final Color particleColor;
  final TextStyle quoteTextStyle;
  final TextStyle countdownTextStyle;

  const RitualThemeConfig({
    required this.backgroundGradient,
    required this.orbGlowColor,
    required this.orbFillColor,
    required this.particleShape,
    required this.particleColor,
    required this.quoteTextStyle,
    required this.countdownTextStyle,
  });

  factory RitualThemeConfig.fromSkin(AppSkin skin) {
    switch (skin.mode) {
      case SkinMode.healing:
        return RitualThemeConfig(
          backgroundGradient: const [
            Color(0xFFFFF5EE), // Seashell
            Color(0xFFFFE4E1), // Misty Rose
          ],
          orbGlowColor: const Color(0xFFFFB7B2), // Blush Pink
          orbFillColor: skin.secondaryAccent, // Dusty Rose
          particleShape: ParticleShape.heart,
          particleColor: const Color(0xFFFFB7B2),
          quoteTextStyle: GoogleFonts.maShanZheng(
            fontSize: 16,
            color: skin.textPrimary.withOpacity(0.7),
          ),
          countdownTextStyle: skin.monoFont.copyWith(fontSize: 48),
        );

      case SkinMode.vintage:
        return RitualThemeConfig(
          backgroundGradient: const [
            Color(0xFF1A1C1E),
            Color(0xFF2C2F33),
          ],
          orbGlowColor: skin.primaryAccent, // Gold
          orbFillColor: skin.secondaryAccent, // Rust
          particleShape: ParticleShape.star,
          particleColor: skin.primaryAccent,
          quoteTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            color: skin.textPrimary.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
          countdownTextStyle: skin.monoFont.copyWith(fontSize: 48),
        );

      case SkinMode.cyber:
        return RitualThemeConfig(
          backgroundGradient: const [
            Color(0xFF050505),
            Color(0xFF1A0033),
          ],
          orbGlowColor: const Color(0xFF00F0FF), // Glitch Blue
          orbFillColor: skin.primaryAccent, // Acid Green
          particleShape: ParticleShape.diamond,
          particleColor: const Color(0xFF00F0FF),
          quoteTextStyle: GoogleFonts.vt323(
            fontSize: 18,
            color: skin.textPrimary.withOpacity(0.8),
            letterSpacing: 2.0,
          ),
          countdownTextStyle: skin.monoFont.copyWith(fontSize: 56),
        );

      case SkinMode.wish:
        return RitualThemeConfig(
          backgroundGradient: const [
            Color(0xFFD4F1F4),
            Color(0xFFB8E2E8),
          ],
          orbGlowColor: const Color(0xFFFCE38A), // Warm Gold
          orbFillColor: const Color(0xFF2B5876), // Deep Blue
          particleShape: ParticleShape.sparkle,
          particleColor: const Color(0xFFFCE38A),
          quoteTextStyle: GoogleFonts.alegreya(
            fontSize: 16,
            color: skin.textPrimary.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
          countdownTextStyle: skin.monoFont.copyWith(fontSize: 48),
        );
    }
  }
}
