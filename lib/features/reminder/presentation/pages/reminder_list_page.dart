import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_state.dart';

/// Main page — displays the list of active reminders.
/// UI is minimal for now; the structure is what matters.
class ReminderListPage extends StatelessWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DoIt'),
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
                return ListTile(
                  title: Text(reminder.title),
                  subtitle: Text(reminder.dueDate.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {
                      context
                          .read<ReminderBloc>()
                          .add(MarkReminderComplete(id: reminder.id));
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add reminder page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
