import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/usecase/usecase.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';
import 'package:app_usage/features/app_usage/domain/usecases/get_installed_apps_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/get_today_usage_usecase.dart';

/// Loads installed apps, ranks today's most-used first, and filters search.
///
/// How to use:
/// ```dart
/// BlocProvider(
///   create: (_) => locator<TimerCubit>()..load(),
///   child: const TimerPage(),
/// );
/// ```
class TimerCubit extends Cubit<TimerState> {
  /// Injects installed-apps + today's usage use cases.
  TimerCubit(
    this._getInstalledApps,
    this._getTodayUsage,
  ) : super(const TimerState());

  final GetInstalledAppsUseCase _getInstalledApps;
  final GetTodayUsageUseCase _getTodayUsage;

  /// Fetches installed apps and merges today's usage so most-used sit on top.
  Future<void> load() async {
    emit(
      state.copyWith(
        status: TimerStatus.loading,
        clearError: true,
      ),
    );

    final installedFuture = _getInstalledApps(const NoParams());
    final todayFuture = _getTodayUsage(const NoParams());
    final installedResult = await installedFuture;
    final todayResult = await todayFuture;

    // Prefer installed-apps failure; today's usage is optional enrichment.
    final installedFailure = installedResult.fold((f) => f, (_) => null);
    if (installedFailure != null) {
      emit(
        state.copyWith(
          status: TimerStatus.error,
          errorMessage: installedFailure.message,
        ),
      );
      return;
    }

    final installed = installedResult.getOrElse(() => const []);
    final today = todayResult.getOrElse(() => const []);

    emit(
      state.copyWith(
        status: TimerStatus.loaded,
        apps: _mergeInstalledWithToday(installed: installed, today: today),
        clearError: true,
      ),
    );
  }

  /// Updates the search query used to filter most-used / other sections.
  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}

/// Combines the full install catalog with today's seconds.
///
/// Most-used packages (seconds > 0) stay first, sorted like Home. Unused apps
/// follow alphabetically. Packages seen in today's usage but missing from the
/// install query (e.g. filtered system apps) are still included when used.
List<AppUsageEntity> _mergeInstalledWithToday({
  required List<AppUsageEntity> installed,
  required List<AppUsageEntity> today,
}) {
  final byPackage = <String, AppUsageEntity>{
    for (final app in installed) app.packageName: app,
  };

  for (final used in today) {
    if (used.todaySeconds <= 0) continue;
    final existing = byPackage[used.packageName];
    if (existing != null) {
      byPackage[used.packageName] = existing.copyWith(
        todaySeconds: used.todaySeconds,
        iconBytes: existing.iconBytes ?? used.iconBytes,
      );
    } else {
      byPackage[used.packageName] = used;
    }
  }

  final mostUsed = byPackage.values.where((a) => a.todaySeconds > 0).toList()
    ..sort((a, b) => b.todaySeconds.compareTo(a.todaySeconds));

  final others = byPackage.values.where((a) => a.todaySeconds <= 0).toList()
    ..sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );

  return [...mostUsed, ...others];
}

/// UI status for the Timer tab.
enum TimerStatus { initial, loading, loaded, error }

/// Immutable state for [TimerCubit].
class TimerState extends Equatable {
  /// Creates Timer UI state.
  const TimerState({
    this.status = TimerStatus.initial,
    this.apps = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  final TimerStatus status;
  final List<AppUsageEntity> apps;
  final String searchQuery;
  final String? errorMessage;

  /// Apps matching [searchQuery] (name or package), case-insensitive.
  List<AppUsageEntity> get filteredApps {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return apps;
    return apps
        .where(
          (app) =>
              app.appName.toLowerCase().contains(q) ||
              app.packageName.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Today's used apps within [filteredApps], already usage-sorted.
  List<AppUsageEntity> get mostUsedApps =>
      filteredApps.where((a) => a.todaySeconds > 0).toList();

  /// Installed apps with no usage today within [filteredApps].
  List<AppUsageEntity> get otherApps =>
      filteredApps.where((a) => a.todaySeconds <= 0).toList();

  /// Returns a copy with selective overrides.
  TimerState copyWith({
    TimerStatus? status,
    List<AppUsageEntity>? apps,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TimerState(
      status: status ?? this.status,
      apps: apps ?? this.apps,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, apps, searchQuery, errorMessage];
}
