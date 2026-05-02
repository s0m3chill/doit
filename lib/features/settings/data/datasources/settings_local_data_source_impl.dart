import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/features/settings/data/datasources/settings_local_data_source.dart';

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final Database database;

  SettingsLocalDataSourceImpl({required this.database});

  static const String tableName = 'settings';

  @override
  Future<Map<String, String>> getAllSettings() async {
    try {
      final maps = await database.query(tableName);
      final result = <String, String>{};
      for (final map in maps) {
        result[map['key'] as String] = map['value'] as String;
      }
      return result;
    } catch (e) {
      throw DatabaseException('Failed to get settings: $e');
    }
  }

  @override
  Future<void> saveSetting(String key, String value) async {
    try {
      await database.insert(
        tableName,
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to save setting: $e');
    }
  }
}
