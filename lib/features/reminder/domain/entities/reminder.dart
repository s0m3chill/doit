import 'package:equatable/equatable.dart';

/// Core domain entity representing a reminder.
/// This is the heart of the app — no framework dependencies here.
class Reminder extends Equatable {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final String repeatInterval; // none, daily, weekly, monthly, yearly
  final int? snoozeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    this.repeatInterval = 'none',
    this.snoozeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    String? repeatInterval,
    int? snoozeMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        dueDate,
        isCompleted,
        repeatInterval,
        snoozeMinutes,
        createdAt,
        updatedAt,
      ];
}
