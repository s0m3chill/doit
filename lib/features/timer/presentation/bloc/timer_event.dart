import 'package:equatable/equatable.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

class LoadTimers extends TimerEvent {
  const LoadTimers();
}

class AddTimer extends TimerEvent {
  final String label;
  final int durationSeconds;

  const AddTimer({required this.label, required this.durationSeconds});

  @override
  List<Object?> get props => [label, durationSeconds];
}

class RemoveTimer extends TimerEvent {
  final String id;

  const RemoveTimer({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Start a countdown for a specific timer template.
class StartCountdown extends TimerEvent {
  final String timerId;

  const StartCountdown({required this.timerId});

  @override
  List<Object?> get props => [timerId];
}

/// Internal tick event — fired every second while a countdown is running.
class CountdownTick extends TimerEvent {
  final String timerId;
  final int remainingSeconds;

  const CountdownTick({required this.timerId, required this.remainingSeconds});

  @override
  List<Object?> get props => [timerId, remainingSeconds];
}

/// Cancel a running countdown.
class CancelCountdown extends TimerEvent {
  final String timerId;

  const CancelCountdown({required this.timerId});

  @override
  List<Object?> get props => [timerId];
}
