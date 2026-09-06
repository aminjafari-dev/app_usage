import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the set of packages that must be blocked on open.
///
/// How to use:
/// ```dart
/// context.read<BlockedAppsCubit>().setBlocked('com.telegram.messenger', true);
/// final blocked = context.watch<BlockedAppsCubit>().isBlocked(package);
/// ```
///
/// [lockedDefaults] are always blocked and cannot be toggled by the user.
/// The overlay isolate reads the same prefs via [readFrom] after
/// [SharedPreferences.reload].
class BlockedAppsCubit extends Cubit<Set<String>> {
  /// Creates a cubit backed by [SharedPreferences].
  BlockedAppsCubit(this._prefs) : super(lockedDefaults);

  static const _prefsKey = 'blocked_apps_v1';

  /// Packages that are always blocked and cannot be changed in Settings/Timer.
  ///
  /// Only these apps get the permanent lock — other apps stay fully user-controlled.
  static const Set<String> lockedDefaults = {
    'com.instagram.android',
    'com.google.android.youtube',
    'com.codegraphi.simba',
  };

  final SharedPreferences _prefs;

  /// Whether [packageName] is one of the permanent default blockers.
  static bool isLockedDefault(String packageName) =>
      lockedDefaults.contains(packageName);

  /// Loads saved packages into state. Call once at app start.
  void load() {
    emit(readFrom(_prefs));
  }

  /// Reads persisted packages plus [lockedDefaults] (also used by the overlay).
  static Set<String> readFrom(SharedPreferences prefs) {
    return {...lockedDefaults, ..._readUserBlocked(prefs)};
  }

  /// Whether [packageName] is currently blocked (including locked defaults).
  bool isBlocked(String packageName) =>
      isLockedDefault(packageName) || state.contains(packageName);

  /// Adds or removes [packageName] from the user-controlled block list.
  ///
  /// No-op for [lockedDefaults] — those stay blocked forever.
  Future<void> setBlocked(String packageName, bool blocked) async {
    if (packageName.isEmpty) return;
    if (isLockedDefault(packageName)) return;

    final userBlocked = _readUserBlocked(_prefs);
    final nextUser = Set<String>.from(userBlocked);
    if (blocked) {
      nextUser.add(packageName);
    } else {
      nextUser.remove(packageName);
    }
    if (nextUser.length == userBlocked.length &&
        blocked == userBlocked.contains(packageName)) {
      return;
    }
    await _writeUserBlocked(nextUser);
    emit({...lockedDefaults, ...nextUser});
  }

  Future<void> _writeUserBlocked(Set<String> packages) async {
    // Never persist locked defaults in the editable prefs list.
    final editable = packages.difference(lockedDefaults).toList()..sort();
    await _prefs.setString(_prefsKey, jsonEncode(editable));
  }

  static Set<String> _readUserBlocked(SharedPreferences prefs) {
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return {
        for (final item in list)
          if (item is String &&
              item.isNotEmpty &&
              !lockedDefaults.contains(item))
            item,
      };
    } catch (_) {
      return const {};
    }
  }
}
