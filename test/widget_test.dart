import 'package:flutter_test/flutter_test.dart';

import 'package:app_usage/core/utils/duration_format.dart';

void main() {
  test('formatUsageDuration uses mm:ss under one hour', () {
    expect(formatUsageDuration(75), '01:15');
  });

  test('formatUsageDuration uses h:mm:ss at one hour or more', () {
    expect(formatUsageDuration(3661), '1:01:01');
  });
}
