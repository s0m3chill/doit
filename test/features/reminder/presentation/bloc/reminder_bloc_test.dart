import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/services/auto_snooze_scheduler.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/services/repeat_scheduler.dart';
import 'package:doit/features/reminder/domain/usecases/get_all_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_active_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_completed_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/create_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/update_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/delete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/complete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/snooze_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/search_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_overdue_count.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_state.dart';

class MockGetAllReminders extends Mock implements GetAllReminders {}
class MockGetActiveReminders extends Mock implements GetActiveReminders {}
class MockGetCompletedReminders extends Mock implements GetCompletedReminders {}
class MockCreateReminder extends Mock implements CreateReminder {}
class MockUpdateReminder extends Mock implements UpdateReminder {}
class MockDeleteReminder extends Mock implements DeleteReminder {}
class MockCompleteReminder extends Mock implements CompleteReminder {}
class MockSnoozeReminder extends Mock implements SnoozeReminder {}
class MockSearchReminders extends Mock implements SearchReminders {}
class MockGetOverdueCount extends Mock implements GetOverdueCount {}
class MockNotificationService extends Mock implements NotificationService {}
class MockAutoSnoozeScheduler extends Mock implements AutoSnoozeScheduler {}
class MockRepeatScheduler extends Mock implements RepeatScheduler {}
class MockUuid extends Mock implements Uuid {}

