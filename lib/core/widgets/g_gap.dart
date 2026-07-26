import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shared spacing tokens wrapped around the Gap package.
///
/// How to use:
/// ```dart
/// Column(children: [widgetA, GGap.m(), widgetB]);
/// ```
///
/// Prefer these helpers instead of raw SizedBox/Gap values so spacing stays consistent.
class GGap {
  GGap._();

  /// Extra-small gap (4). Useful between tightly related labels.
  static Widget xs() => const Gap(4);

  /// Small gap (8). Useful between icon and text.
  static Widget s() => const Gap(8);

  /// Medium gap (16). Default section spacing.
  static Widget m() => const Gap(16);

  /// Large gap (24). Useful between major blocks.
  static Widget l() => const Gap(24);

  /// Extra-large gap (32). Useful for page-level separation.
  static Widget xl() => const Gap(32);
}
