import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/timer/data/models/countdown_timer_model.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';

void main() {
  final now = DateTime(2025, 1, 1);

  group('CountdownTimerModel', () {
    test('should be a subclass of CountdownTimer entity', () {
      final model = CountdownTimerModel(
        id: '1',
        label: 'Eggs',
        durationSeconds: 180,
        createdAt: now,
      );
      expect(model, isA<CountdownTimer>());
    });

    test('should convert to map correctly', () {
      final model = CountdownTimerModel(
        id: '1',
        label: 'Eggs',
        durationSeconds: 180,
        createdAt: now,
      );
      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['label'], 'Eggs');
      expect(map['duration_seconds'], 180);
      expect(map['created_at'], now.millisecondsSinceEpoch);
    });

    test('should create model from map correctly', () {
      final map = {
        'id': '1',
        'label': 'Coffee',
        'duration_seconds': 240,
        'created_at': now.millisecondsSinceEpoch,
      };

      final model = CountdownTimerModel.fromMap(map);

      expect(model.id, '1');
      expect(model.label, 'Coffee');
      expect(model.durationSeconds, 240);
      expect(model.createdAt, now);
    });

    test('should create model from entity', () {
      final entity = CountdownTimer(
        id: '2',
        label: 'Tea',
        durationSeconds: 120,
        createdAt: now,
      );

      final model = CountdownTimerModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.label, entity.label);
      expect(model.durationSeconds, entity.durationSeconds);
      expect(model.createdAt, entity.createdAt);
    });

    test('roundtrip: entity -> model -> map -> model preserves data', () {
      final entity = CountdownTimer(
        id: '3',
        label: 'Roundtrip',
        durationSeconds: 600,
        createdAt: now,
      );

      final model = CountdownTimerModel.fromEntity(entity);
      final map = model.toMap();
      final restored = CountdownTimerModel.fromMap(map);

      expect(restored, model);
    });
  });
}
