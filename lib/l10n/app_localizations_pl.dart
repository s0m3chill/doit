// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'DoIt';

  @override
  String get remindersTab => 'Przypomnienia';

  @override
  String get timersTab => 'Minutniki';

  @override
  String get settingsTab => 'Ustawienia';

  @override
  String get remindersTitle => 'Przypomnienia';

  @override
  String get timersTitle => 'Minutniki';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get searchReminders => 'Szukaj przypomnień…';

  @override
  String get activeTab => 'Aktywne';

  @override
  String get completedTab => 'Ukończone';

  @override
  String get noRemindersYet => 'Brak przypomnień.\nDotknij + aby dodać.';

  @override
  String get noCompletedReminders => 'Brak ukończonych przypomnień';

  @override
  String get noTimersYet => 'Brak minutników.\nDotknij + aby utworzyć.';

  @override
  String get newReminder => 'Nowe przypomnienie';

  @override
  String get editReminder => 'Edytuj przypomnienie';

  @override
  String get titleHint => 'Co musisz zrobić?';

  @override
  String get add => 'Dodaj';

  @override
  String get save => 'Zapisz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get complete => 'Ukończ';

  @override
  String get quickSet => 'Szybki wybór';

  @override
  String get dueDate => 'Termin';

  @override
  String get tapToPickDate => 'Dotknij aby wybrać datę i godzinę';

  @override
  String setTo(String date) {
    return 'Ustaw na: $date';
  }

  @override
  String get repeat => 'Powtarzanie';

  @override
  String get repeatNone => 'Brak';

  @override
  String get repeatDaily => 'Codziennie';

  @override
  String get repeatWeekly => 'Co tydzień';

  @override
  String get repeatMonthly => 'Co miesiąc';

  @override
  String get repeatYearly => 'Co rok';

  @override
  String get autoSnooze => 'Autodrzemka';

  @override
  String get autoSnoozeDisabled => 'Wyłączona';

  @override
  String autoSnoozeDescription(int minutes) {
    return 'Przypomina co $minutes min gdy zaległe';
  }

  @override
  String get interval => 'Interwał';

  @override
  String get maxNags => 'Maks. powtórzeń';

  @override
  String get indefinite => '∞';

  @override
  String get overdue => 'Zaległe';

  @override
  String get today => 'Dzisiaj';

  @override
  String get tomorrow => 'Jutro';

  @override
  String get yesterday => 'Wczoraj';

  @override
  String get reminderCreated => 'Przypomnienie utworzone';

  @override
  String get reminderUpdated => 'Przypomnienie zaktualizowane';

  @override
  String get reminderDeleted => 'Przypomnienie usunięte';

  @override
  String get reminderCompleted => 'Przypomnienie ukończone';

  @override
  String snoozedFor(int minutes) {
    return 'Odłożono na $minutes minut';
  }

  @override
  String get newTimer => 'Nowy minutnik';

  @override
  String get timerLabel => 'Nazwa minutnika';

  @override
  String get duration => 'Czas trwania';

  @override
  String get timerCreated => 'Minutnik utworzony';

  @override
  String get timerDeleted => 'Minutnik usunięty';

  @override
  String get timerDone => 'Minutnik zakończony!';

  @override
  String get appearance => 'Wygląd';

  @override
  String get theme => 'Motyw';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get accentColor => 'Kolor akcentu';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get sound => 'Dźwięk';

  @override
  String get soundDescription => 'Odtwarzaj dźwięk przy powiadomieniu';

  @override
  String get soundDefault => 'Domyślny';

  @override
  String get soundGentle => 'Łagodny';

  @override
  String get soundUrgent => 'Pilny';

  @override
  String get soundSilent => 'Cichy';

  @override
  String get vibration => 'Wibracja';

  @override
  String get vibrationDescription => 'Reakcja dotykowa przy akcjach';

  @override
  String get hapticLight => 'Lekka';

  @override
  String get hapticMedium => 'Średnia';

  @override
  String get hapticHeavy => 'Mocna';

  @override
  String get hapticOff => 'Wył.';

  @override
  String get about => 'O aplikacji';

  @override
  String version(String version) {
    return 'Wersja $version';
  }

  @override
  String get quickTime30min => '30 min';

  @override
  String get quickTime1hour => '1 godz';

  @override
  String get quickTime3hours => '3 godz';

  @override
  String get quickTimeTonight => 'Wieczorem';

  @override
  String get quickTimeTomorrow => 'Jutro';

  @override
  String get quickTime2days => '2 dni';

  @override
  String get quickTime9am => '9:00';

  @override
  String get quickTime12pm => '12:00';

  @override
  String get quickTime3pm => '15:00';

  @override
  String get quickTime6pm => '18:00';

  @override
  String get quickTimeMonday => 'Poniedziałek';

  @override
  String get quickTimeNextWeek => 'Nast. tydzień';

  @override
  String get naturalDateHint => 'np. \"jutro o 15:00\", \"za 2 godziny\"';

  @override
  String overdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zaległych',
      few: '$count zaległe',
      one: '1 zaległe',
    );
    return '$_temp0';
  }

  @override
  String get language => 'Język';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get languagePolish => 'Polski';
}
