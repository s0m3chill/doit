import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/core/usecases/usecase.dart';
import 'package:doit/features/settings/domain/entities/app_settings.dart';
import 'package:doit/features/settings/domain/repositories/settings_repository.dart';

class GetAppSettings extends UseCase<AppSettings, NoParams> {
  final SettingsRepository repository;

  GetAppSettings(this.repository);

  @override
  Future<Either<Failure, AppSettings>> call(NoParams params) {
    return repository.getSettings();
  }
}
