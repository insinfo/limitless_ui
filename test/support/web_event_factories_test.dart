@TestOn('browser')
library;

import 'package:test/test.dart';
import 'package:web/web.dart' as web;

import 'web_event_factories.dart';

void main() {
  test('factories make propagation defaults explicit', () {
    final event = bubblingEvent('test-event');
    final mouseEvent = bubblingMouseEvent('test-mouse');
    final keyboardEvent = bubblingKeyboardEvent(
      'test-keyboard',
      key: 'Enter',
      code: 'Enter',
    );

    expect(event.bubbles, isTrue);
    expect(event.cancelable, isTrue);
    expect(mouseEvent.view == web.window, isTrue);
    expect(mouseEvent.bubbles, isTrue);
    expect(keyboardEvent.view == web.window, isTrue);
    expect(keyboardEvent.key, 'Enter');
    expect(keyboardEvent.bubbles, isTrue);
  });
}
