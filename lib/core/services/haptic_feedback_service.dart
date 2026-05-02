/// Domain-level contract for haptic feedback.
/// Abstracted so we can mock it in tests and respect user preferences.
abstract class HapticFeedbackService {
  Future<void> lightImpact();
  Future<void> mediumImpact();
  Future<void> heavyImpact();
  Future<void> selectionClick();
}
