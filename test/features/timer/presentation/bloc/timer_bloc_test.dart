import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';
import 'package:doit/features/timer/domain/usecases/get_all_timers.dart';
import 'package:doit/features/timer/domain/usecases/create_timer.dart';
import 'package:doit/features/timer/domain/usecases/delete_timer.dart';
import 'package:doit/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:doit/features/timer/presentation/bloc/timer_event.dart';
import 'package:doit/features/timer/presentation/bloc/timer_state.dart';

class MockGetAllTimers extends Mock implements GetAllTimers {}
class MockCreateTimer extends Mock implements CreateTimer {}
class MockDeleteTimer extends Mock implements DeleteTimer {}
class MockNotificationService extends Mock implements NotificationService {}
class MockUuid extends Mock implements Uuid {}

void main() {
  late TimerBloc bloc;
  late MockGetAllTimers mockGetAllTimers;
  late MockCreateTimer mockCreateTimer;
  late MockDeleteTimer mockDeleteTimer;
  late MockNotificationService mockNotificationService;
  late MockUuid mockUuid;

  setUp(() {
    mockGetAllTimers = MockGetAllTimers();
    mockCreateTimer = MockCreateTimer();
    mockDeleteTimer = MockDeleteTimer();
    mockNotificationService = MockNotificationService();
    mockUuid = MockUuid();

    bloc = TimerBloc(
      getAllTimers: mockGetAllTimers,
      createTimer: mockCreateTimer,
      deleteTimer: mockDeleteTimer,
      notificationService: mockNotificationService,
      uuid: mockUuid,
    );
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(CountdownTimer(
      id: 'fallback',
      label: 'fallback',
      durationSeconds: 60,
      createdAt: DateTime(2025),
    ));
  });

  tearDown(() {
    bloc.close();
  });

  final tTimers = [
    CountdownTimer(
      id: '1',
      label: 'Eggs',
      durationSeconds: 180,
      createdAt: DateTime(2025),
    ),
  ];

  test('initial state should be TimerInitial', () {
    expect(bloc.state, const TimerInitial());
  });

  group('LoadTimers', () {
    blocTest<TimerBloc, TimerState>(
      'emits [Loading, Loaded] when successful',
      build: () {
        when(() => mockGetAllTimers(any()))
            .thenAnswer((_) async => Right(tTimers));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadTimers()),
      expect: () => [
        const TimerLoading(),
        TimerLoaded(timers: tTimers),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'emits [Loading, Error] when unsuccessful',
      build: () {
        when(() => mockGetAllTimers(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('db error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadTimers()),
      expect: () => [
        const TimerLoading(),
        const TimerError('db error'),
      ],
    );
  });

  group('AddTimer', () {
    blocTest<TimerBloc, TimerState>(
      'emits [Loading, OperationSuccess, Loaded] when successful',
      build: () {
        when(() => mockUuid.v4()).thenReturn('generated-uuid');
        when(() => mockCreateTimer(any()))
            .thenAnswer((_) async => Right(tTimers.first));
        when(() => mockGetAllTimers(any()))
            .thenAnswer((_) async => Right(tTimers));
        return bloc;
      },
      act: (bloc) => bloc.add(const AddTimer(
        label: 'Eggs',
        durationSeconds: 180,
      )),
      expect: () => [
        const TimerLoading(),
        const TimerOperationSuccess('Timer created'),
        TimerLoaded(timers: tTimers),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'emits [Loading, Error] when creation fails',
      build: () {
        when(() => mockUuid.v4()).thenReturn('generated-uuid');
        when(() => mockCreateTimer(any())).thenAnswer((_) async =>
            const Left(ValidationFailure('Timer label cannot be empty')));
        return bloc;
      },
      act: (bloc) => bloc.add(const AddTimer(
        label: '',
        durationSeconds: 180,
      )),
      expect: () => [
        const TimerLoading(),
        const TimerError('Timer label cannot be empty'),
      ],
    );
  });

  group('RemoveTimer', () {
    blocTest<TimerBloc, TimerState>(
      'emits [Loading, OperationSuccess, Loaded] when successful',
      build: () {
        when(() => mockDeleteTimer(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetAllTimers(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveTimer(id: '1')),
      expect: () => [
        const TimerLoading(),
        const TimerOperationSuccess('Timer deleted'),
        const TimerLoaded(timers: []),
      ],
    );
  });

  group('StartCountdown', () {
    blocTest<TimerBloc, TimerState>(
      'starts countdown and emits updated state with active countdown',
      build: () {
        when(() => mockGetAllTimers(any()))
            .thenAnswer((_) async => Right(tTimers));
        return bloc;
      },
      seed: () => TimerLoaded(timers: tTimers),
      act: (bloc) => bloc.add(const StartCountdown(timerId: '1')),
      expect: () => [
        TimerLoaded(timers: tTimers, activeCountdowns: const {'1': 180}),
        // Subsequent ticks will follow...
      ],
      // Only check the first emission (the start).
      // Ticks are async and will continue.
    );
  });

  group('CancelCountdown', () {
    blocTest<TimerBloc, TimerState>(
      'cancels countdown and removes from active countdowns',
      seed: () =>
          TimerLoaded(timers: tTimers, activeCountdowns: const {'1': 120}),
      build: () => bloc,
      act: (bloc) => bloc.add(const CancelCountdown(timerId: '1')),
      expect: () => [
        TimerLoaded(timers: tTimers, activeCountdowns: const {}),
      ],
    );
  });

  group('CountdownTick', () {
    blocTest<TimerBloc, TimerState>(
      'updates remaining seconds for active countdown',
      seed: () =>
          TimerLoaded(timers: tTimers, activeCountdowns: const {'1': 120}),
      build: () => bloc,
      act: (bloc) =>
          bloc.add(const CountdownTick(timerId: '1', remainingSeconds: 119)),
      expect: () => [
        TimerLoaded(timers: tTimers, activeCountdowns: const {'1': 119}),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'removes countdown when remaining reaches zero',
      seed: () =>
          TimerLoaded(timers: tTimers, activeCountdowns: const {'1': 1}),
      build: () => bloc,
      act: (bloc) =>
          bloc.add(const CountdownTick(timerId: '1', remainingSeconds: 0)),
      expect: () => [
        TimerLoaded(timers: tTimers, activeCountdowns: const {}),
      ],
    );
  });
}
