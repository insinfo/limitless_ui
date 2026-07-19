@TestOn('browser')
library;

import 'package:limitless_ui/src/web_support/html_sinks.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  test('sanitizes normal writes and makes trusted writes explicit', () {
    final element = web.HTMLDivElement();

    setSanitizedHtml(element, '''
      <img src="x" onerror="window.__unsafe = true">
      <script>window.__unsafe = true</script>
      <b>safe text</b>
    ''');

    expect(element.querySelector('script'), isNull);
    expect(element.querySelector('img')?.hasAttribute('onerror'), isFalse);
    expect(element.textContent, contains('safe text'));

    setTrustedHtml(
      element,
      '<span onclick="window.__trusted = true">trusted</span>',
    );

    expect(element.querySelector('span')?.hasAttribute('onclick'), isTrue);
    expect(readHtml(element), contains('trusted'));
  });
}
