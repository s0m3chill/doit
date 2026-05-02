import 'package:dartz/dartz.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/settings/domain/entities/app_settings.dart';

/// Repository contract for all app settings persistence.
abstract class SettingsRepository {
  Future<Either<Failure, AppSettings>> getSettings();
  Future<Either<Failure, AppSettings>> saveSettings(AppSettings settings);
}
