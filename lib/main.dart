import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_usage/core/locale/locale_cubit.dart';
import 'package:app_usage/core/locator/locator.dart';
import 'package:app_usage/core/router/page_name.dart';
import 'package:app_usage/core/router/page_router.dart';
import 'package:app_usage/core/settings/app_timer_cubit.dart';
import 'package:app_usage/core/settings/badge_appearance_cubit.dart';
import 'package:app_usage/core/settings/blocked_apps_cubit.dart';
import 'package:app_usage/core/settings/coach_settings_cubit.dart';
import 'package:app_usage/core/settings/holiday_settings_cubit.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/theme/theme_cubit.dart';
import 'package:app_usage/features/app_usage/presentation/overlay/overlay_app.dart';
import 'package:app_usage/features/drive_sync/domain/drive_sync_service.dart';
import 'package:app_usage/features/drive_sync/drive_sync_scheduler.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// App entrypoint.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();

  // Catch up any missed noon uploads, then schedule the next daily attempt.
  // ignore: unawaited_futures
  locator<DriveSyncService>().syncNow();
  await scheduleDailyDriveSync();

  runApp(const AppUsageApp());
}

/// Separate Flutter entrypoint for the floating overlay window.
///
/// How to use: started by `flutter_overlay_window` when the overlay is shown.
/// Must live in this library so the plugin can discover it.
///
/// [DartPluginRegistrant.ensureInitialized] is required so UsageStats and
/// SharedPreferences work in this secondary isolate — otherwise the badge can
/// start at `00:00` even when Home already shows today's real totals.
@pragma('vm:entry-point')
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // Match the user's language so coach messages are localized even when the
  // main activity is dead. Missing preference defaults to Persian.
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('app_locale');
  final locale = code == 'en' ? const Locale('en') : const Locale('fa');

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightForLocale(locale),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const OverlayApp(),
    ),
  );
}

/// Root widget wiring theme, locales, and named routes.
///
/// How to use: passed to [runApp] from [main].
class AppUsageApp extends StatelessWidget {
  /// Creates the root application widget.
  const AppUsageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: locator<LocaleCubit>()),
        BlocProvider.value(value: locator<ThemeCubit>()),
        BlocProvider.value(value: locator<BadgeAppearanceCubit>()),
        BlocProvider.value(value: locator<AppTimerCubit>()),
        BlocProvider.value(value: locator<BlockedAppsCubit>()),
        BlocProvider.value(value: locator<CoachSettingsCubit>()),
        BlocProvider.value(value: locator<HolidaySettingsCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'تمرکز شیرین',
                theme: AppTheme.lightForLocale(locale),
                darkTheme: AppTheme.darkForLocale(locale),
                themeMode: themeMode,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routes: PageRouter.routes,
                initialRoute: _initialRoute(),
              );
            },
          );
        },
      ),
    );
  }

  /// Android → permissions first; other platforms → unsupported page.
  String _initialRoute() {
    // Desktop/web builds are unsupported for this Android-only MVP.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return PageName.permissions;
    }
    return PageName.unsupported;
  }
}
