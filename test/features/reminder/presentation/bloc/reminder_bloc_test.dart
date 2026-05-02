import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/usecases/get_all_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_active_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_completed_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/create_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/update_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/delete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/complete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/snooze_reminder.dart';
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

  tearDown(() {
    bloc.close();
  });

  final now = DateTime(2025, 1, 1);
  final tReminders = [
    Reminder(
      id: '1',
      title: 'Test',
      dueDate: now,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  test('initial state should be ReminderInitial', () {
    expect(bloc.state, const ReminderInitial());
  });

  group('LoadReminders', () {
    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, Loaded] when successful',
      build: () {
        when(() => mockGetAllReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadReminders()),
      expect: () => [
        const ReminderLoading(),
        ReminderLoaded(tReminders),
      ],
    );

    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, Error] when unsuccessful',
      build: () {
        when(() => mockGetAllReminders(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('db error')));
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
      'emits [Loading, Loaded] when successful',
      build: () {
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadActiveReminders()),
      expect: () => [
        const ReminderLoading(),
        ReminderLoaded(tReminders),
      ],
    );
  });

  group('AddReminder', () {
    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, OperationSuccess, Loaded] when successful',
      build: () {
        when(() => mockUuid.v4()).thenReturn('generated-uuid');
        when(() => mockCreateReminder(any()))
            .thenAnswer((_) async => Right(tReminders.first));
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        return bloc;
      },
      act: (bloc) => bloc.add(AddReminder(
        title: 'Test',
        dueDate: now,
      )),
      expect: () => [
        const ReminderLoading(),
        const ReminderOperationSuccess('Reminder created'),
        ReminderLoaded(tReminders),
      ],
    );

    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, Error] when creation fails',
      build: () {
        when(() => mockUuid.v4()).thenReturn('generated-uuid');
        when(() => mockCreateReminder(any())).thenAnswer(
            (_) async => const Left(ValidationFailure('Title cannot be empty')));
        return bloc;
      },
      act: (bloc) => bloc.add(AddReminder(
        title: '',
        dueDate: now,
      )),
      expect: () => [
        const ReminderLoading(),
        const ReminderError('Title cannot be empty'),
      ],
    );
  });

  group('RemoveReminder', () {
    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, OperationSuccess, Loaded] when successful',
      build: () {
        when(() => mockDeleteReminder(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveReminder(id: '1')),
      expect: () => [
        const ReminderLoading(),
        const ReminderOperationSuccess('Reminder deleted'),
        const ReminderLoaded([]),
      ],
    );
  });

  group('MarkReminderComplete', () {
    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, OperationSuccess, Loaded] when successful',
      build: () {
        when(() => mockCompleteReminder(any()))
            .thenAnswer((_) async => Right(tReminders.first));
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const MarkReminderComplete(id: '1')),
      expect: () => [
        const ReminderLoading(),
        const ReminderOperationSuccess('Reminder completed'),
        const ReminderLoaded([]),
      ],
    );
  });

  group('SnoozeReminderEvent', () {
    blocTest<ReminderBloc, ReminderState>(
      'emits [Loading, OperationSuccess, Loaded] when successful',
      build: () {
        when(() => mockSnoozeReminder(any()))
            .thenAnswer((_) async => Right(tReminders.first));
        when(() => mockGetActiveReminders(any()))
            .thenAnswer((_) async => Right(tReminders));
        return bloc;
      },
      act: (bloc) => bloc.add(const SnoozeReminderEvent(
        id: '1',
        snoozeMinutes: 15,
      )),
      expect: () => [
        const ReminderLoading(),
        const ReminderOperationSuccess('Snoozed for 15 minutes'),
        ReminderLoaded(tReminders),
      ],
    );
  });
}
