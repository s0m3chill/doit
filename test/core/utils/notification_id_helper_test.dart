import 'package:flutter_test/flutter_test.dart';
import 'package:doit/core/utils/notification_id_helper.dart';

void main() {
  group('NotificationIdHelper', () {
    test('primaryId returns non-negative int', () {
      final id = NotificationIdHelper.primaryId('some-uuid-123');
      expect(id, greaterThanOrEqualTo(0));
    });

    test('autoSnoozeId returns different value than primaryId', () {
      const reminderId = 'some-uuid-123';
      final primary = NotificationIdHelper.primaryId(reminderId);
      final autoSnooze = NotificationIdHelper.autoSnoozeId(reminderId);
      expect(autoSnooze, isNot(primary));
    });

    test('autoSnoozeId is offset by 100000 from primaryId', () {
      const reminderId = 'test-id';
      final primary = NotificationIdHelper.primaryId(reminderId);
      final autoSnooze = NotificationIdHelper.autoSnoozeId(reminderId);
      expect(autoSnooze, primary + 100000);
    });

    test('same input produces same output (deterministic)', () {
      const reminderId = 'deterministic-test';
      final id1 = NotificationIdHelper.primaryId(reminderId);
      final id2 = NotificationIdHelper.primaryId(reminderId);
      expect(id1, id2);
    });

    test('different inputs produce different outputs', () {
      final id1 = NotificationIdHelper.primaryId('uuid-1');
      final id2 = NotificationIdHelper.primaryId('uuid-2');
      expect(id1, isNot(id2));
    });
  });
}
