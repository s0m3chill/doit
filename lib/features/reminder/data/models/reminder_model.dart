import 'package:doit/features/reminder/domain/entities/reminder.dart';

/// Data model that extends the domain entity with serialization capabilities.
/// Handles conversion between the domain entity and the database map format.
class ReminderModel extends Reminder {
  const ReminderModel({
    required super.id,
    required super.title,
    required super.dueDate,
    super.isCompleted,
    super.repeatInterval,
    super.autoSnoozeEnabled,
    super.autoSnoozeInterval,
    super.snoozeMinutes,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create a model from a database row map.
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      title: map['title'] as String,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int),
      isCompleted: (map['is_completed'] as int) == 1,
      repeatInterval: map['repeat_interval'] as String? ?? 'none',
      autoSnoozeEnabled: (map['auto_snooze_enabled'] as int?) != 0,
      autoSnoozeInterval: map['auto_snooze_interval'] as int? ?? 5,
      snoozeMinutes: map['snooze_minutes'] as int?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Create a model from a domain entity.
  factory ReminderModel.fromEntity(Reminder entity) {
    return ReminderModel(
      id: entity.id,
      title: entity.title,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      repeatInterval: entity.repeatInterval,
      autoSnoozeEnabled: entity.autoSnoozeEnabled,
      autoSnoozeInterval: entity.autoSnoozeInterval,
      snoozeMinutes: entity.snoozeMinutes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to a database row map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'due_date': dueDate.millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
      'repeat_interval': repeatInterval,
      'auto_snooze_enabled': autoSnoozeEnabled ? 1 : 0,
      'auto_snooze_interval': autoSnoozeInterval,
      'snooze_minutes': snoozeMinutes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
