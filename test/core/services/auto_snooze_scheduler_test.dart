import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/services/auto_snooze_scheduler_impl.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late AutoSnoozeSchedulerImpl scheduler;
  late MockNotificationService mockNotificationService;
  late DateTime fixedNow;

  setUp(() {
    mockNotificationService = MockNotificationService();
    fixedNow = DateTime(2025, 6, 15, 10, 0);
    scheduler = AutoSnoozeSchedulerImpl(
      notificationService: mockNotificationService,
      now: () => fixedNow,
    );
  });

  Reminder makeReminder({
    bool isCompleted = false,
    bool autoSnoozeEnabled = true,
    int autoSnoozeInterval = 5,
    int autoSnoozeMaxCount = 5,
    int autoSnoozeCount = 0,
    DateTime? dueDate,
  }) {
    return Reminder(
      id: 'reminder-1',
      title: 'Test',
      dueDate: dueDate ?? DateTime(2025, 6, 14),
      isCompleted: isCompleted,
      autoSnoozeEnabled: autoSnoozeEnabled,
      autoSnoozeInterval: autoSnoozeInterval,
      autoSnoozeMaxCount: autoSnoozeMaxCount,
      autoSnoozeCount: autoSnoozeCount,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
  }

  void stubSchedule() {
    when(() => mockNotificationService.scheduleAutoSnooze(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          startDate: any(named: 'startDate'),
          intervalMinutes: any(named: 'intervalMinutes'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async => const Right(null));
  }

  void stubCancel() {
    when(() => mockNotificationService.cancelNotification(any()))
        .thenAnswer((_) async => const Right(null));
  }

  group('scheduleNextSnooze', () {
    test('schedules and returns incremented count', () async {
      stubSchedule();

      final count =
          await scheduler.scheduleNextSnooze(makeReminder(autoSnoozeCount: 2));

      expect(count, 3);
      verify(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: 'Reminder: Test',
            body: 'Overdue! Tap to complete or snooze.',
            startDate: fixedNow.add(const Duration(minutes: 5)),
            intervalMinutes: 5,
            payload: 'reminder-1',
          )).called(1);
    });

    test('stops scheduling when count reaches max', () async {
      stubCancel();

      final count = await scheduler.scheduleNextSnooze(
        makeReminder(autoSnoozeMaxCount: 5, autoSnoozeCount: 5),
      );

      expect(count, 5); // unchanged
      verify(() => mockNotificationService.cancelNotification(any()))
          .called(1);
      verifyNever(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: any(named: 'intervalMinutes'),
            payload: any(named: 'payload'),
          ));
    });

    test('schedules indefinitely when maxCount is 0', () async {
      stubSchedule();

      final count = await scheduler.scheduleNextSnooze(
        makeReminder(autoSnoozeMaxCount: 0, autoSnoozeCount: 100),
      );

      expect(count, 101);
      verify(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: any(named: 'intervalMinutes'),
            payload: any(named: 'payload'),
          )).called(1);
    });

    test('cancels for completed reminder', () async {
      stubCancel();

      final count =
          await scheduler.scheduleNextSnooze(makeReminder(isCompleted: true));

      expect(count, 0);
      verify(() => mockNotificationService.cancelNotification(any()))
          .called(1);
    });

    test('does nothing for future reminder', () async {
      final count = await scheduler.scheduleNextSnooze(
        makeReminder(dueDate: DateTime(2025, 6, 16)),
      );

      expect(count, 0);
      verifyNever(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: any(named: 'intervalMinutes'),
            payload: any(named: 'payload'),
          ));
    });
  });

  group('resnoozeAllOnLaunch', () {
    test('resets count to 0 for overdue reminders and schedules them',
        () async {
      stubSchedule();

      final overdue = makeReminder(autoSnoozeCount: 5);
      final future = Reminder(
        id: 'reminder-2',
        title: 'Future',
        dueDate: DateTime(2025, 6, 16),
        autoSnoozeEnabled: true,
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );

      final result =
          await scheduler.resnoozeAllOnLaunch([overdue, future]);

      // Overdue reminder should have count reset to 0.
      expect(result[0].autoSnoozeCount, 0);
      expect(result[0].id, 'reminder-1');

      // Future reminder unchanged.
      expect(result[1].id, 'reminder-2');

      // Only the overdue one gets scheduled.
      verify(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: any(named: 'intervalMinutes'),
            payload: any(named: 'payload'),
          )).called(1);
    });

    test('skips reminders with auto-snooze disabled', () async {
      final disabled = makeReminder(autoSnoozeEnabled: false);
      stubCancel();

      final result = await scheduler.resnoozeAllOnLaunch([disabled]);

      expect(result[0].autoSnoozeEnabled, false);
      // cancelSnooze is called inside scheduleNextSnooze for disabled
      // but no schedule call.
      verifyNever(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: any(named: 'intervalMinutes'),
            payload: any(named: 'payload'),
          ));
    });
  });

  group('cancelSnooze', () {
    test('cancels notification', () async {
      stubCancel();
      await scheduler.cancelSnooze('reminder-1');
      verify(() => mockNotificationService.cancelNotification(any()))
          .called(1);
    });
  });
}
