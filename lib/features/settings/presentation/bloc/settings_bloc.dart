import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doit/core/services/feedback_coordinator.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/settings/domain/entities/app_settings.dart';
import 'package:doit/features/settings/domain/usecases/get_haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/usecases/update_haptic_sound_settings.dart';
import 'package:doit/features/settings/presentation/bloc/settings_event.dart';
import 'package:doit/features/settings/presentation/bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetAppSettings getAppSettings;
  final UpdateAppSettings updateAppSettings;
  final FeedbackCoordinator feedbackCoordinator;

  SettingsBloc({
    required this.getAppSettings,
    required this.updateAppSettings,
    required this.feedbackCoordinator,
  }) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleSound>(_onToggleSound);
    on<ToggleVibration>(_onToggleVibration);
    on<ChangeNotificationSound>(_onChangeNotificationSound);
    on<ChangeHapticIntensity>(_onChangeHapticIntensity);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ChangeThemeColor>(_onChangeThemeColor);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await getAppSettings(const NoParams());
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> _onToggleSound(
    ToggleSound event,
    Emitter<SettingsState> emit,
  ) async {
    final current = _current;
    if (current == null) return;
    final updated = current.copyWith(
      hapticSound: current.hapticSound.copyWith(soundEnabled: event.enabled),
    );
    await _saveAndEmit(updated, emit);
  }

  Future<void> _onToggleVibration(
    ToggleVibration event,
    Emitter<SettingsState> emit,
  ) async {
    final current = _current;
    if (current == null) return;
    final updated = current.copyWith(
      hapticSound:
          current.hapticSound.copyWith(vibrationEnabled: event.enabled),
    );
    await _saveAndEmit(updated, emit);
    if (event.enabled) {
      await feedbackCoordinator.triggerSelection(updated.hapticSound);
    }
  }

  Future<void> _onChangeNotificationSound(
    ChangeNotificationSound event,
    Emitter<SettingsState> emit,
  ) async {
    final current = _current;
    if (current == null) return;
    final updated = current.copyWith(
      hapticSound:
          current.hapticSound.copyWith(notificationSound: event.sound),
    );
    await _saveAndEmit(updated, emit);
  }

  Future<void> _onChangeHapticIntensity(
    ChangeHapticIntensity event,
    Emitter<SettingsState> emit,
  ) async {
    final current = _current;
    if (current == null) return;
    final updated = current.copyWith(
      hapticSound:
          current.hapticSound.copyWith(hapticIntensity: event.intensity),
    );
    await _saveAndEmit(updated, emit);
    await feedbackCoordinator.triggerAction(updated.hapticSound);
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    final current = _current;
    if (current == null) return;
    final updated = current.copyWith(
      theme: current.theme.copyWith(themeMode: event.mode),
    );
    await _saveAndEmit(updated, emit);
  }

  Future<void> _onChangeThemeColor(
    ChangeThemeColor event,
    Emitter<SettingsState> emit,
  ) async {
    final current = _current;
    if (current == null) return;
    final updated = current.copyWith(
      theme: current.theme.copyWith(colorName: event.colorName),
    );
    await _saveAndEmit(updated, emit);
  }

  AppSettings? get _current {
    final s = state;
    return s is SettingsLoaded ? s.settings : null;
  }

  Future<void> _saveAndEmit(
    AppSettings settings,
    Emitter<SettingsState> emit,
  ) async {
    final result = await updateAppSettings(settings);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (saved) => emit(SettingsLoaded(saved)),
    );
  }
}
