import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:doit/core/services/auto_snooze_scheduler.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/core/utils/notification_id_helper.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
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
import 'package:doit/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final GetAllReminders getAllReminders;
  final GetActiveReminders getActiveReminders;
  final GetCompletedReminders getCompletedReminders;
  final CreateReminder createReminder;
  final UpdateReminder updateReminder;
  final DeleteReminder deleteReminder;
  final CompleteReminder completeReminder;
  final SnoozeReminder snoozeReminder;
  final SearchReminders searchReminders;
  final GetOverdueCount getOverdueCount;
  final NotificationService notificationService;
  final AutoSnoozeScheduler autoSnoozeScheduler;
  final RepeatScheduler repeatScheduler;
  final Uuid _uuid;

  ReminderBloc({
    required this.getAllReminders,
    required this.getActiveReminders,
    required this.getCompletedReminders,
    required this.createReminder,
    required this.updateReminder,
    required this.deleteReminder,
    required this.completeReminder,
    required this.snoozeReminder,
    required this.searchReminders,
    required this.getOverdueCount,
    required this.notificationService,
    required this.autoSnoozeScheduler,
    required this.repeatScheduler,
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        super(const ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<LoadActiveReminders>(_onLoadActiveReminders);
    on<LoadCompletedReminders>(_onLoadCompletedReminders);
    on<AddReminder>(_onAddReminder);
    on<EditReminder>(_onEditReminder);
    on<RemoveReminder>(_onRemoveReminder);
    on<MarkReminderComplete>(_onMarkReminderComplete);
    on<SnoozeReminderEvent>(_onSnoozeReminder);
    on<ToggleAutoSnooze>(_onToggleAutoSnooze);
    on<SearchRemindersEvent>(_onSearchReminders);
    on<RefreshOverdueCount>(_onRefreshOverdueCount);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final result = await getAllReminders(const NoParams());
    final overdueResult = await getOverdueCount(const NoParams());
    final overdueCount = overdueResult.getOrElse(() => 0);
    result.fold(
      (failure) => emit(ReminderError(failure.message)),
      (reminders) =>
          emit(ReminderLoaded(reminders, overdueCount: overdueCount)),
    );
  }

  Future<void> _onLoadActiveReminders(
    LoadActiveReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final result = await getActiveReminders(const NoParams());
    await result.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (reminders) async {
        await autoSnoozeScheduler.syncAllSnoozes(reminders);
        final overdueResult = await getOverdueCount(const NoParams());
        final overdueCount = overdueResult.getOrElse(() => 0);
        emit(ReminderLoaded(reminders, overdueCount: overdueCount));
      },
    );
  }

  Future<void> _onLoadCompletedReminders(
    LoadCompletedReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final result = await getCompletedReminders(const NoParams());
    result.fold(
      (failure) => emit(ReminderError(failure.message)),
      (reminders) => emit(ReminderLoaded(reminders)),
    );
  }

  Future<void> _onAddReminder(
    AddReminder event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final now = DateTime.now();
    final reminder = Reminder(
      id: _uuid.v4(),
      title: event.title,
      dueDate: event.dueDate,
      repeatInterval: event.repeatInterval,
      autoSnoozeEnabled: event.autoSnoozeEnabled,
      autoSnoozeInterval: event.autoSnoozeInterval,
      createdAt: now,
      updatedAt: now,
    );
    final result = await createReminder(reminder);
    await result.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (created) async {
        await _scheduleNotification(created);
        emit(const ReminderOperationSuccess('Reminder created'));
        await _reloadActive(emit);
      },
    );
  }

  Future<void> _onEditReminder(
    EditReminder event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final now = DateTime.now();
    final reminder = Reminder(
      id: event.id,
      title: event.title,
      dueDate: event.dueDate,
      repeatInterval: event.repeatInterval,
      autoSnoozeEnabled: event.autoSnoozeEnabled,
      autoSnoozeInterval: event.autoSnoozeInterval,
      createdAt: now,
      updatedAt: now,
    );
    final result = await updateReminder(reminder);
    await result.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (updated) async {
        await _cancelNotification(updated.id);
        await _scheduleNotification(updated);
        emit(const ReminderOperationSuccess('Reminder updated'));
        await _reloadActive(emit);
      },
    );
  }

  Future<void> _onRemoveReminder(
    RemoveReminder event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    await _cancelNotification(event.id);
    await autoSnoozeScheduler.cancelSnooze(event.id);

    final result = await deleteReminder(event.id);
    await result.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (_) async {
        emit(const ReminderOperationSuccess('Reminder deleted'));
        await _reloadActive(emit);
      },
    );
  }

  Future<void> _onMarkReminderComplete(
    MarkReminderComplete event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final result = await completeReminder(event.id);
    await result.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (completed) async {
        await _cancelNotification(completed.id);
        await autoSnoozeScheduler.cancelSnooze(completed.id);

        if (completed.isRecurring) {
          final next = repeatScheduler.computeNextOccurrence(
            completed: completed,
            newId: _uuid.v4(),
            now: DateTime.now(),
          );
          if (next != null) {
            final createResult = await createReminder(next);
            await createResult.fold(
              (_) async {},
              (created) async => await _scheduleNotification(created),
            );
          }
        }

        emit(const ReminderOperationSuccess('Reminder completed'));
        await _reloadActive(emit);
      },
    );
  }

  Future<void> _onSnoozeReminder(
    SnoozeReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final params = SnoozeParams(
      id: event.id,
      snoozeMinutes: event.snoozeMinutes,
    );
    final result = await snoozeReminder(params);
    await result.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (snoozed) async {
        await _cancelNotification(snoozed.id);
        await _scheduleNotification(snoozed);
        await autoSnoozeScheduler.cancelSnooze(snoozed.id);

        emit(ReminderOperationSuccess(
            'Snoozed for ${event.snoozeMinutes} minutes'));
        await _reloadActive(emit);
      },
    );
  }

  Future<void> _onToggleAutoSnooze(
    ToggleAutoSnooze event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final getResult = await getAllReminders(const NoParams());
    await getResult.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (reminders) async {
        final target = reminders.where((r) => r.id == event.id).firstOrNull;
        if (target == null) {
          emit(const ReminderError('Reminder not found'));
          return;
        }
        final updated = target.copyWith(
          autoSnoozeEnabled: event.enabled,
          updatedAt: DateTime.now(),
        );
        final updateResult = await updateReminder(updated);
        await updateResult.fold(
          (failure) async => emit(ReminderError(failure.message)),
          (result) async {
            if (!event.enabled) {
              await autoSnoozeScheduler.cancelSnooze(event.id);
            } else {
              await autoSnoozeScheduler.scheduleNextSnooze(result);
            }
            emit(ReminderOperationSuccess(
              event.enabled ? 'Auto-snooze enabled' : 'Auto-snooze disabled',
            ));
            await _reloadActive(emit);
          },
        );
      },
    );
  }

  Future<void> _onSearchReminders(
    SearchRemindersEvent event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final result = await searchReminders(event.query);
    final overdueResult = await getOverdueCount(const NoParams());
    final overdueCount = overdueResult.getOrElse(() => 0);
    result.fold(
      (failure) => emit(ReminderError(failure.message)),
      (reminders) =>
          emit(ReminderLoaded(reminders, overdueCount: overdueCount)),
    );
  }

  Future<void> _onRefreshOverdueCount(
    RefreshOverdueCount event,
    Emitter<ReminderState> emit,
  ) async {
    final currentState = state;
    final overdueResult = await getOverdueCount(const NoParams());
    final overdueCount = overdueResult.getOrElse(() => 0);
    if (currentState is ReminderLoaded) {
      emit(ReminderLoaded(currentState.reminders,
          overdueCount: overdueCount));
    }
  }

  // ── Helpers ──

  Future<void> _scheduleNotification(Reminder reminder) async {
    if (reminder.dueDate.isAfter(DateTime.now())) {
      await notificationService.scheduleNotification(
        id: NotificationIdHelper.primaryId(reminder.id),
        title: 'DoIt: ${reminder.title}',
        body: 'Time to do it!',
        scheduledDate: reminder.dueDate,
        payload: reminder.id,
      );
    }
  }

  Future<void> _cancelNotification(String reminderId) async {
    await notificationService
        .cancelNotification(NotificationIdHelper.primaryId(reminderId));
  }

  Future<void> _reloadActive(Emitter<ReminderState> emit) async {
    final loadResult = await getActiveReminders(const NoParams());
    await loadResult.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (reminders) async {
        await autoSnoozeScheduler.syncAllSnoozes(reminders);
        final overdueResult = await getOverdueCount(const NoParams());
        final overdueCount = overdueResult.getOrElse(() => 0);
        emit(ReminderLoaded(reminders, overdueCount: overdueCount));
      },
    );
  }
}
