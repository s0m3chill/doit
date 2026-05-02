import 'package:equatable/equatable.dart';
import 'package:doit/features/reminder/domain/entities/recurrence_rule.dart';

/// Core domain entity representing a reminder.
/// No framework dependencies.
class Reminder extends Equatable {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final RecurrenceRule recurrenceRule;
  final bool autoSnoozeEnabled;
  final int autoSnoozeInterval; // minutes between auto-snooze nags
  final int autoSnoozeMaxCount; // max nags before stopping (0 = indefinite)
  final int autoSnoozeCount; // how many times auto-snooze has fired
  final int? snoozeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    this.recurrenceRule = const RecurrenceRule(),
    this.autoSnoozeEnabled = true,
    this.autoSnoozeInterval = 5,
    this.autoSnoozeMaxCount = 5,
    this.autoSnoozeCount = 0,
    this.snoozeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this reminder is overdue right now.
  bool isOverdue(DateTime now) => !isCompleted && dueDate.isBefore(now);

  /// Whether this reminder is a recurring one.
  bool get isRecurring => recurrenceRule.isRecurring;

  /// Whether auto-snooze has reached its limit.
  /// Returns false if max count is 0 (indefinite).
  bool get isAutoSnoozeLimitReached =>
      autoSnoozeMaxCount > 0 && autoSnoozeCount >= autoSnoozeMaxCount;

  /// Compute the next due date based on the recurrence rule.
  DateTime? nextOccurrence() => recurrenceRule.nextOccurrence(dueDate);

  // ── Legacy compatibility ──
  // The old `repeatInterval` string is still used in some places.
  // This getter maps from RecurrenceRule back to the simple string.
  String get repeatInterval => recurrenceRule.frequency;

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    RecurrenceRule? recurrenceRule,
    bool? autoSnoozeEnabled,
    int? autoSnoozeInterval,
    int? autoSnoozeMaxCount,
    int? autoSnoozeCount,
    int? snoozeMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      autoSnoozeEnabled: autoSnoozeEnabled ?? this.autoSnoozeEnabled,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
      autoSnoozeMaxCount: autoSnoozeMaxCount ?? this.autoSnoozeMaxCount,
      autoSnoozeCount: autoSnoozeCount ?? this.autoSnoozeCount,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, title, dueDate, isCompleted, recurrenceRule,
        autoSnoozeEnabled, autoSnoozeInterval, autoSnoozeMaxCount,
        autoSnoozeCount, snoozeMinutes, createdAt, updatedAt,
      ];
}
