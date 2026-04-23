// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/directives/utility_directives_test.dart

@TestOn('browser')
library;

import 'dart:html' as html;
import 'dart:js';

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

void main() {
  group('CpfMaskDirective', () {
    test('applies the CPF mask while typing and ignores extra digits', () {
      final input = _attachInput();
      CpfMaskDirective(input);

      _typeSequentially(input, '12345678901');
      expect(input.value, '123.456.789-01');

      input.value = '${input.value}2';
      input.dispatchEvent(html.Event('input', canBubble: true));
      expect(input.value, '123.456.789-01');

      input.remove();
    });
  });

  group('MinMaxDirective', () {
    test('clamps numeric values to the configured range', () {
      final input = _attachInput()..type = 'number';
      final directive = MinMaxDirective(input)
        ..min = 1.0
        ..max = 10.0;

      input.value = '0';
      input.dispatchEvent(createKeyboardEvent('keyup', 48));
      expect(double.parse(input.value!), directive.min);

      input.value = '42';
      input.dispatchEvent(createKeyboardEvent('keyup', 50));
      expect(double.parse(input.value!), directive.max);

      input.remove();
    });
  });

  group('CnpjMaskDirective', () {
    test('applies the CNPJ mask while typing and ignores extra digits', () {
      final input = _attachInput();
      CnpjMaskDirective(input);

      _typeSequentially(input, '12345678000199');
      expect(input.value, '12.345.678/0001-99');

      input.value = '${input.value}0';
      input.dispatchEvent(html.Event('input', canBubble: true));
      expect(input.value, '12.345.678/0001-99');

      input.remove();
    });
  });

  group('OnlyNumberDirective', () {
    test('prevents non-digit key presses', () {
      final input = _attachInput();
      OnlyNumberDirective(input);

      final blocked = createKeyboardEvent('keypress', 65);
      final allowed = createKeyboardEvent('keypress', 52);

      expect(input.dispatchEvent(blocked), isFalse);
      expect(input.dispatchEvent(allowed), isTrue);

      input.remove();
    });
  });
}

html.InputElement _attachInput() {
  final input = html.InputElement();
  html.document.body!.append(input);
  return input;
}

void _typeSequentially(html.InputElement input, String text) {
  for (final char in text.split('')) {
    input.value = '${input.value ?? ''}$char';
    input.dispatchEvent(html.Event('input', canBubble: true));
  }
}

const _createKeyboardEventName = '__dart_createKeyboardEvent';
const _createKeyboardEventScript = '''
window['$_createKeyboardEventName'] = function(
    type, keyCode, ctrlKey, altKey, shiftKey, metaKey) {
  var event = document.createEvent('KeyboardEvent');

  Object.defineProperty(event, 'keyCode', {
    get: function() { return keyCode; }
  });

  if (event.initKeyboardEvent) {
    event.initKeyboardEvent(type, true, true, document.defaultView, keyCode,
        keyCode, ctrlKey, altKey, shiftKey, metaKey);
  } else {
    event.initKeyEvent(type, true, true, document.defaultView, ctrlKey, altKey,
        shiftKey, metaKey, keyCode, keyCode);
  }

  return event;
}
''';

html.Event createKeyboardEvent(
  String type,
  int keyCode, {
  bool ctrlKey = false,
  bool altKey = false,
  bool shiftKey = false,
  bool metaKey = false,
}) {
  if (!context.hasProperty(_createKeyboardEventName)) {
    final script = html.document.createElement('script')
      ..setAttribute('type', 'text/javascript')
      ..text = _createKeyboardEventScript;
    html.document.body!.append(script);
  }

  return context.callMethod(
    _createKeyboardEventName,
    <Object>[type, keyCode, ctrlKey, altKey, shiftKey, metaKey],
  ) as html.Event;
}
