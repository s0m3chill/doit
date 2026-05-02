import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/core/utils/notification_id_helper.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';
import 'package:doit/features/timer/domain/usecases/get_all_timers.dart';
import 'package:doit/features/timer/domain/usecases/create_timer.dart';
import 'package:doit/features/timer/domain/usecases/delete_timer.dart';
import 'package:doit/features/timer/presentation/bloc/timer_event.dart';
import 'package:doit/features/timer/presentation/bloc/timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final GetAllTimers getAllTimers;
  final CreateTimer createTimer;
  final DeleteTimer deleteTimer;
  final NotificationService notificationService;
  final Uuid _uuid;

  /// Active countdown streams, keyed by timer ID.
  final Map<String, StreamSubscription<int>> _countdownSubscriptions = {};

  TimerBloc({
    required this.getAllTimers,
    required this.createTimer,
    required this.deleteTimer,
    required this.notificationService,
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        super(const TimerInitial()) {
    on<LoadTimers>(_onLoadTimers);
    on<AddTimer>(_onAddTimer);
    on<RemoveTimer>(_onRemoveTimer);
    on<StartCountdown>(_onStartCountdown);
    on<CountdownTick>(_onCountdownTick);
    on<CancelCountdown>(_onCancelCountdown);
  }

  Future<void> _onLoadTimers(
    LoadTimers event,
    Emitter<TimerState> emit,
  ) async {
    emit(const TimerLoading());
    final result = await getAllTimers(const NoParams());
    result.fold(
      (failure) => emit(TimerError(failure.message)),
      (timers) => emit(TimerLoaded(timers: timers)),
    );
  }

  Future<void> _onAddTimer(
    AddTimer event,
    Emitter<TimerState> emit,
  ) async {
    emit(const TimerLoading());
    final timer = CountdownTimer(
      id: _uuid.v4(),
      label: event.label,
      durationSeconds: event.durationSeconds,
      createdAt: DateTime.now(),
    );
    final result = await createTimer(timer);
    await result.fold(
      (failure) async => emit(TimerError(failure.message)),
      (_) async {
        emit(const TimerOperationSuccess('Timer created'));
        final loadResult = await getAllTimers(const NoParams());
        loadResult.fold(
          (failure) => emit(TimerError(failure.message)),
          (timers) => emit(TimerLoaded(timers: timers)),
        );
      },
    );
  }

  Future<void> _onRemoveTimer(
    RemoveTimer event,
    Emitter<TimerState> emit,
  ) async {
    _cancelSubscription(event.id);
    emit(const TimerLoading());
    final result = await deleteTimer(event.id);
    await result.fold(
      (failure) async => emit(TimerError(failure.message)),
      (_) async {
        emit(const TimerOperationSuccess('Timer deleted'));
        final loadResult = await getAllTimers(const NoParams());
        loadResult.fold(
          (failure) => emit(TimerError(failure.message)),
          (timers) => emit(TimerLoaded(timers: timers)),
        );
      },
    );
  }

  Future<void> _onStartCountdown(
    StartCountdown event,
    Emitter<TimerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TimerLoaded) return;

    final timer = currentState.timers.firstWhere(
      (t) => t.id == event.timerId,
      orElse: () => throw StateError('Timer not found'),
    );

    // Cancel any existing countdown for this timer.
    _cancelSubscription(event.timerId);

    // Start a new countdown stream.
    final subscription = Stream.periodic(
      const Duration(seconds: 1),
      (tick) => timer.durationSeconds - tick - 1,
    ).take(timer.durationSeconds).listen(
      (remaining) {
        add(CountdownTick(
          timerId: event.timerId,
          remainingSeconds: remaining,
        ));
      },
      onDone: () {
        // Timer finished — fire notification.
        notificationService.scheduleNotification(
          id: NotificationIdHelper.primaryId(event.timerId),
          title: 'Timer Done!',
          body: timer.label,
          scheduledDate: DateTime.now(),
        );
        add(CountdownTick(timerId: event.timerId, remainingSeconds: 0));
      },
    );

    _countdownSubscriptions[event.timerId] = subscription;

    // Emit initial state with countdown started.
    final updatedCountdowns =
        Map<String, int>.from(currentState.activeCountdowns);
    updatedCountdowns[event.timerId] = timer.durationSeconds;
    emit(currentState.copyWith(activeCountdowns: updatedCountdowns));
  }

  void _onCountdownTick(
    CountdownTick event,
    Emitter<TimerState> emit,
  ) {
    final currentState = state;
    if (currentState is! TimerLoaded) return;

    final updatedCountdowns =
        Map<String, int>.from(currentState.activeCountdowns);

    if (event.remainingSeconds <= 0) {
      updatedCountdowns.remove(event.timerId);
      _cancelSubscription(event.timerId);
    } else {
      updatedCountdowns[event.timerId] = event.remainingSeconds;
    }

    emit(currentState.copyWith(activeCountdowns: updatedCountdowns));
  }

  void _onCancelCountdown(
    CancelCountdown event,
    Emitter<TimerState> emit,
  ) {
    _cancelSubscription(event.timerId);
    final currentState = state;
    if (currentState is! TimerLoaded) return;

    final updatedCountdowns =
        Map<String, int>.from(currentState.activeCountdowns);
    updatedCountdowns.remove(event.timerId);
    emit(currentState.copyWith(activeCountdowns: updatedCountdowns));
  }

  void _cancelSubscription(String timerId) {
    _countdownSubscriptions[timerId]?.cancel();
    _countdownSubscriptions.remove(timerId);
  }

  @override
  Future<void> close() {
    for (final sub in _countdownSubscriptions.values) {
      sub.cancel();
    }
    _countdownSubscriptions.clear();
    return super.close();
  }
}
