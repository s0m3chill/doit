import 'package:doit/core/services/haptic_feedback_service.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';

/// Coordinates haptic feedback based on user settings.
/// Single responsibility: decide which haptic to fire (or none) given the
/// current settings and the type of user action.
class FeedbackCoordinator {
  final HapticFeedbackService _hapticService;

  FeedbackCoordinator({required HapticFeedbackService hapticService})
      : _hapticService = hapticService;

  /// Fire haptic feedback for a user action (e.g., completing a reminder,
  /// tapping a quick-time button). Respects the user's settings.
  Future<void> triggerAction(HapticSoundSettings settings) async {
    if (!settings.vibrationEnabled) return;

    switch (settings.hapticIntensity) {
      case 'light':
        await _hapticService.lightImpact();
      case 'medium':
        await _hapticService.mediumImpact();
      case 'heavy':
        await _hapticService.heavyImpact();
      case 'none':
        break;
      default:
        await _hapticService.mediumImpact();
    }
  }

  /// Fire a subtle selection haptic (e.g., toggling a switch, picking a chip).
  Future<void> triggerSelection(HapticSoundSettings settings) async {
    if (!settings.vibrationEnabled || settings.hapticIntensity == 'none') {
      return;
    }
    await _hapticService.selectionClick();
  }
}
