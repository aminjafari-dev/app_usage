import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_usage/core/locale/locale_cubit.dart';
import 'package:app_usage/core/settings/badge_appearance_cubit.dart';
import 'package:app_usage/core/theme/theme_cubit.dart';
import 'package:app_usage/features/app_usage/di/app_usage_di.dart';

/// Global service locator instance.
///
/// How to use:
/// ```dart
/// final bloc = locator<UsageBloc>();
/// ```
final GetIt locator = GetIt.instance;

/// Registers core + feature dependencies. Call once from [main].
///
/// Example:
/// ```dart
/// WidgetsFlutterBinding.ensureInitialized();
/// await setupLocator();
/// ```
Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);
  locator.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(locator())..load(),
  );
  locator.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(locator())..load(),
  );
  locator.registerLazySingleton<BadgeAppearanceCubit>(
    () => BadgeAppearanceCubit(locator())..load(),
  );

  // Feature modules register their own graph.
  await setupAppUsageLocator(locator);
}
