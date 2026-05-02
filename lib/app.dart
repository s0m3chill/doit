import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:doit/l10n/app_localizations.dart';
import 'package:doit/core/di/injection_container.dart' as di;
import 'package:doit/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:doit/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:doit/features/settings/domain/services/theme_color_palette.dart';
import 'package:doit/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:doit/features/settings/presentation/bloc/settings_event.dart';
import 'package:doit/features/settings/presentation/bloc/settings_state.dart';
import 'package:doit/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:doit/features/timer/presentation/bloc/timer_event.dart';
import 'package:doit/features/shared/presentation/pages/main_shell_page.dart';

class DoItApp extends StatelessWidget {
  const DoItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<SettingsBloc>()..add(const LoadSettings()),
        ),
        BlocProvider(
          create: (_) =>
              di.sl<ReminderBloc>()..add(const LoadActiveReminders()),
        ),
        BlocProvider(
          create: (_) => di.sl<TimerBloc>()..add(const LoadTimers()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final colorSeed = _resolveColor(state);
          final themeMode = _resolveThemeMode(state);

          return MaterialApp(
            title: 'DoIt',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            // Localization
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              colorSchemeSeed: colorSeed,
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: colorSeed,
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            home: const MainShellPage(),
          );
        },
      ),
    );
  }

  Color _resolveColor(SettingsState state) {
    if (state is SettingsLoaded) {
      final hex =
          ThemeColorPalette.hexForName(state.settings.theme.colorName);
      return Color(hex);
    }
    return const Color(0xFF673AB7);
  }

  ThemeMode _resolveThemeMode(SettingsState state) {
    if (state is SettingsLoaded) {
      switch (state.settings.theme.themeMode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    }
    return ThemeMode.system;
  }
}
