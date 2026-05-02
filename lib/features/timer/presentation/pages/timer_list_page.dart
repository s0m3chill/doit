import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doit/features/timer/domain/entities/countdown_timer.dart';
import 'package:doit/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:doit/features/timer/presentation/bloc/timer_event.dart';
import 'package:doit/features/timer/presentation/bloc/timer_state.dart';

/// Timers tab — list of timer templates with play/stop and circular progress.
class TimerListPage extends StatelessWidget {
  const TimerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TimerBloc, TimerState>(
      listener: (context, state) {
        if (state is TimerOperationSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          context.read<TimerBloc>().add(const LoadTimers());
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 16, bottom: 12),
              child: Row(
                children: [
                  Text(
                    'Timers',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: BlocBuilder<TimerBloc, TimerState>(
                builder: (context, state) {
                  if (state is TimerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TimerError) {
                    return _TimerEmptyState(
                      icon: Icons.error_outline,
                      message: state.message,
                    );
                  }
                  if (state is TimerLoaded) {
                    if (state.timers.isEmpty) {
                      return const _TimerEmptyState(
                        icon: Icons.timer_off_outlined,
                        message: 'No timers yet.\nTap + to create one.',
                      );
                    }
                    return _TimerListView(
                      timers: state.timers,
                      activeCountdowns: state.activeCountdowns,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────────────────

class _TimerEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _TimerEmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Timer list view ────────────────────────────────────────────────────────

class _TimerListView extends StatelessWidget {
  final List<CountdownTimer> timers;
  final Map<String, int> activeCountdowns;

  const _TimerListView({
    required this.timers,
    required this.activeCountdowns,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
      itemCount: timers.length,
      itemBuilder: (context, index) {
        final timer = timers[index];
        final remaining = activeCountdowns[timer.id];
        return _TimerCard(timer: timer, remainingSeconds: remaining);
      },
    );
  }
}

// ─── Timer card ─────────────────────────────────────────────────────────────

class _TimerCard extends StatelessWidget {
  final CountdownTimer timer;
  final int? remainingSeconds;

  const _TimerCard({required this.timer, this.remainingSeconds});

  bool get _isRunning => remainingSeconds != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(timer.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Delete',
                  style: TextStyle(
                      color: colorScheme.onError,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Icon(Icons.delete, color: colorScheme.onError),
            ],
          ),
        ),
        onDismissed: (_) {
          context.read<TimerBloc>().add(RemoveTimer(id: timer.id));
        },
        child: Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: _isRunning
              ? colorScheme.primaryContainer.withValues(alpha: 0.4)
              : colorScheme.surfaceContainerHighest,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Circular progress or static icon
                _isRunning
                    ? _CountdownIndicator(
                        remaining: remainingSeconds!,
                        total: timer.durationSeconds,
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primaryContainer,
                        ),
                        child: Icon(Icons.timer,
                            color: colorScheme.onPrimaryContainer),
                      ),
                const SizedBox(width: 16),
                // Label + duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timer.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isRunning
                            ? _formatSeconds(remainingSeconds!)
                            : timer.formattedDuration,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _isRunning
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              _isRunning ? FontWeight.w600 : FontWeight.normal,
                          fontFeatures: const [
                            FontFeature.tabularFigures()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Play / Stop button
                IconButton.filled(
                  onPressed: () {
                    final bloc = context.read<TimerBloc>();
                    if (_isRunning) {
                      bloc.add(CancelCountdown(timerId: timer.id));
                    } else {
                      bloc.add(StartCountdown(timerId: timer.id));
                    }
                  },
                  icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                  style: IconButton.styleFrom(
                    backgroundColor: _isRunning
                        ? colorScheme.error
                        : colorScheme.primary,
                    foregroundColor: _isRunning
                        ? colorScheme.onError
                        : colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSeconds(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ─── Circular countdown indicator ───────────────────────────────────────────

class _CountdownIndicator extends StatelessWidget {
  final int remaining;
  final int total;

  const _CountdownIndicator({required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = total > 0 ? remaining / total : 0.0;

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: colorScheme.primary,
          ),
          Text(
            '${remaining}s',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add timer dialog (shown from FAB in MainShellPage) ─────────────────────

/// Call this to show the add-timer dialog. Returns true if a timer was added.
Future<bool> showAddTimerDialog(BuildContext context) async {
  final result = await showDialog<_TimerDialogResult>(
    context: context,
    builder: (_) => const _AddTimerDialog(),
  );

  if (result != null) {
    if (context.mounted) {
      context.read<TimerBloc>().add(AddTimer(
            label: result.label,
            durationSeconds: result.durationSeconds,
          ));
    }
    return true;
  }
  return false;
}

class _TimerDialogResult {
  final String label;
  final int durationSeconds;
  const _TimerDialogResult(this.label, this.durationSeconds);
}

class _AddTimerDialog extends StatefulWidget {
  const _AddTimerDialog();

  @override
  State<_AddTimerDialog> createState() => _AddTimerDialogState();
}

class _AddTimerDialogState extends State<_AddTimerDialog> {
  final _labelController = TextEditingController();
  int _hours = 0;
  int _minutes = 5;
  int _seconds = 0;

  int get _totalSeconds => _hours * 3600 + _minutes * 60 + _seconds;
  bool get _canSave =>
      _labelController.text.trim().isNotEmpty && _totalSeconds > 0;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('New Timer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Timer label',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text('Duration',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            // Duration wheels
            SizedBox(
              height: 120,
              child: Row(
                children: [
                  _WheelColumn(
                    label: 'h',
                    value: _hours,
                    max: 23,
                    onChanged: (v) => setState(() => _hours = v),
                  ),
                  const SizedBox(width: 8),
                  _WheelColumn(
                    label: 'm',
                    value: _minutes,
                    max: 59,
                    onChanged: (v) => setState(() => _minutes = v),
                  ),
                  const SizedBox(width: 8),
                  _WheelColumn(
                    label: 's',
                    value: _seconds,
                    max: 59,
                    onChanged: (v) => setState(() => _seconds = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSave
              ? () => Navigator.pop(
                    context,
                    _TimerDialogResult(
                      _labelController.text.trim(),
                      _totalSeconds,
                    ),
                  )
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ─── Wheel column for duration picker ───────────────────────────────────────

class _WheelColumn extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              itemExtent: 32,
              physics: const FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: value),
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: max + 1,
                builder: (context, index) {
                  final isSelected = index == value;
                  return Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: isSelected ? 20 : 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
