import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:doit/core/constants/app_constants.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:doit/features/reminder/presentation/widgets/quick_time_grid.dart';

/// Add or edit a reminder — polished card-based layout.
class AddEditReminderPage extends StatefulWidget {
  final Reminder? reminder;

  const AddEditReminderPage({super.key, this.reminder});

  @override
  State<AddEditReminderPage> createState() => _AddEditReminderPageState();
}

class _AddEditReminderPageState extends State<AddEditReminderPage> {
  late final TextEditingController _titleController;
  DateTime? _selectedDueDate;
  String _repeatInterval = AppConstants.repeatNone;
  bool _autoSnoozeEnabled = true;
  int _autoSnoozeInterval = 5;
  int _autoSnoozeMaxCount = 5;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _titleController = TextEditingController(text: r?.title ?? '');
    _selectedDueDate = r?.dueDate;
    _repeatInterval = r?.repeatInterval ?? AppConstants.repeatNone;
    _autoSnoozeEnabled = r?.autoSnoozeEnabled ?? true;
    _autoSnoozeInterval = r?.autoSnoozeInterval ?? 5;
    _autoSnoozeMaxCount = r?.autoSnoozeMaxCount ?? 5;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reminder' : 'New Reminder'),
        actions: [
          FilledButton(
            onPressed: _canSave ? _save : null,
            child: Text(_isEditing ? 'Save' : 'Add'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            _SectionCard(
              child: TextField(
                controller: _titleController,
                autofocus: !_isEditing,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.titleMedium,
                decoration: InputDecoration(
                  hintText: 'What do you need to do?',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),

            // ── Quick time grid ──
            _SectionCard(
              child: QuickTimeGrid(
                currentSelection: _selectedDueDate,
                onTimeSelected: (time) {
                  setState(() => _selectedDueDate = time);
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── Manual date/time picker ──
            _SectionCard(
              child: _DateTimeTile(
                value: _selectedDueDate,
                onTap: _pickDateTime,
              ),
            ),
            const SizedBox(height: 16),

            // ── Repeat ──
            _SectionCard(
              child: _RepeatSelector(
                value: _repeatInterval,
                onChanged: (v) => setState(() => _repeatInterval = v),
              ),
            ),
            const SizedBox(height: 16),

            // ── Auto-snooze ──
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Auto-snooze'),
                    subtitle: Text(
                      _autoSnoozeEnabled
                          ? 'Nags every $_autoSnoozeInterval min when overdue'
                          : 'Disabled',
                    ),
                    value: _autoSnoozeEnabled,
                    onChanged: (v) => setState(() => _autoSnoozeEnabled = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_autoSnoozeEnabled) ...[
                    const SizedBox(height: 4),
                    Text('Interval',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.snoozeIntervals.map((minutes) {
                        final isSelected = _autoSnoozeInterval == minutes;
                        return ChoiceChip(
                          label: Text(minutes >= 60
                              ? '${minutes ~/ 60}h'
                              : '${minutes}m'),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _autoSnoozeInterval = minutes),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('Max nags',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    _MaxSnoozeCountSelector(
                      value: _autoSnoozeMaxCount,
                      onChanged: (v) =>
                          setState(() => _autoSnoozeMaxCount = v),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty && _selectedDueDate != null;

  void _save() {
    if (!_canSave) return;

    final bloc = context.read<ReminderBloc>();

    if (_isEditing) {
      bloc.add(EditReminder(
        id: widget.reminder!.id,
        title: _titleController.text.trim(),
        dueDate: _selectedDueDate!,
        repeatInterval: _repeatInterval,
        autoSnoozeEnabled: _autoSnoozeEnabled,
        autoSnoozeInterval: _autoSnoozeInterval,
        autoSnoozeMaxCount: _autoSnoozeMaxCount,
      ));
    } else {
      bloc.add(AddReminder(
        title: _titleController.text.trim(),
        dueDate: _selectedDueDate!,
        repeatInterval: _repeatInterval,
        autoSnoozeEnabled: _autoSnoozeEnabled,
        autoSnoozeInterval: _autoSnoozeInterval,
        autoSnoozeMaxCount: _autoSnoozeMaxCount,
      ));
    }

    Navigator.of(context).pop();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          _selectedDueDate ?? now.add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }
}

// ─── Section card wrapper ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// ─── Date/time tile ─────────────────────────────────────────────────────────

class _DateTimeTile extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const _DateTimeTile({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatted = value != null
        ? DateFormat.yMMMd().add_jm().format(value!)
        : 'Tap to pick date & time';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.calendar_today,
              color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Due date', style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(
                  formatted,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: value != null
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_calendar,
              size: 18, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

// ─── Repeat selector ────────────────────────────────────────────────────────

class _RepeatSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _RepeatSelector({required this.value, required this.onChanged});

  static const _intervals = [
    (AppConstants.repeatNone, 'None'),
    (AppConstants.repeatDaily, 'Daily'),
    (AppConstants.repeatWeekly, 'Weekly'),
    (AppConstants.repeatMonthly, 'Monthly'),
    (AppConstants.repeatYearly, 'Yearly'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Repeat',
            style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _intervals.map((entry) {
            final (val, label) = entry;
            return ChoiceChip(
              label: Text(label),
              selected: value == val,
              onSelected: (_) => onChanged(val),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Max snooze count selector ──────────────────────────────────────────────

class _MaxSnoozeCountSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _MaxSnoozeCountSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 1-10 plus ∞ (0 = indefinite)
    final options = <int>[...List.generate(10, (i) => i + 1), 0];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((count) {
        final label = count == 0 ? '∞' : '$count';
        return ChoiceChip(
          label: Text(label),
          selected: value == count,
          onSelected: (_) => onChanged(count),
        );
      }).toList(),
    );
  }
}
