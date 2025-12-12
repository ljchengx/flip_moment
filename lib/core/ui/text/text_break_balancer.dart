import 'package:flutter/material.dart';

/// Core algorithm for preventing orphan characters and balancing line breaks.
///
/// This class provides intelligent text wrapping that ensures no line contains
/// fewer than a specified minimum number of characters. It analyzes text layout
/// using TextPainter and redistributes content across lines when orphans are detected.
class TextBreakBalancer {
  /// Balances line breaks in text to prevent orphan characters.
  ///
  /// [text] The original text to process
  /// [maxWidth] Maximum width available for text layout
  /// [style] TextStyle to use for measurements
  /// [minCharsPerLine] Minimum number of characters allowed per line
  ///
  /// Returns the processed text with manual line breaks (\n) inserted at
  /// optimal positions to prevent orphans.
  static String balance(
    String text,
    double maxWidth,
    TextStyle style,
    int minCharsPerLine,
  ) {
    // Early return for very short text
    if (text.length < minCharsPerLine) {
      return text;
    }

    try {
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: null,
      );

      // 1. Measure single-line width
      textPainter.layout(maxWidth: double.infinity);
      final singleLineWidth = textPainter.width;

      // 2. If single line fits, return original text
      if (singleLineWidth <= maxWidth) {
        return text;
      }

      // 3. Calculate line metrics with wrapping
      textPainter.layout(maxWidth: maxWidth);
      final lineMetrics = textPainter.computeLineMetrics();

      // 4. Check if last line has orphan characters
      if (lineMetrics.isNotEmpty) {
        final lastLineStart = _getLastLineStartIndex(text, textPainter, maxWidth, style);
        final lastLineChars = text.length - lastLineStart;

        // 5. If last line has too few characters, redistribute
        if (lastLineChars < minCharsPerLine && lastLineChars > 0) {
          return _redistributeLines(text, maxWidth, style, minCharsPerLine);
        }
      }

      return text;
    } catch (e) {
      // Fallback: return original text if measurement fails
      return text;
    }
  }

  /// Gets the starting index of the last line in wrapped text.
  static int _getLastLineStartIndex(
    String text,
    TextPainter textPainter,
    double maxWidth,
    TextStyle style,
  ) {
    final lineMetrics = textPainter.computeLineMetrics();
    if (lineMetrics.isEmpty) return 0;

    // Binary search to find where the last line starts
    int left = 0;
    int right = text.length;

    while (left < right) {
      final mid = (left + right) ~/ 2;
      final testPainter = TextPainter(
        text: TextSpan(text: text.substring(0, mid), style: style),
        textDirection: TextDirection.ltr,
        maxLines: null,
      );
      testPainter.layout(maxWidth: maxWidth);
      final testLines = testPainter.computeLineMetrics();

      if (testLines.length < lineMetrics.length) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }

    return left;
  }

  /// Redistributes text across lines to ensure minimum characters per line.
  static String _redistributeLines(
    String text,
    double maxWidth,
    TextStyle style,
    int minChars,
  ) {
    final totalChars = text.length;

    // Calculate how many lines we need
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    final lineCount = textPainter.computeLineMetrics().length;

    if (lineCount <= 1) return text;

    // Calculate ideal characters per line for balanced distribution
    final idealCharsPerLine = (totalChars / lineCount).ceil();

    // Find optimal break points
    final breakPoints = <int>[];
    int currentPos = 0;

    for (int i = 1; i < lineCount; i++) {
      int targetPos = currentPos + idealCharsPerLine;
      targetPos = targetPos.clamp(currentPos + minChars, totalChars - minChars);

      // Find best break point near target position
      int bestBreak = _findBestBreakPoint(text, targetPos, minChars, totalChars);

      // Ensure we don't create duplicate break points
      if (bestBreak > currentPos && bestBreak < totalChars) {
        breakPoints.add(bestBreak);
        currentPos = bestBreak;
      }
    }

    // Insert line breaks at calculated positions
    if (breakPoints.isEmpty) return text;

    final buffer = StringBuffer();
    int lastBreak = 0;
    for (final bp in breakPoints) {
      if (bp > lastBreak && bp <= text.length) {
        buffer.write(text.substring(lastBreak, bp));
        buffer.write('\n');
        lastBreak = bp;
      }
    }
    buffer.write(text.substring(lastBreak));

    return buffer.toString();
  }

  /// Finds the best break point near a target position.
  ///
  /// Prefers breaking at punctuation marks within ±3 characters of target.
  /// Falls back to target position if no punctuation found.
  static int _findBestBreakPoint(String text, int target, int minChars, int totalChars) {
    // Punctuation marks where line breaks are preferred
    // Includes both Western and CJK punctuation
    const punctuation = '，。！？、；：""''）】》.,!?;:"\')]}>';

    // Search within ±3 characters of target for punctuation
    for (int offset = 0; offset <= 3; offset++) {
      // Check target + offset
      final forwardPos = target + offset;
      if (forwardPos < totalChars - minChars && forwardPos < text.length) {
        if (punctuation.contains(text[forwardPos])) {
          return forwardPos + 1; // Break after punctuation
        }
      }

      // Check target - offset
      if (offset > 0) {
        final backwardPos = target - offset;
        if (backwardPos > minChars && backwardPos < text.length) {
          if (punctuation.contains(text[backwardPos])) {
            return backwardPos + 1; // Break after punctuation
          }
        }
      }
    }

    // No punctuation found, break at target position
    return target.clamp(minChars, totalChars - minChars);
  }
}
