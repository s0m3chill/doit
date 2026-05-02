import 'package:doit/features/reminder/data/models/reminder_model.dart';

/// Contract for the local data source.
/// Throws [DatabaseException] on failure — the repository converts these to [Failure]s.
abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getAllReminders();
  Future<List<ReminderModel>> getActiveReminders();
  Future<List<ReminderModel>> getCompletedReminders();
  Future<List<ReminderModel>> searchReminders(String query);
  Future<ReminderModel> getReminderById(String id);
  Future<ReminderModel> createReminder(ReminderModel reminder);
  Future<ReminderModel> updateReminder(ReminderModel reminder);
  Future<void> deleteReminder(String id);
}
