import 'package:equatable/equatable.dart';

/// A single quick-access time preset.
/// Each preset has a display label and a resolver that computes
/// a concrete DateTime from the current time.
///
/// This is a pure domain object — no UI dependencies.
class QuickTimePreset extends Equatable {
  final String id;
  final String label;
  final String icon;
  final DateTime Function(DateTime now) resolve;

  const QuickTimePreset({
    required this.id,
    required this.label,
    required this.icon,
    required this.resolve,
  });

  /// Compute the target DateTime from the given [now].
  DateTime resolveFrom(DateTime now) => resolve(now);

  @override
  List<Object?> get props => [id, label, icon];
}
