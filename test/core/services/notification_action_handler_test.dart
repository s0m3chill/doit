import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/services/auto_snooze_scheduler.dart';
import 'package:doit/core/services/notification_action_handler_impl.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/usecases/complete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/snooze_reminder.dart';

class MockCompleteReminder extends Mock implements CompleteReminder {}

class MockSnoozeReminder extends Mock implements SnoozeReminder {}

class MockNotificationService extends Mock implements NotificationService {}

class MockAutoSnoozeScheduler extends Mock implements AutoSnoozeScheduler {}

void main() {
  late NotificationActionHandlerImpl handler;
  late MockCompleteReminder mockCompleteReminder;
  late MockSnoozeReminder mockSnoozeReminder;
  late MockNotificationService mockNotificationService;
  late MockAutoSnoozeScheduler mockAutoSnoozeScheduler;
  late bool actionCompletedCalled;

  setUp(() {
    mockCompleteReminder = MockCompleteReminder();
    mockSnoozeReminder = MockSnoozeReminder();
    mockNotificationService = MockNotificationService();
    mockAutoSnoozeScheduler = MockAutoSnoozeScheduler();
    actionCompletedCalled = false;

    handler = NotificationActionHandlerImpl(
      completeReminder: mockCompleteReminder,
      snoozeReminder: mockSnoozeReminder,
      notificationService: mockNotificationService,
      autoSnoozeScheduler: mockAutoSnoozeScheduler,
      onActionCompleted: () => actionCompletedCalled = true,
    );
  });

  setUpAll(() {
    registerFallbackValue(
        const SnoozeParams(id: 'fallback', snoozeMinutes: 5));
  });

  final now = DateTime(2025, 6, 15);
  final tReminder = Reminder(
    id: 'reminder-1',
    title: 'Test',
    dueDate: now.add(const Duration(minutes: 5)),
    createdAt: now,
    updatedAt: now,
  );

  group('handleAction - complete', () {
    test('completes reminder and cancels notifications', () async {
      when(() => mockCompleteReminder('reminder-1'))
          .thenAnswer((_) async => Right(tReminder));
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
          .thenAnswer((_) async {});

      await handler.handleAction('complete', 'reminder-1');

      verify(() => mockCompleteReminder('reminder-1')).called(1);
      verify(() => mockNotificationService.cancelNotification(any()))
          .called(1);
      verify(() => mockAutoSnoozeScheduler.cancelSnooze('reminder-1'))
          .called(1);
      expect(actionCompletedCalled, true);
    });
  });

  group('handleAction - snooze', () {
    test('snoozes reminder for 5 minutes', () async {
      final snoozedReminder = tReminder.copyWith(
        dueDate: DateTime.now().add(const Duration(minutes: 5)),
      );
      when(() => mockSnoozeReminder(any()))
          .thenAnswer((_) async => Right(snoozedReminder));
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => const Right(null));

      await handler.handleAction('snooze_5', 'reminder-1');

      verify(() => mockSnoozeReminder(any())).called(1);
      expect(actionCompletedCalled, true);
    });

    test('snoozes reminder for 1 minute', () async {
      final snoozedReminder = tReminder.copyWith(
        dueDate: DateTime.now().add(const Duration(minutes: 1)),
      );
      when(() => mockSnoozeReminder(any()))
          .thenAnswer((_) async => Right(snoozedReminder));
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => const Right(null));

      await handler.handleAction('snooze_1', 'reminder-1');

      final captured =
          verify(() => mockSnoozeReminder(captureAny())).captured;
      final params = captured.first as SnoozeParams;
      expect(params.snoozeMinutes, 1);
    });

    test('snoozes reminder for 15 minutes', () async {
      final snoozedReminder = tReminder.copyWith(
        dueDate: DateTime.now().add(const Duration(minutes: 15)),
      );
      when(() => mockSnoozeReminder(any()))
          .thenAnswer((_) async => Right(snoozedReminder));
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => const Right(null));

      await handler.handleAction('snooze_15', 'reminder-1');

      final captured =
          verify(() => mockSnoozeReminder(captureAny())).captured;
      final params = captured.first as SnoozeParams;
      expect(params.snoozeMinutes, 15);
    });

    test('snoozes reminder for 30 minutes', () async {
      final snoozedReminder = tReminder.copyWith(
        dueDate: DateTime.now().add(const Duration(minutes: 30)),
      );
      when(() => mockSnoozeReminder(any()))
          .thenAnswer((_) async => Right(snoozedReminder));
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => const Right(null));

      await handler.handleAction('snooze_30', 'reminder-1');

      final captured =
          verify(() => mockSnoozeReminder(captureAny())).captured;
      expect((captured.first as SnoozeParams).snoozeMinutes, 30);
    });

    test('snoozes reminder for 60 minutes', () async {
      final snoozedReminder = tReminder.copyWith(
        dueDate: DateTime.now().add(const Duration(minutes: 60)),
      );
      when(() => mockSnoozeReminder(any()))
          .thenAnswer((_) async => Right(snoozedReminder));
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => const Right(null));

      await handler.handleAction('snooze_60', 'reminder-1');

      final captured =
          verify(() => mockSnoozeReminder(captureAny())).captured;
      expect((captured.first as SnoozeParams).snoozeMinutes, 60);
    });
  });

  group('handleAction - edge cases', () {
    test('does nothing when payload is null', () async {
      await handler.handleAction('complete', null);

      verifyNever(() => mockCompleteReminder(any()));
      expect(actionCompletedCalled, false);
    });

    test('does nothing when payload is empty', () async {
      await handler.handleAction('complete', '');

      verifyNever(() => mockCompleteReminder(any()));
    });

    test('does nothing for unknown action ID', () async {
      await handler.handleAction('unknown_action', 'reminder-1');

      verifyNever(() => mockCompleteReminder(any()));
      verifyNever(() => mockSnoozeReminder(any()));
      expect(actionCompletedCalled, true); // callback still fires
    });
  });

  group('handleNotificationTap', () {
    test('does not throw for any payload', () async {
      await handler.handleNotificationTap('reminder-1');
      await handler.handleNotificationTap(null);
      // No assertions needed — just verifying no crash.
    });
  });
}
