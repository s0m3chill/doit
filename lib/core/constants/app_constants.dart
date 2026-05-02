/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'DoIt';
  static const String databaseName = 'doit.db';
  static const int databaseVersion = 1;

  // Default snooze intervals in minutes
  static const List<int> snoozeIntervals = [1, 5, 10, 15, 30, 60];

  // Default repeat intervals
  static const String repeatNone = 'none';
  static const String repeatDaily = 'daily';
  static const String repeatWeekly = 'weekly';
  static const String repeatMonthly = 'monthly';
  static const String repeatYearly = 'yearly';
}
