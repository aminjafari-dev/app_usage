import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and emits the active [ThemeMode] (light / dark).
///
/// How to use:
/// ```dart
/// context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
/// ```
///
/// Wire this into [MaterialApp.themeMode] so the whole tree rebuilds on change.
class ThemeCubit extends Cubit<ThemeMode> {
  /// Creates a cubit backed by [SharedPreferences].
  ///
  /// Example:
  /// ```dart
  /// final cubit = ThemeCubit(prefs)..load();
  /// ```
  ThemeCubit(this._prefs) : super(ThemeMode.light);

  static const _key = 'app_theme_mode';

  final SharedPreferences _prefs;

  /// Loads the saved theme or falls back to light.
  ///
  /// Useful at app startup before the first frame.
  void load() {
    final value = _prefs.getString(_key);
    // Restore dark only when the user previously chose it.
    if (value == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }

  /// Saves and emits a new [mode] (light or dark).
  ///
  /// Example: theme segmented control on the settings page.
  Future<void> setThemeMode(ThemeMode mode) async {
    final persisted = mode == ThemeMode.dark ? 'dark' : 'light';
    await _prefs.setString(_key, persisted);
    emit(mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light);
  }

  /// Whether the active mode is dark.
  bool get isDark => state == ThemeMode.dark;
}
