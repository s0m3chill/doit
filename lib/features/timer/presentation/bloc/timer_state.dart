import 'package:equatable/equatable.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';

abstract class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object?> get props => [];
}

class TimerInitial extends TimerState {
  const TimerInitial();
}

class TimerLoading extends TimerState {
  const TimerLoading();
}

class TimerLoaded extends TimerState {
  final List<CountdownTimer> timers;

  /// Map of timerId -> remaining seconds for active countdowns.
  final Map<String, int> activeCountdowns;

  const TimerLoaded({
    required this.timers,
    this.activeCountdowns = const {},
  });

  TimerLoaded copyWith({
    List<CountdownTimer>? timers,
    Map<String, int>? activeCountdowns,
  }) {
    return TimerLoaded(
      timers: timers ?? this.timers,
      activeCountdowns: activeCountdowns ?? this.activeCountdowns,
    );
  }

  @override
  List<Object?> get props => [timers, activeCountdowns];
}

class TimerOperationSuccess extends TimerState {
  final String message;

  const TimerOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TimerError extends TimerState {
  final String message;

  const TimerError(this.message);

  @override
  List<Object?> get props => [message];
}
