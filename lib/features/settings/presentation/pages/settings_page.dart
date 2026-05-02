import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doit/l10n/app_localizations.dart';
import 'package:doit/core/constants/app_constants.dart';
import 'package:doit/features/settings/domain/services/theme_color_palette.dart';
import 'package:doit/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:doit/features/settings/presentation/bloc/settings_event.dart';
import 'package:doit/features/settings/presentation/bloc/settings_state.dart';

/// Settings tab — Appearance, Notifications, About.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading || state is SettingsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsError) {
            return Center(child: Text(state.message));
          }
          if (state is! SettingsLoaded) return const SizedBox.shrink();

          final settings = state.settings;

          // Map persisted sound values to l10n labels
          String soundLabel(String value) {
            switch (value) {
              case 'default':
                return l10n.soundDefault;
              case 'gentle':
                return l10n.soundGentle;
              case 'urgent':
                return l10n.soundUrgent;
              case 'none':
                return l10n.soundSilent;
              default:
                return value;
            }
          }

          // Map persisted haptic values to l10n labels
          String hapticLabel(String value) {
            switch (value) {
              case 'light':
                return l10n.hapticLight;
              case 'medium':
                return l10n.hapticMedium;
              case 'heavy':
                return l10n.hapticHeavy;
              case 'none':
                return l10n.hapticOff;
              default:
                return value;
            }
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 16, bottom: 12),
                child: Text(
                  l10n.settingsTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ── Appearance ──
              _SectionHeader(title: l10n.appearance),
              _SettingsCard(
                children: [
                  // Theme mode
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.theme,
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 10),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                                value: 'system', label: Text(l10n.themeSystem)),
                            ButtonSegment(
                                value: 'light', label: Text(l10n.themeLight)),
                            ButtonSegment(
                                value: 'dark', label: Text(l10n.themeDark)),
                          ],
                          selected: {settings.theme.themeMode},
                          onSelectionChanged: (sel) {
                            context.read<SettingsBloc>().add(
                                  ChangeThemeMode(mode: sel.first),
                                );
                          },
                          showSelectedIcon: false,
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Color picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.accentColor,
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      _ColorGrid(
                        selectedId: settings.theme.colorName,
                        onSelected: (id) {
                          context.read<SettingsBloc>().add(
                                ChangeThemeColor(colorName: id),
                              );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // ── Language ──
              _SectionHeader(title: l10n.language),
              _SettingsCard(
                children: [
                  _LanguagePicker(
                    selected: settings.language,
                    onChanged: (lang) {
                      context.read<SettingsBloc>().add(
                            ChangeLanguage(language: lang),
                          );
                    },
                  ),
                ],
              ),

              // ── Notifications ──
              _SectionHeader(title: l10n.notifications),
              _SettingsCard(
                children: [
                  // Sound toggle
                  SwitchListTile(
                    title: Text(l10n.sound),
                    subtitle: Text(l10n.soundDescription),
                    value: settings.hapticSound.soundEnabled,
                    onChanged: (v) {
                      context
                          .read<SettingsBloc>()
                          .add(ToggleSound(enabled: v));
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Sound picker
                  if (settings.hapticSound.soundEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 8,
                        children:
                            AppConstants.notificationSounds.map((entry) {
                          final (value, _) = entry;
                          return ChoiceChip(
                            label: Text(soundLabel(value)),
                            selected:
                                settings.hapticSound.notificationSound ==
                                    value,
                            onSelected: (_) {
                              context.read<SettingsBloc>().add(
                                    ChangeNotificationSound(sound: value),
                                  );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const Divider(height: 1),
                  // Vibration toggle
                  SwitchListTile(
                    title: Text(l10n.vibration),
                    subtitle: Text(l10n.vibrationDescription),
                    value: settings.hapticSound.vibrationEnabled,
                    onChanged: (v) {
                      context
                          .read<SettingsBloc>()
                          .add(ToggleVibration(enabled: v));
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Haptic intensity
                  if (settings.hapticSound.vibrationEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Wrap(
                        spacing: 8,
                        children:
                            AppConstants.hapticIntensities.map((entry) {
                          final (value, _) = entry;
                          return ChoiceChip(
                            label: Text(hapticLabel(value)),
                            selected:
                                settings.hapticSound.hapticIntensity ==
                                    value,
                            onSelected: (_) {
                              context.read<SettingsBloc>().add(
                                    ChangeHapticIntensity(
                                        intensity: value),
                                  );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),

              // ── About ──
              _SectionHeader(title: l10n.about),
              _SettingsCard(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.appName,
                        style: theme.textTheme.titleMedium),
                    subtitle: Text(l10n.version('1.0.0')),
                    leading: ExcludeSemantics(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.check_circle,
                            color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ─── Settings card wrapper ──────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

// ─── Color grid ─────────────────────────────────────────────────────────────

class _ColorGrid extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _ColorGrid({required this.selectedId, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ThemeColorPalette.colors.map((c) {
        final isSelected = c.id == selectedId;
        final color = Color(c.hex);

        return GestureDetector(
          onTap: () => onSelected(c.id),
          child: Semantics(
            label: '${c.label} color${isSelected ? ', selected' : ''}',
            button: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 3)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: isSelected
                  ? const ExcludeSemantics(
                      child: Icon(Icons.check, color: Colors.white, size: 20),
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Language picker ────────────────────────────────────────────────────────

class _LanguagePicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LanguagePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final options = [
      ('system', l10n.languageSystem, '🌐'),
      ('en', l10n.languageEnglish, '🇬🇧'),
      ('uk', l10n.languageUkrainian, '🇺🇦'),
      ('pl', l10n.languagePolish, '🇵🇱'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((entry) {
        final (value, label, flag) = entry;
        final isSelected = selected == value;

        return ListTile(
          leading: Text(flag, style: const TextStyle(fontSize: 24)),
          title: Text(label),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: colorScheme.primary)
              : null,
          onTap: () => onChanged(value),
          dense: true,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}
