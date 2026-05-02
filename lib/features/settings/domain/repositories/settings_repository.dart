import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';

/// Repository contract for app settings persistence.
abstract class SettingsRepository {
  Future<Either<Failure, HapticSoundSettings>> getHapticSoundSettings();
  Future<Either<Failure, HapticSoundSettings>> saveHapticSoundSettings(
      HapticSoundSettings settings);
}
