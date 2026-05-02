/// Language-specific keywords for the natural date parser.
/// Each locale provides its own weekday names, named days, relative units,
/// time connectors, and month names.
class DateParserLocale {
  /// Weekday name → weekday number (1=Mon, 7=Sun).
  /// Include both full and abbreviated forms.
  final Map<String, int> weekdays;

  /// Named day → semantic key used by the parser.
  /// Keys: 'today', 'tomorrow', 'tonight', 'this_evening', 'this_afternoon',
  ///        'this_morning', 'noon', 'midnight', 'day_after_tomorrow'
  final Map<String, String> namedDays;

  /// Prefix for "next" (e.g., "next Monday", "наступний понеділок").
  final List<String> nextPrefixes;

  /// Prefix for "this" (e.g., "this Friday").
  final List<String> thisPrefixes;

  /// Connector word for time (e.g., "at" in "tomorrow at 3pm", "о" in Ukrainian).
  final List<String> timeConnectors;

  /// Prefix for relative durations (e.g., "in" in "in 2 hours", "через" in Ukrainian).
  final List<String> relativePrefixes;

  /// Unit keywords for relative durations.
  /// Maps to canonical unit: 'min', 'hour', 'day', 'week', 'month'.
  final Map<String, String> relativeUnits;

  /// Month name → month number (1-12).
  final Map<String, int> months;

  /// Named time expressions (e.g., "noon" → 12:00).
  final Map<String, ({int hour, int minute})> namedTimes;

