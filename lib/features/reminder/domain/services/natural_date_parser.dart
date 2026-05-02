/// Result of parsing a date from a reminder title.
class TitleParseResult {
  final DateTime date;
  final String cleanTitle;

  const TitleParseResult({required this.date, required this.cleanTitle});
}

/// Parses natural language date/time expressions into DateTime objects.
///
/// Two modes:
/// 1. `parse(text)` — parse a standalone date expression
/// 2. `parseFromTitle(title)` — scan a reminder title for embedded date/time,
///    returning the parsed date and the title with the date fragment removed.
///
/// This matches Due's behavior: type "Product Meeting Friday 9am" and it
/// detects "Friday 9am", offering to set the due date accordingly.
class NaturalDateParser {
  final DateTime Function() _now;

  NaturalDateParser({DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// Parse a standalone date/time expression.
  DateTime? parse(String input) {
    final text = input.trim().toLowerCase();
    if (text.isEmpty) return null;

    return _tryRelativeDuration(text) ??
        _tryCombinedDayAndTime(text) ??
        _tryWeekdayWithTime(text) ??
        _tryAbsoluteDate(text) ??
        _tryNamedDay(text) ??
        _tryWeekday(text) ??
        _tryTimeOnly(text);
  }

  /// Scan a reminder title for embedded date/time fragments.
  /// Returns the parsed date and the cleaned title, or null if nothing found.
  ///
  /// Example: "Collect passport next Monday 4pm"
  ///   → date: next Monday at 4 PM
  ///   → cleanTitle: "Collect passport"
  TitleParseResult? parseFromTitle(String title) {
    final text = title.trim();
    if (text.isEmpty) return null;

    for (final extractor in _titleExtractors) {
      final result = extractor(text);
      if (result != null) return result;
    }
    return null;
  }

  late final List<TitleParseResult? Function(String)> _titleExtractors = [
    _extractRelative,
    _extractCombinedDayAndTime,
    _extractWeekdayWithTime,
    _extractAbsoluteDate,
    _extractNamedDayWithTime,
    _extractNamedDay,
    _extractWeekday,
    _extractTrailingTime,
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // Title extractors — find date fragments within a larger string
  // ═══════════════════════════════════════════════════════════════════════════

  TitleParseResult? _extractRelative(String title) {
    final match = _relativeRe.firstMatch(title.toLowerCase());
    if (match == null) return null;
    final date = _tryRelativeDuration(match.group(0)!);
    if (date == null) return null;
    return _buildResult(title, match, date);
  }

  TitleParseResult? _extractCombinedDayAndTime(String title) {
    final match = _combinedDayTimeRe.firstMatch(title.toLowerCase());
    if (match == null) return null;
    final date = parse(match.group(0)!);
    if (date == null) return null;
    return _buildResult(title, match, date);
  }

  TitleParseResult? _extractWeekdayWithTime(String title) {
    final match = _weekdayTimeRe.firstMatch(title.toLowerCase());
    if (match == null) return null;
    final date = _tryWeekdayWithTime(match.group(0)!);
    if (date == null) return null;
    return _buildResult(title, match, date);
  }

  TitleParseResult? _extractAbsoluteDate(String title) {
    final match = _absoluteDateRe.firstMatch(title.toLowerCase());
    if (match == null) return null;
    final date = _tryAbsoluteDate(match.group(0)!);
    if (date == null) return null;
    return _buildResult(title, match, date);
  }

  TitleParseResult? _extractNamedDayWithTime(String title) {
    final match = _namedDayTimeRe.firstMatch(title.toLowerCase());
    if (match == null) return null;
    final date = parse(match.group(0)!);
    if (date == null) return null;
    return _buildResult(title, match, date);
  }

  TitleParseResult? _extractNamedDay(String title) {
    final lower = title.toLowerCase();
    for (final day in _namedDays) {
      final pattern = RegExp('\\b${RegExp.escape(day)}\\b');
      final match = pattern.firstMatch(lower);
      if (match != null) {
        final date = _tryNamedDay(day);
        if (date != null) return _buildResult(title, match, date);
      }
    }
    return null;
  }

  TitleParseResult? _extractWeekday(String title) {
    final match = _weekdayRe.firstMatch(title.toLowerCase());
    if (match == null) return null;
    final date = _tryWeekday(match.group(0)!);
    if (date == null) return null;
    return _buildResult(title, match, date);
  }

  TitleParseResult? _extractTrailingTime(String title) {
    final match = _trailingTimeRe.firstMatch(title.toLowerCase());
    if (match == null) return null;
    final date = _tryTimeOnly(match.group(0)!.trim());
    if (date == null) return null;
    return _buildResult(title, match, date);
  }

  TitleParseResult _buildResult(String title, Match match, DateTime date) {
    final clean = (title.substring(0, match.start) +
            title.substring(match.end))
        .trim()
        .replaceAll(RegExp(r'\s{2,}'), ' ');
    return TitleParseResult(date: date, cleanTitle: clean);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Standalone parsers
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Relative: "in 30 minutes", "in 2 hours" ──

  static final _relativeRe = RegExp(
    r'in\s+(\d+)\s*(min(?:ute)?s?|hours?|h|days?|d|weeks?|w|months?|mo)',
  );

  DateTime? _tryRelativeDuration(String text) {
    final match = _relativeRe.firstMatch(text);
    if (match == null) return null;
    final amount = int.tryParse(match.group(1)!) ?? 0;
    final unit = match.group(2)!;
    final now = _now();

    if (unit.startsWith('min')) return now.add(Duration(minutes: amount));
    if (unit.startsWith('h')) return now.add(Duration(hours: amount));
    if (unit.startsWith('d')) {
      return DateTime(now.year, now.month, now.day + amount, 9, 0);
    }
    if (unit.startsWith('w')) {
      return DateTime(now.year, now.month, now.day + amount * 7, 9, 0);
    }
    if (unit.startsWith('mo')) {
      return DateTime(now.year, now.month + amount, now.day, 9, 0);
    }
    return null;
  }

  // ── Combined day + time: "tomorrow at 3pm" ──

  static final _combinedDayTimeRe = RegExp(
    r'(?:today|tomorrow|tonight|(?:next\s+)?(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|wed|thu|fri|sat|sun))'
    r'\s+(?:at\s+)\d{1,2}(?::\d{2})?\s*(?:am|pm)?',
  );

  DateTime? _tryCombinedDayAndTime(String text) {
    final atIndex = text.indexOf(' at ');
    if (atIndex == -1) return null;
    final dayPart = text.substring(0, atIndex).trim();
    final timePart = text.substring(atIndex + 4).trim();
    final day = _tryNamedDay(dayPart) ?? _tryWeekday(dayPart);
    final time = _parseTimeExpression(timePart);
    if (day == null || time == null) return null;
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  // ── Weekday + time without "at": "Friday 9am", "next Monday 4pm" ──

  static final _weekdayTimeRe = RegExp(
    r'(?:next\s+|this\s+)?(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday'
    r'|mon|tue|wed|thu|fri|sat|sun)\s+'
    r'\d{1,2}(?::\d{2})?\s*(?:am|pm)',
  );

  DateTime? _tryWeekdayWithTime(String text) {
    final match = _weekdayTimeRe.firstMatch(text);
    if (match == null) return null;
    final fragment = match.group(0)!;

    // Split into weekday part and time part.
    final timeMatch = _time12Re.firstMatch(fragment);
    if (timeMatch == null) return null;

    final dayPart = fragment.substring(0, timeMatch.start).trim();
    final day = _tryWeekday(dayPart);
    final time = _parseTimeExpression(timeMatch.group(0)!);
    if (day == null || time == null) return null;

    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  // ── Absolute dates: "Aug 22", "May 30 2023", "8/22" ──

  static final _absoluteDateRe = RegExp(
    r'(?:jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)'
    r'\s+\d{1,2}(?:\s+\d{4})?'
    r'(?:\s+(?:at\s+)?\d{1,2}(?::\d{2})?\s*(?:am|pm))?',
  );

  DateTime? _tryAbsoluteDate(String text) {
    final match = _absoluteDateRe.firstMatch(text);
    if (match == null) return null;
    final fragment = match.group(0)!;

    // Parse month name.
    final monthMatch = RegExp(
      r'(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)',
    ).firstMatch(fragment);
    if (monthMatch == null) return null;

    final month = _monthFromName(monthMatch.group(1)!);
    if (month == null) return null;

    // Parse day number.
    final afterMonth = fragment.substring(monthMatch.end).trim();
    final dayMatch = RegExp(r'(\d{1,2})').firstMatch(afterMonth);
    if (dayMatch == null) return null;
    final day = int.tryParse(dayMatch.group(1)!) ?? 0;
    if (day < 1 || day > 31) return null;

    // Parse optional year.
    final now = _now();
    var year = now.year;
    final yearMatch = RegExp(r'\b(\d{4})\b').firstMatch(afterMonth);
    if (yearMatch != null) {
      year = int.tryParse(yearMatch.group(1)!) ?? year;
    }

    // Parse optional time.
    var hour = 9;
    var minute = 0;
    final timeMatch = _time12Re.firstMatch(fragment);
    if (timeMatch != null) {
      final parsed = _parseTimeExpression(timeMatch.group(0)!);
      if (parsed != null) {
        hour = parsed.hour;
        minute = parsed.minute;
      }
    }

    var result = DateTime(year, month, day, hour, minute);
    // If the date is in the past, push to next year.
    if (result.isBefore(now) && yearMatch == null) {
      result = DateTime(year + 1, month, day, hour, minute);
    }
    return result;
  }

  // ── Named days ──

  static const _namedDays = [
    'day after tomorrow',
    'this afternoon',
    'this evening',
    'this morning',
    'tomorrow',
    'tonight',
    'midnight',
    'today',
    'noon',
  ];

  DateTime? _tryNamedDay(String text) {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    switch (text) {
      case 'today':
        return _defaultTime(today, 9, now);
      case 'tomorrow':
        return DateTime(today.year, today.month, today.day + 1, 9, 0);
      case 'tonight':
      case 'this evening':
        return _nextTime(now, 21, 0);
      case 'this afternoon':
        return _nextTime(now, 14, 0);
      case 'this morning':
        return _nextTime(now, 9, 0);
      case 'noon':
        return _nextTime(now, 12, 0);
      case 'midnight':
        return DateTime(today.year, today.month, today.day + 1, 0, 0);
      case 'day after tomorrow':
        return DateTime(today.year, today.month, today.day + 2, 9, 0);
      default:
        return null;
    }
  }

  // ── Weekdays ──

  static final _weekdayRe = RegExp(
    r'(?:next\s+|this\s+)?(monday|tuesday|wednesday|thursday|friday|saturday|sunday'
    r'|mon|tue|wed|thu|fri|sat|sun)\b',
  );

  DateTime? _tryWeekday(String text) {
    final match = _weekdayRe.firstMatch(text);
    if (match == null) return null;
    final isNext = text.startsWith('next');
    final dayName = match.group(1)!;
    final targetWeekday = _weekdayFromName(dayName);
    if (targetWeekday == null) return null;

    final now = _now();
    var daysAhead = (targetWeekday - now.weekday + 7) % 7;
    if (daysAhead == 0) daysAhead = 7;
    if (isNext && daysAhead < 7) daysAhead += 7;

    return DateTime(now.year, now.month, now.day + daysAhead, 9, 0);
  }

  // ── Time only ──

  DateTime? _tryTimeOnly(String text) {
    var cleaned = text;
    if (cleaned.startsWith('at ')) cleaned = cleaned.substring(3).trim();
    final time = _parseTimeExpression(cleaned);
    if (time == null) return null;
    return _nextTime(_now(), time.hour, time.minute);
  }

  // ── Named day + time pattern for extraction ──

  static final _namedDayTimeRe = RegExp(
    r'(?:today|tomorrow|tonight)\s+(?:at\s+)?\d{1,2}(?::\d{2})?\s*(?:am|pm)',
  );

  static final _trailingTimeRe = RegExp(
    r'\s+(?:at\s+)?\d{1,2}(?::\d{2})?\s*(?:am|pm)\s*$',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Time expression parser
  // ═══════════════════════════════════════════════════════════════════════════

  static final _time12Re = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)');
  static final _time24Re = RegExp(r'(\d{1,2}):(\d{2})');

  ({int hour, int minute})? _parseTimeExpression(String text) {
    switch (text) {
      case 'noon':
        return (hour: 12, minute: 0);
      case 'midnight':
        return (hour: 0, minute: 0);
    }

    final match12 = _time12Re.firstMatch(text);
    if (match12 != null) {
      var hour = int.tryParse(match12.group(1)!) ?? 0;
      final minute = int.tryParse(match12.group(2) ?? '0') ?? 0;
      final period = match12.group(3)!;
      if (period == 'pm' && hour != 12) hour += 12;
      if (period == 'am' && hour == 12) hour = 0;
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return (hour: hour, minute: minute);
      }
    }

    final match24 = _time24Re.firstMatch(text);
    if (match24 != null) {
      final hour = int.tryParse(match24.group(1)!) ?? 0;
      final minute = int.tryParse(match24.group(2)!) ?? 0;
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return (hour: hour, minute: minute);
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  int? _weekdayFromName(String name) {
    const map = {
      'monday': 1, 'mon': 1, 'tuesday': 2, 'tue': 2,
      'wednesday': 3, 'wed': 3, 'thursday': 4, 'thu': 4,
      'friday': 5, 'fri': 5, 'saturday': 6, 'sat': 6,
      'sunday': 7, 'sun': 7,
    };
    return map[name];
  }

  int? _monthFromName(String name) {
    const map = {
      'jan': 1, 'january': 1, 'feb': 2, 'february': 2,
      'mar': 3, 'march': 3, 'apr': 4, 'april': 4,
      'may': 5, 'jun': 6, 'june': 6, 'jul': 7, 'july': 7,
      'aug': 8, 'august': 8, 'sep': 9, 'september': 9,
      'oct': 10, 'october': 10, 'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    };
    return map[name];
  }

  DateTime _defaultTime(DateTime today, int defaultHour, DateTime now) {
    final candidate =
        DateTime(today.year, today.month, today.day, defaultHour, 0);
    if (candidate.isAfter(now)) return candidate;
    return DateTime(now.year, now.month, now.day, now.hour + 1, 0);
  }

  DateTime _nextTime(DateTime now, int hour, int minute) {
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now) || target.isAtSameMomentAs(now)) {
      target = DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
    return target;
  }
}
