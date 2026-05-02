import 'package:equatable/equatable.dart';

/// Describes a complex recurrence pattern for a reminder.
///
/// Supports:
/// - Simple: every N days/weeks/months/years
/// - Nth weekday of month: "3rd Wednesday" (weekday + ordinal)
/// - Specific days of week: "Mon, Wed, Fri" (weekdays list with weekly freq)
/// - Day-of-month: "1st and 15th" (monthDays list with monthly freq)
///
/// Serialized as a JSON string for DB storage.
class RecurrenceRule extends Equatable {
  /// Base frequency: 'none', 'daily', 'weekly', 'monthly', 'yearly'
  final String frequency;

  /// Repeat every [interval] units of [frequency]. Default 1.
  /// e.g., interval=2 + frequency='weekly' = every 2 weeks.
  final int interval;

  /// For weekly: which days of the week (1=Mon, 7=Sun).
  /// e.g., [1, 3, 5] = Mon, Wed, Fri.
  final List<int> weekdays;

  /// For monthly: which days of the month.
  /// e.g., [1, 15] = 1st and 15th.
  final List<int> monthDays;

  /// For "nth weekday of month" patterns.
  /// e.g., ordinalWeek=3, ordinalWeekday=3 = 3rd Wednesday.
  /// null means not using this pattern.
  final int? ordinalWeek;

  /// Day of week for ordinal pattern (1=Mon, 7=Sun).
  final int? ordinalWeekday;

  const RecurrenceRule({
    this.frequency = 'none',
    this.interval = 1,
    this.weekdays = const [],
    this.monthDays = const [],
    this.ordinalWeek,
    this.ordinalWeekday,
  });

  bool get isNone => frequency == 'none';
  bool get isRecurring => !isNone;

  /// Whether this uses the "nth weekday of month" pattern.
  bool get isOrdinalWeekday =>
      ordinalWeek != null && ordinalWeekday != null;

  /// Compute the next occurrence after [from].
  DateTime? nextOccurrence(DateTime from) {
    if (isNone) return null;

    switch (frequency) {
      case 'daily':
        return from.add(Duration(days: interval));

      case 'weekly':
        return _nextWeekly(from);

      case 'monthly':
        return _nextMonthly(from);

      case 'yearly':
        return DateTime(
          from.year + interval,
          from.month,
          from.day,
          from.hour,
          from.minute,
        );

      default:
        return null;
    }
  }

  DateTime _nextWeekly(DateTime from) {
    if (weekdays.isEmpty) {
      // Simple "every N weeks"
      return from.add(Duration(days: 7 * interval));
    }

    // Find the next matching weekday.
    // weekdays are 1=Mon..7=Sun (matching DateTime.monday..DateTime.sunday).
    final sortedDays = List<int>.from(weekdays)..sort();

    // Look for the next day this week.
    for (final day in sortedDays) {
      if (day > from.weekday) {
        final diff = day - from.weekday;
        return DateTime(
            from.year, from.month, from.day + diff, from.hour, from.minute);
      }
    }

    // No more days this week — jump to the first matching day of the next
    // interval week.
    final daysUntilNextWeek = 7 - from.weekday + sortedDays.first;
    final extraWeeks = (interval - 1) * 7;
    return DateTime(from.year, from.month,
        from.day + daysUntilNextWeek + extraWeeks, from.hour, from.minute);
  }

  DateTime _nextMonthly(DateTime from) {
    if (isOrdinalWeekday) {
      return _nextOrdinalWeekday(from);
    }

    if (monthDays.isNotEmpty) {
      return _nextMonthDay(from);
    }

    // Simple "every N months"
    return DateTime(
      from.year,
      from.month + interval,
      from.day,
      from.hour,
      from.minute,
    );
  }

  /// Find the next occurrence of the Nth weekday of a month.
  /// e.g., 3rd Wednesday: ordinalWeek=3, ordinalWeekday=3
  DateTime _nextOrdinalWeekday(DateTime from) {
    // Try this month first, then subsequent months.
    var targetMonth = from.month;
    var targetYear = from.year;

    for (var attempt = 0; attempt < 24; attempt++) {
      final candidate = _nthWeekdayOfMonth(
        targetYear,
        targetMonth,
        ordinalWeekday!,
        ordinalWeek!,
        from.hour,
        from.minute,
      );

      if (candidate != null && candidate.isAfter(from)) {
        return candidate;
      }

      // Move to next interval month.
      targetMonth += interval;
      if (targetMonth > 12) {
        targetYear += targetMonth ~/ 12;
        targetMonth = targetMonth % 12;
        if (targetMonth == 0) {
          targetMonth = 12;
          targetYear--;
        }
      }
    }

    // Fallback: simple monthly advance.
    return DateTime(
        from.year, from.month + interval, from.day, from.hour, from.minute);
  }

  /// Find the Nth occurrence of [weekday] in [year]/[month].
  /// Returns null if the month doesn't have that many occurrences.
  static DateTime? _nthWeekdayOfMonth(
    int year,
    int month,
    int weekday,
    int n,
    int hour,
    int minute,
  ) {
    // Find the first occurrence of [weekday] in the month.
    var day = DateTime(year, month, 1);
    while (day.weekday != weekday) {
      day = day.add(const Duration(days: 1));
    }

    // Advance to the Nth occurrence.
    final target = day.add(Duration(days: (n - 1) * 7));

    // Verify it's still in the same month.
    if (target.month != month) return null;

    return DateTime(year, month, target.day, hour, minute);
  }

