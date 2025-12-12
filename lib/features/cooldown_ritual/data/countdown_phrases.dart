import '../../../l10n/app_localizations.dart';

/// Helper class for accessing localized countdown phrases
class CountdownPhrases {
  /// Get gathering phrases (for remaining time > 45 seconds)
  static List<String> getGatheringPhrases(AppLocalizations loc) => [
        loc.cooldownGatheringPhrase1,
        loc.cooldownGatheringPhrase2,
        loc.cooldownGatheringPhrase3,
      ];

  /// Get almost ready phrases (for remaining time 20-45 seconds)
  static List<String> getAlmostReadyPhrases(AppLocalizations loc) => [
        loc.cooldownAlmostReadyPhrase1,
        loc.cooldownAlmostReadyPhrase2,
        loc.cooldownAlmostReadyPhrase3,
      ];

  /// Get wisdom quotes for rotation
  static List<String> getWisdomQuotes(AppLocalizations loc) => [
        loc.wisdomQuote1,
        loc.wisdomQuote2,
        loc.wisdomQuote3,
        loc.wisdomQuote4,
        loc.wisdomQuote5,
        loc.wisdomQuote6,
        loc.wisdomQuote7,
        loc.wisdomQuote8,
      ];
}
