import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doit/features/reminder/domain/services/natural_date_parser.dart';

/// A text field that parses natural language date/time as the user types.
/// Shows a suggestion chip below the field when a date is recognized.
/// Tapping the chip confirms the parsed date.
class NaturalDateInput extends StatefulWidget {
  final void Function(DateTime parsedDate) onDateParsed;
  final DateTime? currentSelection;

  const NaturalDateInput({
    super.key,
    required this.onDateParsed,
    this.currentSelection,
  });

  @override
  State<NaturalDateInput> createState() => _NaturalDateInputState();
}

class _NaturalDateInputState extends State<NaturalDateInput> {
  final _controller = TextEditingController();
  final _parser = NaturalDateParser();
  DateTime? _parsedDate;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final result = _parser.parse(text);
    setState(() => _parsedDate = result);
  }

  void _confirmDate() {
    if (_parsedDate != null) {
      widget.onDateParsed(_parsedDate!);
      _controller.clear();
      setState(() => _parsedDate = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Type a date',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'e.g. "tomorrow at 3pm", "in 2 hours"',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: _parsedDate != null
                ? IconButton(
                    icon: Icon(Icons.check_circle, color: colorScheme.primary),
                    onPressed: _confirmDate,
                  )
                : null,
          ),
          onChanged: _onTextChanged,
          onSubmitted: (_) => _confirmDate(),
          textInputAction: TextInputAction.done,
        ),
        // Suggestion chip
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _parsedDate != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: _confirmDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event,
                              size: 16,
                              color: colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            _formatParsedDate(_parsedDate!),
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tap to set',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _formatParsedDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;
    final timeStr = DateFormat.jm().format(dt);

    if (diff == 0) return 'Today $timeStr';
    if (diff == 1) return 'Tomorrow $timeStr';
    if (diff < 7) return '${DateFormat.EEEE().format(dt)} $timeStr';
    return '${DateFormat.MMMd().format(dt)} $timeStr';
  }
}
