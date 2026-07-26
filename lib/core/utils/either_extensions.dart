import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';

import 'package:app_usage/core/error/failures.dart';

/// Helpers for working with Either&lt;Failure, T&gt; in UI and use cases.
///
/// How to use:
/// ```dart
/// result.when(
///   failure: (f) => Text(f.message),
///   success: (data) => Text('$data'),
/// );
/// ```
extension EitherExtensions<L, R> on Either<L, R> {
  /// Returns the right value. Only call when you already know it is Right.
  R getRight() => (this as Right<L, R>).value;

  /// Returns the left value. Only call when you already know it is Left.
  L getLeft() => (this as Left<L, R>).value;

  /// Maps Either to widgets for presentation layers.
  Widget when({
    required Widget Function(L failure) failure,
    required Widget Function(R data) success,
  }) {
    return fold(
      (l) => failure(l),
      (r) => success(r),
    );
  }

  /// Chains another Either-returning operation after a success.
  Either<L, T> flatMap<T>(Either<L, T> Function(R r) f) {
    return fold(
      (l) => Left(l),
      (r) => f(r),
    );
  }
}

/// Convenience typedef for domain results.
typedef ResultFuture<T> = Future<Either<Failure, T>>;
