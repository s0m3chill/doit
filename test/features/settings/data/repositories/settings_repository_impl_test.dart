import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:doit/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';

class MockSettingsLocalDataSource extends Mock
    implements SettingsLocalDataSource {}

void main() {
  late SettingsRepositoryImpl repository;
  late MockSettingsLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSettingsLocalDataSource();
    repository = SettingsRepositoryImpl(localDataSource: mockDataSource);
  });

  group('getHapticSoundSettings', () {
    test('returns defaults when no settings stored', () async {
      when(() => mockDataSource.getAllSettings())
          .thenAnswer((_) async => {});

      final result = await repository.getHapticSoundSettings();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (settings) {
          expect(settings.soundEnabled, true);
          expect(settings.vibrationEnabled, true);
          expect(settings.notificationSound, 'default');
          expect(settings.hapticIntensity, 'medium');
        },
      );
    });

    test('returns stored settings', () async {
      when(() => mockDataSource.getAllSettings()).thenAnswer((_) async => {
            'sound_enabled': 'false',
            'vibration_enabled': 'true',
            'notification_sound': 'gentle',
            'haptic_intensity': 'light',
          });

      final result = await repository.getHapticSoundSettings();

      result.fold(
        (_) => fail('Should be Right'),
        (settings) {
          expect(settings.soundEnabled, false);
          expect(settings.vibrationEnabled, true);
          expect(settings.notificationSound, 'gentle');
          expect(settings.hapticIntensity, 'light');
        },
      );
    });

    test('returns DatabaseFailure on exception', () async {
      when(() => mockDataSource.getAllSettings())
          .thenThrow(const DatabaseException('error'));

      final result = await repository.getHapticSoundSettings();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('saveHapticSoundSettings', () {
    test('saves all settings and returns them', () async {
      when(() => mockDataSource.saveSetting(any(), any()))
          .thenAnswer((_) async {});

      const settings = HapticSoundSettings(
        soundEnabled: false,
        vibrationEnabled: true,
        notificationSound: 'urgent',
        hapticIntensity: 'heavy',
      );

      final result = await repository.saveHapticSoundSettings(settings);

      expect(result, Right(settings));
      verify(() => mockDataSource.saveSetting('sound_enabled', 'false'))
          .called(1);
      verify(() => mockDataSource.saveSetting('vibration_enabled', 'true'))
          .called(1);
      verify(() => mockDataSource.saveSetting('notification_sound', 'urgent'))
          .called(1);
      verify(() => mockDataSource.saveSetting('haptic_intensity', 'heavy'))
          .called(1);
    });

    test('returns DatabaseFailure on exception', () async {
      when(() => mockDataSource.saveSetting(any(), any()))
          .thenThrow(const DatabaseException('error'));

      final result = await repository
          .saveHapticSoundSettings(const HapticSoundSettings());

      expect(result.isLeft(), true);
    });
  });
}
