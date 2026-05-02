import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:doit/core/constants/app_constants.dart';

/// Manages SQLite database lifecycle.
/// Single responsibility: open, create tables, provide the database instance.
class DatabaseHelper {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        due_date INTEGER NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        repeat_interval TEXT NOT NULL DEFAULT 'none',
        auto_snooze_enabled INTEGER NOT NULL DEFAULT 1,
        auto_snooze_interval INTEGER NOT NULL DEFAULT 5,
        snooze_minutes INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE timers (
        id TEXT PRIMARY KEY,
        label TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
