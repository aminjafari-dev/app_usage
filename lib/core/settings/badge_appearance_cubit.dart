import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Size + opacity for the floating usage badge.
///
/// How to use:
/// ```dart
/// final appearance = context.watch<BadgeAppearanceCubit>().state;
/// Opacity(opacity: appearance.opacity, child: Transform.scale(...));
/// ```
class BadgeAppearance extends Equatable {
  /// Creates badge appearance values.
  ///
  /// [sizeScale] is `1.0` for 100%; [opacity] is `0.0`–`1.0`.
  const BadgeAppearance({
    this.sizeScale = 1.0,
    this.opacity = 0.9,
  });

  /// Multiplier for badge size ([minSizeScale]–[maxSizeScale] → 75%–250%).
  final double sizeScale;

  /// Badge opacity (`0.3`–`1.0` → 30%–100%).
  final double opacity;

  /// Smallest size the customize-badge slider allows (75%).
  static const double minSizeScale = 0.75;

  /// Largest size the customize-badge slider allows (250%).
  static const double maxSizeScale = 2.5;

  /// Default appearance used on first launch.
  static const BadgeAppearance defaults = BadgeAppearance();

  /// Clamps [sizeScale] / [opacity] into the supported ranges.
  BadgeAppearance copyWith({double? sizeScale, double? opacity}) {
    return BadgeAppearance(
      sizeScale:
          (sizeScale ?? this.sizeScale).clamp(minSizeScale, maxSizeScale),
      opacity: (opacity ?? this.opacity).clamp(0.3, 1.0),
    );
  }

  /// Size as a whole percent for UI labels (e.g. `100`).
  int get sizePercent => (sizeScale * 100).round();

  /// Opacity as a whole percent for UI labels (e.g. `90`).
  int get opacityPercent => (opacity * 100).round();

  /// Encodes fields for SharedPreferences / overlay messaging.
  Map<String, dynamic> toMap() => {
        'type': 'badgeAppearance',
        'sizeScale': sizeScale,
        'opacity': opacity,
      };

  /// Decodes a map from prefs or the overlay message channel.
  factory BadgeAppearance.fromMap(Map<dynamic, dynamic> map) {
    return BadgeAppearance(
      sizeScale: (map['sizeScale'] as num?)?.toDouble() ?? 1.0,
      opacity: (map['opacity'] as num?)?.toDouble() ?? 0.9,
    ).copyWith();
  }

  @override
  List<Object?> get props => [sizeScale, opacity];
}

/// Persists and emits [BadgeAppearance] for the live overlay badge.
///
/// How to use:
/// ```dart
/// context.read<BadgeAppearanceCubit>().save(
///   const BadgeAppearance(sizeScale: 1.1, opacity: 0.85),
/// );
/// ```
class BadgeAppearanceCubit extends Cubit<BadgeAppearance> {
  /// Creates a cubit backed by [SharedPreferences].
  BadgeAppearanceCubit(this._prefs) : super(BadgeAppearance.defaults);

  static const _sizeKey = 'badge_size_scale';
  static const _opacityKey = 'badge_opacity';

  final SharedPreferences _prefs;

  /// Loads saved size/opacity or falls back to defaults.
  void load() {
    final size = _prefs.getDouble(_sizeKey);
    final opacity = _prefs.getDouble(_opacityKey);
    emit(
      BadgeAppearance(
        sizeScale: size ?? BadgeAppearance.defaults.sizeScale,
        opacity: opacity ?? BadgeAppearance.defaults.opacity,
      ).copyWith(),
    );
  }

  /// Persists and emits a new [appearance].
  ///
  /// Example: Save Changes on the customize-badge sheet.
  Future<void> save(BadgeAppearance appearance) async {
    final next = appearance.copyWith();
    await _prefs.setDouble(_sizeKey, next.sizeScale);
    await _prefs.setDouble(_opacityKey, next.opacity);
    emit(next);
  }

  /// Reads appearance without a cubit (e.g. overlay isolate startup).
  static BadgeAppearance readFrom(SharedPreferences prefs) {
    return BadgeAppearance(
      sizeScale: prefs.getDouble(_sizeKey) ?? BadgeAppearance.defaults.sizeScale,
      opacity: prefs.getDouble(_opacityKey) ?? BadgeAppearance.defaults.opacity,
    ).copyWith();
  }
}
