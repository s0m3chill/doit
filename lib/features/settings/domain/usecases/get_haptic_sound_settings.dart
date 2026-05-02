import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';
import 'package:doit/features/settings/domain/repositories/settings_repository.dart';

class GetHapticSoundSettings
    extends UseCase<HapticSoundSettings, NoParams> {
  final SettingsRepository repository;

  GetHapticSoundSettings(this.repository);

  @override
  Future<Either<Failure, HapticSoundSettings>> call(NoParams params) {
    return repository.getHapticSoundSettings();
  }
}
