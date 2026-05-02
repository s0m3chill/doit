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
      expect(model.snoozeMinutes, null);
    });

    test('should handle is_completed = 1 as true', () {
      final map = {
        'id': '1',
        'title': 'Test',
        'due_date': now.millisecondsSinceEpoch,
        'is_completed': 1,
        'repeat_interval': 'daily',
        'snooze_minutes': 5,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final model = ReminderModel.fromMap(map);

      expect(model.isCompleted, true);
      expect(model.repeatInterval, 'daily');
      expect(model.snoozeMinutes, 5);
    });

    test('should create model from entity', () {
      final entity = Reminder(
        id: '2',
        title: 'From Entity',
        dueDate: now,
        isCompleted: true,
        repeatInterval: 'weekly',
        snoozeMinutes: 10,
        createdAt: now,
        updatedAt: now,
      );

      final model = ReminderModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.isCompleted, entity.isCompleted);
      expect(model.repeatInterval, entity.repeatInterval);
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
