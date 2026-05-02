/// Contract for settings local persistence.
abstract class SettingsLocalDataSource {
  Future<Map<String, String>> getAllSettings();
  Future<void> saveSetting(String key, String value);
}
