import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and emits the active app [Locale] (English / Persian).
///
/// How to use:
/// ```dart
/// context.read<LocaleCubit>().setLocale(const Locale('fa'));
/// ```
///
/// Wire this into [MaterialApp.locale] so the whole tree rebuilds on change.
class LocaleCubit extends Cubit<Locale> {
  /// Creates a cubit backed by [SharedPreferences].
  ///
  /// Example:
  /// ```dart
  /// final cubit = LocaleCubit(prefs)..load();
  /// ```
  LocaleCubit(this._prefs) : super(const Locale('en'));

  static const _key = 'app_locale';

  final SharedPreferences _prefs;

  /// Loads the saved locale or falls back to English.
  ///
  /// Useful at app startup before the first frame.
  void load() {
    final code = _prefs.getString(_key);
    // If the user previously chose Persian, restore it on cold start.
    if (code == 'fa') {
      emit(const Locale('fa'));
    } else {
      emit(const Locale('en'));
    }
  }

  /// Saves and emits a new [locale].
  ///
  /// Example: language toggle on the home page.
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_key, locale.languageCode);
    emit(locale);
  }

  /// Toggles between English and Persian.
  Future<void> toggle() async {
    final next = state.languageCode == 'fa'
        ? const Locale('en')
        : const Locale('fa');
    await setLocale(next);
  }
}
