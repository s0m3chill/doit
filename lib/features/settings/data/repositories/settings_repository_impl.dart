import 'package:dartz/dartz.dart';
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  // Key constants for the settings table.
  static const _soundEnabled = 'sound_enabled';
  static const _vibrationEnabled = 'vibration_enabled';
  static const _notificationSound = 'notification_sound';
  static const _hapticIntensity = 'haptic_intensity';

  @override
  Future<Either<Failure, HapticSoundSettings>>
      getHapticSoundSettings() async {
    try {
      final map = await localDataSource.getAllSettings();
      return Right(HapticSoundSettings(
        soundEnabled: map[_soundEnabled] != 'false',
        vibrationEnabled: map[_vibrationEnabled] != 'false',
        notificationSound: map[_notificationSound] ?? 'default',
        hapticIntensity: map[_hapticIntensity] ?? 'medium',
      ));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, HapticSoundSettings>> saveHapticSoundSettings(
      HapticSoundSettings settings) async {
    try {
      await localDataSource.saveSetting(
          _soundEnabled, settings.soundEnabled.toString());
      await localDataSource.saveSetting(
          _vibrationEnabled, settings.vibrationEnabled.toString());
      await localDataSource.saveSetting(
          _notificationSound, settings.notificationSound);
      await localDataSource.saveSetting(
          _hapticIntensity, settings.hapticIntensity);
      return Right(settings);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
