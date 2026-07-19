@TestOn('browser')
library;

import 'package:limitless_ui/src/web_support/js_type_guards.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  test('elementOrNull rejects ordinary Dart objects safely', () {
    final element = web.HTMLDivElement();

    expect(elementOrNull(element), equals(element));
    expect(elementOrNull(Object()), isNull);
    expect(elementOrNull(<String, Object?>{}), isNull);
    expect(elementOrNull(null), isNull);
  });
}
