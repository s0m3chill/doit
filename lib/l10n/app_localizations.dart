import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_uk.dart';

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
    Locale('pl'),
    Locale('uk'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DoIt'**
  String get appName;

  /// No description provided for @remindersTab.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTab;

  /// No description provided for @timersTab.
  ///
  /// In en, this message translates to:
  /// **'Timers'**
  String get timersTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @timersTitle.
  ///
  /// In en, this message translates to:
  /// **'Timers'**
  String get timersTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @searchReminders.
  ///
  /// In en, this message translates to:
  /// **'Search reminders…'**
  String get searchReminders;

  /// No description provided for @activeTab.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeTab;

  /// No description provided for @completedTab.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTab;

  /// No description provided for @noRemindersYet.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet.\nTap + to add one.'**
  String get noRemindersYet;

  /// No description provided for @noCompletedReminders.
  ///
  /// In en, this message translates to:
  /// **'No completed reminders'**
  String get noCompletedReminders;

  /// No description provided for @noTimersYet.
  ///
  /// In en, this message translates to:
  /// **'No timers yet.\nTap + to create one.'**
  String get noTimersYet;

  /// No description provided for @newReminder.
  ///
  /// In en, this message translates to:
  /// **'New Reminder'**
  String get newReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'What do you need to do?'**
  String get titleHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @quickSet.
  ///
  /// In en, this message translates to:
  /// **'Quick set'**
  String get quickSet;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @tapToPickDate.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick date & time'**
  String get tapToPickDate;

  /// No description provided for @setTo.
  ///
  /// In en, this message translates to:
  /// **'Set to: {date}'**
  String setTo(String date);

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get repeatNone;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeatYearly;

  /// No description provided for @autoSnooze.
  ///
  /// In en, this message translates to:
  /// **'Auto-snooze'**
  String get autoSnooze;

  /// No description provided for @autoSnoozeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get autoSnoozeDisabled;

  /// No description provided for @autoSnoozeDescription.
  ///
  /// In en, this message translates to:
  /// **'Nags every {minutes} min when overdue'**
  String autoSnoozeDescription(int minutes);

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @maxNags.
  ///
  /// In en, this message translates to:
  /// **'Max nags'**
  String get maxNags;

  /// No description provided for @indefinite.
  ///
  /// In en, this message translates to:
  /// **'∞'**
  String get indefinite;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @reminderCreated.
  ///
  /// In en, this message translates to:
  /// **'Reminder created'**
  String get reminderCreated;

  /// No description provided for @reminderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reminder updated'**
  String get reminderUpdated;

  /// No description provided for @reminderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted'**
  String get reminderDeleted;

  /// No description provided for @reminderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder completed'**
  String get reminderCompleted;

  /// No description provided for @snoozedFor.
  ///
  /// In en, this message translates to:
  /// **'Snoozed for {minutes} minutes'**
  String snoozedFor(int minutes);

  /// No description provided for @newTimer.
  ///
  /// In en, this message translates to:
  /// **'New Timer'**
  String get newTimer;

  /// No description provided for @timerLabel.
  ///
  /// In en, this message translates to:
  /// **'Timer label'**
  String get timerLabel;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @timerCreated.
  ///
  /// In en, this message translates to:
  /// **'Timer created'**
  String get timerCreated;

  /// No description provided for @timerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Timer deleted'**
  String get timerDeleted;

  /// No description provided for @timerDone.
  ///
  /// In en, this message translates to:
  /// **'Timer Done!'**
  String get timerDone;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColor;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundDescription.
  ///
  /// In en, this message translates to:
  /// **'Play sound on notification'**
  String get soundDescription;

  /// No description provided for @soundDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get soundDefault;

  /// No description provided for @soundGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get soundGentle;

  /// No description provided for @soundUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get soundUrgent;

  /// No description provided for @soundSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get soundSilent;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback on actions'**
  String get vibrationDescription;

  /// No description provided for @hapticLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get hapticLight;

  /// No description provided for @hapticMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get hapticMedium;

  /// No description provided for @hapticHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get hapticHeavy;

  /// No description provided for @hapticOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get hapticOff;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @quickTime30min.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get quickTime30min;

  /// No description provided for @quickTime1hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get quickTime1hour;

  /// No description provided for @quickTime3hours.
  ///
  /// In en, this message translates to:
  /// **'3 hours'**
  String get quickTime3hours;

  /// No description provided for @quickTimeTonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get quickTimeTonight;

  /// No description provided for @quickTimeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get quickTimeTomorrow;

  /// No description provided for @quickTime2days.
  ///
  /// In en, this message translates to:
  /// **'2 days'**
  String get quickTime2days;

  /// No description provided for @quickTime9am.
  ///
  /// In en, this message translates to:
  /// **'9 AM'**
  String get quickTime9am;

  /// No description provided for @quickTime12pm.
  ///
  /// In en, this message translates to:
  /// **'12 PM'**
  String get quickTime12pm;

  /// No description provided for @quickTime3pm.
  ///
  /// In en, this message translates to:
  /// **'3 PM'**
  String get quickTime3pm;

  /// No description provided for @quickTime6pm.
  ///
  /// In en, this message translates to:
  /// **'6 PM'**
  String get quickTime6pm;

  /// No description provided for @quickTimeMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get quickTimeMonday;

  /// No description provided for @quickTimeNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get quickTimeNextWeek;

  /// No description provided for @naturalDateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"tomorrow at 3pm\", \"in 2 hours\"'**
  String get naturalDateHint;

  /// No description provided for @overdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue} other{{count} overdue}}'**
  String overdueCount(int count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get languageUkrainian;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get languagePolish;
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
      <String>['en', 'pl', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
