import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doit/features/reminder/domain/entities/quick_time_preset.dart';
import 'package:doit/features/reminder/domain/services/quick_time_presets.dart';

/// A compact 2×6 grid of quick-access time buttons.
/// Tapping a button calls [onTimeSelected] with the resolved DateTime.
///
/// Design rationale:
/// - Two rows: top row = relative offsets, bottom row = absolute times
/// - Each button shows icon + label + resolved time preview
/// - Compact enough to sit above a text field without scrolling
class QuickTimeGrid extends StatelessWidget {
  final void Function(DateTime selectedTime) onTimeSelected;
  final DateTime? currentSelection;
  final List<QuickTimePreset>? presets;

  const QuickTimeGrid({
    super.key,
    required this.onTimeSelected,
    this.currentSelection,
    this.presets,
  });

  @override
  Widget build(BuildContext context) {
    final items = presets ?? QuickTimePresets.defaults;
    final now = DateTime.now();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Quick set',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // Row 1: first 6 presets (relative offsets)
        _buildRow(context, items.take(6).toList(), now, colorScheme),
        const SizedBox(height: 8),
        // Row 2: last 6 presets (absolute times)
        _buildRow(context, items.skip(6).take(6).toList(), now, colorScheme),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    List<QuickTimePreset> rowPresets,
    DateTime now,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rowPresets.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final preset = rowPresets[index];
          final resolvedTime = preset.resolveFrom(now);
          final isSelected = currentSelection != null &&
              _isSameMinute(currentSelection!, resolvedTime);

          return _QuickTimeButton(
            preset: preset,
            resolvedTime: resolvedTime,
            isSelected: isSelected,
            colorScheme: colorScheme,
            onTap: () => onTimeSelected(resolvedTime),
          );
        },
      ),
    );
  }

  bool _isSameMinute(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }
}

class _QuickTimeButton extends StatelessWidget {
  final QuickTimePreset preset;
  final DateTime resolvedTime;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _QuickTimeButton({
    required this.preset,
    required this.resolvedTime,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm(); // e.g. "9:00 AM"
    final isToday = _isToday(resolvedTime);
    final subtitle =
        isToday ? timeFormat.format(resolvedTime) : _shortDate(resolvedTime);

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                preset.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                      : colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  String _shortDate(DateTime dt) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (dt.year == tomorrow.year &&
        dt.month == tomorrow.month &&
        dt.day == tomorrow.day) {
      return 'Tomorrow';
    }
    return DateFormat.MMMd().format(dt); // e.g. "Jun 15"
  }
}
