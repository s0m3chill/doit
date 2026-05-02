import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/domain/usecases/get_all_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_active_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/get_completed_reminders.dart';
import 'package:doit/features/reminder/domain/usecases/create_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/update_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/delete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/complete_reminder.dart';
import 'package:doit/features/reminder/domain/usecases/snooze_reminder.dart';
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
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final result = await getAllReminders(const NoParams());
    result.fold(
      (failure) => emit(ReminderError(failure.message)),
      (reminders) => emit(ReminderLoaded(reminders)),
    );
  }

  Future<void> _onLoadActiveReminders(
    LoadActiveReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final result = await getActiveReminders(const NoParams());
    result.fold(
      (failure) => emit(ReminderError(failure.message)),
      (reminders) => emit(ReminderLoaded(reminders)),
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
      createdAt: now,
      updatedAt: now,
    );
    final result = await createReminder(reminder);
    await result.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (_) async {
        emit(const ReminderOperationSuccess('Reminder created'));
        final loadResult = await getActiveReminders(const NoParams());
        loadResult.fold(
          (failure) => emit(ReminderError(failure.message)),
          (reminders) => emit(ReminderLoaded(reminders)),
        );
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
      createdAt: now, // Will be preserved by repository
      updatedAt: now,
    );
    final result = await updateReminder(reminder);
    await result.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (_) async {
        emit(const ReminderOperationSuccess('Reminder updated'));
        final loadResult = await getActiveReminders(const NoParams());
        loadResult.fold(
          (failure) => emit(ReminderError(failure.message)),
          (reminders) => emit(ReminderLoaded(reminders)),
        );
      },
    );
  }

  Future<void> _onRemoveReminder(
    RemoveReminder event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    final result = await deleteReminder(event.id);
    await result.fold(
      (failure) async => emit(ReminderError(failure.message)),
      (_) async {
        emit(const ReminderOperationSuccess('Reminder deleted'));
        final loadResult = await getActiveReminders(const NoParams());
        loadResult.fold(
          (failure) => emit(ReminderError(failure.message)),
          (reminders) => emit(ReminderLoaded(reminders)),
        );
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
      (_) async {
        emit(const ReminderOperationSuccess('Reminder completed'));
        final loadResult = await getActiveReminders(const NoParams());
        loadResult.fold(
          (failure) => emit(ReminderError(failure.message)),
          (reminders) => emit(ReminderLoaded(reminders)),
        );
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
      (_) async {
        emit(ReminderOperationSuccess(
            'Snoozed for ${event.snoozeMinutes} minutes'));
        final loadResult = await getActiveReminders(const NoParams());
        loadResult.fold(
          (failure) => emit(ReminderError(failure.message)),
          (reminders) => emit(ReminderLoaded(reminders)),
        );
      },
    );
  }
}
