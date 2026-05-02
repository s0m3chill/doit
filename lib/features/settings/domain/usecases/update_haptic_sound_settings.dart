import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/settings/domain/entities/app_settings.dart';
import 'package:doit/features/settings/domain/repositories/settings_repository.dart';

class UpdateAppSettings extends UseCase<AppSettings, AppSettings> {
  final SettingsRepository repository;

  UpdateAppSettings(this.repository);

  @override
  Future<Either<Failure, AppSettings>> call(AppSettings params) {
    return repository.saveSettings(params);
  }
}
