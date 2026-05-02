import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/data/models/reminder_model.dart';
import 'package:doit/features/reminder/domain/entities/recurrence_rule.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';

void main() {
  final now = DateTime(2025, 1, 1);

  group('ReminderModel', () {
    test('should be a subclass of Reminder entity', () {
      final model = ReminderModel(
        id: '1', title: 'Test', dueDate: now, createdAt: now, updatedAt: now,
      );
      expect(model, isA<Reminder>());
    });

    test('should convert to map with recurrence_rule JSON', () {
      final model = ReminderModel(
        id: '1',
        title: 'Test',
        dueDate: now,
        recurrenceRule: RecurrenceRule.nthWeekdayOfMonth(3, 3),
        autoSnoozeMaxCount: 10,
        autoSnoozeCount: 3,
        createdAt: now,
        updatedAt: now,
      );
      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['recurrence_rule'], isA<String>());
      expect(map['auto_snooze_max_count'], 10);
      expect(map['auto_snooze_count'], 3);

      // Verify the JSON is valid and contains the right data.
      final ruleMap =
          json.decode(map['recurrence_rule'] as String) as Map<String, dynamic>;
      expect(ruleMap['frequency'], 'monthly');
      expect(ruleMap['ordinalWeek'], 3);
      expect(ruleMap['ordinalWeekday'], 3);
    });

    test('should create model from map with recurrence_rule', () {
      final ruleJson = json.encode(
          RecurrenceRule.onWeekdays([1, 3, 5]).toMap());
      final map = {
        'id': '1',
        'title': 'Test',
        'due_date': now.millisecondsSinceEpoch,
        'is_completed': 0,
        'recurrence_rule': ruleJson,
        'auto_snooze_enabled': 1,
        'auto_snooze_interval': 5,
        'auto_snooze_max_count': 7,
        'auto_snooze_count': 2,
        'snooze_minutes': null,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final model = ReminderModel.fromMap(map);

      expect(model.recurrenceRule.frequency, 'weekly');
      expect(model.recurrenceRule.weekdays, [1, 3, 5]);
      expect(model.autoSnoozeMaxCount, 7);
      expect(model.autoSnoozeCount, 2);
    });

    test('should migrate legacy repeat_interval when no recurrence_rule', () {
      final map = {
        'id': '1',
        'title': 'Legacy',
        'due_date': now.millisecondsSinceEpoch,
        'is_completed': 0,
        'repeat_interval': 'weekly',
        'auto_snooze_enabled': 1,
        'auto_snooze_interval': 5,
        'snooze_minutes': null,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final model = ReminderModel.fromMap(map);

      expect(model.recurrenceRule.frequency, 'weekly');
      expect(model.recurrenceRule.interval, 1);
      expect(model.isRecurring, true);
    });

    test('should create model from entity', () {
      final entity = Reminder(
        id: '2',
        title: 'From Entity',
        dueDate: now,
        recurrenceRule: RecurrenceRule.onMonthDays([1, 15]),
        autoSnoozeMaxCount: 10,
        autoSnoozeCount: 5,
        createdAt: now,
        updatedAt: now,
      );

      final model = ReminderModel.fromEntity(entity);

      expect(model.recurrenceRule, entity.recurrenceRule);
      expect(model.autoSnoozeMaxCount, 10);
      expect(model.autoSnoozeCount, 5);
    });

    test('roundtrip: entity -> model -> map -> model preserves data', () {
      final entity = Reminder(
        id: '3',
        title: 'Roundtrip',
        dueDate: now,
        recurrenceRule: RecurrenceRule.nthWeekdayOfMonth(2, 5),
        autoSnoozeMaxCount: 8,
        autoSnoozeCount: 4,
        createdAt: now,
        updatedAt: now,
      );

      final model = ReminderModel.fromEntity(entity);
      final map = model.toMap();
      final restored = ReminderModel.fromMap(map);

      expect(restored.recurrenceRule, model.recurrenceRule);
      expect(restored.autoSnoozeMaxCount, model.autoSnoozeMaxCount);
      expect(restored.autoSnoozeCount, model.autoSnoozeCount);
    });
  });
}
