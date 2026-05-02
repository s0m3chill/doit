import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/features/timer/data/models/countdown_timer_model.dart';
import 'package:doit/features/timer/data/datasources/timer_local_data_source.dart';

class TimerLocalDataSourceImpl implements TimerLocalDataSource {
  final Database database;

  TimerLocalDataSourceImpl({required this.database});

  static const String tableName = 'timers';

  @override
  Future<List<CountdownTimerModel>> getAllTimers() async {
    try {
      final maps = await database.query(tableName, orderBy: 'created_at DESC');
      return maps.map((map) => CountdownTimerModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get timers: $e');
    }
  }

  @override
  Future<CountdownTimerModel> getTimerById(String id) async {
    try {
      final maps = await database.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        throw const DatabaseException('Timer not found');
      }
      return CountdownTimerModel.fromMap(maps.first);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to get timer: $e');
    }
  }

  @override
  Future<CountdownTimerModel> createTimer(CountdownTimerModel timer) async {
    try {
      await database.insert(tableName, timer.toMap());
      return timer;
    } catch (e) {
      throw DatabaseException('Failed to create timer: $e');
    }
  }

  @override
  Future<CountdownTimerModel> updateTimer(CountdownTimerModel timer) async {
    try {
      final count = await database.update(
        tableName,
        timer.toMap(),
        where: 'id = ?',
        whereArgs: [timer.id],
      );
      if (count == 0) {
        throw const DatabaseException('Timer not found for update');
      }
      return timer;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to update timer: $e');
    }
  }

  @override
  Future<void> deleteTimer(String id) async {
    try {
      final count = await database.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) {
        throw const DatabaseException('Timer not found for deletion');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to delete timer: $e');
    }
  }
}
