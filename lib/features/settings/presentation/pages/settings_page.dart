import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/locale/locale_cubit.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/theme/theme_cubit.dart';
import 'package:app_usage/core/widgets/g_card.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_scaffold.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/settings/presentation/widgets/badge_appearance_sheet.dart';
import 'package:app_usage/features/settings/presentation/widgets/settings_choice_segment.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// App settings: language, theme, and floating badge appearance.
///
/// How to use:
/// ```dart
/// // As a pushed route:
/// Navigator.of(context).pushNamed(PageName.settings);
///
/// // As a main-shell tab:
/// SettingsPage(embedded: true);
/// ```
class SettingsPage extends StatelessWidget {
  /// Creates the settings screen.
  ///
  /// When [embedded] is true, hides the back button (hosted by the main shell).
  const SettingsPage({super.key, this.embedded = false});

  /// True when shown inside [MainShellPage] instead of a pushed route.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GScaffold(
      title: l10n.settingsTitle,
      centerTitle: true,
      circularBackButton: !embedded,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          _SectionLabel(l10n.settingsPreferencesSection),
          GGap.s(),
          GCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PreferenceHeader(
                  icon: Icons.language_rounded,
                  label: l10n.switchLanguage,
                ),
                GGap.s(),
                BlocBuilder<LocaleCubit, Locale>(
                  builder: (context, locale) {
                    final isFa = locale.languageCode == 'fa';
                    return SettingsChoiceSegment(
                      choices: [
                        SettingsChoice(label: l10n.languageEnglish),
                        // Keep the native Persian spelling in both locales.
                        const SettingsChoice(label: 'فارسی'),
                      ],
                      selectedIndex: isFa ? 1 : 0,
                      onChanged: (index) {
                        context.read<LocaleCubit>().setLocale(
                              Locale(index == 1 ? 'fa' : 'en'),
                            );
                      },
                    );
                  },
                ),
                GGap.l(),
                _PreferenceHeader(
                  icon: Icons.palette_outlined,
                  label: l10n.settingsTheme,
                ),
                GGap.s(),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, mode) {
                    final isDark = mode == ThemeMode.dark;
                    return SettingsChoiceSegment(
                      choices: [
                        SettingsChoice(
                          label: l10n.themeLight,
                          icon: Icons.wb_sunny_outlined,
                        ),
                        SettingsChoice(
                          label: l10n.themeDark,
                          icon: Icons.dark_mode_outlined,
                        ),
                      ],
                      selectedIndex: isDark ? 1 : 0,
                      onChanged: (index) {
                        context.read<ThemeCubit>().setThemeMode(
                              index == 1 ? ThemeMode.dark : ThemeMode.light,
                            );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          GGap.l(),
          _SectionLabel(l10n.settingsTrackerSection),
          GGap.s(),
          GCard(
            child: GSettingsTile(
              icon: Icons.layers_rounded,
              iconColor: AppTheme.iconGreen,
              title: l10n.badgeAppearanceTitle,
              subtitle: l10n.badgeAppearanceSubtitle,
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.onSurfaceMuted,
              ),
              onTap: () => showBadgeAppearanceSheet(context),
            ),
          ),
          GGap.xl(),
          const _SettingsFooter(),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 18),
      child: GText(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
        color: AppTheme.onSurfaceMuted,
      ),
    );
  }
}

class _PreferenceHeader extends StatelessWidget {
  const _PreferenceHeader({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.onSurfaceOf(context)),
        const SizedBox(width: 10),
        GText(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _SettingsFooter extends StatelessWidget {
  const _SettingsFooter();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FooterLink(label: l10n.privacyPolicy),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GText(
                '·',
                color: AppTheme.onSurfaceMuted,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            _FooterLink(label: l10n.termsOfService),
          ],
        ),
        GGap.s(),
        GText(
          // Keep in sync with pubspec.yaml version.
          'v1.0.0',
          style: Theme.of(context).textTheme.bodySmall,
          color: AppTheme.onSurfaceMuted,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(label)),
        );
      },
      child: GText(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: AppTheme.onSurfaceMuted,
            ),
        color: AppTheme.onSurfaceMuted,
      ),
    );
  }
}
