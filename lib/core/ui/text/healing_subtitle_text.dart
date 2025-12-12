import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'text_break_balancer.dart';

/// Healing theme subtitle text widget with balanced multi-line wrapping.
///
/// This widget implements the Healing theme's soft, hand-written aesthetic
/// for subtitle text. It uses TextBreakBalancer to ensure natural multi-line
/// wrapping while preventing orphan characters (lines with too few characters).
///
/// Key features:
/// - Natural multi-line wrapping with minimum 4 chars per line
/// - Fixed font size (24px, no scaling)
/// - Line height of 1.4 for comfortable reading
/// - Maintains soft, journal-style aesthetic
class HealingSubTitleText extends StatelessWidget {
  /// The subtitle text to display
  final String text;

  /// The color to use for the text
  final Color textColor;

  const HealingSubTitleText({
    super.key,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = GoogleFonts.maShanZheng(
          fontSize: 24,
          color: textColor,
          height: 1.4,
        );

        // Use TextBreakBalancer to prevent orphan characters
        // Ensures each line has at least 4 characters
        final processedText = TextBreakBalancer.balance(
          text,
          constraints.maxWidth,
          style,
          4, // minCharsPerLine
        );

        return Text(
          processedText,
          textAlign: TextAlign.center,
          style: style,
        );
      },
    );
  }
}
