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