  /// Find the next matching day-of-month.
  DateTime _nextMonthDay(DateTime from) {
    final sortedDays = List<int>.from(monthDays)..sort();

    // Look for a matching day later this month.
    for (final day in sortedDays) {
      if (day > from.day) {
        final candidate =
            DateTime(from.year, from.month, day, from.hour, from.minute);
        if (candidate.month == from.month) {
          return candidate;
        }
      }
    }

    // No more days this month — jump to the first matching day of the
    // next interval month.
    var nextMonth = from.month + interval;
    var nextYear = from.year;
    if (nextMonth > 12) {
      nextYear += nextMonth ~/ 12;
      nextMonth = nextMonth % 12;
      if (nextMonth == 0) {
        nextMonth = 12;
        nextYear--;
      }
    }

    final day = sortedDays.first;
    return DateTime(nextYear, nextMonth, day, from.hour, from.minute);
  }

  /// Serialize to a map for JSON/DB storage.
  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency,
      'interval': interval,
      'weekdays': weekdays,
      'monthDays': monthDays,
      'ordinalWeek': ordinalWeek,
      'ordinalWeekday': ordinalWeekday,
    };
  }

  /// Deserialize from a map.
  factory RecurrenceRule.fromMap(Map<String, dynamic> map) {
    return RecurrenceRule(
      frequency: map['frequency'] as String? ?? 'none',
      interval: map['interval'] as int? ?? 1,
      weekdays: (map['weekdays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      monthDays: (map['monthDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      ordinalWeek: map['ordinalWeek'] as int?,
      ordinalWeekday: map['ordinalWeekday'] as int?,
    );
  }

  /// Convenience constructors for common patterns.

  /// No recurrence.
  static const none = RecurrenceRule();

  /// Every day.
  static const daily = RecurrenceRule(frequency: 'daily');

  /// Every week.
  static const weekly = RecurrenceRule(frequency: 'weekly');

  /// Every month.
  static const monthly = RecurrenceRule(frequency: 'monthly');

  /// Every year.
  static const yearly = RecurrenceRule(frequency: 'yearly');

  /// Every N days.
  factory RecurrenceRule.everyNDays(int n) =>
      RecurrenceRule(frequency: 'daily', interval: n);

  /// Every N weeks.
  factory RecurrenceRule.everyNWeeks(int n) =>
      RecurrenceRule(frequency: 'weekly', interval: n);

  /// Specific days of the week, every N weeks.
  factory RecurrenceRule.onWeekdays(List<int> days, {int interval = 1}) =>
      RecurrenceRule(
          frequency: 'weekly', interval: interval, weekdays: days);

  /// Nth weekday of every N months (e.g., 3rd Wednesday).
  factory RecurrenceRule.nthWeekdayOfMonth(
    int ordinal,
    int weekday, {
    int interval = 1,
  }) =>
      RecurrenceRule(
        frequency: 'monthly',
        interval: interval,
        ordinalWeek: ordinal,
        ordinalWeekday: weekday,
      );

  /// Specific days of the month (e.g., 1st and 15th).
  factory RecurrenceRule.onMonthDays(List<int> days, {int interval = 1}) =>
      RecurrenceRule(
          frequency: 'monthly', interval: interval, monthDays: days);

  /// Human-readable description.
  String get description {
    if (isNone) return 'Does not repeat';

    final prefix = interval > 1 ? 'Every $interval ' : 'Every ';

    switch (frequency) {
      case 'daily':
        return interval > 1 ? '${prefix}days' : 'Daily';
      case 'weekly':
        if (weekdays.isNotEmpty) {
          final dayNames = weekdays.map(_weekdayName).join(', ');
          return interval > 1
              ? '$prefix weeks on $dayNames'
              : 'Weekly on $dayNames';
        }
        return interval > 1 ? '${prefix}weeks' : 'Weekly';
      case 'monthly':
        if (isOrdinalWeekday) {
          final ordName = _ordinalName(ordinalWeek!);
          final dayName = _weekdayName(ordinalWeekday!);
          return interval > 1
              ? '${prefix}months on the $ordName $dayName'
              : 'Monthly on the $ordName $dayName';
        }
        if (monthDays.isNotEmpty) {
          final dayList = monthDays.map(_ordinalDay).join(' and ');
          return interval > 1
              ? '${prefix}months on the $dayList'
              : 'Monthly on the $dayList';
        }
        return interval > 1 ? '${prefix}months' : 'Monthly';
      case 'yearly':
        return interval > 1 ? '${prefix}years' : 'Yearly';
      default:
        return 'Custom';
    }
  }

  static String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1).clamp(0, 6)];
  }

  static String _ordinalName(int n) {
    const names = ['1st', '2nd', '3rd', '4th', '5th'];
    return names[(n - 1).clamp(0, 4)];
  }

  static String _ordinalDay(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  @override
  List<Object?> get props => [
        frequency,
        interval,
        weekdays,
        monthDays,
        ordinalWeek,
        ordinalWeekday,
      ];
}
