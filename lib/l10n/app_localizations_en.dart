// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DoIt';

  @override
  String get remindersTab => 'Reminders';

  @override
  String get timersTab => 'Timers';

  @override
  String get settingsTab => 'Settings';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get timersTitle => 'Timers';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get searchReminders => 'Search reminders…';

  @override
  String get activeTab => 'Active';

  @override
  String get completedTab => 'Completed';

  @override
  String get noRemindersYet => 'No reminders yet.\nTap + to add one.';

  @override
  String get noCompletedReminders => 'No completed reminders';

  @override
  String get noTimersYet => 'No timers yet.\nTap + to create one.';

  @override
  String get newReminder => 'New Reminder';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get titleHint => 'What do you need to do?';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get complete => 'Complete';

  @override
  String get quickSet => 'Quick set';

  @override
  String get dueDate => 'Due date';

  @override
  String get tapToPickDate => 'Tap to pick date & time';

  @override
  String setTo(String date) {
    return 'Set to: $date';
  }

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatNone => 'None';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatYearly => 'Yearly';

  @override
  String get autoSnooze => 'Auto-snooze';

  @override
  String get autoSnoozeDisabled => 'Disabled';

  @override
  String autoSnoozeDescription(int minutes) {
    return 'Nags every $minutes min when overdue';
  }

  @override
  String get interval => 'Interval';

  @override
  String get maxNags => 'Max nags';

  @override
  String get indefinite => '∞';

  @override
  String get overdue => 'Overdue';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get reminderCreated => 'Reminder created';

  @override
  String get reminderUpdated => 'Reminder updated';

  @override
  String get reminderDeleted => 'Reminder deleted';

  @override
  String get reminderCompleted => 'Reminder completed';

  @override
  String snoozedFor(int minutes) {
    return 'Snoozed for $minutes minutes';
  }

  @override
  String get newTimer => 'New Timer';

  @override
  String get timerLabel => 'Timer label';

  @override
  String get duration => 'Duration';

  @override
  String get timerCreated => 'Timer created';

  @override
  String get timerDeleted => 'Timer deleted';

  @override
  String get timerDone => 'Timer Done!';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get accentColor => 'Accent color';

  @override
  String get notifications => 'Notifications';

  @override
  String get sound => 'Sound';

  @override
  String get soundDescription => 'Play sound on notification';

  @override
  String get soundDefault => 'Default';

  @override
  String get soundGentle => 'Gentle';

  @override
  String get soundUrgent => 'Urgent';

  @override
  String get soundSilent => 'Silent';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationDescription => 'Haptic feedback on actions';

  @override
  String get hapticLight => 'Light';

  @override
  String get hapticMedium => 'Medium';

  @override
  String get hapticHeavy => 'Heavy';

  @override
  String get hapticOff => 'Off';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get quickTime30min => '30 min';

  @override
  String get quickTime1hour => '1 hour';

  @override
  String get quickTime3hours => '3 hours';

  @override
  String get quickTimeTonight => 'Tonight';

  @override
  String get quickTimeTomorrow => 'Tomorrow';

  @override
  String get quickTime2days => '2 days';

  @override
  String get quickTime9am => '9 AM';

  @override
  String get quickTime12pm => '12 PM';

  @override
  String get quickTime3pm => '3 PM';

  @override
  String get quickTime6pm => '6 PM';

  @override
  String get quickTimeMonday => 'Monday';

  @override
  String get quickTimeNextWeek => 'Next week';

  @override
  String get naturalDateHint => 'e.g. \"tomorrow at 3pm\", \"in 2 hours\"';

  @override
  String overdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '1 overdue',
    );
    return '$_temp0';
  }

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get languagePolish => 'Polski';
}
