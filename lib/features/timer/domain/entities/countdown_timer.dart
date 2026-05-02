import 'package:equatable/equatable.dart';

/// Domain entity for a reusable countdown timer.
/// Timers are templates — you create one, then start it whenever you need it.
class CountdownTimer extends Equatable {
  final String id;
  final String label;
  final int durationSeconds;
  final DateTime createdAt;

  const CountdownTimer({
    required this.id,
    required this.label,
    required this.durationSeconds,
    required this.createdAt,
  });

  CountdownTimer copyWith({
    String? id,
    String? label,
    int? durationSeconds,
    DateTime? createdAt,
  }) {
    return CountdownTimer(
      id: id ?? this.id,
      label: label ?? this.label,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Format duration as mm:ss or hh:mm:ss.
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [id, label, durationSeconds, createdAt];
}
