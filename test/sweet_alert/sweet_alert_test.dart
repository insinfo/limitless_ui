// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/sweet_alert/sweet_alert_test.dart

@TestOn('browser')
library;

import 'dart:async';
import 'package:limitless_ui/src/web_support/dom_tokens.dart';
import 'package:web/web.dart' as web;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

import '../support/web_event_factories.dart';

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

    final popup = web.document.querySelector('.swal2-popup.swal2-modal');
    expect(popup, isNotNull);
    final resolvedPopup = popup!;
    final root = web.document.querySelector('[data-label="li_sa_root"]');
    expect(root, isNotNull);
    expect(root!.getAttribute('data-open'), 'true');
    expect(resolvedPopup.getAttribute('data-label'), 'li_sa_popup');
    expect(resolvedPopup.getAttribute('data-type'), 'success');
    expect(resolvedPopup.getAttribute('data-open'), 'true');
    expect(
      resolvedPopup.querySelector('[data-label="li_sa_title"]'),
      isNotNull,
    );
    expect(
      resolvedPopup.querySelector('[data-label="li_sa_body"]'),
      isNotNull,
    );
    expect(web.window.getComputedStyle(resolvedPopup).display, 'grid');
    expect(resolvedPopup.classList.contains('swal2-icon-success'), isTrue);
    expect(
      resolvedPopup
          .querySelector('[data-label="li_sa_icon"]')
          ?.getAttribute('data-value'),
      'success',
    );
    expect(resolvedPopup.textContent, contains('Deployment ready'));
    expect(resolvedPopup.textContent,
        contains('The release summary is available.'));
    expect(
      resolvedPopup.querySelector('[data-label="li_sa_actions"]'),
      isNotNull,
    );
    expect(
      resolvedPopup.querySelector('[data-label="li_sa_close"]'),
      isNotNull,
    );
    final confirmButton =
        resolvedPopup.querySelector('.swal2-confirm') as web.HTMLButtonElement?;
    expect(confirmButton, isNotNull);
    expect(confirmButton!.getAttribute('data-label'), 'li_sa_confirm');
    expect(confirmButton.classList.contains('btn'), isTrue);
    expect(confirmButton.classList.contains('btn-primary'), isTrue);

    _click('.swal2-confirm');
    final result = await future;

    expect(result.isConfirmed, isTrue);
    expect(result.isDismissed, isFalse);
    expect(web.document.querySelector('.swal2-container'), isNull);
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
    final cancelButton =
        web.document.querySelector('.swal2-cancel') as web.HTMLButtonElement?;
    expect(cancelButton, isNotNull);
    expect(cancelButton!.getAttribute('data-label'), 'li_sa_cancel');
    _click('.swal2-cancel');
    final result = await future;

    expect(result.isConfirmed, isFalse);
    expect(result.isDismissed, isTrue);
    expect(result.dismissReason, SweetAlertDismissReason.cancel);
  });

  test('confirm and cancel callbacks run on button actions', () async {
    var confirmCalled = false;
    var cancelCalled = false;

    final confirmFuture = SweetAlert.confirm(
      title: 'Publish release',
      message: 'Run callbacks inline.',
      onConfirmAction: (result) {
        confirmCalled = result.isConfirmed;
      },
    );

    await _settle();
    _click('.swal2-confirm');
    await _settle();

    final confirmResult = await confirmFuture;
    expect(confirmCalled, isTrue);
    expect(confirmResult.isConfirmed, isTrue);

    final cancelFuture = SweetAlert.confirm(
      title: 'Abort release',
      message: 'Run cancel callback inline.',
      onCancelAction: (result) {
        cancelCalled = result.dismissReason == SweetAlertDismissReason.cancel;
      },
    );

    await _settle();
    _click('.swal2-cancel');
    await _settle();

    final cancelResult = await cancelFuture;
    expect(cancelCalled, isTrue);
    expect(cancelResult.dismissReason, SweetAlertDismissReason.cancel);
  });

  test('dismiss callback runs for close button backdrop and escape', () async {
    final dismissReasons = <SweetAlertDismissReason>[];

    final closeButtonFuture = SweetAlert.show(
      title: 'Dismiss me',
      showCloseButton: true,
      onDismissAction: (result) {
        dismissReasons.add(result.dismissReason!);
      },
    );

    await _settle();
    _click('.swal2-close');
    final closeButtonResult = await closeButtonFuture;
    expect(
        closeButtonResult.dismissReason, SweetAlertDismissReason.closeButton);

    final backdropFuture = SweetAlert.show(
      title: 'Backdrop dismiss',
      onDismissAction: (result) {
        dismissReasons.add(result.dismissReason!);
      },
    );

    await _settle();
    _click('.swal2-container');
    final backdropResult = await backdropFuture;
    expect(backdropResult.dismissReason, SweetAlertDismissReason.backdrop);

    final escapeFuture = SweetAlert.show(
      title: 'Escape dismiss',
      onDismissAction: (result) {
        dismissReasons.add(result.dismissReason!);
      },
    );

    await _settle();
    web.document.dispatchEvent(_createKeyEvent('keydown', key: 'Escape'));
    final escapeResult = await escapeFuture;
    expect(escapeResult.dismissReason, SweetAlertDismissReason.escape);

    expect(
      dismissReasons,
      equals(<SweetAlertDismissReason>[
        SweetAlertDismissReason.closeButton,
        SweetAlertDismissReason.backdrop,
        SweetAlertDismissReason.escape,
      ]),
    );
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
        web.document.querySelector('.swal2-validation-message') as web.Element;
    expect(validationMessage.getAttribute('data-label'), 'li_sa_validation');
    expect(validationMessage.textContent, contains('Identifier is required'));
    expect(
        web.window.getComputedStyle(validationMessage).display, isNot('none'));

    final input =
        web.document.querySelector('.swal2-input') as web.HTMLInputElement?;
    expect(input, isNotNull);
    input!
      ..value = 'batch-42'
      ..dispatchEvent(bubblingEvent('input', bubbles: true));

    _click('.swal2-confirm');
    final result = await future;

    expect(result.isConfirmed, isTrue);
    expect(result.value, 'batch-42');
  });

  test('textarea prompt renders with usable default field chrome', () async {
    final future = SweetAlert.prompt(
      title: 'Correction reason',
      inputType: SweetAlertInputType.textarea,
      inputPlaceholder: 'Describe the reason',
    );

    await _settle();

    final textarea = web.document.querySelector('.swal2-textarea')
        as web.HTMLTextAreaElement?;
    expect(textarea, isNotNull);
    expect(textarea!.classList.contains('form-control'), isTrue);
    expect(textarea.rows, 4);
    expect(textarea.style.width, '100%');
    expect(textarea.style.minHeight, '7rem');
    expect(textarea.style.resize, 'vertical');

    textarea.value = 'Wrong dispatch selected.';
    _click('.swal2-confirm');
    final result = await future;

    expect(result.isConfirmed, isTrue);
    expect(result.value, 'Wrong dispatch selected.');
  });

  test('prompt input config applies classes attributes and constraints',
      () async {
    final future = SweetAlert.prompt(
      title: 'Correction reason',
      inputType: SweetAlertInputType.textarea,
      inputConfig: const SweetAlertInputConfig(
        className: 'li-swalert-textarea form-control-lg',
        rows: 6,
        minLength: 10,
        maxLength: 240,
        attributes: <String, String>{
          'aria-label': 'Correction reason',
          'data-test-id': 'correction-reason',
        },
        style: <String, String>{
          'min-height': '10rem',
          'resize': 'none',
        },
      ),
    );

    await _settle();

    final textarea = web.document.querySelector('.swal2-textarea')
        as web.HTMLTextAreaElement?;
    expect(textarea, isNotNull);
    expect(textarea!.classList.contains('li-swalert-textarea'), isTrue);
    expect(textarea.classList.contains('form-control-lg'), isTrue);
    expect(textarea.rows, 6);
    expect(textarea.minLength, 10);
    expect(textarea.maxLength, 240);
    expect(textarea.getAttribute('aria-label'), 'Correction reason');
    expect(textarea.getAttribute('data-test-id'), 'correction-reason');
    expect(textarea.style.minHeight, '10rem');
    expect(textarea.style.resize, 'none');

    textarea.value = 'Wrong dispatch selected.';
    _click('.swal2-confirm');
    await future;
  });

  test('toast closes on timer and clears body state classes', () async {
    final controller = SweetAlert.toast(
      'Saved successfully',
      type: SweetAlertType.success,
      timer: const Duration(milliseconds: 120),
    );

    await _settle();
    expect(web.document.querySelector('.swal2-toast'), isNotNull);
    expect(web.document.body!.classList.contains('swal2-toast-shown'), isTrue);

    final reason = await controller.closed;
    await _settle();

    expect(reason, SweetAlertDismissReason.timer);
    expect(web.document.querySelector('.swal2-toast'), isNull);
    expect(web.document.body!.classList.contains('swal2-toast-shown'), isFalse);
  });

  test('error type renders the x-mark structure expected by Limitless CSS',
      () async {
    final future = SweetAlert.show(
      title: 'Oops',
      message: 'Something went wrong.',
      type: SweetAlertType.error,
    );

    await _settle();

    expect(web.document.querySelector('.swal2-icon.swal2-error .swal2-x-mark'),
        isNotNull);
    expect(
      web.document
          .querySelector('.swal2-icon.swal2-error .swal2-x-mark-line-left'),
      isNotNull,
    );
    expect(
      web.document
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

    expect(web.document.querySelector('.swal2-container.swal2-center-end'),
        isNotNull);
    final actions = web.document.querySelector('.swal2-actions');
    expect(actions, isNotNull);
    final actionButtons =
        web.JSImmutableListWrapper<web.HTMLCollection, web.Element>(
      actions!.children,
    )
            .where((element) => element.classList.contains('swal2-styled'))
            .toList(growable: false);
    expect(actionButtons.first.classList.contains('swal2-cancel'), isTrue);
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
        web.document.querySelector('.swal2-select') as web.HTMLSelectElement?;
    expect(select, isNotNull);
    expect(select!.getAttribute('data-label'), 'li_sa_input');
    expect(select.getAttribute('data-value'), 'select');
    expect(
      select.querySelector(
        '[data-label="li_sa_input_option"][data-value="prod"]',
      ),
      isNotNull,
    );
    expect(select.value, 'staging');
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
        web.document.querySelector('input[type="radio"][value="fast"]')
            as web.HTMLInputElement?;
    expect(radio, isNotNull);
    expect(radio!.getAttribute('data-label'), 'li_sa_input_radio');
    expect(radio.getAttribute('data-value'), 'fast');
    radio.checked = true;
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
    final checkbox = web.document.querySelector('input[type="checkbox"]')
        as web.HTMLInputElement?;
    expect(checkbox, isNotNull);
    expect(checkbox!.getAttribute('data-label'), 'li_sa_input_checkbox');
    checkbox.checked = false;
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
    final range = web.document.querySelector('input[type="range"]')
        as web.HTMLInputElement?;
    expect(range, isNotNull);
    expect(range!.getAttribute('data-label'), 'li_sa_input');
    expect(range.getAttribute('data-value'), 'range');
    range.value = '70';
    _click('.swal2-confirm');
    final rangeResult = await rangeFuture;
    expect(rangeResult.value, '70');
  });
}

void _click(String selector) {
  final element = web.document.querySelector(selector);
  expect(element, isNotNull);
  element!.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
}

void _resetSweetAlertDom() {
  SweetAlert.dismissAll();
  web.document.body?.classList.removeAllTokens(
    const <String>['swal2-shown', 'swal2-height-auto', 'swal2-toast-shown'],
  );
}

Future<void> _settle() async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
}

web.Event _createKeyEvent(
  String type, {
  required String key,
  String? code,
}) =>
    bubblingKeyboardEvent(type, key: key, code: code ?? key);
