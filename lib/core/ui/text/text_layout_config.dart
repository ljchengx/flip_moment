/// Configuration model for theme-specific text layout parameters.
///
/// This class defines the styling and behavior parameters for text layout
/// in different themes (Vintage and Healing). Each theme has distinct
/// requirements for font sizing, line breaking, and character distribution.
class TextLayoutConfig {
  /// Base font size for the text
  final double fontSize;

  /// Minimum font size when scaling is allowed
  final double minFontSize;

  /// Maximum font size when scaling is allowed
  final double maxFontSize;

  /// Letter spacing between characters
  final double letterSpacing;

  /// Line height multiplier (e.g., 1.4 means 140% of font size)
  final double lineHeight;

  /// Minimum number of characters allowed per line to prevent orphans
  final int minCharsPerLine;

  /// Whether the text is allowed to scale down to fit
  final bool allowScaling;

  const TextLayoutConfig({
    required this.fontSize,
    required this.minFontSize,
    required this.maxFontSize,
    required this.letterSpacing,
    required this.lineHeight,
    required this.minCharsPerLine,
    required this.allowScaling,
  });

  /// Configuration for Vintage theme
  ///
  /// Vintage theme emphasizes:
  /// - Compact, magazine-style layout
  /// - Single-line with scaling (20px → 14px minimum)
  /// - Wider letter spacing for classic feel
  /// - Minimum 2 characters per line
  static const vintage = TextLayoutConfig(
    fontSize: 20.0,
    minFontSize: 14.0,
    maxFontSize: 20.0,
    letterSpacing: 1.2,
    lineHeight: 1.3,
    minCharsPerLine: 2,
    allowScaling: true,
  );

  /// Configuration for Healing theme
  ///
  /// Healing theme emphasizes:
  /// - Soft, hand-written aesthetic
  /// - Natural multi-line wrapping without scaling
  /// - Fixed font size for consistency
  /// - Minimum 4 characters per line for balanced appearance
  static const healing = TextLayoutConfig(
    fontSize: 24.0,
    minFontSize: 20.0,
    maxFontSize: 24.0,
    letterSpacing: 0.5,
    lineHeight: 1.4,
    minCharsPerLine: 4,
    allowScaling: false,
  );
}
