// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'DoIt';

  @override
  String get remindersTab => 'Нагадування';

  @override
  String get timersTab => 'Таймери';

  @override
  String get settingsTab => 'Налаштування';

  @override
  String get remindersTitle => 'Нагадування';

  @override
  String get timersTitle => 'Таймери';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get searchReminders => 'Пошук нагадувань…';

  @override
  String get activeTab => 'Активні';

  @override
  String get completedTab => 'Виконані';

  @override
  String get noRemindersYet => 'Нагадувань ще немає.\nНатисніть + щоб додати.';

  @override
  String get noCompletedReminders => 'Немає виконаних нагадувань';

  @override
  String get noTimersYet => 'Таймерів ще немає.\nНатисніть + щоб створити.';

  @override
  String get newReminder => 'Нове нагадування';

  @override
  String get editReminder => 'Редагувати нагадування';

  @override
  String get titleHint => 'Що потрібно зробити?';

  @override
  String get add => 'Додати';

  @override
  String get save => 'Зберегти';

  @override
  String get cancel => 'Скасувати';

  @override
  String get delete => 'Видалити';

  @override
  String get complete => 'Виконати';

  @override
  String get quickSet => 'Швидкий вибір';

  @override
  String get dueDate => 'Дата виконання';

  @override
  String get tapToPickDate => 'Натисніть для вибору дати і часу';

  @override
  String setTo(String date) {
    return 'Встановити: $date';
  }

  @override
  String get repeat => 'Повторення';

  @override
  String get repeatNone => 'Немає';

  @override
  String get repeatDaily => 'Щодня';

  @override
  String get repeatWeekly => 'Щотижня';

  @override
  String get repeatMonthly => 'Щомісяця';

  @override
  String get repeatYearly => 'Щороку';

  @override
  String get autoSnooze => 'Автоповтор';

  @override
  String get autoSnoozeDisabled => 'Вимкнено';

  @override
  String autoSnoozeDescription(int minutes) {
    return 'Нагадує кожні $minutes хв коли прострочено';
  }

  @override
  String get interval => 'Інтервал';

  @override
  String get maxNags => 'Макс. повторів';

  @override
  String get indefinite => '∞';

  @override
  String get overdue => 'Прострочено';

  @override
  String get today => 'Сьогодні';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get yesterday => 'Вчора';

  @override
  String get reminderCreated => 'Нагадування створено';

  @override
  String get reminderUpdated => 'Нагадування оновлено';

  @override
  String get reminderDeleted => 'Нагадування видалено';

  @override
  String get reminderCompleted => 'Нагадування виконано';

  @override
  String snoozedFor(int minutes) {
    return 'Відкладено на $minutes хвилин';
  }

  @override
  String get newTimer => 'Новий таймер';

  @override
  String get timerLabel => 'Назва таймера';

  @override
  String get duration => 'Тривалість';

  @override
  String get timerCreated => 'Таймер створено';

  @override
  String get timerDeleted => 'Таймер видалено';

  @override
  String get timerDone => 'Таймер завершено!';

  @override
  String get appearance => 'Зовнішній вигляд';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системна';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeDark => 'Темна';

  @override
  String get accentColor => 'Колір акценту';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get sound => 'Звук';

  @override
  String get soundDescription => 'Відтворювати звук при сповіщенні';

  @override
  String get soundDefault => 'Стандартний';

  @override
  String get soundGentle => 'М\'який';

  @override
  String get soundUrgent => 'Терміновий';

  @override
  String get soundSilent => 'Без звуку';

  @override
  String get vibration => 'Вібрація';

  @override
  String get vibrationDescription => 'Тактильний відгук при діях';

  @override
  String get hapticLight => 'Легка';

  @override
  String get hapticMedium => 'Середня';

  @override
  String get hapticHeavy => 'Сильна';

  @override
  String get hapticOff => 'Вимк.';

  @override
  String get about => 'Про додаток';

  @override
  String version(String version) {
    return 'Версія $version';
  }

  @override
  String get quickTime30min => '30 хв';

  @override
  String get quickTime1hour => '1 год';

  @override
  String get quickTime3hours => '3 год';

  @override
  String get quickTimeTonight => 'Ввечері';

  @override
  String get quickTimeTomorrow => 'Завтра';

  @override
  String get quickTime2days => '2 дні';

  @override
  String get quickTime9am => '9:00';

  @override
  String get quickTime12pm => '12:00';

  @override
  String get quickTime3pm => '15:00';

  @override
  String get quickTime6pm => '18:00';

  @override
  String get quickTimeMonday => 'Понеділок';

  @override
  String get quickTimeNextWeek => 'Наст. тиждень';

  @override
  String get naturalDateHint => 'напр. \"завтра о 15:00\", \"через 2 години\"';

  @override
  String overdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count прострочених',
      few: '$count прострочені',
      one: '1 прострочене',
    );
    return '$_temp0';
  }
}
