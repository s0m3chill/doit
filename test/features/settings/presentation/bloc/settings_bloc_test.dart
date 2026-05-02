import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/services/feedback_coordinator.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/usecases/get_haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/usecases/update_haptic_sound_settings.dart';
import 'package:doit/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:doit/features/settings/presentation/bloc/settings_event.dart';
import 'package:doit/features/settings/presentation/bloc/settings_state.dart';

class MockGetHapticSoundSettings extends Mock
    implements GetHapticSoundSettings {}

class MockUpdateHapticSoundSettings extends Mock
    implements UpdateHapticSoundSettings {}

class MockFeedbackCoordinator extends Mock implements FeedbackCoordinator {}

void main() {
  late SettingsBloc bloc;
  late MockGetHapticSoundSettings mockGet;
  late MockUpdateHapticSoundSettings mockUpdate;
  late MockFeedbackCoordinator mockFeedback;

  setUp(() {
    mockGet = MockGetHapticSoundSettings();
    mockUpdate = MockUpdateHapticSoundSettings();
    mockFeedback = MockFeedbackCoordinator();

    bloc = SettingsBloc(
      getHapticSoundSettings: mockGet,
      updateHapticSoundSettings: mockUpdate,
      feedbackCoordinator: mockFeedback,
    );
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const HapticSoundSettings());
  });

  tearDown(() => bloc.close());

  const defaultSettings = HapticSoundSettings();

  test('initial state is SettingsInitial', () {
    expect(bloc.state, const SettingsInitial());
  });

  group('LoadSettings', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits [Loading, Loaded] when successful',
      build: () {
        when(() => mockGet(any()))
            .thenAnswer((_) async => const Right(defaultSettings));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSettings()),
      expect: () => [
        const SettingsLoading(),
        const SettingsLoaded(defaultSettings),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits [Loading, Error] when fails',
      build: () {
        when(() => mockGet(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('error')));
        return bloc;
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
      seed: () => const SettingsLoaded(defaultSettings),
      build: () {
        final expected = defaultSettings.copyWith(soundEnabled: false);
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleSound(enabled: false)),
      expect: () => [
        SettingsLoaded(defaultSettings.copyWith(soundEnabled: false)),
      ],
    );
  });

  group('ToggleVibration', () {
    blocTest<SettingsBloc, SettingsState>(
      'enables vibration, saves, and triggers haptic feedback',
      seed: () => SettingsLoaded(
          defaultSettings.copyWith(vibrationEnabled: false)),
      build: () {
        final expected = defaultSettings.copyWith(vibrationEnabled: true);
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        when(() => mockFeedback.triggerSelection(any()))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleVibration(enabled: true)),
      expect: () => [
        const SettingsLoaded(defaultSettings),
      ],
      verify: (_) {
        verify(() => mockFeedback.triggerSelection(any())).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'disables vibration without triggering haptic',
      seed: () => const SettingsLoaded(defaultSettings),
      build: () {
        final expected = defaultSettings.copyWith(vibrationEnabled: false);
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleVibration(enabled: false)),
      expect: () => [
        SettingsLoaded(defaultSettings.copyWith(vibrationEnabled: false)),
      ],
      verify: (_) {
        verifyNever(() => mockFeedback.triggerSelection(any()));
      },
    );
  });

  group('ChangeNotificationSound', () {
    blocTest<SettingsBloc, SettingsState>(
      'changes sound to gentle',
      seed: () => const SettingsLoaded(defaultSettings),
      build: () {
        final expected =
            defaultSettings.copyWith(notificationSound: 'gentle');
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const ChangeNotificationSound(sound: 'gentle')),
      expect: () => [
        SettingsLoaded(
            defaultSettings.copyWith(notificationSound: 'gentle')),
      ],
    );
  });

  group('ChangeHapticIntensity', () {
    blocTest<SettingsBloc, SettingsState>(
      'changes intensity to heavy and triggers feedback',
      seed: () => const SettingsLoaded(defaultSettings),
      build: () {
        final expected =
            defaultSettings.copyWith(hapticIntensity: 'heavy');
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(expected));
        when(() => mockFeedback.triggerAction(any()))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const ChangeHapticIntensity(intensity: 'heavy')),
      expect: () => [
        SettingsLoaded(
            defaultSettings.copyWith(hapticIntensity: 'heavy')),
      ],
      verify: (_) {
        verify(() => mockFeedback.triggerAction(any())).called(1);
      },
    );
  });

  group('edge cases', () {
    blocTest<SettingsBloc, SettingsState>(
      'does nothing when toggling sound before settings are loaded',
      build: () => bloc,
      act: (bloc) => bloc.add(const ToggleSound(enabled: false)),
      expect: () => [],
    );
  });
}
