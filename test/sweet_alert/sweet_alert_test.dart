// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/sweet_alert/sweet_alert_test.dart

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

void main() {
  setUp(_resetSweetAlertDom);
  tearDown(_resetSweetAlertDom);

  test('show renders a modal and resolves after confirmation', () async {
    final future = SweetAlert.show(
      title: 'Deployment ready',
      message: 'The release summary is available.',
      type: SweetAlertType.success,
      confirmButtonText: 'Continue',
      showCloseButton: true,
    );

    await _settle();

    final popup = html.document.querySelector('.swal2-popup.swal2-modal');
    expect(popup, isNotNull);
    final resolvedPopup = popup!;
    expect(resolvedPopup.getComputedStyle().display, 'grid');
    expect(resolvedPopup.classes.contains('swal2-icon-success'), isTrue);
    expect(resolvedPopup.text, contains('Deployment ready'));
    expect(resolvedPopup.text, contains('The release summary is available.'));
    final confirmButton =
        resolvedPopup.querySelector('.swal2-confirm') as html.ButtonElement?;
    expect(confirmButton, isNotNull);
    expect(confirmButton!.classes.contains('btn'), isTrue);
    expect(confirmButton.classes.contains('btn-primary'), isTrue);

    _click('.swal2-confirm');
    final result = await future;

    expect(result.isConfirmed, isTrue);
    expect(result.isDismissed, isFalse);
    expect(html.document.querySelector('.swal2-container'), isNull);
  });

  test('confirm resolves as cancelled when the cancel button is used',
      () async {
    final future = SweetAlert.confirm(
      title: 'Publish release',
      message: 'Do you want to continue?',
      confirmButtonText: 'Publish',
      cancelButtonText: 'Review',
    );

    await _settle();
    _click('.swal2-cancel');
    final result = await future;

    expect(result.isConfirmed, isFalse);
    expect(result.isDismissed, isTrue);
    expect(result.dismissReason, SweetAlertDismissReason.cancel);
  });

  test('prompt validates empty values and returns the confirmed input',
      () async {
    final future = SweetAlert.prompt(
      title: 'Batch priority',
      message: 'Enter the batch identifier.',
      inputPlaceholder: 'batch-42',
      inputValidator: (value) {
        if (value.trim().isEmpty) {
          return 'Identifier is required';
        }
        return null;
      },
    );

    await _settle();
    _click('.swal2-confirm');
    await _settle();

    final validationMessage =
        html.document.querySelector('.swal2-validation-message');
    expect(validationMessage, isNotNull);
    expect(validationMessage!.text, contains('Identifier is required'));
    expect(validationMessage.getComputedStyle().display, isNot('none'));

    final input =
        html.document.querySelector('.swal2-input') as html.InputElement?;
    expect(input, isNotNull);
    input!
      ..value = 'batch-42'
      ..dispatchEvent(html.Event('input', canBubble: true));

    _click('.swal2-confirm');
    final result = await future;

    expect(result.isConfirmed, isTrue);
    expect(result.value, 'batch-42');
  });

  test('toast closes on timer and clears body state classes', () async {
    final controller = SweetAlert.toast(
      'Saved successfully',
      type: SweetAlertType.success,
      timer: const Duration(milliseconds: 120),
    );

    await _settle();
    expect(html.document.querySelector('.swal2-toast'), isNotNull);
    expect(html.document.body!.classes.contains('swal2-toast-shown'), isTrue);

    final reason = await controller.closed;
    await _settle();

    expect(reason, SweetAlertDismissReason.timer);
    expect(html.document.querySelector('.swal2-toast'), isNull);
    expect(html.document.body!.classes.contains('swal2-toast-shown'), isFalse);
  });

  test('error type renders the x-mark structure expected by Limitless CSS',
      () async {
    final future = SweetAlert.show(
      title: 'Oops',
      message: 'Something went wrong.',
      type: SweetAlertType.error,
    );

    await _settle();

    expect(html.document.querySelector('.swal2-icon.swal2-error .swal2-x-mark'),
        isNotNull);
    expect(
      html.document
          .querySelector('.swal2-icon.swal2-error .swal2-x-mark-line-left'),
      isNotNull,
    );
    expect(
      html.document
          .querySelector('.swal2-icon.swal2-error .swal2-x-mark-line-right'),
      isNotNull,
    );

    _click('.swal2-confirm');
    await future;
  });

  test(
      'confirm supports side positions, reversed buttons, and lifecycle callbacks',
      () async {
    var opened = false;
    var closed = false;

    final future = SweetAlert.confirm(
      title: 'Publish release',
      message: 'Use the expanded API.',
      position: SweetAlertPosition.centerEnd,
      reverseButtons: true,
      onOpen: (_) {
        opened = true;
      },
      onClose: (_) {
        closed = true;
      },
    );

    await _settle();

    expect(html.document.querySelector('.swal2-container.swal2-center-end'),
        isNotNull);
    final actions = html.document.querySelector('.swal2-actions');
    expect(actions, isNotNull);
    final actionButtons = actions!.children
        .where((element) => element.classes.contains('swal2-styled'))
        .toList(growable: false);
    expect(actionButtons.first.classes.contains('swal2-cancel'), isTrue);
    expect(opened, isTrue);

    _click('.swal2-confirm');
    final result = await future;

    expect(result.isConfirmed, isTrue);
    expect(closed, isTrue);
  });

  test('prompt supports select input type', () async {
    final future = SweetAlert.prompt(
      title: 'Select environment',
      inputType: SweetAlertInputType.select,
      inputOptions: const <String, String>{
        'prod': 'Production',
        'staging': 'Staging',
      },
      inputValue: 'staging',
    );

    await _settle();

    final select =
        html.document.querySelector('.swal2-select') as html.SelectElement?;
    expect(select, isNotNull);
    expect(select!.value, 'staging');
    select.value = 'prod';

    _click('.swal2-confirm');
    final result = await future;

    expect(result.isConfirmed, isTrue);
    expect(result.value, 'prod');
  });

  test('prompt supports radio, checkbox, and range inputs', () async {
    final radioFuture = SweetAlert.prompt(
      title: 'Choose strategy',
      inputType: SweetAlertInputType.radio,
      inputOptions: const <String, String>{
        'fast': 'Fast track',
        'safe': 'Safe mode',
      },
      inputValue: 'safe',
    );

    await _settle();
    final radio =
        html.document.querySelector('input[type="radio"][value="fast"]')
            as html.RadioButtonInputElement?;
    expect(radio, isNotNull);
    radio!.checked = true;
    _click('.swal2-confirm');
    final radioResult = await radioFuture;
    expect(radioResult.value, 'fast');

    final checkboxFuture = SweetAlert.prompt(
      title: 'Notify team',
      inputType: SweetAlertInputType.checkbox,
      inputLabel: 'Send status message',
      inputChecked: true,
    );

    await _settle();
    final checkbox = html.document.querySelector('input[type="checkbox"]')
        as html.CheckboxInputElement?;
    expect(checkbox, isNotNull);
    checkbox!.checked = false;
    _click('.swal2-confirm');
    final checkboxResult = await checkboxFuture;
    expect(checkboxResult.value, 'false');

    final rangeFuture = SweetAlert.prompt(
      title: 'Adjust intensity',
      inputType: SweetAlertInputType.range,
      inputMin: 0,
      inputMax: 100,
      inputStep: 10,
      inputValue: '40',
    );

    await _settle();
    final range = html.document.querySelector('input[type="range"]')
        as html.InputElement?;
    expect(range, isNotNull);
    range!.value = '70';
    _click('.swal2-confirm');
    final rangeResult = await rangeFuture;
    expect(rangeResult.value, '70');
  });
}

void _click(String selector) {
  final element = html.document.querySelector(selector);
  expect(element, isNotNull);
  element!.dispatchEvent(html.MouseEvent('click', canBubble: true));
}

void _resetSweetAlertDom() {
  SweetAlert.dismissAll();
  html.document.body?.classes.removeAll(
    const <String>['swal2-shown', 'swal2-height-auto', 'swal2-toast-shown'],
  );
}

Future<void> _settle() async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
}
