import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doit/core/services/feedback_coordinator.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/usecases/get_haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/usecases/update_haptic_sound_settings.dart';
import 'package:doit/features/settings/presentation/bloc/settings_event.dart';
import 'package:doit/features/settings/presentation/bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetHapticSoundSettings getHapticSoundSettings;
  final UpdateHapticSoundSettings updateHapticSoundSettings;
  final FeedbackCoordinator feedbackCoordinator;

  SettingsBloc({
    required this.getHapticSoundSettings,
    required this.updateHapticSoundSettings,
    required this.feedbackCoordinator,
  }) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleSound>(_onToggleSound);
    on<ToggleVibration>(_onToggleVibration);
    on<ChangeNotificationSound>(_onChangeNotificationSound);
    on<ChangeHapticIntensity>(_onChangeHapticIntensity);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await getHapticSoundSettings(const NoParams());
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> _onToggleSound(
    ToggleSound event,
    Emitter<SettingsState> emit,
  ) async {
    final current = _currentSettings;
    if (current == null) return;
    final updated = current.copyWith(soundEnabled: event.enabled);
    await _saveAndEmit(updated, emit);
  }

  Future<void> _onToggleVibration(
    ToggleVibration event,
    Emitter<SettingsState> emit,
  ) async {
    final current = _currentSettings;
    if (current == null) return;
    final updated = current.copyWith(vibrationEnabled: event.enabled);
    await _saveAndEmit(updated, emit);
    // Give immediate feedback when enabling vibration.
    if (event.enabled) {
      await feedbackCoordinator.triggerSelection(updated);
    }
  }

  Future<void> _onChangeNotificationSound(
    ChangeNotificationSound event,
    Emitter<SettingsState> emit,
  ) async {
    final current = _currentSettings;
    if (current == null) return;
    final updated = current.copyWith(notificationSound: event.sound);
    await _saveAndEmit(updated, emit);
  }

  Future<void> _onChangeHapticIntensity(
    ChangeHapticIntensity event,
    Emitter<SettingsState> emit,
  ) async {
    final current = _currentSettings;
    if (current == null) return;
    final updated = current.copyWith(hapticIntensity: event.intensity);
    await _saveAndEmit(updated, emit);
    // Give immediate feedback with the new intensity.
    await feedbackCoordinator.triggerAction(updated);
  }

  HapticSoundSettings? get _currentSettings {
    final s = state;
    return s is SettingsLoaded ? s.settings : null;
  }

  Future<void> _saveAndEmit(
    HapticSoundSettings settings,
    Emitter<SettingsState> emit,
  ) async {
    final result = await updateHapticSoundSettings(settings);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (saved) => emit(SettingsLoaded(saved)),
    );
  }
}
