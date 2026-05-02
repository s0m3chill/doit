import 'package:dartz/dartz.dart';
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:doit/features/settings/domain/entities/app_settings.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/entities/theme_settings.dart';
import 'package:doit/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  // Haptic/sound keys
  static const _soundEnabled = 'sound_enabled';
  static const _vibrationEnabled = 'vibration_enabled';
  static const _notificationSound = 'notification_sound';
  static const _hapticIntensity = 'haptic_intensity';

  // Theme keys
  static const _themeMode = 'theme_mode';
  static const _colorName = 'color_name';

  // Language key
  static const _language = 'language';

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final map = await localDataSource.getAllSettings();
      return Right(AppSettings(
        hapticSound: HapticSoundSettings(
          soundEnabled: map[_soundEnabled] != 'false',
          vibrationEnabled: map[_vibrationEnabled] != 'false',
          notificationSound: map[_notificationSound] ?? 'default',
          hapticIntensity: map[_hapticIntensity] ?? 'medium',
        ),
        theme: ThemeSettings(
          themeMode: map[_themeMode] ?? 'system',
          colorName: map[_colorName] ?? 'deepPurple',
        ),
        language: map[_language] ?? 'system',
      ));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> saveSettings(
      AppSettings settings) async {
    try {
      final hs = settings.hapticSound;
      await localDataSource.saveSetting(
          _soundEnabled, hs.soundEnabled.toString());
      await localDataSource.saveSetting(
          _vibrationEnabled, hs.vibrationEnabled.toString());
      await localDataSource.saveSetting(
          _notificationSound, hs.notificationSound);
      await localDataSource.saveSetting(
          _hapticIntensity, hs.hapticIntensity);

      final ts = settings.theme;
      await localDataSource.saveSetting(_themeMode, ts.themeMode);
      await localDataSource.saveSetting(_colorName, ts.colorName);

      await localDataSource.saveSetting(_language, settings.language);

      return Right(settings);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
