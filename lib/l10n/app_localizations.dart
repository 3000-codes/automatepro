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
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AutoMate Pro'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @clickControl.
  ///
  /// In en, this message translates to:
  /// **'Click Control'**
  String get clickControl;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @clickPosition.
  ///
  /// In en, this message translates to:
  /// **'Click Position'**
  String get clickPosition;

  /// No description provided for @xCoordinate.
  ///
  /// In en, this message translates to:
  /// **'X Coordinate'**
  String get xCoordinate;

  /// No description provided for @yCoordinate.
  ///
  /// In en, this message translates to:
  /// **'Y Coordinate'**
  String get yCoordinate;

  /// No description provided for @pickPosition.
  ///
  /// In en, this message translates to:
  /// **'Pick Position'**
  String get pickPosition;

  /// No description provided for @currentMouse.
  ///
  /// In en, this message translates to:
  /// **'Current Mouse'**
  String get currentMouse;

  /// No description provided for @currentMousePos.
  ///
  /// In en, this message translates to:
  /// **'Current Mouse Position'**
  String get currentMousePos;

  /// No description provided for @randomPosition.
  ///
  /// In en, this message translates to:
  /// **'Random Position'**
  String get randomPosition;

  /// No description provided for @randomPositionDesc.
  ///
  /// In en, this message translates to:
  /// **'Add slight randomization to click position'**
  String get randomPositionDesc;

  /// No description provided for @randomness.
  ///
  /// In en, this message translates to:
  /// **'Randomness'**
  String get randomness;

  /// No description provided for @randomnessValue.
  ///
  /// In en, this message translates to:
  /// **'Randomness: '**
  String get randomnessValue;

  /// No description provided for @px.
  ///
  /// In en, this message translates to:
  /// **'px'**
  String get px;

  /// No description provided for @clickSettings.
  ///
  /// In en, this message translates to:
  /// **'Click Settings'**
  String get clickSettings;

  /// No description provided for @clickMode.
  ///
  /// In en, this message translates to:
  /// **'Click Mode'**
  String get clickMode;

  /// No description provided for @singleClick.
  ///
  /// In en, this message translates to:
  /// **'Single Click'**
  String get singleClick;

  /// No description provided for @continuous.
  ///
  /// In en, this message translates to:
  /// **'Continuous'**
  String get continuous;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get hold;

  /// No description provided for @doubleClick.
  ///
  /// In en, this message translates to:
  /// **'Double Click'**
  String get doubleClick;

  /// No description provided for @mouseButton.
  ///
  /// In en, this message translates to:
  /// **'Mouse Button'**
  String get mouseButton;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @middle.
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get middle;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @clickSpeed.
  ///
  /// In en, this message translates to:
  /// **'Click Speed'**
  String get clickSpeed;

  /// No description provided for @cps.
  ///
  /// In en, this message translates to:
  /// **'CPS'**
  String get cps;

  /// No description provided for @cpsValue.
  ///
  /// In en, this message translates to:
  /// **'{cps} CPS'**
  String cpsValue(String cps);

  /// No description provided for @intervalType.
  ///
  /// In en, this message translates to:
  /// **'Interval Type'**
  String get intervalType;

  /// No description provided for @fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// No description provided for @random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// No description provided for @fixedIntervalMs.
  ///
  /// In en, this message translates to:
  /// **'Fixed Interval (ms)'**
  String get fixedIntervalMs;

  /// No description provided for @minMs.
  ///
  /// In en, this message translates to:
  /// **'Min (ms)'**
  String get minMs;

  /// No description provided for @maxMs.
  ///
  /// In en, this message translates to:
  /// **'Max (ms)'**
  String get maxMs;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @infiniteRepeat.
  ///
  /// In en, this message translates to:
  /// **'Infinite Repeat'**
  String get infiniteRepeat;

  /// No description provided for @repeatCount.
  ///
  /// In en, this message translates to:
  /// **'Repeat Count'**
  String get repeatCount;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @hotkeys.
  ///
  /// In en, this message translates to:
  /// **'Hotkeys'**
  String get hotkeys;

  /// No description provided for @startClicking.
  ///
  /// In en, this message translates to:
  /// **'Start Clicking'**
  String get startClicking;

  /// No description provided for @stopClicking.
  ///
  /// In en, this message translates to:
  /// **'Stop Clicking'**
  String get stopClicking;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @noPresets.
  ///
  /// In en, this message translates to:
  /// **'No presets yet'**
  String get noPresets;

  /// No description provided for @createPresetTip.
  ///
  /// In en, this message translates to:
  /// **'Create a preset to save your click configurations'**
  String get createPresetTip;

  /// No description provided for @load.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @newPreset.
  ///
  /// In en, this message translates to:
  /// **'New Preset'**
  String get newPreset;

  /// No description provided for @clickAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Click anywhere on screen to pick coordinates'**
  String get clickAnywhere;

  /// No description provided for @clickStartToBegin.
  ///
  /// In en, this message translates to:
  /// **'Click Start to begin'**
  String get clickStartToBegin;

  /// No description provided for @clicks.
  ///
  /// In en, this message translates to:
  /// **'clicks'**
  String get clicks;

  /// No description provided for @clicksValue.
  ///
  /// In en, this message translates to:
  /// **'{count} clicks'**
  String clicksValue(int count);

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @runningCps.
  ///
  /// In en, this message translates to:
  /// **'Running - {cps} CPS'**
  String runningCps(String cps);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @logsCopied.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard'**
  String get logsCopied;

  /// No description provided for @logsSaved.
  ///
  /// In en, this message translates to:
  /// **'Logs saved to: {path}'**
  String logsSaved(String path);

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @autoScroll.
  ///
  /// In en, this message translates to:
  /// **'Auto scroll'**
  String get autoScroll;

  /// No description provided for @logWindow.
  ///
  /// In en, this message translates to:
  /// **'Log Window'**
  String get logWindow;

  /// No description provided for @windowOpacity.
  ///
  /// In en, this message translates to:
  /// **'Log window opacity'**
  String get windowOpacity;

  /// No description provided for @mainWindowOpacity.
  ///
  /// In en, this message translates to:
  /// **'Main Window Opacity'**
  String get mainWindowOpacity;

  /// No description provided for @logWindowOpacity.
  ///
  /// In en, this message translates to:
  /// **'Log Window Opacity'**
  String get logWindowOpacity;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// No description provided for @clearLogsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all logs? This action cannot be undone.'**
  String get clearLogsConfirm;

  /// No description provided for @scrollToBottom.
  ///
  /// In en, this message translates to:
  /// **'Scroll to bottom'**
  String get scrollToBottom;

  /// No description provided for @pauseAutoScroll.
  ///
  /// In en, this message translates to:
  /// **'Pause auto scroll'**
  String get pauseAutoScroll;

  /// No description provided for @logLevel.
  ///
  /// In en, this message translates to:
  /// **'Log Level'**
  String get logLevel;

  /// No description provided for @timeFilter.
  ///
  /// In en, this message translates to:
  /// **'Time Filter'**
  String get timeFilter;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @last5Minutes.
  ///
  /// In en, this message translates to:
  /// **'Last 5 Minutes'**
  String get last5Minutes;

  /// No description provided for @last1Hour.
  ///
  /// In en, this message translates to:
  /// **'Last 1 Hour'**
  String get last1Hour;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipboard;

  /// No description provided for @copyMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get copyMessage;

  /// No description provided for @copyAll.
  ///
  /// In en, this message translates to:
  /// **'Copy all'**
  String get copyAll;

  /// No description provided for @timestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get timestamp;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @logSettings.
  ///
  /// In en, this message translates to:
  /// **'Log Settings'**
  String get logSettings;

  /// No description provided for @persistLogs.
  ///
  /// In en, this message translates to:
  /// **'Save logs to file'**
  String get persistLogs;

  /// No description provided for @logSavePath.
  ///
  /// In en, this message translates to:
  /// **'Save path'**
  String get logSavePath;

  /// No description provided for @autoSaveInterval.
  ///
  /// In en, this message translates to:
  /// **'Auto save interval'**
  String get autoSaveInterval;

  /// No description provided for @retentionDays.
  ///
  /// In en, this message translates to:
  /// **'Retention days'**
  String get retentionDays;

  /// No description provided for @maxLogCount.
  ///
  /// In en, this message translates to:
  /// **'Max log count'**
  String get maxLogCount;

  /// No description provided for @windowEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable log window by default'**
  String get windowEnabled;
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
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

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