  const DateParserLocale({
    required this.weekdays,
    required this.namedDays,
    required this.nextPrefixes,
    required this.thisPrefixes,
    required this.timeConnectors,
    required this.relativePrefixes,
    required this.relativeUnits,
    required this.months,
    required this.namedTimes,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // English
  // ═══════════════════════════════════════════════════════════════════════════

  static const en = DateParserLocale(
    weekdays: {
      'monday': 1, 'mon': 1, 'tuesday': 2, 'tue': 2,
      'wednesday': 3, 'wed': 3, 'thursday': 4, 'thu': 4,
      'friday': 5, 'fri': 5, 'saturday': 6, 'sat': 6,
      'sunday': 7, 'sun': 7,
    },
    namedDays: {
      'today': 'today', 'tomorrow': 'tomorrow', 'tonight': 'tonight',
      'this evening': 'tonight', 'this afternoon': 'this_afternoon',
      'this morning': 'this_morning', 'noon': 'noon',
      'midnight': 'midnight', 'day after tomorrow': 'day_after_tomorrow',
    },
    nextPrefixes: ['next'],
    thisPrefixes: ['this'],
    timeConnectors: ['at'],
    relativePrefixes: ['in'],
    relativeUnits: {
      'minutes': 'min', 'minute': 'min', 'mins': 'min', 'min': 'min',
      'hours': 'hour', 'hour': 'hour', 'h': 'hour',
      'days': 'day', 'day': 'day', 'd': 'day',
      'weeks': 'week', 'week': 'week', 'w': 'week',
      'months': 'month', 'month': 'month', 'mo': 'month',
    },
    months: {
      'jan': 1, 'january': 1, 'feb': 2, 'february': 2,
      'mar': 3, 'march': 3, 'apr': 4, 'april': 4,
      'may': 5, 'jun': 6, 'june': 6, 'jul': 7, 'july': 7,
      'aug': 8, 'august': 8, 'sep': 9, 'september': 9,
      'oct': 10, 'october': 10, 'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    },
    namedTimes: {
      'noon': (hour: 12, minute: 0),
      'midnight': (hour: 0, minute: 0),
    },
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Ukrainian
  // ═══════════════════════════════════════════════════════════════════════════

  static const uk = DateParserLocale(
    weekdays: {
      'понеділок': 1, 'пн': 1, 'вівторок': 2, 'вт': 2,
      'середа': 3, 'ср': 3, 'четвер': 4, 'чт': 4,
      'п\'ятниця': 5, 'пт': 5, 'субота': 6, 'сб': 6,
      'неділя': 7, 'нд': 7,
    },
    namedDays: {
      'сьогодні': 'today', 'завтра': 'tomorrow', 'сьогодні ввечері': 'tonight',
      'ввечері': 'tonight', 'вдень': 'this_afternoon',
      'вранці': 'this_morning', 'полудень': 'noon',
      'опівночі': 'midnight', 'післязавтра': 'day_after_tomorrow',
    },
    nextPrefixes: ['наступний', 'наступна', 'наступне', 'наст'],
    thisPrefixes: ['цей', 'ця', 'це'],
    timeConnectors: ['о', 'об', 'на'],
    relativePrefixes: ['через'],
    relativeUnits: {
      'хвилин': 'min', 'хвилини': 'min', 'хвилину': 'min', 'хв': 'min',
      'годин': 'hour', 'години': 'hour', 'годину': 'hour', 'год': 'hour',
      'днів': 'day', 'дні': 'day', 'день': 'day',
      'тижнів': 'week', 'тижні': 'week', 'тиждень': 'week',
      'місяців': 'month', 'місяці': 'month', 'місяць': 'month', 'міс': 'month',
    },
    months: {
      'січ': 1, 'січень': 1, 'січня': 1,
      'лют': 2, 'лютий': 2, 'лютого': 2,
      'бер': 3, 'березень': 3, 'березня': 3,
      'кві': 4, 'квітень': 4, 'квітня': 4,
      'тра': 5, 'травень': 5, 'травня': 5,
      'чер': 6, 'червень': 6, 'червня': 6,
      'лип': 7, 'липень': 7, 'липня': 7,
      'сер': 8, 'серпень': 8, 'серпня': 8,
      'вер': 9, 'вересень': 9, 'вересня': 9,
      'жов': 10, 'жовтень': 10, 'жовтня': 10,
      'лис': 11, 'листопад': 11, 'листопада': 11,
      'гру': 12, 'грудень': 12, 'грудня': 12,
    },
    namedTimes: {
      'полудень': (hour: 12, minute: 0),
      'опівночі': (hour: 0, minute: 0),
    },
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Polish
  // ═══════════════════════════════════════════════════════════════════════════

  static const pl = DateParserLocale(
    weekdays: {
      'poniedziałek': 1, 'pon': 1, 'pn': 1,
      'wtorek': 2, 'wt': 2,
      'środa': 3, 'śr': 3, 'sr': 3,
      'czwartek': 4, 'czw': 4, 'cz': 4,
      'piątek': 5, 'pt': 5, 'piatek': 5,
      'sobota': 6, 'sob': 6, 'sb': 6,
      'niedziela': 7, 'ndz': 7, 'nd': 7,
    },
    namedDays: {
      'dzisiaj': 'today', 'dziś': 'today', 'dzis': 'today',
      'jutro': 'tomorrow', 'dziś wieczorem': 'tonight',
      'wieczorem': 'tonight', 'po południu': 'this_afternoon',
      'rano': 'this_morning', 'południe': 'noon',
      'północ': 'midnight', 'polnoc': 'midnight',
      'pojutrze': 'day_after_tomorrow',
    },
    nextPrefixes: ['następny', 'następna', 'następne', 'nast', 'nastepny', 'nastepna'],
    thisPrefixes: ['ten', 'ta', 'to', 'w'],
    timeConnectors: ['o', 'na'],
    relativePrefixes: ['za'],
    relativeUnits: {
      'minut': 'min', 'minuty': 'min', 'minutę': 'min', 'minute': 'min', 'min': 'min',
      'godzin': 'hour', 'godziny': 'hour', 'godzinę': 'hour', 'godzine': 'hour', 'godz': 'hour',
      'dni': 'day', 'dzień': 'day', 'dzien': 'day',
      'tygodni': 'week', 'tygodnie': 'week', 'tydzień': 'week', 'tydzien': 'week',
      'miesięcy': 'month', 'miesiące': 'month', 'miesiąc': 'month', 'miesiac': 'month', 'mies': 'month',
    },
    months: {
      'sty': 1, 'styczeń': 1, 'styczen': 1, 'stycznia': 1,
      'lut': 2, 'luty': 2, 'lutego': 2,
      'mar': 3, 'marzec': 3, 'marca': 3,
      'kwi': 4, 'kwiecień': 4, 'kwiecien': 4, 'kwietnia': 4,
      'maj': 5, 'maja': 5,
      'cze': 6, 'czerwiec': 6, 'czerwca': 6,
      'lip': 7, 'lipiec': 7, 'lipca': 7,
      'sie': 8, 'sierpień': 8, 'sierpien': 8, 'sierpnia': 8,
      'wrz': 9, 'wrzesień': 9, 'wrzesien': 9, 'września': 9, 'wrzesnia': 9,
      'paź': 10, 'paz': 10, 'październik': 10, 'pazdziernik': 10, 'października': 10, 'pazdziernika': 10,
      'lis': 11, 'listopad': 11, 'listopada': 11,
      'gru': 12, 'grudzień': 12, 'grudzien': 12, 'grudnia': 12,
    },
    namedTimes: {
      'południe': (hour: 12, minute: 0),
      'poludnie': (hour: 12, minute: 0),
      'północ': (hour: 0, minute: 0),
      'polnoc': (hour: 0, minute: 0),
    },
  );

  /// All supported locales. The parser tries each one.
  static const all = [en, uk, pl];
}
