import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_state.dart';
import 'package:doit/features/reminder/presentation/pages/add_edit_reminder_page.dart';

/// Reminders tab — search bar, active/completed toggle, swipeable cards, FAB.
class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  bool _showCompleted = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged(bool showCompleted) {
    setState(() => _showCompleted = showCompleted);
    final bloc = context.read<ReminderBloc>();
    if (showCompleted) {
      bloc.add(const LoadCompletedReminders());
    } else {
      bloc.add(const LoadActiveReminders());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<ReminderBloc, ReminderState>(
      listener: (context, state) {
        if (state is ReminderOperationSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          // Reload current list after operation
          final bloc = context.read<ReminderBloc>();
          if (_showCompleted) {
            bloc.add(const LoadCompletedReminders());
          } else {
            bloc.add(const LoadActiveReminders());
          }
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Reminders',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search reminders…',
                leading: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.search, size: 20),
                ),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<ReminderBloc>()
                            .add(const SearchRemindersEvent(query: ''));
                        setState(() {});
                      },
                    ),
                ],
                elevation: WidgetStatePropertyAll(0),
                backgroundColor:
                    WidgetStatePropertyAll(colorScheme.surfaceContainerHighest),
                onChanged: (query) {
                  context
                      .read<ReminderBloc>()
                      .add(SearchRemindersEvent(query: query));
                  setState(() {});
                },
              ),
            ),

            const SizedBox(height: 8),

            // Active / Completed toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Active')),
                  ButtonSegment(value: true, label: Text('Completed')),
                ],
                selected: {_showCompleted},
                onSelectionChanged: (sel) => _onTabChanged(sel.first),
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // List
            Expanded(
              child: BlocBuilder<ReminderBloc, ReminderState>(
                builder: (context, state) {
                  if (state is ReminderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ReminderError) {
                    return _EmptyState(
                      icon: Icons.error_outline,
                      message: state.message,
                    );
                  }
                  if (state is ReminderLoaded) {
                    if (state.reminders.isEmpty) {
                      return _EmptyState(
                        icon: _showCompleted
                            ? Icons.task_alt
                            : Icons.notifications_none,
                        message: _showCompleted
                            ? 'No completed reminders'
                            : 'No reminders yet.\nTap + to add one.',
                      );
                    }
                    return _ReminderListView(
                      reminders: state.reminders,
                      showCompleted: _showCompleted,
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
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

// ─── Reminder list view ─────────────────────────────────────────────────────

class _ReminderListView extends StatelessWidget {
  final List<Reminder> reminders;
  final bool showCompleted;

  const _ReminderListView({
    required this.reminders,
    required this.showCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        return _ReminderCard(
          reminder: reminders[index],
          showCompleted: showCompleted,
        );
      },
    );
  }
}

// ─── Reminder card ──────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final bool showCompleted;

  const _ReminderCard({required this.reminder, required this.showCompleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final isOverdue = reminder.isOverdue(now);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(reminder.id),
        // Swipe right → complete (start-to-end)
        // Swipe left  → delete  (end-to-start)
        background: _SwipeBackground(
          alignment: Alignment.centerLeft,
          color: Colors.green,
          icon: Icons.check,
          label: 'Complete',
        ),
        secondaryBackground: _SwipeBackground(
          alignment: Alignment.centerRight,
          color: colorScheme.error,
          icon: Icons.delete,
          label: 'Delete',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Complete
            context
                .read<ReminderBloc>()
                .add(MarkReminderComplete(id: reminder.id));
            return false; // bloc handles removal from list
          } else {
            // Delete
            return true;
          }
        },
        onDismissed: (_) {
          context.read<ReminderBloc>().add(RemoveReminder(id: reminder.id));
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isOverdue
                ? BorderSide(color: colorScheme.error.withValues(alpha: 0.5), width: 1.5)
                : BorderSide.none,
          ),
          color: isOverdue
              ? colorScheme.errorContainer.withValues(alpha: 0.3)
              : colorScheme.surfaceContainerHighest,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToEdit(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Left content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          reminder.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isOverdue ? FontWeight.w700 : FontWeight.w500,
                            color: isOverdue ? colorScheme.error : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Due date
                        Text(
                          _formatDueDate(reminder.dueDate, now),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOverdue
                                ? colorScheme.error.withValues(alpha: 0.8)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Badges row
                        _BadgeRow(reminder: reminder, isOverdue: isOverdue),
                      ],
                    ),
                  ),
                  // Trailing chevron
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    final bloc = context.read<ReminderBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AddEditReminderPage(reminder: reminder),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime dueDate, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = dueDay.difference(today).inDays;
    final timeStr = DateFormat.jm().format(dueDate);

    if (diff == 0) return 'Today $timeStr';
    if (diff == 1) return 'Tomorrow $timeStr';
    if (diff == -1) return 'Yesterday $timeStr';
    if (diff < -1) {
      return '${DateFormat.MMMd().format(dueDate)} $timeStr';
    }
    if (diff < 7) {
      return '${DateFormat.EEEE().format(dueDate)} $timeStr';
    }
    return '${DateFormat.MMMd().format(dueDate)} $timeStr';
  }
}

// ─── Badge row ──────────────────────────────────────────────────────────────

class _BadgeRow extends StatelessWidget {
  final Reminder reminder;
  final bool isOverdue;

  const _BadgeRow({required this.reminder, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chips = <Widget>[];

    if (reminder.recurrenceRule.isRecurring) {
      chips.add(_MiniChip(
        icon: Icons.repeat,
        label: reminder.recurrenceRule.description,
        color: colorScheme.primary,
      ));
    }

    if (reminder.autoSnoozeEnabled) {
      chips.add(_MiniChip(
        icon: Icons.snooze,
        label: '${reminder.autoSnoozeInterval}m',
        color: isOverdue ? colorScheme.error : colorScheme.tertiary,
      ));
    }

    if (isOverdue) {
      chips.add(_MiniChip(
        icon: Icons.warning_amber_rounded,
        label: 'Overdue',
        color: colorScheme.error,
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 6, runSpacing: 4, children: chips);
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─── Swipe background ───────────────────────────────────────────────────────

class _SwipeBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: Colors.white),
          if (alignment == Alignment.centerLeft) ...[
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}
