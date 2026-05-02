import 'package:doit/features/timer/domain/entities/countdown_timer.dart';

class CountdownTimerModel extends CountdownTimer {
  const CountdownTimerModel({
    required super.id,
    required super.label,
    required super.durationSeconds,
    required super.createdAt,
  });

  factory CountdownTimerModel.fromMap(Map<String, dynamic> map) {
    return CountdownTimerModel(
      id: map['id'] as String,
      label: map['label'] as String,
      durationSeconds: map['duration_seconds'] as int,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  factory CountdownTimerModel.fromEntity(CountdownTimer entity) {
    return CountdownTimerModel(
      id: entity.id,
      label: entity.label,
      durationSeconds: entity.durationSeconds,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'duration_seconds': durationSeconds,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
