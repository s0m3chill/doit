import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/features/reminder/data/models/reminder_model.dart';
import 'package:doit/features/reminder/data/datasources/reminder_local_data_source.dart';

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final Database database;

  ReminderLocalDataSourceImpl({required this.database});

  static const String tableName = 'reminders';

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    try {
      final maps = await database.query(tableName, orderBy: 'due_date ASC');
      return maps.map((map) => ReminderModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get reminders: $e');
    }
  }

  @override
  Future<List<ReminderModel>> getActiveReminders() async {
    try {
      final maps = await database.query(
        tableName,
        where: 'is_completed = ?',
        whereArgs: [0],
        orderBy: 'due_date ASC',
      );
      return maps.map((map) => ReminderModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get active reminders: $e');
    }
  }

  @override
  Future<List<ReminderModel>> getCompletedReminders() async {
    try {
      final maps = await database.query(
        tableName,
        where: 'is_completed = ?',
        whereArgs: [1],
        orderBy: 'updated_at DESC',
      );
      return maps.map((map) => ReminderModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get completed reminders: $e');
    }
  }

  @override
  Future<ReminderModel> getReminderById(String id) async {
    try {
      final maps = await database.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        throw const DatabaseException('Reminder not found');
      }
      return ReminderModel.fromMap(maps.first);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to get reminder: $e');
    }
  }

  @override
  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    try {
      await database.insert(tableName, reminder.toMap());
      return reminder;
    } catch (e) {
      throw DatabaseException('Failed to create reminder: $e');
    }
  }

  @override
  Future<ReminderModel> updateReminder(ReminderModel reminder) async {
    try {
      final count = await database.update(
        tableName,
        reminder.toMap(),
        where: 'id = ?',
        whereArgs: [reminder.id],
      );
      if (count == 0) {
        throw const DatabaseException('Reminder not found for update');
      }
      return reminder;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to update reminder: $e');
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      final count = await database.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) {
        throw const DatabaseException('Reminder not found for deletion');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to delete reminder: $e');
    }
  }
}
