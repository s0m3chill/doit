import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doit/l10n/app_localizations.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_state.dart';
import 'package:doit/features/reminder/presentation/pages/reminder_list_page.dart';
import 'package:doit/features/reminder/presentation/pages/add_edit_reminder_page.dart';
import 'package:doit/features/timer/presentation/pages/timer_list_page.dart';
import 'package:doit/features/settings/presentation/pages/settings_page.dart';

/// Root shell with bottom navigation — three tabs: Reminders, Timers, Settings.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    ReminderListPage(),
    TimerListPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ReminderBloc>().add(const RefreshOverdueCount());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // FAB for Reminders (index 0) and Timers (index 1)
      floatingActionButton: _currentIndex < 2
          ? Semantics(
              label: l10n.newReminder,
              button: true,
              child: FloatingActionButton(
                onPressed: () => _onFabPressed(context),
                child: ExcludeSemantics(child: const Icon(Icons.add)),
              ),
            )
          : null,
      bottomNavigationBar: BlocBuilder<ReminderBloc, ReminderState>(
        buildWhen: (prev, curr) {
          final prevCount =
              prev is ReminderLoaded ? prev.overdueCount : 0;
          final currCount =
              curr is ReminderLoaded ? curr.overdueCount : 0;
          return prevCount != currCount;
        },
        builder: (context, state) {
          final overdueCount =
              state is ReminderLoaded ? state.overdueCount : 0;

          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              NavigationDestination(
                icon: Semantics(
                  label: l10n.remindersTab,
                  child: Badge(
                    isLabelVisible: overdueCount > 0,
                    label: Text('$overdueCount'),
                    child: const Icon(Icons.notifications_active_outlined),
                  ),
                ),
                selectedIcon: Semantics(
                  label: l10n.remindersTab,
                  child: Badge(
                    isLabelVisible: overdueCount > 0,
                    label: Text('$overdueCount'),
                    child: const Icon(Icons.notifications_active),
                  ),
                ),
                label: l10n.remindersTab,
              ),
              NavigationDestination(
                icon: Semantics(
                  label: l10n.timersTab,
                  child: const Icon(Icons.timer_outlined),
                ),
                selectedIcon: Semantics(
                  label: l10n.timersTab,
                  child: const Icon(Icons.timer),
                ),
                label: l10n.timersTab,
              ),
              NavigationDestination(
                icon: Semantics(
                  label: l10n.settingsTab,
                  child: const Icon(Icons.settings_outlined),
                ),
                selectedIcon: Semantics(
                  label: l10n.settingsTab,
                  child: const Icon(Icons.settings),
                ),
                label: l10n.settingsTab,
              ),
            ],
          );
        },
      ),
    );
  }

  void _onFabPressed(BuildContext context) {
    if (_currentIndex == 0) {
      // Add reminder
      final bloc = context.read<ReminderBloc>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const AddEditReminderPage(),
          ),
        ),
      );
    } else if (_currentIndex == 1) {
      // Add timer
      showAddTimerDialog(context);
    }
  }
}
