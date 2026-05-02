import 'package:flutter/services.dart';
import 'package:doit/core/services/haptic_feedback_service.dart';

/// Concrete implementation wrapping Flutter's HapticFeedback.
class HapticFeedbackServiceImpl implements HapticFeedbackService {
  @override
  Future<void> lightImpact() => HapticFeedback.lightImpact();

  @override
  Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  @override
  Future<void> heavyImpact() => HapticFeedback.heavyImpact();

  @override
  Future<void> selectionClick() => HapticFeedback.selectionClick();
}
