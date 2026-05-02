import 'package:equatable/equatable.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {
  const LoadReminders();
}

class LoadActiveReminders extends ReminderEvent {
  const LoadActiveReminders();
}

class LoadCompletedReminders extends ReminderEvent {
  const LoadCompletedReminders();
}

class AddReminder extends ReminderEvent {
  final String title;
  final DateTime dueDate;
  final String repeatInterval;
  final bool autoSnoozeEnabled;
  final int autoSnoozeInterval;
  final int autoSnoozeMaxCount;

  const AddReminder({
    required this.title,
    required this.dueDate,
    this.repeatInterval = 'none',
    this.autoSnoozeEnabled = true,
    this.autoSnoozeInterval = 5,
    this.autoSnoozeMaxCount = 5,
  });

  @override
  List<Object?> get props =>
      [title, dueDate, repeatInterval, autoSnoozeEnabled, autoSnoozeInterval,
       autoSnoozeMaxCount];
}

class EditReminder extends ReminderEvent {
  final String id;
  final String title;
  final DateTime dueDate;
  final String repeatInterval;
  final bool autoSnoozeEnabled;
  final int autoSnoozeInterval;
  final int autoSnoozeMaxCount;

  const EditReminder({
    required this.id,
    required this.title,
    required this.dueDate,
    this.repeatInterval = 'none',
    this.autoSnoozeEnabled = true,
    this.autoSnoozeInterval = 5,
    this.autoSnoozeMaxCount = 5,
  });

  @override
  List<Object?> get props =>
      [id, title, dueDate, repeatInterval, autoSnoozeEnabled, autoSnoozeInterval,
       autoSnoozeMaxCount];
}

class RemoveReminder extends ReminderEvent {
  final String id;

  const RemoveReminder({required this.id});

  @override
  List<Object?> get props => [id];
}

class MarkReminderComplete extends ReminderEvent {
  final String id;

  const MarkReminderComplete({required this.id});

  @override
  List<Object?> get props => [id];
}

class SnoozeReminderEvent extends ReminderEvent {
  final String id;
  final int snoozeMinutes;

  const SnoozeReminderEvent({
    required this.id,
    required this.snoozeMinutes,
  });

  @override
  List<Object?> get props => [id, snoozeMinutes];
}

/// Toggle auto-snooze on/off for a specific reminder.
class ToggleAutoSnooze extends ReminderEvent {
  final String id;
  final bool enabled;

  const ToggleAutoSnooze({required this.id, required this.enabled});

  @override
  List<Object?> get props => [id, enabled];
}

/// Search reminders by title.
class SearchRemindersEvent extends ReminderEvent {
  final String query;

  const SearchRemindersEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Refresh the overdue badge count.
class RefreshOverdueCount extends ReminderEvent {
  const RefreshOverdueCount();
}
