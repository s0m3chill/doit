import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:doit/core/database/database_helper.dart';
import 'package:doit/core/services/auto_snooze_scheduler.dart';
import 'package:doit/core/services/auto_snooze_scheduler_impl.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/core/services/notification_service_impl.dart';
import 'package:doit/features/reminder/data/datasources/reminder_local_data_source.dart';
import 'package:doit/features/reminder/data/datasources/reminder_local_data_source_impl.dart';
import 'package:doit/features/reminder/data/repositories/reminder_repository_impl.dart';
import 'package:doit/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:doit/features/reminder/domain/services/repeat_scheduler.dart';
import 'package:doit/features/reminder/domain/usecases/get_all_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_active_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_completed_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/create_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/update_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/delete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/complete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/snooze_reminder.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:doit/features/timer/data/datasources/timer_local_data_source.dart';
import 'package:doit/features/timer/data/datasources/timer_local_data_source_impl.dart';
import 'package:doit/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:doit/features/timer/domain/repositories/timer_repository.dart';
import 'package:doit/features/timer/domain/usecases/get_all_timers.dart';
import 'package:doit/features/timer/domain/usecases/create_timer.dart';
import 'package:doit/features/timer/domain/usecases/delete_timer.dart';
import 'package:doit/features/timer/presentation/bloc/timer_bloc.dart';

final sl = GetIt.instance;

/// Registers all dependencies. Called once at app startup.
Future<void> init() async {
  // ── Core Services ──
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
  sl.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(plugin: sl()),
  );
  sl.registerLazySingleton<AutoSnoozeScheduler>(
    () => AutoSnoozeSchedulerImpl(notificationService: sl()),
  );
  sl.registerLazySingleton(() => RepeatScheduler());

  // ── Reminder BLoC ──
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
      notificationService: sl(),
      autoSnoozeScheduler: sl(),
      repeatScheduler: sl(),
    ),
  );

  // ── Timer BLoC ──
  sl.registerFactory(
    () => TimerBloc(
      getAllTimers: sl(),
      createTimer: sl(),
      deleteTimer: sl(),
      notificationService: sl(),
    ),
  );

  // ── Reminder Use Cases ──
  sl.registerLazySingleton(() => GetAllReminders(sl()));
  sl.registerLazySingleton(() => GetActiveReminders(sl()));
  sl.registerLazySingleton(() => GetCompletedReminders(sl()));
  sl.registerLazySingleton(() => CreateReminder(sl()));
  sl.registerLazySingleton(() => UpdateReminder(sl()));
  sl.registerLazySingleton(() => DeleteReminder(sl()));
  sl.registerLazySingleton(() => CompleteReminder(sl()));
  sl.registerLazySingleton(() => SnoozeReminder(sl()));

  // ── Timer Use Cases ──
  sl.registerLazySingleton(() => GetAllTimers(sl()));
  sl.registerLazySingleton(() => CreateTimer(sl()));
  sl.registerLazySingleton(() => DeleteTimer(sl()));

  // ── Reminder Repository ──
  sl.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(localDataSource: sl()),
  );

  // ── Timer Repository ──
  sl.registerLazySingleton<TimerRepository>(
    () => TimerRepositoryImpl(localDataSource: sl()),
  );

  // ── Reminder Data Source ──
  sl.registerLazySingleton<ReminderLocalDataSource>(
    () => ReminderLocalDataSourceImpl(database: sl()),
  );

  // ── Timer Data Source ──
  sl.registerLazySingleton<TimerLocalDataSource>(
    () => TimerLocalDataSourceImpl(database: sl()),
  );

  // ── Database ──
  final databaseHelper = DatabaseHelper();
  final database = await databaseHelper.database;
  sl.registerLazySingleton(() => database);
  sl.registerLazySingleton(() => databaseHelper);
}