void main() {
  late ReminderBloc bloc;
  late MockGetAllReminders mockGetAllReminders;
  late MockGetActiveReminders mockGetActiveReminders;
  late MockGetCompletedReminders mockGetCompletedReminders;
  late MockCreateReminder mockCreateReminder;
  late MockUpdateReminder mockUpdateReminder;
  late MockDeleteReminder mockDeleteReminder;
  late MockCompleteReminder mockCompleteReminder;
  late MockSnoozeReminder mockSnoozeReminder;
  late MockSearchReminders mockSearchReminders;
  late MockGetOverdueCount mockGetOverdueCount;
  late MockNotificationService mockNotificationService;
  late MockAutoSnoozeScheduler mockAutoSnoozeScheduler;
  late MockRepeatScheduler mockRepeatScheduler;
  late MockUuid mockUuid;

  setUp(() {
    mockGetAllReminders = MockGetAllReminders();
    mockGetActiveReminders = MockGetActiveReminders();
    mockGetCompletedReminders = MockGetCompletedReminders();
    mockCreateReminder = MockCreateReminder();
    mockUpdateReminder = MockUpdateReminder();
    mockDeleteReminder = MockDeleteReminder();
    mockCompleteReminder = MockCompleteReminder();
    mockSnoozeReminder = MockSnoozeReminder();
    mockSearchReminders = MockSearchReminders();
    mockGetOverdueCount = MockGetOverdueCount();
    mockNotificationService = MockNotificationService();
    mockAutoSnoozeScheduler = MockAutoSnoozeScheduler();
    mockRepeatScheduler = MockRepeatScheduler();
    mockUuid = MockUuid();

    bloc = ReminderBloc(
      getAllReminders: mockGetAllReminders,
      getActiveReminders: mockGetActiveReminders,
      getCompletedReminders: mockGetCompletedReminders,
      createReminder: mockCreateReminder,
      updateReminder: mockUpdateReminder,
      deleteReminder: mockDeleteReminder,
      completeReminder: mockCompleteReminder,
      snoozeReminder: mockSnoozeReminder,
      searchReminders: mockSearchReminders,
      getOverdueCount: mockGetOverdueCount,
      notificationService: mockNotificationService,
      autoSnoozeScheduler: mockAutoSnoozeScheduler,
      repeatScheduler: mockRepeatScheduler,
      uuid: mockUuid,
    );
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(Reminder(
      id: 'fallback',
      title: 'fallback',
      dueDate: DateTime(2025),
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ));
    registerFallbackValue(
        const SnoozeParams(id: 'fallback', snoozeMinutes: 5));
  });

  tearDown(() => bloc.close());

  final now = DateTime(2025, 1, 1);
  final tReminders = [
    Reminder(id: '1', title: 'Test', dueDate: now, createdAt: now, updatedAt: now),
  ];

  void stubAutoSnoozeSync() {
    when(() => mockAutoSnoozeScheduler.syncAllSnoozes(any()))
        .thenAnswer((_) async {});
  }

  void stubOverdueCount([int count = 0]) {
    when(() => mockGetOverdueCount(any()))
        .thenAnswer((_) async => Right(count));
  }

  test('initial state should be ReminderInitial', () {
    expect(bloc.state, const ReminderInitial());
  });

  group('LoadReminders', () {
    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, Loaded] with overdue count',
      build: () {
        when(() => mockGetAllReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        stubOverdueCount(1);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadReminders()),
      expect: () => [
        const ReminderLoading(),
        ReminderLoaded(tReminders, overdueCount: 1),
      ],
    );

    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, Error] when unsuccessful',
      build: () {
        when(() => mockGetAllReminders(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('db error')));
        stubOverdueCount();
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadReminders()),
      expect: () => [
        const ReminderLoading(),
        const ReminderError('db error'),
      ],
    );
  });

  group('LoadActiveReminders', () {
    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, Loaded] and syncs auto-snooze with overdue count',
      build: () {
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        stubAutoSnoozeSync();
        stubOverdueCount(1);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadActiveReminders()),
      expect: () => [
        const ReminderLoading(),
        ReminderLoaded(tReminders, overdueCount: 1),
      ],
      verify: (_) {
        verify(() => mockAutoSnoozeScheduler.syncAllSnoozes(tReminders))
            .called(1);
      },
    );
  });

  group('AddReminder', () {
    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, OperationSuccess, Loaded] and schedules notification',
      build: () {
        when(() => mockUuid.v4()).thenReturn('generated-uuid');
        when(() => mockCreateReminder(any()))
            .thenAnswer((_) async => Right(tReminders.first));
        when(() => mockNotificationService.scheduleNotification(
              id: any(named: 'id'),
              title: any(named: 'title'),
              body: any(named: 'body'),
              scheduledDate: any(named: 'scheduledDate'),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async => const Right(null));
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        stubAutoSnoozeSync();
        stubOverdueCount();
        return bloc;
      },
      act: (bloc) => bloc.add(AddReminder(title: 'Test', dueDate: now)),
      expect: () => [
        const ReminderLoading(),
        const ReminderOperationSuccess('Reminder created'),
        ReminderLoaded(tReminders, overdueCount: 0),
      ],
    );

    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, Error] when creation fails',
      build: () {
        when(() => mockUuid.v4()).thenReturn('generated-uuid');
        when(() => mockCreateReminder(any())).thenAnswer((_) async =>
            const Left(ValidationFailure('Title cannot be empty')));
        return bloc;
      },
      act: (bloc) => bloc.add(AddReminder(title: '', dueDate: now)),
      expect: () => [
        const ReminderLoading(),
        const ReminderError('Title cannot be empty'),
      ],
    );
  });

  group('RemoveReminder', () {
    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, OperationSuccess, Loaded] and cancels notifications',
      build: () {
        when(() => mockNotificationService.cancelNotification(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
            .thenAnswer((_) async {});
        when(() => mockDeleteReminder(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => const Right([]));
        stubAutoSnoozeSync();
        stubOverdueCount();
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveReminder(id: '1')),
      expect: () => [
        const ReminderLoading(),
        const ReminderOperationSuccess('Reminder deleted'),
        const ReminderLoaded([], overdueCount: 0),
      ],
    );
  });

  group('MarkReminderComplete', () {
    blocTest<ReminderBloc, ReminderState>(
      'completes non-recurring reminder and cancels notifications',
      build: () {
        final completedReminder = tReminders.first.copyWith(isCompleted: true);
        when(() => mockCompleteReminder(any()))
            .thenAnswer((_) async => Right(completedReminder));
        when(() => mockNotificationService.cancelNotification(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
            .thenAnswer((_) async {});
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => const Right([]));
        stubAutoSnoozeSync();
        stubOverdueCount();
        return bloc;
      },
      act: (bloc) => bloc.add(const MarkReminderComplete(id: '1')),
      expect: () => [
        const ReminderLoading(),
        const ReminderOperationSuccess('Reminder completed'),
        const ReminderLoaded([], overdueCount: 0),
      ],
    );

    blocTest<ReminderBloc, ReminderState>(
      'completes recurring reminder and creates next occurrence',
      build: () {
        final recurringReminder = Reminder(
          id: '1', title: 'Daily Task', dueDate: now,
          isCompleted: true, repeatInterval: 'daily',
          createdAt: now, updatedAt: now,
        );
        final nextReminder = Reminder(
          id: 'next-id', title: 'Daily Task',
          dueDate: DateTime(2025, 1, 2), repeatInterval: 'daily',
          createdAt: now, updatedAt: now,
        );

        when(() => mockCompleteReminder(any()))
            .thenAnswer((_) async => Right(recurringReminder));
        when(() => mockNotificationService.cancelNotification(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
            .thenAnswer((_) async {});
        when(() => mockRepeatScheduler.computeNextOccurrence(
              completed: any(named: 'completed'),
              newId: any(named: 'newId'),
              now: any(named: 'now'),
            )).thenReturn(nextReminder);
        when(() => mockUuid.v4()).thenReturn('next-id');
        when(() => mockCreateReminder(any()))
            .thenAnswer((_) async => Right(nextReminder));
        when(() => mockNotificationService.scheduleNotification(
              id: any(named: 'id'),
              title: any(named: 'title'),
              body: any(named: 'body'),
              scheduledDate: any(named: 'scheduledDate'),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async => const Right(null));
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => Right([nextReminder]));
        stubAutoSnoozeSync();
        stubOverdueCount();
        return bloc;
      },
      act: (bloc) => bloc.add(const MarkReminderComplete(id: '1')),
      expect: () => [
        const ReminderLoading(),
        const ReminderOperationSuccess('Reminder completed'),
        isA<ReminderLoaded>(),
      ],
      verify: (_) {
        verify(() => mockCreateReminder(any())).called(1);
      },
    );
  });

  group('SnoozeReminderEvent', () {
    blocTest<ReminderBloc, ReminderState>(
      'snoozes and reschedules notification',
      build: () {
        final snoozedReminder = tReminders.first.copyWith(
          dueDate: now.add(const Duration(minutes: 15)),
        );
        when(() => mockSnoozeReminder(any()))
            .thenAnswer((_) async => Right(snoozedReminder));
        when(() => mockNotificationService.cancelNotification(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockNotificationService.scheduleNotification(
              id: any(named: 'id'),
              title: any(named: 'title'),
              body: any(named: 'body'),
              scheduledDate: any(named: 'scheduledDate'),
              payload: any(named: 'payload'),
            )).thenAnswer((_) async => const Right(null));
        when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
            .thenAnswer((_) async {});
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        stubAutoSnoozeSync();
        stubOverdueCount();
        return bloc;
      },
      act: (bloc) => bloc.add(
          const SnoozeReminderEvent(id: '1', snoozeMinutes: 15)),
      expect: () => [
        const ReminderLoading(),
        const ReminderOperationSuccess('Snoozed for 15 minutes'),
        ReminderLoaded(tReminders, overdueCount: 0),
      ],
    );
  });

  group('ToggleAutoSnooze', () {
    blocTest<ReminderBloc, ReminderState>(
      'disables auto-snooze and cancels snooze notifications',
      build: () {
        when(() => mockGetAllReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        when(() => mockUpdateReminder(any()))
            .thenAnswer((_) async => Right(
                  tReminders.first.copyWith(autoSnoozeEnabled: false),
                ));
        when(() => mockAutoSnoozeScheduler.cancelSnooze(any()))
            .thenAnswer((_) async {});
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        stubAutoSnoozeSync();
        stubOverdueCount();
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const ToggleAutoSnooze(id: '1', enabled: false)),
      expect: () => [
        const ReminderLoading(),
        const ReminderOperationSuccess('Auto-snooze disabled'),
        ReminderLoaded(tReminders, overdueCount: 0),
      ],
    );
  });

  group('SearchRemindersEvent', () {
    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, Loaded] with search results',
      build: () {
        when(() => mockSearchReminders('groceries'))
            .thenAnswer((_) async => Right([tReminders.first]));
        stubOverdueCount(1);
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const SearchRemindersEvent(query: 'groceries')),
      expect: () => [
        const ReminderLoading(),
        ReminderLoaded([tReminders.first], overdueCount: 1),
      ],
    );

    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, Error] when search fails',
      build: () {
        when(() => mockSearchReminders('test'))
            .thenAnswer((_) async => const Left(DatabaseFailure('error')));
        stubOverdueCount();
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const SearchRemindersEvent(query: 'test')),
      expect: () => [
        const ReminderLoading(),
        const ReminderError('error'),
      ],
    );
  });

  group('RefreshOverdueCount', () {
    blocTest<ReminderBloc, ReminderState>(
      'updates overdue count on existing loaded state',
      seed: () => ReminderLoaded(tReminders, overdueCount: 0),
      build: () {
        stubOverdueCount(3);
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshOverdueCount()),
      expect: () => [
        ReminderLoaded(tReminders, overdueCount: 3),
      ],
    );
  });
}
