import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/ritual_theme_config.dart';

/// Decision counter badge showing "第 N 次决策" or "Decision #N"
class DecisionCounterBadge extends StatelessWidget {
  final int decisionCount;
  final RitualThemeConfig config;

  const DecisionCounterBadge({
    super.key,
    required this.decisionCount,
    required this.config,
  });

  /// Format decision count (Property 8)
  static String getFormattedCount(int count, AppLocalizations loc) {
    return loc.decisionCounterFormat(count + 1);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final formattedCount = getFormattedCount(decisionCount, loc);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: config.orbGlowColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: config.orbGlowColor.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        formattedCount,
        style: config.quoteTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
