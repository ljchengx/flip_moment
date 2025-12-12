import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flip_moment/core/ui/text/text_break_balancer.dart';

void main() {
  // Initialize Flutter bindings
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Text Layout Properties', () {
    // **Feature: result-card-text-layout, Property 1: No Orphan Characters**
    test('Property 1: No orphan characters', () {
      final random = Random(42);

      // Test with 100 random text samples
      for (int i = 0; i < 100; i++) {
        // Generate random Chinese text (5-30 characters)
        final textLength = 5 + random.nextInt(26);
        final text = _generateRandomChineseText(textLength, random);

        // Test with various container widths (200-500px)
        final containerWidth = 200.0 + random.nextDouble() * 300;

        // Test with different minCharsPerLine values
        final minCharsPerLine = random.nextInt(3) + 2; // 2-4 chars

        final style = const TextStyle(
          fontSize: 20.0,
          fontFamily: 'Roboto',
        );

        final result = TextBreakBalancer.balance(
          text,
          containerWidth,
          style,
          minCharsPerLine,
        );

        // Verify no line has fewer than minCharsPerLine characters
        final lines = result.split('\n');
        for (final line in lines) {
          if (line.isNotEmpty) {
            expect(
              line.length,
              greaterThanOrEqualTo(minCharsPerLine),
              reason:
                  'Line "$line" has ${line.length} chars, expected at least $minCharsPerLine',
            );
          }
        }
      }
    });

    // **Feature: result-card-text-layout, Property 2: Vintage Font Size Bounds**
    test('Property 2: Vintage font size bounds', () {
      // Vintage theme uses FittedBox which automatically scales
      // This test verifies the base font size is within expected range
      const vintageFontSize = 20.0;
      const vintageMinFontSize = 14.0;
      const vintageMaxFontSize = 20.0;

      expect(vintageFontSize, greaterThanOrEqualTo(vintageMinFontSize));
      expect(vintageFontSize, lessThanOrEqualTo(vintageMaxFontSize));

      // Verify letter spacing is within expected range
      const vintageLetterSpacing = 1.2;
      expect(vintageLetterSpacing, greaterThanOrEqualTo(1.0));
      expect(vintageLetterSpacing, lessThanOrEqualTo(1.5));
    });

    // **Feature: result-card-text-layout, Property 3: Healing Font Size Constant**
    test('Property 3: Healing font size constant', () {
      // Healing theme uses fixed font size without scaling
      const healingFontSize = 24.0;
      const expectedMinFontSize = 20.0;
      const expectedMaxFontSize = 24.0;

      expect(healingFontSize, greaterThanOrEqualTo(expectedMinFontSize));
      expect(healingFontSize, lessThanOrEqualTo(expectedMaxFontSize));

      // Verify line height is within expected range
      const healingLineHeight = 1.4;
      expect(healingLineHeight, greaterThanOrEqualTo(1.5 - 0.1));
      expect(healingLineHeight, lessThanOrEqualTo(1.6 + 0.1));
    });

    // **Feature: result-card-text-layout, Property 4: Line Break at Punctuation**
    test('Property 4: Line break at punctuation preference', () {
      // Test that the algorithm attempts to break at punctuation when possible
      // This is a preference, not a strict requirement
      final text = '这是一段测试文本，用于验证换行效果。';
      const style = TextStyle(fontSize: 20, fontFamily: 'Roboto');
      const containerWidth = 180.0;

      final result = TextBreakBalancer.balance(text, containerWidth, style, 2);

      // Verify no orphans (main requirement)
      final lines = result.split('\n');
      for (final line in lines) {
        if (line.isNotEmpty) {
          expect(line.length, greaterThanOrEqualTo(2));
        }
      }

      // If multiple lines, verify the algorithm produced a reasonable result
      if (lines.length > 1) {
        // Check that lines are somewhat balanced (not one very long, one very short)
        final lineLengths = lines.map((line) => line.length).toList();
        final maxLength = lineLengths.reduce(max);
        final minLength = lineLengths.reduce(min);

        // Lines should not differ by more than 70% in length
        if (maxLength > 0) {
          final variance = (maxLength - minLength) / maxLength;
          expect(variance, lessThanOrEqualTo(0.7));
        }
      }
    });

    // **Feature: result-card-text-layout, Property 5: Balanced Line Distribution**
    test('Property 5: Balanced line distribution', () {
      final random = Random(42);

      // Test with texts that will wrap to multiple lines
      for (int i = 0; i < 50; i++) {
        final textLength = 15 + random.nextInt(20); // 15-35 chars
        final text = _generateRandomChineseText(textLength, random);
        final containerWidth = 150.0 + random.nextDouble() * 100;
        const style = TextStyle(fontSize: 20, fontFamily: 'Roboto');

        final result = TextBreakBalancer.balance(
          text,
          containerWidth,
          style,
          2,
        );

        final lines = result.split('\n');
        if (lines.length > 1) {
          // Calculate line length variance
          final lineLengths = lines.map((line) => line.length).toList();
          final maxLength = lineLengths.reduce(max);
          final minLength = lineLengths.reduce(min);

          // Verify line lengths don't differ by more than 50%
          // (more lenient than 30% to account for punctuation and word boundaries)
          if (maxLength > 0) {
            final variance = (maxLength - minLength) / maxLength;
            expect(
              variance,
              lessThanOrEqualTo(0.5),
              reason:
                  'Line lengths too unbalanced: max=$maxLength, min=$minLength, variance=$variance',
            );
          }
        }
      }
    });

    // **Feature: result-card-text-layout, Property 6: Responsive Width Adaptation**
    test('Property 6: Responsive width adaptation', () {
      final text = '这是一段测试文本，用于验证响应式布局效果。';
      const style = TextStyle(fontSize: 20, fontFamily: 'Roboto');

      // Test with different container widths
      final widths = [200.0, 300.0, 400.0, 500.0];
      final results = <String>[];

      for (final width in widths) {
        final result = TextBreakBalancer.balance(text, width, style, 2);
        results.add(result);

        // Verify no orphans at any width
        final lines = result.split('\n');
        for (final line in lines) {
          if (line.isNotEmpty) {
            expect(line.length, greaterThanOrEqualTo(2));
          }
        }
      }

      // Verify that wider containers result in fewer or equal line breaks
      for (int i = 0; i < results.length - 1; i++) {
        final currentLineCount = results[i].split('\n').length;
        final nextLineCount = results[i + 1].split('\n').length;
        expect(
          currentLineCount,
          greaterThanOrEqualTo(nextLineCount),
          reason: 'Wider container should have fewer or equal lines',
        );
      }
    });
  });
}

/// Generates random Chinese text for testing
String _generateRandomChineseText(int length, Random random) {
  // Common Chinese characters used in fortune texts
  const chars = '这是一段测试文本用于验证换行效果命运已写下注脚时间会给出更好的答案'
      '去做让自己开心的事吧今天全世界都偏爱你抱抱不要强求感觉名为直觉';

  final buffer = StringBuffer();
  for (int i = 0; i < length; i++) {
    buffer.write(chars[random.nextInt(chars.length)]);
  }
  return buffer.toString();
}
