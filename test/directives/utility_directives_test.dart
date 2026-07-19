// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/directives/utility_directives_test.dart

@TestOn('browser')
library;

import 'package:web/web.dart' as web;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

import '../support/web_event_factories.dart';

void main() {
  group('LiAutoClickFileInputDirective', () {
    test('accepts only input elements whose type is file', () {
      final textInput = (web.HTMLInputElement()..type = 'text');
      expect(
        () => LiAutoClickFileInputDirective(textInput),
        throwsStateError,
      );

      final fileInput = (web.HTMLInputElement()..type = 'file');
      final directive = LiAutoClickFileInputDirective(fileInput);
      directive.ngOnDestroy();
    });
  });

  group('LiCpfMaskDirective', () {
    test('applies the CPF mask while typing and ignores extra digits', () {
      final input = _attachInput();
      LiCpfMaskDirective(input);

      _typeSequentially(input, '12345678901');
      expect(input.value, '123.456.789-01');

      input.value = '${input.value}2';
      input.dispatchEvent(bubblingEvent('input', bubbles: true));
      expect(input.value, '123.456.789-01');

      input.remove();
    });
  });

  group('LiMinMaxDirective', () {
    test('clamps numeric values to the configured range', () {
      final input = _attachInput()..type = 'number';
      final directive = LiMinMaxDirective(input)
        ..liMin = 1.0
        ..liMax = 10.0;

      input.value = '0';
      input.dispatchEvent(createKeyboardEvent('keyup', '0'));
      expect(double.parse(input.value), directive.liMin);

      input.value = '42';
      input.dispatchEvent(createKeyboardEvent('keyup', '2'));
      expect(double.parse(input.value), directive.liMax);

      input.value = '';
      input.dispatchEvent(createKeyboardEvent('keyup', '1'));
      expect(double.parse(input.value), directive.liMin);

      input.remove();
    });
  });

  group('LiCnpjMaskDirective', () {
    test('applies the CNPJ mask while typing and ignores extra digits', () {
      final input = _attachInput();
      LiCnpjMaskDirective(input);

      _typeSequentially(input, '12345678000199');
      expect(input.value, '12.345.678/0001-99');

      input.value = '${input.value}0';
      input.dispatchEvent(bubblingEvent('input', bubbles: true));
      expect(input.value, '12.345.678/0001-99');

      input.remove();
    });
  });

  group('LiOnlyNumberDirective', () {
    test('prevents non-digit key presses', () {
      final input = _attachInput();
      LiOnlyNumberDirective(input);

      final blocked = createKeyboardEvent('keypress', 'A');
      final allowed = createKeyboardEvent('keypress', '4');

      expect(input.dispatchEvent(blocked), isFalse);
      expect(input.dispatchEvent(allowed), isTrue);

      input.remove();
    });
  });
}

web.HTMLInputElement _attachInput() {
  final input = web.HTMLInputElement();
  web.document.body!.appendChild(input);
  return input;
}

void _typeSequentially(web.HTMLInputElement input, String text) {
  for (final char in text.split('')) {
    input.value = '${input.value}$char';
    input.dispatchEvent(bubblingEvent('input', bubbles: true));
  }
}

web.Event createKeyboardEvent(
  String type,
  String key, {
  bool ctrlKey = false,
  bool altKey = false,
  bool shiftKey = false,
  bool metaKey = false,
}) =>
    bubblingKeyboardEvent(
      type,
      key: key,
      code: key,
      ctrlKey: ctrlKey,
      altKey: altKey,
      shiftKey: shiftKey,
      metaKey: metaKey,
    );
