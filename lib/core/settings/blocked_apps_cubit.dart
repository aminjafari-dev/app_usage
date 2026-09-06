import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the set of packages that must be blocked on open.
///
/// How to use:
/// ```dart
/// context.read<BlockedAppsCubit>().setBlocked('com.google.android.youtube', true);
/// final blocked = context.watch<BlockedAppsCubit>().isBlocked(package);
/// ```
///
/// The overlay isolate reads the same prefs via [readFrom] after
/// [SharedPreferences.reload].
class BlockedAppsCubit extends Cubit<Set<String>> {
  /// Creates a cubit backed by [SharedPreferences].
  BlockedAppsCubit(this._prefs) : super(const {});

  static const _prefsKey = 'blocked_apps_v1';

  final SharedPreferences _prefs;

  /// Loads saved packages into state. Call once at app start.
  void load() {
    emit(readFrom(_prefs));
  }

  /// Reads persisted packages (also used by the overlay isolate).
  static Set<String> readFrom(SharedPreferences prefs) {
    return _readAll(prefs);
  }

  /// Whether [packageName] is currently blocked.
  bool isBlocked(String packageName) => state.contains(packageName);

  /// Adds or removes [packageName] from the block list.
  Future<void> setBlocked(String packageName, bool blocked) async {
    if (packageName.isEmpty) return;
    final next = Set<String>.from(state);
    if (blocked) {
      next.add(packageName);
    } else {
      next.remove(packageName);
    }
    if (next.length == state.length && blocked == state.contains(packageName)) {
      return;
    }
    emit(next);
    await _writeAll(next);
  }

  Future<void> _writeAll(Set<String> packages) async {
    final encoded = jsonEncode(packages.toList()..sort());
    await _prefs.setString(_prefsKey, encoded);
  }

  static Set<String> _readAll(SharedPreferences prefs) {
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return {
        for (final item in list)
          if (item is String && item.isNotEmpty) item,
      };
    } catch (_) {
      return const {};
    }
  }
}
