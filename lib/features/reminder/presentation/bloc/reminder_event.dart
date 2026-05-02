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

  const AddReminder({
    required this.title,
    required this.dueDate,
    this.repeatInterval = 'none',
  });

  @override
  List<Object?> get props => [title, dueDate, repeatInterval];
}

class EditReminder extends ReminderEvent {
  final String id;
  final String title;
  final DateTime dueDate;
  final String repeatInterval;

  const EditReminder({
    required this.id,
    required this.title,
    required this.dueDate,
    this.repeatInterval = 'none',
  });

  @override
  List<Object?> get props => [id, title, dueDate, repeatInterval];
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
