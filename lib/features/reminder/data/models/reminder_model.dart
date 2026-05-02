import 'dart:convert';
import 'package:doit/features/reminder/domain/entities/recurrence_rule.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';

/// Data model with serialization for the database.
class ReminderModel extends Reminder {
  const ReminderModel({
    required super.id,
    required super.title,
    required super.dueDate,
    super.isCompleted,
    super.recurrenceRule,
    super.autoSnoozeEnabled,
    super.autoSnoozeInterval,
    super.autoSnoozeMaxCount,
    super.autoSnoozeCount,
    super.snoozeMinutes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    RecurrenceRule rule;
    final ruleJson = map['recurrence_rule'] as String?;
    if (ruleJson != null && ruleJson.isNotEmpty) {
      rule = RecurrenceRule.fromMap(
          json.decode(ruleJson) as Map<String, dynamic>);
    } else {
      // Legacy: migrate old repeat_interval string.
      final legacy = map['repeat_interval'] as String? ?? 'none';
      rule = RecurrenceRule(frequency: legacy);
    }

    return ReminderModel(
      id: map['id'] as String,
      title: map['title'] as String,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int),
      isCompleted: (map['is_completed'] as int) == 1,
      recurrenceRule: rule,
      autoSnoozeEnabled: (map['auto_snooze_enabled'] as int?) != 0,
      autoSnoozeInterval: map['auto_snooze_interval'] as int? ?? 5,
      autoSnoozeMaxCount: map['auto_snooze_max_count'] as int? ?? 5,
      autoSnoozeCount: map['auto_snooze_count'] as int? ?? 0,
      snoozeMinutes: map['snooze_minutes'] as int?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  factory ReminderModel.fromEntity(Reminder entity) {
    return ReminderModel(
      id: entity.id,
      title: entity.title,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      recurrenceRule: entity.recurrenceRule,
      autoSnoozeEnabled: entity.autoSnoozeEnabled,
      autoSnoozeInterval: entity.autoSnoozeInterval,
      autoSnoozeMaxCount: entity.autoSnoozeMaxCount,
      autoSnoozeCount: entity.autoSnoozeCount,
      snoozeMinutes: entity.snoozeMinutes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'due_date': dueDate.millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
      'repeat_interval': recurrenceRule.frequency, // legacy compat
      'recurrence_rule': json.encode(recurrenceRule.toMap()),
      'auto_snooze_enabled': autoSnoozeEnabled ? 1 : 0,
      'auto_snooze_interval': autoSnoozeInterval,
      'auto_snooze_max_count': autoSnoozeMaxCount,
      'auto_snooze_count': autoSnoozeCount,
      'snooze_minutes': snoozeMinutes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
