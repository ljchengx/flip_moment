import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flip Moment'**
  String get appTitle;

  /// No description provided for @tapToDecide.
  ///
  /// In en, this message translates to:
  /// **'TAP TO DECIDE'**
  String get tapToDecide;

  /// No description provided for @pokeGently.
  ///
  /// In en, this message translates to:
  /// **'Poke me gently ~'**
  String get pokeGently;

  /// No description provided for @resultYes.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get resultYes;

  /// No description provided for @resultNo.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get resultNo;

  /// No description provided for @recordSaved.
  ///
  /// In en, this message translates to:
  /// **'Record saved'**
  String get recordSaved;

  /// No description provided for @flipMomentLogo.
  ///
  /// In en, this message translates to:
  /// **'FLIP MOMENT'**
  String get flipMomentLogo;

  /// No description provided for @resultCardTitle.
  ///
  /// In en, this message translates to:
  /// **'The Answer'**
  String get resultCardTitle;

  /// No description provided for @resultCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trust your intuition.'**
  String get resultCardSubtitle;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get shareButton;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get closeButton;

  /// No description provided for @scanForLuck.
  ///
  /// In en, this message translates to:
  /// **'SCAN FOR LUCK'**
  String get scanForLuck;

  /// No description provided for @luckyIndex.
  ///
  /// In en, this message translates to:
  /// **'LUCK INDEX'**
  String get luckyIndex;

  /// No description provided for @luckyColor.
  ///
  /// In en, this message translates to:
  /// **'LUCKY COLOR'**
  String get luckyColor;

  /// No description provided for @vinYes1.
  ///
  /// In en, this message translates to:
  /// **'UNDOUBTEDLY'**
  String get vinYes1;

  /// No description provided for @vinYesSub1.
  ///
  /// In en, this message translates to:
  /// **'Destiny has spoken.'**
  String get vinYesSub1;

  /// No description provided for @vinYes2.
  ///
  /// In en, this message translates to:
  /// **'PROCEED'**
  String get vinYes2;

  /// No description provided for @vinYesSub2.
  ///
  /// In en, this message translates to:
  /// **'Intuition is your guide.'**
  String get vinYesSub2;

  /// No description provided for @vinYes3.
  ///
  /// In en, this message translates to:
  /// **'CERTAINLY'**
  String get vinYes3;

  /// No description provided for @vinYesSub3.
  ///
  /// In en, this message translates to:
  /// **'As natural as sunrise.'**
  String get vinYesSub3;

  /// No description provided for @vinNo1.
  ///
  /// In en, this message translates to:
  /// **'PATIENCE'**
  String get vinNo1;

  /// No description provided for @vinNoSub1.
  ///
  /// In en, this message translates to:
  /// **'Time holds better answers.'**
  String get vinNoSub1;

  /// No description provided for @vinNo2.
  ///
  /// In en, this message translates to:
  /// **'HALT'**
  String get vinNo2;

  /// No description provided for @vinNoSub2.
  ///
  /// In en, this message translates to:
  /// **'A closed door is protection.'**
  String get vinNoSub2;

  /// No description provided for @vinNo3.
  ///
  /// In en, this message translates to:
  /// **'NOT YET'**
  String get vinNo3;

  /// No description provided for @vinNoSub3.
  ///
  /// In en, this message translates to:
  /// **'Waiting is wisdom.'**
  String get vinNoSub3;

  /// No description provided for @heaYes1.
  ///
  /// In en, this message translates to:
  /// **'YAY!'**
  String get heaYes1;

  /// No description provided for @heaYesSub1.
  ///
  /// In en, this message translates to:
  /// **'Do what makes you happy!'**
  String get heaYesSub1;

  /// No description provided for @heaYes2.
  ///
  /// In en, this message translates to:
  /// **'GO FOR IT'**
  String get heaYes2;

  /// No description provided for @heaYesSub2.
  ///
  /// In en, this message translates to:
  /// **'The world loves you today.'**
  String get heaYesSub2;

  /// No description provided for @heaYes3.
  ///
  /// In en, this message translates to:
  /// **'SURE THING'**
  String get heaYes3;

  /// No description provided for @heaYesSub3.
  ///
  /// In en, this message translates to:
  /// **'Trust yourself, you got this.'**
  String get heaYesSub3;

  /// No description provided for @heaNo1.
  ///
  /// In en, this message translates to:
  /// **'TAKE A NAP'**
  String get heaNo1;

  /// No description provided for @heaNoSub1.
  ///
  /// In en, this message translates to:
  /// **'Hugs! No need to force it.'**
  String get heaNoSub1;

  /// No description provided for @heaNo2.
  ///
  /// In en, this message translates to:
  /// **'SLOW DOWN'**
  String get heaNo2;

  /// No description provided for @heaNoSub2.
  ///
  /// In en, this message translates to:
  /// **'It\'s not a big deal anyway.'**
  String get heaNoSub2;

  /// No description provided for @heaNo3.
  ///
  /// In en, this message translates to:
  /// **'WAIT A BIT'**
  String get heaNo3;

  /// No description provided for @heaNoSub3.
  ///
  /// In en, this message translates to:
  /// **'Something better is coming.'**
  String get heaNoSub3;

  /// No description provided for @cybYes1.
  ///
  /// In en, this message translates to:
  /// **'GRANTED'**
  String get cybYes1;

  /// No description provided for @cybYesSub1.
  ///
  /// In en, this message translates to:
  /// **'ROOT_ACCESS_GRANTED'**
  String get cybYesSub1;

  /// No description provided for @cybYes2.
  ///
  /// In en, this message translates to:
  /// **'LINKED'**
  String get cybYes2;

  /// No description provided for @cybYesSub2.
  ///
  /// In en, this message translates to:
  /// **'UPLINK_ESTABLISHED'**
  String get cybYesSub2;

  /// No description provided for @cybYes3.
  ///
  /// In en, this message translates to:
  /// **'EXECUTE'**
  String get cybYes3;

  /// No description provided for @cybYesSub3.
  ///
  /// In en, this message translates to:
  /// **'EXECUTE_IMMEDIATELY'**
  String get cybYesSub3;

  /// No description provided for @cybNo1.
  ///
  /// In en, this message translates to:
  /// **'DENIED'**
  String get cybNo1;

  /// No description provided for @cybNoSub1.
  ///
  /// In en, this message translates to:
  /// **'CONNECTION_REFUSED'**
  String get cybNoSub1;

  /// No description provided for @cybNo2.
  ///
  /// In en, this message translates to:
  /// **'BLOCKED'**
  String get cybNo2;

  /// No description provided for @cybNoSub2.
  ///
  /// In en, this message translates to:
  /// **'FIREWALL_BLOCKING'**
  String get cybNoSub2;

  /// No description provided for @cybNo3.
  ///
  /// In en, this message translates to:
  /// **'NO_DATA'**
  String get cybNo3;

  /// No description provided for @cybNoSub3.
  ///
  /// In en, this message translates to:
  /// **'INSUFFICIENT_DATA'**
  String get cybNoSub3;

  /// No description provided for @wisYes1.
  ///
  /// In en, this message translates to:
  /// **'STARDUST'**
  String get wisYes1;

  /// No description provided for @wisYesSub1.
  ///
  /// In en, this message translates to:
  /// **'The galaxy winks at you.'**
  String get wisYesSub1;

  /// No description provided for @wisYes2.
  ///
  /// In en, this message translates to:
  /// **'MIRACLE'**
  String get wisYes2;

  /// No description provided for @wisYesSub2.
  ///
  /// In en, this message translates to:
  /// **'Manifestation in progress.'**
  String get wisYesSub2;

  /// No description provided for @wisYes3.
  ///
  /// In en, this message translates to:
  /// **'GRANTED'**
  String get wisYes3;

  /// No description provided for @wisYesSub3.
  ///
  /// In en, this message translates to:
  /// **'As you wish.'**
  String get wisYesSub3;

  /// No description provided for @wisNo1.
  ///
  /// In en, this message translates to:
  /// **'FOGGY'**
  String get wisNo1;

  /// No description provided for @wisNoSub1.
  ///
  /// In en, this message translates to:
  /// **'The path is not clear yet.'**
  String get wisNoSub1;

  /// No description provided for @wisNo2.
  ///
  /// In en, this message translates to:
  /// **'SILENCE'**
  String get wisNo2;

  /// No description provided for @wisNoSub2.
  ///
  /// In en, this message translates to:
  /// **'Love yourself first.'**
  String get wisNoSub2;

  /// No description provided for @wisNo3.
  ///
  /// In en, this message translates to:
  /// **'DELAY'**
  String get wisNo3;

  /// No description provided for @wisNoSub3.
  ///
  /// In en, this message translates to:
  /// **'Wait for the bloom.'**
  String get wisNoSub3;

  /// No description provided for @meTitle.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTitle;

  /// No description provided for @identityTitle.
  ///
  /// In en, this message translates to:
  /// **'Lv.5 Fate Navigator'**
  String get identityTitle;

  /// No description provided for @identityDesc.
  ///
  /// In en, this message translates to:
  /// **'Collecting moments, one flip at a time.'**
  String get identityDesc;

  /// No description provided for @statsFlips.
  ///
  /// In en, this message translates to:
  /// **'Flips'**
  String get statsFlips;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statsStreak;

  /// No description provided for @statsHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get statsHappy;

  /// No description provided for @sectionFeatures.
  ///
  /// In en, this message translates to:
  /// **'CORE FEATURES'**
  String get sectionFeatures;

  /// No description provided for @featureThemes.
  ///
  /// In en, this message translates to:
  /// **'Theme Skins'**
  String get featureThemes;

  /// No description provided for @featureLog.
  ///
  /// In en, this message translates to:
  /// **'Decision Log'**
  String get featureLog;

  /// No description provided for @featureLogSub.
  ///
  /// In en, this message translates to:
  /// **'Review your moments'**
  String get featureLogSub;

  /// No description provided for @featureWidgets.
  ///
  /// In en, this message translates to:
  /// **'Home Widgets'**
  String get featureWidgets;

  /// No description provided for @featureWidgetsSub.
  ///
  /// In en, this message translates to:
  /// **'Setup desktop shortcuts'**
  String get featureWidgetsSub;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get sectionGeneral;

  /// No description provided for @settingGeneral.
  ///
  /// In en, this message translates to:
  /// **'Settings & More'**
  String get settingGeneral;

  /// No description provided for @settingHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & Feedback'**
  String get settingHelp;

  /// No description provided for @settingAbout.
  ///
  /// In en, this message translates to:
  /// **'About Flip Moment'**
  String get settingAbout;

  /// No description provided for @settingSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingSoundEffects;

  /// No description provided for @settingHapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get settingHapticFeedback;

  /// No description provided for @footerVersion.
  ///
  /// In en, this message translates to:
  /// **'Flip Moment v1.0.0 (Build 108)'**
  String get footerVersion;

  /// No description provided for @themeVintage.
  ///
  /// In en, this message translates to:
  /// **'Vintage'**
  String get themeVintage;

  /// No description provided for @themeHealing.
  ///
  /// In en, this message translates to:
  /// **'Healing'**
  String get themeHealing;

  /// No description provided for @themeCyber.
  ///
  /// In en, this message translates to:
  /// **'Cyber'**
  String get themeCyber;

  /// No description provided for @themeWish.
  ///
  /// In en, this message translates to:
  /// **'Wish'**
  String get themeWish;

  /// No description provided for @skinDescVintage.
  ///
  /// In en, this message translates to:
  /// **'Classic mechanics & aesthetics.'**
  String get skinDescVintage;

  /// No description provided for @skinDescHealing.
  ///
  /// In en, this message translates to:
  /// **'Soft, cute, and stress-free.'**
  String get skinDescHealing;

  /// No description provided for @skinDescCyber.
  ///
  /// In en, this message translates to:
  /// **'Decode your destiny from the future.'**
  String get skinDescCyber;

  /// No description provided for @skinDescWish.
  ///
  /// In en, this message translates to:
  /// **'Make a wish into the galaxy.'**
  String get skinDescWish;

  /// No description provided for @galleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Gallery'**
  String get galleryTitle;

  /// No description provided for @statusApplied.
  ///
  /// In en, this message translates to:
  /// **'CURRENTLY APPLIED'**
  String get statusApplied;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'APPLY THEME'**
  String get actionApply;

  /// No description provided for @actionUnlock.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK PREMIUM'**
  String get actionUnlock;

  /// No description provided for @actionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get actionComingSoon;

  /// No description provided for @vipBadge.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get vipBadge;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Decision Log'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No moments collected yet'**
  String get historyEmpty;

  /// No description provided for @historyEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Your decision history will appear here'**
  String get historyEmptyDesc;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @levelUpTitle.
  ///
  /// In en, this message translates to:
  /// **'LEVEL UP!'**
  String get levelUpTitle;

  /// No description provided for @awesomeButton.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get awesomeButton;

  /// No description provided for @expProgress.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get expProgress;

  /// No description provided for @titleDrifter.
  ///
  /// In en, this message translates to:
  /// **'Drifter'**
  String get titleDrifter;

  /// No description provided for @titleLightSeeker.
  ///
  /// In en, this message translates to:
  /// **'Light Seeker'**
  String get titleLightSeeker;

  /// No description provided for @titleMomentCollector.
  ///
  /// In en, this message translates to:
  /// **'Moment Collector'**
  String get titleMomentCollector;

  /// No description provided for @titleStarReader.
  ///
  /// In en, this message translates to:
  /// **'Star Reader'**
  String get titleStarReader;

  /// No description provided for @titleFateArchitect.
  ///
  /// In en, this message translates to:
  /// **'Fate Architect'**
  String get titleFateArchitect;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
