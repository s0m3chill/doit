import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:doit/core/database/database_helper.dart';
import 'package:doit/core/services/auto_snooze_scheduler.dart';
import 'package:doit/core/services/auto_snooze_scheduler_impl.dart';
import 'package:doit/core/services/feedback_coordinator.dart';
import 'package:doit/core/services/haptic_feedback_service.dart';
import 'package:doit/core/services/haptic_feedback_service_impl.dart';
import 'package:doit/core/services/notification_action_handler.dart';
import 'package:doit/core/services/notification_action_handler_impl.dart';
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
import 'package:doit/features/reminder/domain/usecases/search_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_overdue_count.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:doit/features/timer/data/datasources/timer_local_data_source.dart';
import 'package:doit/features/timer/data/datasources/timer_local_data_source_impl.dart';
import 'package:doit/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:doit/features/timer/domain/repositories/timer_repository.dart';
import 'package:doit/features/timer/domain/usecases/get_all_timers.dart';
import 'package:doit/features/timer/domain/usecases/create_timer.dart';
import 'package:doit/features/timer/domain/usecases/delete_timer.dart';
import 'package:doit/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:doit/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:doit/features/settings/data/datasources/settings_local_data_source_impl.dart';
import 'package:doit/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:doit/features/settings/domain/repositories/settings_repository.dart';
import 'package:doit/features/settings/domain/usecases/get_haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/usecases/update_haptic_sound_settings.dart';
import 'package:doit/features/settings/presentation/bloc/settings_bloc.dart';

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
  sl.registerLazySingleton<HapticFeedbackService>(
    () => HapticFeedbackServiceImpl(),
  );
  sl.registerLazySingleton(
    () => FeedbackCoordinator(hapticService: sl()),
  );

  // ── Notification Action Handler ──
  sl.registerLazySingleton<NotificationActionHandler>(
    () => NotificationActionHandlerImpl(
      completeReminder: sl(),
      snoozeReminder: sl(),
      notificationService: sl(),
      autoSnoozeScheduler: sl(),
    ),
  );

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
      searchReminders: sl(),
      getOverdueCount: sl(),
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

  // ── Settings BLoC ──
  sl.registerFactory(
    () => SettingsBloc(
      getHapticSoundSettings: sl(),
      updateHapticSoundSettings: sl(),
      feedbackCoordinator: sl(),
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
  sl.registerLazySingleton(() => SearchReminders(sl()));
  sl.registerLazySingleton(() => GetOverdueCount(sl()));

  // ── Timer Use Cases ──
  sl.registerLazySingleton(() => GetAllTimers(sl()));
  sl.registerLazySingleton(() => CreateTimer(sl()));
  sl.registerLazySingleton(() => DeleteTimer(sl()));

  // ── Settings Use Cases ──
  sl.registerLazySingleton(() => GetHapticSoundSettings(sl()));
  sl.registerLazySingleton(() => UpdateHapticSoundSettings(sl()));

  // ── Repositories ──
  sl.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TimerRepository>(
    () => TimerRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );

  // ── Data Sources ──
  sl.registerLazySingleton<ReminderLocalDataSource>(
    () => ReminderLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<TimerLocalDataSource>(
    () => TimerLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(database: sl()),
  );

  // ── Database ──
  final databaseHelper = DatabaseHelper();
  final database = await databaseHelper.database;
  sl.registerLazySingleton(() => database);
  sl.registerLazySingleton(() => databaseHelper);
}
