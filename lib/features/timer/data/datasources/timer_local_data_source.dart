import 'package:doit/features/timer/data/models/countdown_timer_model.dart';

/// Contract for timer local persistence.
abstract class TimerLocalDataSource {
  Future<List<CountdownTimerModel>> getAllTimers();
  Future<CountdownTimerModel> getTimerById(String id);
  Future<CountdownTimerModel> createTimer(CountdownTimerModel timer);
  Future<CountdownTimerModel> updateTimer(CountdownTimerModel timer);
  Future<void> deleteTimer(String id);
}
