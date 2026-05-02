import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:doit/core/constants/app_constants.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:doit/features/reminder/presentation/widgets/quick_time_grid.dart';

/// Add or edit a reminder.
/// When [reminder] is provided, we're editing; otherwise creating.
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
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reminder' : 'New Reminder'),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: Text(_isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextField(
              controller: _titleController,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'What do you need to do?',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Quick time grid — the star of the show
            QuickTimeGrid(
              currentSelection: _selectedDueDate,
              onTimeSelected: (time) {
                setState(() => _selectedDueDate = time);
              },
            ),
            const SizedBox(height: 16),

            // Manual date/time picker fallback
            _DateTimeTile(
              label: 'Due date',
              value: _selectedDueDate,
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 16),

            // Repeat interval
            _buildRepeatSelector(theme),
            const SizedBox(height: 16),

            // Auto-snooze toggle
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

            // Auto-snooze interval selector
            if (_autoSnoozeEnabled) ...[
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatSelector(ThemeData theme) {
    const intervals = [
      (AppConstants.repeatNone, 'None'),
      (AppConstants.repeatDaily, 'Daily'),
      (AppConstants.repeatWeekly, 'Weekly'),
      (AppConstants.repeatMonthly, 'Monthly'),
      (AppConstants.repeatYearly, 'Yearly'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Repeat', style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        )),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: intervals.map((entry) {
            final (value, label) = entry;
            return ChoiceChip(
              label: Text(label),
              selected: _repeatInterval == value,
              onSelected: (_) =>
                  setState(() => _repeatInterval = value),
            );
          }).toList(),
        ),
      ],
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
      ));
    } else {
      bloc.add(AddReminder(
        title: _titleController.text.trim(),
        dueDate: _selectedDueDate!,
        repeatInterval: _repeatInterval,
        autoSnoozeEnabled: _autoSnoozeEnabled,
        autoSnoozeInterval: _autoSnoozeInterval,
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
      firstDate: now,
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
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }
}

/// Tappable tile showing the selected date/time or a placeholder.
class _DateTimeTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = value != null
        ? DateFormat.yMMMd().add_jm().format(value!)
        : 'Tap to pick or use quick set above';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.calendar_today,
        color: theme.colorScheme.primary,
      ),
      title: Text(label),
      subtitle: Text(
        formatted,
        style: TextStyle(
          color: value != null
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
    );
  }
}
