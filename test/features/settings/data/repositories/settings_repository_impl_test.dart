import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:doit/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:doit/features/settings/domain/entities/app_settings.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/entities/theme_settings.dart';

class MockSettingsLocalDataSource extends Mock
    implements SettingsLocalDataSource {}

void main() {
  late SettingsRepositoryImpl repository;
  late MockSettingsLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSettingsLocalDataSource();
    repository = SettingsRepositoryImpl(localDataSource: mockDataSource);
  });

  group('getSettings', () {
    test('returns defaults when no settings stored', () async {
      when(() => mockDataSource.getAllSettings())
          .thenAnswer((_) async => {});

      final result = await repository.getSettings();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (settings) {
          expect(settings.hapticSound.soundEnabled, true);
          expect(settings.hapticSound.vibrationEnabled, true);
          expect(settings.hapticSound.notificationSound, 'default');
          expect(settings.hapticSound.hapticIntensity, 'medium');
          expect(settings.theme.themeMode, 'system');
          expect(settings.theme.colorName, 'deepPurple');
        },
      );
    });

    test('returns stored settings including theme', () async {
      when(() => mockDataSource.getAllSettings()).thenAnswer((_) async => {
            'sound_enabled': 'false',
            'vibration_enabled': 'true',
            'notification_sound': 'gentle',
            'haptic_intensity': 'light',
            'theme_mode': 'dark',
            'color_name': 'blue',
          });

      final result = await repository.getSettings();

      result.fold(
        (_) => fail('Should be Right'),
        (settings) {
          expect(settings.hapticSound.soundEnabled, false);
          expect(settings.hapticSound.notificationSound, 'gentle');
          expect(settings.theme.themeMode, 'dark');
          expect(settings.theme.colorName, 'blue');
        },
      );
    });

    test('returns DatabaseFailure on exception', () async {
      when(() => mockDataSource.getAllSettings())
          .thenThrow(const DatabaseException('error'));

      final result = await repository.getSettings();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('saveSettings', () {
    test('saves all settings including theme and returns them', () async {
      when(() => mockDataSource.saveSetting(any(), any()))
          .thenAnswer((_) async {});

      const settings = AppSettings(
        hapticSound: HapticSoundSettings(
          soundEnabled: false,
          notificationSound: 'urgent',
        ),
        theme: ThemeSettings(themeMode: 'light', colorName: 'teal'),
      );

      final result = await repository.saveSettings(settings);

      expect(result, Right(settings));
      verify(() => mockDataSource.saveSetting('sound_enabled', 'false'))
          .called(1);
      verify(() => mockDataSource.saveSetting('theme_mode', 'light'))
          .called(1);
      verify(() => mockDataSource.saveSetting('color_name', 'teal'))
          .called(1);
    });

    test('returns DatabaseFailure on exception', () async {
      when(() => mockDataSource.saveSetting(any(), any()))
          .thenThrow(const DatabaseException('error'));

      final result =
          await repository.saveSettings(const AppSettings());

      expect(result.isLeft(), true);
    });
  });
}
