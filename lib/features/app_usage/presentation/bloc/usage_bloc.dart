import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/usecase/usecase.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';
import 'package:app_usage/features/app_usage/domain/usecases/check_permissions_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/ensure_auto_tracking_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/get_today_usage_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/request_overlay_permission_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/request_usage_permission_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/start_live_tracking_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/stop_live_tracking_usecase.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_event.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_state.dart';

/// BLoC that drives permissions, today's list, and live tracking.
///
/// How to use:
/// ```dart
/// BlocProvider(
///   create: (_) => getIt<UsageBloc>()..add(const UsageEvent.started()),
///   child: const HomePage(),
/// );
/// ```
class UsageBloc extends Bloc<UsageEvent, UsageState> {
  /// Injects use cases and the repository stream sources.
  UsageBloc({
    required this._checkPermissionsUseCase,
    required this._requestUsagePermissionUseCase,
    required this._requestOverlayPermissionUseCase,
    required this._getTodayUsageUseCase,
    required this._startLiveTrackingUseCase,
    required this._stopLiveTrackingUseCase,
    required this._ensureAutoTrackingUseCase,
    required this._repository,
  }) : super(UsageState.initial()) {
    on<UsageEvent>(_onEvent);

    // Bridge repository streams into bloc events (safe emit path).
    _usageSub = _repository.usageStream.listen((apps) {
      if (!isClosed) add(UsageEvent.usageUpdated(apps));
    });
    _currentSub = _repository.currentAppStream.listen((app) {
      if (!isClosed) add(UsageEvent.currentAppUpdated(app));
    });
  }

  final CheckPermissionsUseCase _checkPermissionsUseCase;
  final RequestUsagePermissionUseCase _requestUsagePermissionUseCase;
  final RequestOverlayPermissionUseCase _requestOverlayPermissionUseCase;
  final GetTodayUsageUseCase _getTodayUsageUseCase;
  final StartLiveTrackingUseCase _startLiveTrackingUseCase;
  final StopLiveTrackingUseCase _stopLiveTrackingUseCase;
  final EnsureAutoTrackingUseCase _ensureAutoTrackingUseCase;
  final AppUsageRepository _repository;

  StreamSubscription<List<AppUsageEntity>>? _usageSub;
  StreamSubscription<AppUsageEntity?>? _currentSub;

  Future<void> _onEvent(UsageEvent event, Emitter<UsageState> emit) async {
    switch (event) {
      case UsageStarted():
        await _onStarted(emit);
      case UsageRefreshPermissions():
        await _onRefreshPermissions(emit);
        // After returning from settings, start the top counter automatically.
        await _onEnsureAutoTracking(emit);
      case UsageRequestUsagePermission():
        await _onRequestUsagePermission(emit);
      case UsageRequestOverlayPermission():
        await _onRequestOverlayPermission(emit);
      case UsageRefreshUsage():
        await _onRefreshUsage(emit);
      case UsageStartTracking():
        await _onStartTracking(emit);
      case UsageStopTracking():
        await _onStopTracking(emit);
      case UsageUpdated(:final apps):
        // Live ticks update the list without a loading spinner.
        emit(state.copyWith(todayUsage: TodayUsageOpState.completed(apps)));
      case UsageCurrentAppUpdated(:final app):
        emit(state.copyWith(currentApp: app, clearCurrentApp: app == null));
    }
  }

  Future<void> _onStarted(Emitter<UsageState> emit) async {
    await _onRefreshPermissions(emit);
    await _onRefreshUsage(emit);
    // Auto-start the top overlay whenever permissions allow it.
    await _onEnsureAutoTracking(emit);
    emit(
      state.copyWith(
        tracking: TrackingOpState.completed(
          isTracking: _repository.isTracking,
        ),
      ),
    );
  }

  Future<void> _onEnsureAutoTracking(Emitter<UsageState> emit) async {
    final result = await _ensureAutoTrackingUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(tracking: TrackingOpState.error(failure.message)),
      ),
      (_) => emit(
        state.copyWith(
          tracking: TrackingOpState.completed(
            isTracking: _repository.isTracking,
          ),
        ),
      ),
    );
    // Refresh list so Home shows seeded totals right away.
    if (_repository.isTracking) {
      await _onRefreshUsage(emit);
    }
  }

  Future<void> _onRefreshPermissions(Emitter<UsageState> emit) async {
    emit(state.copyWith(permissions: const PermissionsOpState.loading()));
    final result = await _checkPermissionsUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          permissions: PermissionsOpState.error(failure.message),
        ),
      ),
      (status) => emit(
        state.copyWith(
          permissions: PermissionsOpState.completed(status),
        ),
      ),
    );
  }

  Future<void> _onRequestUsagePermission(Emitter<UsageState> emit) async {
    await _requestUsagePermissionUseCase(const NoParams());
    await _onRefreshPermissions(emit);
    await _onEnsureAutoTracking(emit);
  }

  Future<void> _onRequestOverlayPermission(Emitter<UsageState> emit) async {
    await _requestOverlayPermissionUseCase(const NoParams());
    await _onRefreshPermissions(emit);
    await _onEnsureAutoTracking(emit);
  }

  Future<void> _onRefreshUsage(Emitter<UsageState> emit) async {
    emit(state.copyWith(todayUsage: const TodayUsageOpState.loading()));
    final result = await _getTodayUsageUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(todayUsage: TodayUsageOpState.error(failure.message)),
      ),
      (apps) => emit(
        state.copyWith(todayUsage: TodayUsageOpState.completed(apps)),
      ),
    );
  }

  Future<void> _onStartTracking(Emitter<UsageState> emit) async {
    emit(state.copyWith(tracking: const TrackingOpState.loading()));
    final result = await _startLiveTrackingUseCase(const NoParams());
    await result.fold(
      (failure) async {
        emit(state.copyWith(tracking: TrackingOpState.error(failure.message)));
      },
      (_) async {
        emit(
          state.copyWith(
            tracking: const TrackingOpState.completed(isTracking: true),
          ),
        );
        await _onRefreshUsage(emit);
      },
    );
  }

  Future<void> _onStopTracking(Emitter<UsageState> emit) async {
    emit(state.copyWith(tracking: const TrackingOpState.loading()));
    final result = await _stopLiveTrackingUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(tracking: TrackingOpState.error(failure.message)),
      ),
      (_) => emit(
        state.copyWith(
          tracking: const TrackingOpState.completed(isTracking: false),
          clearCurrentApp: true,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _usageSub?.cancel();
    await _currentSub?.cancel();
    return super.close();
  }
}
