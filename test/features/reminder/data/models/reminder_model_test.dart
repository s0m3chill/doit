import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/reminder/data/models/reminder_model.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';

void main() {
  final now = DateTime(2025, 1, 1);
  final tModel = ReminderModel(
    id: '1',
    title: 'Test',
    dueDate: now,
    isCompleted: false,
    repeatInterval: 'none',
    autoSnoozeEnabled: true,
    autoSnoozeInterval: 5,
    snoozeMinutes: null,
    createdAt: now,
    updatedAt: now,
  );

  group('ReminderModel', () {
    test('should be a subclass of Reminder entity', () {
      expect(tModel, isA<Reminder>());
    });

    test('should convert to map correctly', () {
      final map = tModel.toMap();

      expect(map['id'], '1');
      expect(map['title'], 'Test');
      expect(map['due_date'], now.millisecondsSinceEpoch);
      expect(map['is_completed'], 0);
      expect(map['repeat_interval'], 'none');
      expect(map['auto_snooze_enabled'], 1);
      expect(map['auto_snooze_interval'], 5);
      expect(map['snooze_minutes'], null);
      expect(map['created_at'], now.millisecondsSinceEpoch);
      expect(map['updated_at'], now.millisecondsSinceEpoch);
    });

    test('should create model from map correctly', () {
      final map = {
        'id': '1',
        'title': 'Test',
        'due_date': now.millisecondsSinceEpoch,
        'is_completed': 0,
        'repeat_interval': 'none',
        'auto_snooze_enabled': 1,
        'auto_snooze_interval': 5,
        'snooze_minutes': null,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final model = ReminderModel.fromMap(map);

      expect(model.id, '1');
      expect(model.title, 'Test');
      expect(model.dueDate, now);
      expect(model.isCompleted, false);
      expect(model.repeatInterval, 'none');
      expect(model.autoSnoozeEnabled, true);
      expect(model.autoSnoozeInterval, 5);
      expect(model.snoozeMinutes, null);
    });

    test('should handle is_completed = 1 as true', () {
      final map = {
        'id': '1',
        'title': 'Test',
        'due_date': now.millisecondsSinceEpoch,
        'is_completed': 1,
        'repeat_interval': 'daily',
        'auto_snooze_enabled': 0,
        'auto_snooze_interval': 15,
        'snooze_minutes': 5,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final model = ReminderModel.fromMap(map);

      expect(model.isCompleted, true);
      expect(model.repeatInterval, 'daily');
      expect(model.autoSnoozeEnabled, false);
      expect(model.autoSnoozeInterval, 15);
      expect(model.snoozeMinutes, 5);
    });

    test('should default auto_snooze_enabled to true when null in map', () {
      final map = {
        'id': '1',
        'title': 'Test',
        'due_date': now.millisecondsSinceEpoch,
        'is_completed': 0,
        'repeat_interval': 'none',
        'auto_snooze_enabled': null,
        'auto_snooze_interval': null,
        'snooze_minutes': null,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final model = ReminderModel.fromMap(map);

      expect(model.autoSnoozeEnabled, true);
      expect(model.autoSnoozeInterval, 5);
    });

    test('should create model from entity', () {
      final entity = Reminder(
        id: '2',
        title: 'From Entity',
        dueDate: now,
        isCompleted: true,
        repeatInterval: 'weekly',
        autoSnoozeEnabled: false,
        autoSnoozeInterval: 30,
        snoozeMinutes: 10,
        createdAt: now,
        updatedAt: now,
      );

      final model = ReminderModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.isCompleted, entity.isCompleted);
      expect(model.repeatInterval, entity.repeatInterval);
      expect(model.autoSnoozeEnabled, entity.autoSnoozeEnabled);
      expect(model.autoSnoozeInterval, entity.autoSnoozeInterval);
      expect(model.snoozeMinutes, entity.snoozeMinutes);
    });

    test('roundtrip: entity -> model -> map -> model should preserve data',
        () {
      final entity = Reminder(
        id: '3',
        title: 'Roundtrip',
        dueDate: now,
        isCompleted: false,
        repeatInterval: 'monthly',
        autoSnoozeEnabled: true,
        autoSnoozeInterval: 10,
        snoozeMinutes: 30,
        createdAt: now,
        updatedAt: now,
      );

      final model = ReminderModel.fromEntity(entity);
      final map = model.toMap();
      final restored = ReminderModel.fromMap(map);

      expect(restored, model);
    });
  });
}
