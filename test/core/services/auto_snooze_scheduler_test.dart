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
    DateTime? dueDate,
  }) {
    return Reminder(
      id: 'reminder-1',
      title: 'Test',
      dueDate: dueDate ?? DateTime(2025, 6, 14), // overdue by default
      isCompleted: isCompleted,
      autoSnoozeEnabled: autoSnoozeEnabled,
      autoSnoozeInterval: autoSnoozeInterval,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
  }

  group('scheduleNextSnooze', () {
    test('schedules notification for overdue reminder with auto-snooze', () async {
      when(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: any(named: 'intervalMinutes'),
          )).thenAnswer((_) async => const Right(null));

      await scheduler.scheduleNextSnooze(makeReminder());

      verify(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: 'Reminder: Test',
            body: 'Overdue! Tap to complete or snooze.',
            startDate: fixedNow.add(const Duration(minutes: 5)),
            intervalMinutes: 5,
          )).called(1);
    });

    test('cancels snooze for completed reminder', () async {
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => const Right(null));

      await scheduler.scheduleNextSnooze(makeReminder(isCompleted: true));

      verify(() => mockNotificationService.cancelNotification(any())).called(1);
      verifyNever(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: any(named: 'intervalMinutes'),
          ));
    });

    test('cancels snooze when auto-snooze is disabled', () async {
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => const Right(null));

      await scheduler
          .scheduleNextSnooze(makeReminder(autoSnoozeEnabled: false));

      verify(() => mockNotificationService.cancelNotification(any())).called(1);
    });

    test('does nothing for future (not yet overdue) reminder', () async {
      await scheduler.scheduleNextSnooze(
        makeReminder(dueDate: DateTime(2025, 6, 16)),
      );

      verifyNever(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: any(named: 'intervalMinutes'),
          ));
      verifyNever(
          () => mockNotificationService.cancelNotification(any()));
    });

    test('uses custom auto-snooze interval', () async {
      when(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: any(named: 'intervalMinutes'),
          )).thenAnswer((_) async => const Right(null));

      await scheduler
          .scheduleNextSnooze(makeReminder(autoSnoozeInterval: 15));

      verify(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: fixedNow.add(const Duration(minutes: 15)),
            intervalMinutes: 15,
          )).called(1);
    });
  });

  group('cancelSnooze', () {
    test('cancels notification with correct ID', () async {
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => const Right(null));

      await scheduler.cancelSnooze('reminder-1');

      verify(() => mockNotificationService.cancelNotification(any())).called(1);
    });
  });

  group('syncAllSnoozes', () {
    test('schedules snooze for overdue reminders and cancels for non-overdue',
        () async {
      when(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: any(named: 'intervalMinutes'),
          )).thenAnswer((_) async => const Right(null));
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => const Right(null));

      final overdueReminder = makeReminder();
      final futureReminder = Reminder(
        id: 'reminder-2',
        title: 'Future',
        dueDate: DateTime(2025, 6, 16),
        autoSnoozeEnabled: true,
        autoSnoozeInterval: 5,
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );

      await scheduler.syncAllSnoozes([overdueReminder, futureReminder]);

      // Overdue one gets scheduled.
      verify(() => mockNotificationService.scheduleAutoSnooze(
            id: any(named: 'id'),
            title: 'Reminder: Test',
            body: any(named: 'body'),
            startDate: any(named: 'startDate'),
            intervalMinutes: 5,
          )).called(1);

      // Future one gets cancelled.
      verify(() => mockNotificationService.cancelNotification(any())).called(1);
    });
  });
}
