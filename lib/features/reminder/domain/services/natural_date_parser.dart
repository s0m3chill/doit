import 'package:doit/features/reminder/domain/services/date_parser_locale.dart';

/// Result of parsing a date from a reminder title.
class TitleParseResult {
  final DateTime date;
  final String cleanTitle;

  const TitleParseResult({required this.date, required this.cleanTitle});
}

/// Parses natural language date/time expressions in English, Ukrainian, and Polish.
///
/// Tries all supported locales — the first successful parse wins.
/// This means "завтра о 15:00" and "tomorrow at 3pm" both work.
class NaturalDateParser {
  final DateTime Function() _now;
  final List<DateParserLocale> _locales;

  NaturalDateParser({
    DateTime Function()? now,
    List<DateParserLocale>? locales,
  })  : _now = now ?? DateTime.now,
        _locales = locales ?? DateParserLocale.all;

  /// Parse a standalone date/time expression in any supported language.
  DateTime? parse(String input) {
    final text = input.trim().toLowerCase();
    if (text.isEmpty) return null;

    for (final locale in _locales) {
      final result = _parseWithLocale(text, locale);
      if (result != null) return result;
    }
    return null;
  }

  /// Scan a reminder title for embedded date/time in any supported language.
  TitleParseResult? parseFromTitle(String title) {
    final text = title.trim();
    if (text.isEmpty) return null;

    for (final locale in _locales) {
      final result = _parseFromTitleWithLocale(text, locale);
      if (result != null) return result;
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Per-locale parsing
  // ═══════════════════════════════════════════════════════════════════════════

  DateTime? _parseWithLocale(String text, DateParserLocale locale) {
    return _tryRelative(text, locale) ??
        _tryCombinedDayAndTime(text, locale) ??
        _tryWeekdayWithTime(text, locale) ??
        _tryAbsoluteDate(text, locale) ??
        _tryNamedDay(text, locale) ??
        _tryWeekday(text, locale) ??
        _tryTimeOnly(text, locale);
  }

  TitleParseResult? _parseFromTitleWithLocale(
      String title, DateParserLocale locale) {
    final lower = title.toLowerCase();

    // Try extractors in order of specificity.
    return _extractRelative(title, lower, locale) ??
        _extractCombinedDayAndTime(title, lower, locale) ??
        _extractWeekdayWithTime(title, lower, locale) ??
        _extractAbsoluteDate(title, lower, locale) ??
        _extractNamedDayWithTime(title, lower, locale) ??
        _extractNamedDay(title, lower, locale) ??
        _extractWeekday(title, lower, locale) ??
        _extractTrailingTime(title, lower, locale);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Relative: "in 2 hours" / "через 2 години" / "za 2 godziny"
  // ═══════════════════════════════════════════════════════════════════════════

  DateTime? _tryRelative(String text, DateParserLocale locale) {
    for (final prefix in locale.relativePrefixes) {
      final pattern = RegExp(
        '${RegExp.escape(prefix)}\\s+(\\d+)\\s+(\\S+)',
      );
      final match = pattern.firstMatch(text);
      if (match == null) continue;

      final amount = int.tryParse(match.group(1)!) ?? 0;
      final unitWord = match.group(2)!;
      final unit = locale.relativeUnits[unitWord];
      if (unit == null) continue;

      return _applyRelativeUnit(amount, unit);
    }
    return null;
  }

  DateTime _applyRelativeUnit(int amount, String unit) {
    final now = _now();
    switch (unit) {
      case 'min':
        return now.add(Duration(minutes: amount));
      case 'hour':
        return now.add(Duration(hours: amount));
      case 'day':
        return DateTime(now.year, now.month, now.day + amount, 9, 0);
      case 'week':
        return DateTime(now.year, now.month, now.day + amount * 7, 9, 0);
      case 'month':
        return DateTime(now.year, now.month + amount, now.day, 9, 0);
      default:
        return now;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Combined day + time: "tomorrow at 3pm" / "завтра о 15:00"
  // ═══════════════════════════════════════════════════════════════════════════

  DateTime? _tryCombinedDayAndTime(String text, DateParserLocale locale) {
    for (final connector in locale.timeConnectors) {
      final sep = ' $connector ';
      final idx = text.indexOf(sep);
      if (idx == -1) continue;

      final dayPart = text.substring(0, idx).trim();
      final timePart = text.substring(idx + sep.length).trim();

      final day = _tryNamedDay(dayPart, locale) ?? _tryWeekday(dayPart, locale);
      final time = _parseTimeExpression(timePart, locale);
      if (day == null || time == null) continue;

      return DateTime(day.year, day.month, day.day, time.hour, time.minute);
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Weekday + time: "Friday 9am" / "п'ятниця 9:00"
  // ═══════════════════════════════════════════════════════════════════════════

  DateTime? _tryWeekdayWithTime(String text, DateParserLocale locale) {
    // Try to find a weekday followed by a time expression.
    for (final entry in locale.weekdays.entries) {
      if (!text.contains(entry.key)) continue;

      final idx = text.indexOf(entry.key);
      final afterDay = text.substring(idx + entry.key.length).trim();
      // Strip optional time connector.
      var timePart = afterDay;
      for (final conn in locale.timeConnectors) {
        if (timePart.startsWith('$conn ')) {
          timePart = timePart.substring(conn.length + 1).trim();
          break;
        }
      }

      final time = _parseTimeExpression(timePart, locale);
      if (time == null) continue;

      // Check for "next" prefix.
      final beforeDay = text.substring(0, idx).trim();
      final isNext =
          locale.nextPrefixes.any((p) => beforeDay.endsWith(p));

      final now = _now();
      var daysAhead = (entry.value - now.weekday + 7) % 7;
      if (daysAhead == 0) daysAhead = 7;
      if (isNext && daysAhead < 7) daysAhead += 7;

      return DateTime(
          now.year, now.month, now.day + daysAhead, time.hour, time.minute);
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Absolute dates: "Aug 22" / "22 серпня" / "22 sierpnia"
  // ═══════════════════════════════════════════════════════════════════════════

  DateTime? _tryAbsoluteDate(String text, DateParserLocale locale) {
    // Try "month day" and "day month" patterns.
    for (final entry in locale.months.entries) {
      final monthName = entry.key;
      if (!text.contains(monthName)) continue;

      final idx = text.indexOf(monthName);
      final before = text.substring(0, idx).trim();
      final after = text.substring(idx + monthName.length).trim();

      int? day;
      String remaining;

      // Try "day month" (e.g., "22 серпня")
      final dayBefore = RegExp(r'(\d{1,2})$').firstMatch(before);
      if (dayBefore != null) {
        day = int.tryParse(dayBefore.group(1)!);
        remaining = after;
      }

      // Try "month day" (e.g., "Aug 22")
      if (day == null) {
        final dayAfter = RegExp(r'^(\d{1,2})').firstMatch(after);
        if (dayAfter != null) {
          day = int.tryParse(dayAfter.group(1)!);
          remaining = after.substring(dayAfter.end).trim();
        } else {
          continue;
        }
      } else {
        remaining = after;
      }

      if (day == null || day < 1 || day > 31) continue;

      final now = _now();
      var year = now.year;
      final yearMatch = RegExp(r'\b(\d{4})\b').firstMatch(remaining);
      if (yearMatch != null) {
        year = int.tryParse(yearMatch.group(1)!) ?? year;
      }

      // Optional time.
      var hour = 9;
      var minute = 0;
      final time = _parseTimeExpression(remaining, locale);
      if (time != null) {
        hour = time.hour;
        minute = time.minute;
      }

      var result = DateTime(year, entry.value, day, hour, minute);
      if (result.isBefore(now) && yearMatch == null) {
        result = DateTime(year + 1, entry.value, day, hour, minute);
      }
      return result;
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Named days: "today" / "сьогодні" / "dzisiaj"
  // ═══════════════════════════════════════════════════════════════════════════

  DateTime? _tryNamedDay(String text, DateParserLocale locale) {
    final semantic = locale.namedDays[text];
    if (semantic == null) return null;
    return _resolveNamedDay(semantic);
  }

  DateTime _resolveNamedDay(String semantic) {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    switch (semantic) {
      case 'today':
        final candidate = DateTime(today.year, today.month, today.day, 9, 0);
        if (candidate.isAfter(now)) return candidate;
        return DateTime(now.year, now.month, now.day, now.hour + 1, 0);
      case 'tomorrow':
        return DateTime(today.year, today.month, today.day + 1, 9, 0);
      case 'tonight':
        return _nextTime(now, 21, 0);
      case 'this_afternoon':
        return _nextTime(now, 14, 0);
      case 'this_morning':
        return _nextTime(now, 9, 0);
      case 'noon':
        return _nextTime(now, 12, 0);
      case 'midnight':
        return DateTime(today.year, today.month, today.day + 1, 0, 0);
      case 'day_after_tomorrow':
        return DateTime(today.year, today.month, today.day + 2, 9, 0);
      default:
        return DateTime(today.year, today.month, today.day + 1, 9, 0);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Weekdays: "monday" / "понеділок" / "poniedziałek"
  // ═══════════════════════════════════════════════════════════════════════════

  DateTime? _tryWeekday(String text, DateParserLocale locale) {
    // Strip "next"/"this" prefixes.
    var cleaned = text;
    var isNext = false;
    for (final prefix in locale.nextPrefixes) {
      if (cleaned.startsWith('$prefix ')) {
        cleaned = cleaned.substring(prefix.length + 1).trim();
        isNext = true;
        break;
      }
    }
    for (final prefix in locale.thisPrefixes) {
      if (cleaned.startsWith('$prefix ')) {
        cleaned = cleaned.substring(prefix.length + 1).trim();
        break;
      }
    }

    final weekday = locale.weekdays[cleaned];
    if (weekday == null) return null;

    final now = _now();
    var daysAhead = (weekday - now.weekday + 7) % 7;
    if (daysAhead == 0) daysAhead = 7;
    if (isNext && daysAhead < 7) daysAhead += 7;

    return DateTime(now.year, now.month, now.day + daysAhead, 9, 0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Time only: "3pm" / "15:00"
  // ═══════════════════════════════════════════════════════════════════════════

  DateTime? _tryTimeOnly(String text, DateParserLocale locale) {
    var cleaned = text;
    for (final conn in locale.timeConnectors) {
      if (cleaned.startsWith('$conn ')) {
        cleaned = cleaned.substring(conn.length + 1).trim();
        break;
      }
    }
    // Only match if the remaining text is purely a time expression
    // (no other words around it).
    final time = _parseTimeExpression(cleaned, locale);
    if (time == null) return null;
    // Verify the cleaned text doesn't contain non-time words.
    final stripped = cleaned
        .replaceAll(RegExp(r'\d{1,2}(?::\d{2})?\s*(?:am|pm)?'), '')
        .trim();
    if (stripped.isNotEmpty) return null;
    return _nextTime(_now(), time.hour, time.minute);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Time expression parser (shared across all locales)
  // ═══════════════════════════════════════════════════════════════════════════

  static final _time12Re = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)');
  static final _time24Re = RegExp(r'(\d{1,2}):(\d{2})');

  ({int hour, int minute})? _parseTimeExpression(
      String text, DateParserLocale locale) {
    // Check named times first.
    for (final entry in locale.namedTimes.entries) {
      if (text.contains(entry.key)) return entry.value;
    }

    // 12-hour: "3pm", "3:30 pm"
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

    // 24-hour: "14:30", "09:00"
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
  // Title extractors
  // ═══════════════════════════════════════════════════════════════════════════

  TitleParseResult? _extractRelative(
      String title, String lower, DateParserLocale locale) {
    for (final prefix in locale.relativePrefixes) {
      final pattern = RegExp(
        '${RegExp.escape(prefix)}\\s+\\d+\\s+\\S+',
      );
      final match = pattern.firstMatch(lower);
      if (match == null) continue;
      final date = _tryRelative(match.group(0)!, locale);
      if (date != null) return _buildResult(title, match, date);
    }
    return null;
  }

  TitleParseResult? _extractCombinedDayAndTime(
      String title, String lower, DateParserLocale locale) {
    for (final connector in locale.timeConnectors) {
      final sep = ' $connector ';
      final idx = lower.indexOf(sep);
      if (idx == -1) continue;

      // Try parsing the whole fragment from the named day/weekday before the connector.
      // Find the start of the day expression by looking backwards for known words.
      for (final dayWord in [...locale.namedDays.keys, ...locale.weekdays.keys]) {
        final dayIdx = lower.lastIndexOf(dayWord, idx);
        if (dayIdx == -1) continue;

        // Find the end of the time expression after the connector.
        final afterConnector = lower.substring(idx + sep.length);
        final timeMatch = _time12Re.firstMatch(afterConnector) ??
            _time24Re.firstMatch(afterConnector);
        if (timeMatch == null) continue;

        final fullEnd = idx + sep.length + timeMatch.end;
        final fragment = lower.substring(dayIdx, fullEnd);
        final date = _tryCombinedDayAndTime(fragment, locale) ??
            _parseWithLocale(fragment, locale);
        if (date == null) continue;

        // Build result using original title positions.
        final fakeMatch = _RangeMatch(dayIdx, fullEnd);
        return _buildResult(title, fakeMatch, date);
      }
    }
    return null;
  }

  TitleParseResult? _extractWeekdayWithTime(
      String title, String lower, DateParserLocale locale) {
    for (final entry in locale.weekdays.entries) {
      final dayName = entry.key;
      final idx = lower.indexOf(dayName);
      if (idx == -1) continue;

      // Check for "next" prefix.
      var start = idx;
      for (final prefix in locale.nextPrefixes) {
        final prefixStart = idx - prefix.length - 1;
        if (prefixStart >= 0 &&
            lower.substring(prefixStart, idx).trim() == prefix) {
          start = prefixStart;
          break;
        }
      }

      final afterDay = lower.substring(idx + dayName.length).trim();
      // Strip optional connector.
      var timePart = afterDay;
      for (final conn in locale.timeConnectors) {
        if (timePart.startsWith('$conn ')) {
          timePart = timePart.substring(conn.length + 1).trim();
          break;
        }
      }

      final time = _parseTimeExpression(timePart, locale);
      if (time == null) continue;

      // Find the end of the time expression in the original string.
      final timeInOriginal = _time12Re.firstMatch(lower.substring(idx)) ??
          _time24Re.firstMatch(lower.substring(idx));
      if (timeInOriginal == null) continue;

      final end = idx + timeInOriginal.end;
      final fragment = lower.substring(start, end);
      final date = _tryWeekdayWithTime(fragment, locale);
      if (date == null) continue;

      return _buildResult(title, _RangeMatch(start, end), date);
    }
    return null;
  }

  TitleParseResult? _extractAbsoluteDate(
      String title, String lower, DateParserLocale locale) {
    for (final monthName in locale.months.keys) {
      final idx = lower.indexOf(monthName);
      if (idx == -1) continue;

      // Find the extent of the date expression.
      // Look for a day number before or after the month name.
      final before = lower.substring(0, idx).trimRight();
      final after = lower.substring(idx + monthName.length).trimLeft();

      int start = idx;
      int end = idx + monthName.length;

      // "22 серпня" pattern
      final dayBefore = RegExp(r'(\d{1,2})\s*$').firstMatch(before);
      if (dayBefore != null) {
        start = dayBefore.start;
      }

      // "Aug 22" pattern
      final dayAfter = RegExp(r'^\s*(\d{1,2})').firstMatch(after);
      if (dayAfter != null && dayBefore == null) {
        end = idx + monthName.length + dayAfter.end;
      }

      // Optional year and time after.
      final remaining = lower.substring(end).trimLeft();
      final yearMatch = RegExp(r'^\s*(\d{4})').firstMatch(remaining);
      if (yearMatch != null) {
        end += yearMatch.end;
      }
      final timeAfter = _time12Re.firstMatch(lower.substring(end)) ??
          _time24Re.firstMatch(lower.substring(end));
      if (timeAfter != null) {
        // Check if there's a connector before the time.
        final gap = lower.substring(end, end + timeAfter.start).trim();
        final isConnector = gap.isEmpty ||
            locale.timeConnectors.any((c) => gap == c);
        if (isConnector) {
          end += timeAfter.end;
        }
      }

      final fragment = lower.substring(start, end);
      final date = _tryAbsoluteDate(fragment, locale);
      if (date == null) continue;

      return _buildResult(title, _RangeMatch(start, end), date);
    }
    return null;
  }

  TitleParseResult? _extractNamedDayWithTime(
      String title, String lower, DateParserLocale locale) {
    for (final dayWord in locale.namedDays.keys) {
      final idx = lower.indexOf(dayWord);
      if (idx == -1) continue;

      final afterDay = lower.substring(idx + dayWord.length).trim();
      // Look for time after the named day.
      var timePart = afterDay;
      for (final conn in locale.timeConnectors) {
        if (timePart.startsWith('$conn ')) {
          timePart = timePart.substring(conn.length + 1).trim();
          break;
        }
      }

      final time = _parseTimeExpression(timePart, locale);
      if (time == null) continue;

      final day = _tryNamedDay(dayWord, locale);
      if (day == null) continue;

      // Find end of time in original.
      final timeInOriginal = _time12Re.firstMatch(lower.substring(idx)) ??
          _time24Re.firstMatch(lower.substring(idx));
      if (timeInOriginal == null) continue;

      final end = idx + timeInOriginal.end;
      final date =
          DateTime(day.year, day.month, day.day, time.hour, time.minute);
      return _buildResult(title, _RangeMatch(idx, end), date);
    }
    return null;
  }

  TitleParseResult? _extractNamedDay(
      String title, String lower, DateParserLocale locale) {
    // Sort by length descending so "day after tomorrow" matches before "today".
    final sortedDays = locale.namedDays.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final day in sortedDays) {
      final idx = lower.indexOf(day);
      if (idx == -1) continue;

      // Word boundary check.
      final before = idx > 0 ? lower[idx - 1] : ' ';
      final afterIdx = idx + day.length;
      final after = afterIdx < lower.length ? lower[afterIdx] : ' ';
      if (before != ' ' || (after != ' ' && after != ',' && after != '.')) {
        continue;
      }

      final date = _tryNamedDay(day, locale);
      if (date != null) {
        return _buildResult(title, _RangeMatch(idx, afterIdx), date);
      }
    }
    return null;
  }

  TitleParseResult? _extractWeekday(
      String title, String lower, DateParserLocale locale) {
    for (final entry in locale.weekdays.entries) {
      final idx = lower.indexOf(entry.key);
      if (idx == -1) continue;

      var start = idx;
      var fragment = entry.key;

      // Check for "next" prefix.
      for (final prefix in locale.nextPrefixes) {
        final prefixStart = idx - prefix.length - 1;
        if (prefixStart >= 0 &&
            lower.substring(prefixStart, idx).trim() == prefix) {
          start = prefixStart;
          fragment = lower.substring(start, idx + entry.key.length);
          break;
        }
      }

      final date = _tryWeekday(fragment, locale);
      if (date == null) continue;

      return _buildResult(
          title, _RangeMatch(start, idx + entry.key.length), date);
    }
    return null;
  }

  TitleParseResult? _extractTrailingTime(
      String title, String lower, DateParserLocale locale) {
    // Look for time at the end of the string.
    final match12 = RegExp(r'\s+(?:\S+\s+)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)\s*$')
        .firstMatch(lower);
    final match24 = RegExp(r'\s+(?:\S+\s+)?(\d{1,2}):(\d{2})\s*$')
        .firstMatch(lower);

    final match = match12 ?? match24;
    if (match == null) return null;

    final fragment = match.group(0)!.trim();
    final date = _tryTimeOnly(fragment, locale);
    if (date == null) return null;

    return _buildResult(title, match, date);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  TitleParseResult _buildResult(String title, Match match, DateTime date) {
    final clean = (title.substring(0, match.start) +
            title.substring(match.end))
        .trim()
        .replaceAll(RegExp(r'\s{2,}'), ' ');
    return TitleParseResult(date: date, cleanTitle: clean);
  }

  DateTime _nextTime(DateTime now, int hour, int minute) {
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now) || target.isAtSameMomentAs(now)) {
      target = DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
    return target;
  }
}

/// Simple Match implementation for range-based extraction.
class _RangeMatch implements Match {
  @override
  final int start;
  @override
  final int end;

  _RangeMatch(this.start, this.end);

  @override
  String? group(int group) => null;
  @override
  String operator [](int group) => '';
  @override
  List<String?> groups(List<int> groupIndices) => [];
  @override
  int get groupCount => 0;
  @override
  String get input => '';
  @override
  Pattern get pattern => '';
}
