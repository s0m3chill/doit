import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doit/core/services/feedback_coordinator.dart';
import 'package:doit/core/services/haptic_feedback_service.dart';
import 'package:doit/features/settings/domain/entities/haptic_sound_settings.dart';

class MockHapticFeedbackService extends Mock
    implements HapticFeedbackService {}

void main() {
  late FeedbackCoordinator coordinator;
  late MockHapticFeedbackService mockHaptic;

  setUp(() {
    mockHaptic = MockHapticFeedbackService();
    coordinator = FeedbackCoordinator(hapticService: mockHaptic);

    when(() => mockHaptic.lightImpact()).thenAnswer((_) async {});
    when(() => mockHaptic.mediumImpact()).thenAnswer((_) async {});
    when(() => mockHaptic.heavyImpact()).thenAnswer((_) async {});
    when(() => mockHaptic.selectionClick()).thenAnswer((_) async {});
  });

  group('triggerAction', () {
    test('fires light impact when intensity is light', () async {
      const settings = HapticSoundSettings(hapticIntensity: 'light');
      await coordinator.triggerAction(settings);
      verify(() => mockHaptic.lightImpact()).called(1);
    });

    test('fires medium impact when intensity is medium', () async {
      const settings = HapticSoundSettings(hapticIntensity: 'medium');
      await coordinator.triggerAction(settings);
      verify(() => mockHaptic.mediumImpact()).called(1);
    });

    test('fires heavy impact when intensity is heavy', () async {
      const settings = HapticSoundSettings(hapticIntensity: 'heavy');
      await coordinator.triggerAction(settings);
      verify(() => mockHaptic.heavyImpact()).called(1);
    });

    test('does nothing when intensity is none', () async {
      const settings = HapticSoundSettings(hapticIntensity: 'none');
      await coordinator.triggerAction(settings);
      verifyNever(() => mockHaptic.lightImpact());
      verifyNever(() => mockHaptic.mediumImpact());
      verifyNever(() => mockHaptic.heavyImpact());
    });

    test('does nothing when vibration is disabled', () async {
      const settings = HapticSoundSettings(
        vibrationEnabled: false,
        hapticIntensity: 'heavy',
      );
      await coordinator.triggerAction(settings);
      verifyNever(() => mockHaptic.heavyImpact());
    });

    test('defaults to medium for unknown intensity', () async {
      const settings = HapticSoundSettings(hapticIntensity: 'unknown');
      await coordinator.triggerAction(settings);
      verify(() => mockHaptic.mediumImpact()).called(1);
    });
  });

  group('triggerSelection', () {
    test('fires selection click when vibration enabled', () async {
      const settings = HapticSoundSettings();
      await coordinator.triggerSelection(settings);
      verify(() => mockHaptic.selectionClick()).called(1);
    });

    test('does nothing when vibration disabled', () async {
      const settings = HapticSoundSettings(vibrationEnabled: false);
      await coordinator.triggerSelection(settings);
      verifyNever(() => mockHaptic.selectionClick());
    });

    test('does nothing when haptic intensity is none', () async {
      const settings = HapticSoundSettings(hapticIntensity: 'none');
      await coordinator.triggerSelection(settings);
      verifyNever(() => mockHaptic.selectionClick());
    });
  });
}
