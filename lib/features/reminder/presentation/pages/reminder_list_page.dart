import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:doit/features/reminder/domain/entities/reminder.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_state.dart';
import 'package:doit/features/reminder/presentation/pages/add_edit_reminder_page.dart';

/// Main page — displays the list of active reminders.
class ReminderListPage extends StatelessWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DoIt'),
        actions: [
          BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, state) {
              final overdueCount =
                  state is ReminderLoaded ? state.overdueCount : 0;
              if (overdueCount == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Badge(
                  label: Text('$overdueCount'),
                  child: const Icon(Icons.notifications_active),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReminderError) {
            return Center(child: Text(state.message));
          }
          if (state is ReminderLoaded) {
            if (state.reminders.isEmpty) {
              return const Center(
                child: Text('No reminders yet. Tap + to add one.'),
              );
            }
            return ListView.builder(
              itemCount: state.reminders.length,
              itemBuilder: (context, index) {
                final reminder = state.reminders[index];
                return _ReminderTile(reminder: reminder);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    final bloc = context.read<ReminderBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const AddEditReminderPage(),
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;

  const _ReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = reminder.isOverdue(DateTime.now());
    final timeFormat = DateFormat.yMMMd().add_jm();

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) {
        context.read<ReminderBloc>().add(RemoveReminder(id: reminder.id));
      },
      child: ListTile(
        title: Text(
          reminder.title,
          style: TextStyle(
            color: isOverdue ? theme.colorScheme.error : null,
            fontWeight: isOverdue ? FontWeight.w600 : null,
          ),
        ),
        subtitle: Text(
          timeFormat.format(reminder.dueDate),
          style: TextStyle(
            color: isOverdue ? theme.colorScheme.error.withValues(alpha: 0.7) : null,
          ),
        ),
        leading: Icon(
          reminder.isRecurring ? Icons.repeat : Icons.notifications_none,
          color: isOverdue ? theme.colorScheme.error : null,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () {
            context
                .read<ReminderBloc>()
                .add(MarkReminderComplete(id: reminder.id));
          },
        ),
        onTap: () => _navigateToEdit(context),
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
}
