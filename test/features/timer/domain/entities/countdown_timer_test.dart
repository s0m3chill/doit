import 'package:flutter_test/flutter_test.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';

void main() {
  group('CountdownTimer', () {
    test('formattedDuration shows mm:ss for durations under an hour', () {
      final t = CountdownTimer(
        id: '1',
        label: 'Eggs',
        durationSeconds: 180,
        createdAt: DateTime(2025),
      );
      expect(t.formattedDuration, '03:00');
    });

    test('formattedDuration shows hh:mm:ss for durations over an hour', () {
      final t = CountdownTimer(
        id: '1',
        label: 'Long',
        durationSeconds: 3661,
        createdAt: DateTime(2025),
      );
      expect(t.formattedDuration, '01:01:01');
    });

    test('formattedDuration handles zero', () {
      final t = CountdownTimer(
        id: '1',
        label: 'Zero',
        durationSeconds: 0,
        createdAt: DateTime(2025),
      );
      expect(t.formattedDuration, '00:00');
    });

    test('formattedDuration handles 59 seconds', () {
      final t = CountdownTimer(
        id: '1',
        label: 'Short',
        durationSeconds: 59,
        createdAt: DateTime(2025),
      );
      expect(t.formattedDuration, '00:59');
    });

    test('copyWith preserves fields when no args given', () {
      final t = CountdownTimer(
        id: '1',
        label: 'Test',
        durationSeconds: 300,
        createdAt: DateTime(2025),
      );
      expect(t.copyWith(), t);
    });

    test('copyWith overrides specified fields', () {
      final t = CountdownTimer(
        id: '1',
        label: 'Test',
        durationSeconds: 300,
        createdAt: DateTime(2025),
      );
      final updated = t.copyWith(label: 'Updated', durationSeconds: 600);
      expect(updated.label, 'Updated');
      expect(updated.durationSeconds, 600);
      expect(updated.id, '1');
    });

    test('equality works correctly', () {
      final t1 = CountdownTimer(
        id: '1',
        label: 'Test',
        durationSeconds: 300,
        createdAt: DateTime(2025),
      );
      final t2 = CountdownTimer(
        id: '1',
        label: 'Test',
        durationSeconds: 300,
        createdAt: DateTime(2025),
      );
      expect(t1, t2);
    });
  });
}
