import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/services/feedback_coordinator.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/settings/domain/entities/app_settings.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/usecases/get_haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/usecases/update_haptic_sound_settings.dart';
import 'package:doit/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:doit/features/settings/presentation/bloc/settings_event.dart';
import 'package:doit/features/settings/presentation/bloc/settings_state.dart';

class MockGetAppSettings extends Mock implements GetAppSettings {}

class MockUpdateAppSettings extends Mock implements UpdateAppSettings {}

class MockFeedbackCoordinator extends Mock implements FeedbackCoordinator {}

void main() {
  late MockGetAppSettings mockGet;
  late MockUpdateAppSettings mockUpdate;
  late MockFeedbackCoordinator mockFeedback;

  setUp(() {
    mockGet = MockGetAppSettings();
    mockUpdate = MockUpdateAppSettings();
    mockFeedback = MockFeedbackCoordinator();
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const AppSettings());
    registerFallbackValue(const HapticSoundSettings());
  });

  SettingsBloc buildBloc() => SettingsBloc(
        getAppSettings: mockGet,
        updateAppSettings: mockUpdate,
        feedbackCoordinator: mockFeedback,
      );

  const defaults = AppSettings();

  test('initial state is SettingsInitial', () {
    final bloc = buildBloc();
    expect(bloc.state, const SettingsInitial());
    bloc.close();
  });

  group('LoadSettings', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits [Loading, Loaded] when successful',
      build: () {
        when(() => mockGet(any()))
            .thenAnswer((_) async => const Right(defaults));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadSettings()),
      expect: () => [
        const SettingsLoading(),
        const SettingsLoaded(defaults),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits [Loading, Error] when fails',
      build: () {
        when(() => mockGet(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('error')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadSettings()),
      expect: () => [
        const SettingsLoading(),
        const SettingsError('error'),
      ],
    );
  });

  group('ToggleSound', () {
    blocTest<SettingsBloc, SettingsState>(
      'disables sound and saves',
      seed: () => const SettingsLoaded(defaults),
      build: () {
        final expected = defaults.copyWith(
          hapticSound: defaults.hapticSound.copyWith(soundEnabled: false),
        );
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ToggleSound(enabled: false)),
      expect: () => [
        SettingsLoaded(defaults.copyWith(
          hapticSound: defaults.hapticSound.copyWith(soundEnabled: false),
        )),
      ],
    );
  });

  group('ToggleVibration', () {
    blocTest<SettingsBloc, SettingsState>(
      'enables vibration and triggers haptic feedback',
      seed: () => SettingsLoaded(defaults.copyWith(
        hapticSound: defaults.hapticSound.copyWith(vibrationEnabled: false),
      )),
      build: () {
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => const Right(defaults));
        when(() => mockFeedback.triggerSelection(any()))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ToggleVibration(enabled: true)),
      expect: () => [const SettingsLoaded(defaults)],
      verify: (_) {
        verify(() => mockFeedback.triggerSelection(any())).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'disables vibration without triggering haptic',
      seed: () => const SettingsLoaded(defaults),
      build: () {
        final expected = defaults.copyWith(
          hapticSound:
              defaults.hapticSound.copyWith(vibrationEnabled: false),
        );
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ToggleVibration(enabled: false)),
      expect: () => [
        SettingsLoaded(defaults.copyWith(
          hapticSound:
              defaults.hapticSound.copyWith(vibrationEnabled: false),
        )),
      ],
      verify: (_) {
        verifyNever(() => mockFeedback.triggerSelection(any()));
      },
    );
  });

  group('ChangeNotificationSound', () {
    blocTest<SettingsBloc, SettingsState>(
      'changes sound to gentle',
      seed: () => const SettingsLoaded(defaults),
      build: () {
        final expected = defaults.copyWith(
          hapticSound:
              defaults.hapticSound.copyWith(notificationSound: 'gentle'),
        );
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const ChangeNotificationSound(sound: 'gentle')),
      expect: () => [
        SettingsLoaded(defaults.copyWith(
          hapticSound:
              defaults.hapticSound.copyWith(notificationSound: 'gentle'),
        )),
      ],
    );
  });

  group('ChangeHapticIntensity', () {
    blocTest<SettingsBloc, SettingsState>(
      'changes intensity to heavy and triggers feedback',
      seed: () => const SettingsLoaded(defaults),
      build: () {
        final expected = defaults.copyWith(
          hapticSound:
              defaults.hapticSound.copyWith(hapticIntensity: 'heavy'),
        );
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        when(() => mockFeedback.triggerAction(any()))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const ChangeHapticIntensity(intensity: 'heavy')),
      expect: () => [
        SettingsLoaded(defaults.copyWith(
          hapticSound:
              defaults.hapticSound.copyWith(hapticIntensity: 'heavy'),
        )),
      ],
      verify: (_) {
        verify(() => mockFeedback.triggerAction(any())).called(1);
      },
    );
  });

  group('ChangeThemeMode', () {
    blocTest<SettingsBloc, SettingsState>(
      'changes theme mode to dark',
      seed: () => const SettingsLoaded(defaults),
      build: () {
        final expected = defaults.copyWith(
          theme: defaults.theme.copyWith(themeMode: 'dark'),
        );
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ChangeThemeMode(mode: 'dark')),
      expect: () => [
        SettingsLoaded(defaults.copyWith(
          theme: defaults.theme.copyWith(themeMode: 'dark'),
        )),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'changes theme mode to light',
      seed: () => const SettingsLoaded(defaults),
      build: () {
        final expected = defaults.copyWith(
          theme: defaults.theme.copyWith(themeMode: 'light'),
        );
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ChangeThemeMode(mode: 'light')),
      expect: () => [
        SettingsLoaded(defaults.copyWith(
          theme: defaults.theme.copyWith(themeMode: 'light'),
        )),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'changes theme mode to system',
      seed: () => SettingsLoaded(defaults.copyWith(
        theme: defaults.theme.copyWith(themeMode: 'dark'),
      )),
      build: () {
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => const Right(defaults));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ChangeThemeMode(mode: 'system')),
      expect: () => [const SettingsLoaded(defaults)],
    );
  });

  group('ChangeThemeColor', () {
    blocTest<SettingsBloc, SettingsState>(
      'changes color to blue',
      seed: () => const SettingsLoaded(defaults),
      build: () {
        final expected = defaults.copyWith(
          theme: defaults.theme.copyWith(colorName: 'blue'),
        );
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const ChangeThemeColor(colorName: 'blue')),
      expect: () => [
        SettingsLoaded(defaults.copyWith(
          theme: defaults.theme.copyWith(colorName: 'blue'),
        )),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'changes color to red',
      seed: () => const SettingsLoaded(defaults),
      build: () {
        final expected = defaults.copyWith(
          theme: defaults.theme.copyWith(colorName: 'red'),
        );
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const ChangeThemeColor(colorName: 'red')),
      expect: () => [
        SettingsLoaded(defaults.copyWith(
          theme: defaults.theme.copyWith(colorName: 'red'),
        )),
      ],
    );
  });

  group('edge cases', () {
    blocTest<SettingsBloc, SettingsState>(
      'does nothing when changing theme before settings are loaded',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const ChangeThemeMode(mode: 'dark')),
      expect: () => [],
    );

    blocTest<SettingsBloc, SettingsState>(
      'does nothing when changing color before settings are loaded',
      build: () => buildBloc(),
      act: (bloc) =>
          bloc.add(const ChangeThemeColor(colorName: 'blue')),
      expect: () => [],
    );
  });
}
