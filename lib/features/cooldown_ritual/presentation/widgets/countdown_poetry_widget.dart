import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/countdown_phrases.dart';
import '../../data/ritual_theme_config.dart';

/// Countdown poetry widget with threshold-based text display
class CountdownPoetryWidget extends StatelessWidget {
  final int remainingSeconds;
  final RitualThemeConfig config;

  static const int gatheringThreshold = 45;
  static const int almostReadyThreshold = 20;

  const CountdownPoetryWidget({
    super.key,
    required this.remainingSeconds,
    required this.config,
  });

  /// Get display text based on remaining time (Property 7)
  static String getDisplayText(int remainingSeconds, AppLocalizations loc) {
    if (remainingSeconds > gatheringThreshold) {
      final phrases = CountdownPhrases.getGatheringPhrases(loc);
      return phrases[math.Random(remainingSeconds).nextInt(phrases.length)];
    } else if (remainingSeconds >= almostReadyThreshold) {
      final phrases = CountdownPhrases.getAlmostReadyPhrases(loc);
      return phrases[math.Random(remainingSeconds).nextInt(phrases.length)];
    } else {
      return remainingSeconds.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final displayText = getDisplayText(remainingSeconds, loc);
    final isNumeric = remainingSeconds < almostReadyThreshold;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        displayText,
        key: ValueKey(displayText),
        style: isNumeric
            ? config.countdownTextStyle.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              )
            : config.quoteTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
