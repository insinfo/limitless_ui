// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/helpers/li_simple_dialog_prompt_test.dart

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

void main() {
  setUp(_resetSimpleDialogDom);
  tearDown(_resetSimpleDialogDom);

  test('showPrompt resolves with the confirmed text input value', () async {
    final future = LiSimpleDialogComponent.showPrompt(
      'Enter the release name.',
      title: 'Release',
      inputPlaceholder: 'release-2026',
    );

    await _settle();

    final input = html.document.querySelector('.li-simple-dialog__input')
        as html.InputElement?;
    expect(input, isNotNull);
    expect(input!.placeholder, 'release-2026');
    input.value = 'release-2026';

    _click('.BtnOk');
    final result = await future;

    expect(result, 'release-2026');
    expect(html.document.querySelector('.li-simple-dialog-root'), isNull);
  });

  test('showPrompt resolves with null when cancelled', () async {
    final future = LiSimpleDialogComponent.showPrompt(
      'Enter the release name.',
    );

    await _settle();
    _click('.BtnCancel');
    final result = await future;

    expect(result, isNull);
    expect(html.document.querySelector('.li-simple-dialog-root'), isNull);
  });

  test('showPrompt supports textarea config and validation', () async {
    final future = LiSimpleDialogComponent.showPrompt(
      'Describe the correction reason.',
      inputType: LiSimpleDialogInputType.textarea,
      inputConfig: const LiSimpleDialogInputConfig(
        className: 'correction-reason',
        rows: 6,
        maxLength: 240,
        attributes: <String, String>{
          'aria-label': 'Correction reason',
        },
        style: <String, String>{
          'min-height': '10rem',
        },
      ),
      inputValidator: (value) {
        if (value.trim().isEmpty) {
          return 'Reason is required';
        }
        return null;
      },
    );

    await _settle();

    final textarea = html.document.querySelector('.li-simple-dialog__textarea')
        as html.TextAreaElement?;
    expect(textarea, isNotNull);
    expect(textarea!.classes.contains('correction-reason'), isTrue);
    expect(textarea.rows, 6);
    expect(textarea.maxLength, 240);
    expect(textarea.attributes['aria-label'], 'Correction reason');
    expect(textarea.style.minHeight, '10rem');

    _click('.BtnOk');
    await _settle();
    expect(textarea.classes.contains('is-invalid'), isTrue);
    expect(
      html.document.querySelector('.li-simple-dialog__validation')!.text,
      contains('Reason is required'),
    );

    textarea.value = 'Wrong dispatch selected.';
    _click('.BtnOk');
    final result = await future;

    expect(result, 'Wrong dispatch selected.');
    expect(html.document.querySelector('.li-simple-dialog-root'), isNull);
  });
}

void _click(String selector) {
  final element = html.document.querySelector(selector);
  expect(element, isNotNull);
  element!.dispatchEvent(html.MouseEvent('click', canBubble: true));
}

void _resetSimpleDialogDom() {
  html.document.querySelectorAll('.li-simple-dialog-root').forEach((element) {
    element.remove();
  });
}

Future<void> _settle() async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
}
