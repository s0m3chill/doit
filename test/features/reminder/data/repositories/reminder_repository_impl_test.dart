import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/error/exceptions.dart';
import 'package:doit/core/error/failures.dart';
import 'package:doit/features/reminder/data/datasources/reminder_local_data_source.dart';
import 'package:doit/features/reminder/data/models/reminder_model.dart';
import 'package:doit/features/reminder/data/repositories/reminder_repository_impl.dart';

class MockLocalDataSource extends Mock implements ReminderLocalDataSource {}

void main() {
  late ReminderRepositoryImpl repository;
  late MockLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLocalDataSource();
    repository = ReminderRepositoryImpl(localDataSource: mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(ReminderModel(
      id: 'fallback',
      title: 'fallback',
      dueDate: DateTime(2025),
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ));
  });

  final now = DateTime(2025, 1, 1);
  final tModel = ReminderModel(
    id: '1',
    title: 'Test',
    dueDate: now,
    autoSnoozeEnabled: true,
    autoSnoozeInterval: 5,
    createdAt: now,
    updatedAt: now,
  );
  final tModels = [tModel];

  group('getAllReminders', () {
    test('should return list of reminders on success', () async {
      when(() => mockDataSource.getAllReminders())
          .thenAnswer((_) async => tModels);

      final result = await repository.getAllReminders();

      expect(result, Right(tModels));
    });

    test('should return DatabaseFailure on exception', () async {
      when(() => mockDataSource.getAllReminders())
          .thenThrow(const DatabaseException('error'));

      final result = await repository.getAllReminders();

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('createReminder', () {
    test('should return created reminder on success', () async {
      when(() => mockDataSource.createReminder(any()))
          .thenAnswer((_) async => tModel);

      final result = await repository.createReminder(tModel);

      expect(result, Right(tModel));
    });

    test('should return DatabaseFailure on exception', () async {
      when(() => mockDataSource.createReminder(any()))
          .thenThrow(const DatabaseException('error'));

      final result = await repository.createReminder(tModel);

      expect(result, isA<Left>());
    });
  });

  group('deleteReminder', () {
    test('should return Right(null) on success', () async {
      when(() => mockDataSource.deleteReminder(any()))
          .thenAnswer((_) async {});

      final result = await repository.deleteReminder('1');

      expect(result, const Right(null));
    });

    test('should return DatabaseFailure on exception', () async {
      when(() => mockDataSource.deleteReminder(any()))
          .thenThrow(const DatabaseException('error'));

      final result = await repository.deleteReminder('1');

      expect(result, isA<Left>());
    });
  });

  group('completeReminder', () {
    test('should mark reminder as completed', () async {
      when(() => mockDataSource.getReminderById('1'))
          .thenAnswer((_) async => tModel);
      when(() => mockDataSource.updateReminder(any()))
          .thenAnswer((_) async => ReminderModel(
                id: tModel.id,
                title: tModel.title,
                dueDate: tModel.dueDate,
                isCompleted: true,
                autoSnoozeEnabled: tModel.autoSnoozeEnabled,
                autoSnoozeInterval: tModel.autoSnoozeInterval,
                createdAt: tModel.createdAt,
                updatedAt: tModel.updatedAt,
              ));

      final result = await repository.completeReminder('1');

      expect(result, isA<Right>());
      final captured =
          verify(() => mockDataSource.updateReminder(captureAny())).captured;
      expect((captured.first as ReminderModel).isCompleted, true);
    });
  });

  group('snoozeReminder', () {
    test('should update due date with snooze duration', () async {
      when(() => mockDataSource.getReminderById('1'))
          .thenAnswer((_) async => tModel);
      when(() => mockDataSource.updateReminder(any()))
          .thenAnswer((invocation) async =>
              invocation.positionalArguments.first as ReminderModel);

      final result = await repository.snoozeReminder('1', 15);

      expect(result, isA<Right>());
      final captured =
          verify(() => mockDataSource.updateReminder(captureAny())).captured;
      final snoozed = captured.first as ReminderModel;
      expect(snoozed.snoozeMinutes, 15);
      expect(snoozed.isCompleted, false);
    });
  });
}
