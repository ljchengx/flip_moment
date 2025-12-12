import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vintage theme subtitle text widget with FittedBox scaling strategy.
///
/// This widget implements the Vintage theme's compact, magazine-style layout
/// for subtitle text. It uses FittedBox to automatically scale down text
/// that's too long to fit, maintaining a single-line appearance when possible.
///
/// Key features:
/// - Single-line with scale-down (20px → 14px minimum via FittedBox)
/// - Semi-transparent background highlight (5% opacity black)
/// - Letter spacing of 1.2 for classic feel
/// - Center alignment
class VintageSubTitleText extends StatelessWidget {
  /// The subtitle text to display
  final String text;

  const VintageSubTitleText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: Colors.black.withOpacity(0.05),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 1,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.maShanZheng(
                fontSize: 20,
                color: Colors.black54,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
