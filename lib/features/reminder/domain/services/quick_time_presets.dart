import 'package:doit/features/reminder/domain/entities/quick_time_preset.dart';

/// Provides the default 12 quick-access time presets.
/// Organized as two conceptual rows:
///   Row 1: Relative offsets (from now)
///   Row 2: Absolute time targets (next occurrence of a clock time)
///
/// Pure domain logic — no framework dependencies.
class QuickTimePresets {
  QuickTimePresets._();

  static List<QuickTimePreset> get defaults => [
        // ── Row 1: Relative offsets ──
        QuickTimePreset(
          id: 'in_30_min',
          label: '30 min',
          icon: '⏱',
          resolve: (now) => now.add(const Duration(minutes: 30)),
        ),
        QuickTimePreset(
          id: 'in_1_hour',
          label: '1 hour',
          icon: '🕐',
          resolve: (now) => now.add(const Duration(hours: 1)),
        ),
        QuickTimePreset(
          id: 'in_3_hours',
          label: '3 hours',
          icon: '🕒',
          resolve: (now) => now.add(const Duration(hours: 3)),
        ),
        QuickTimePreset(
          id: 'tonight',
          label: 'Tonight',
          icon: '🌙',
          resolve: (now) => _nextTime(now, 21, 0),
        ),
        QuickTimePreset(
          id: 'tomorrow',
          label: 'Tomorrow',
          icon: '☀️',
          resolve: (now) => DateTime(
                now.year, now.month, now.day + 1, 9, 0),
        ),
        QuickTimePreset(
          id: 'in_2_days',
          label: '2 days',
          icon: '📅',
          resolve: (now) => DateTime(
                now.year, now.month, now.day + 2, 9, 0),
        ),

        // ── Row 2: Absolute time targets ──
        QuickTimePreset(
          id: 'next_9am',
          label: '9 AM',
          icon: '🌅',
          resolve: (now) => _nextTime(now, 9, 0),
        ),
        QuickTimePreset(
          id: 'next_12pm',
          label: '12 PM',
          icon: '☀️',
          resolve: (now) => _nextTime(now, 12, 0),
        ),
        QuickTimePreset(
          id: 'next_3pm',
          label: '3 PM',
          icon: '🕒',
          resolve: (now) => _nextTime(now, 15, 0),
        ),
        QuickTimePreset(
          id: 'next_6pm',
          label: '6 PM',
          icon: '🌆',
          resolve: (now) => _nextTime(now, 18, 0),
        ),
        QuickTimePreset(
          id: 'next_monday',
          label: 'Monday',
          icon: '📆',
          resolve: (now) {
            final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
            final days = daysUntilMonday == 0 ? 7 : daysUntilMonday;
            return DateTime(now.year, now.month, now.day + days, 9, 0);
          },
        ),
        QuickTimePreset(
          id: 'next_week',
          label: 'Next week',
          icon: '📋',
          resolve: (now) => DateTime(
                now.year, now.month, now.day + 7, 9, 0),
        ),
      ];

  /// Returns the next occurrence of [hour]:[minute].
  /// If that time has already passed today, returns tomorrow at that time.
  static DateTime _nextTime(DateTime now, int hour, int minute) {
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now) || target.isAtSameMomentAs(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target;
  }
}
