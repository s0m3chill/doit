import 'package:get_it/get_it.dart';
import 'package:doit/core/database/database_helper.dart';
import 'package:doit/features/reminder/data/datasources/reminder_local_data_source.dart';
import 'package:doit/features/reminder/data/datasources/reminder_local_data_source_impl.dart';
import 'package:doit/features/reminder/data/repositories/reminder_repository_impl.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:doit/features/reminder/domain/usecases/get_all_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_active_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_completed_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/create_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/update_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/delete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/complete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/snooze_reminder.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';

final sl = GetIt.instance;

/// Registers all dependencies. Called once at app startup.
Future<void> init() async {
  // ── BLoC ──
  sl.registerFactory(
    () => ReminderBloc(
      getAllReminders: sl(),
      getActiveReminders: sl(),
      getCompletedReminders: sl(),
      createReminder: sl(),
      updateReminder: sl(),
      deleteReminder: sl(),
      completeReminder: sl(),
      snoozeReminder: sl(),
    ),
  );

  // ── Use Cases ──
  sl.registerLazySingleton(() => GetAllReminders(sl()));
  sl.registerLazySingleton(() => GetActiveReminders(sl()));
  sl.registerLazySingleton(() => GetCompletedReminders(sl()));
  sl.registerLazySingleton(() => CreateReminder(sl()));
  sl.registerLazySingleton(() => UpdateReminder(sl()));
  sl.registerLazySingleton(() => DeleteReminder(sl()));
  sl.registerLazySingleton(() => CompleteReminder(sl()));
  sl.registerLazySingleton(() => SnoozeReminder(sl()));

  // ── Repository ──
  sl.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(localDataSource: sl()),
  );

  // ── Data Sources ──
  sl.registerLazySingleton<ReminderLocalDataSource>(
    () => ReminderLocalDataSourceImpl(database: sl()),
  );

  // ── Database ──
  final databaseHelper = DatabaseHelper();
  final database = await databaseHelper.database;
  sl.registerLazySingleton(() => database);
  sl.registerLazySingleton(() => databaseHelper);
}
