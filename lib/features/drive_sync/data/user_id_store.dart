import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Persists a stable anonymous user id for Drive file naming.
///
/// How to use:
/// ```dart
/// final id = await UserIdStore(prefs).getOrCreate();
/// // usage_<id>.json on Drive
/// ```
class UserIdStore {
  /// Creates a store backed by [SharedPreferences].
  UserIdStore(this._prefs);

  static const _key = 'drive_sync_user_id';

  final SharedPreferences _prefs;

  /// Returns the existing id or creates a new UUID (no dashes, 32 chars).
  Future<String> getOrCreate() async {
    final existing = _prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;

    final id = const Uuid().v4().replaceAll('-', '');
    await _prefs.setString(_key, id);
    return id;
  }
}
