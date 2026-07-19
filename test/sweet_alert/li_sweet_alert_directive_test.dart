// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/sweet_alert/li_sweet_alert_directive_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/src/web_support/dom_tokens.dart';
import 'package:web/web.dart' as web;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import '../support/web_event_factories.dart';

import 'li_sweet_alert_directive_test.template.dart' as ng;

@Component(
  selector: 'li-sweet-alert-directive-test-host',
  template: '''
    <button
        id="show-button"
        type="button"
        [liSweetAlert]="'Directive modal body'"
        liSweetAlertTitle="Directive modal"
        liSweetAlertType="info">
      Show
    </button>

    <button
        id="confirm-button"
        type="button"
        [liSweetAlert]="'Delete item?'"
        liSweetAlertMode="confirm"
        liSweetAlertTitle="Delete"
        liSweetAlertConfirmText="Delete"
        liSweetAlertCancelText="Keep"
        liSweetAlertType="warning"
        (liSweetAlertResult)="confirmResult = \$event">
      Confirm
    </button>

    <button
        id="prompt-button"
        type="button"
        [liSweetAlert]="'Enter the identifier'"
        liSweetAlertMode="prompt"
        liSweetAlertTitle="Batch"
        liSweetAlertPromptPlaceholder="batch-42"
        (liSweetAlertResult)="promptResult = \$event">
      Prompt
    </button>

    <button
        id="textarea-prompt-button"
        type="button"
        [liSweetAlert]="'Describe the required correction reason'"
        liSweetAlertMode="prompt"
        liSweetAlertTitle="Correction"
        liSweetAlertInputType="textarea"
        liSweetAlertPromptPlaceholder="Correction reason"
        liSweetAlertInputClass="li-swalert-textarea"
        [liSweetAlertInputRows]="6"
        [liSweetAlertInputMaxLength]="240"
        liSweetAlertInputAriaLabel="Correction reason"
        (liSweetAlertResult)="promptResult = \$event">
      Textarea prompt
    </button>
  ''',
  directives: [coreDirectives, liSweetAlertDirectives],
  providers: [ClassProvider(SweetAlertService)],
)
class SweetAlertDirectiveTestHostComponent {
  Object? confirmResult;
  Object? promptResult;
}

void main() {
  tearDown(disposeAnyRunningTest);
  tearDown(_resetSweetAlertDom);

  final testBed = NgTestBed<SweetAlertDirectiveTestHostComponent>(
    ng.SweetAlertDirectiveTestHostComponentNgFactory,
  );

  test('uses centered positioning by default for modal mode', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final button = fixture.rootElement.querySelector('#show-button')
        as web.HTMLButtonElement;

    await fixture.update((_) {
      button.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(
        web.document.querySelector('.swal2-container.swal2-center'), isNotNull);
    expect(web.document.querySelector('.swal2-popup.swal2-modal'), isNotNull);

    await fixture.update((_) {
      _click('.swal2-confirm');
    });
    await _settle(fixture);
  });

  test('opens confirm dialogs and emits the confirmation result', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final button = fixture.rootElement.querySelector('#confirm-button')
        as web.HTMLButtonElement;

    await fixture.update((_) {
      button.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(web.document.querySelector('.swal2-popup'), isNotNull);

    await fixture.update((_) {
      _click('.swal2-confirm');
    });
    await _settle(fixture);

    final result = host.confirmResult as SweetAlertResult<bool>;
    expect(result.isConfirmed, isTrue);
    expect(result.value, isTrue);
  });

  test('opens prompt dialogs and emits the entered value', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final button = fixture.rootElement.querySelector('#prompt-button')
        as web.HTMLButtonElement;

    await fixture.update((_) {
      button.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    final input =
        web.document.querySelector('.swal2-input') as web.HTMLInputElement;
    await fixture.update((_) {
      input.value = 'batch-42';
      input.dispatchEvent(bubblingEvent('input', bubbles: true));
      _click('.swal2-confirm');
    });
    await _settle(fixture);

    final result = host.promptResult as SweetAlertResult<String>;
    expect(result.isConfirmed, isTrue);
    expect(result.value, 'batch-42');
  });

  test('passes prompt input customization through the directive', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final button = fixture.rootElement.querySelector('#textarea-prompt-button')
        as web.HTMLButtonElement;

    await fixture.update((_) {
      button.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    final textarea = web.document.querySelector('.swal2-textarea')
        as web.HTMLTextAreaElement;
    expect(textarea.classList.contains('li-swalert-textarea'), isTrue);
    expect(textarea.rows, 6);
    expect(textarea.maxLength, 240);
    expect(textarea.getAttribute('aria-label'), 'Correction reason');

    await fixture.update((_) {
      textarea.value = 'Wrong dispatch selected.';
      textarea.dispatchEvent(bubblingEvent('input', bubbles: true));
      _click('.swal2-confirm');
    });
    await _settle(fixture);

    final result =
        fixture.assertOnlyInstance.promptResult as SweetAlertResult<String>;
    expect(result.isConfirmed, isTrue);
    expect(result.value, 'Wrong dispatch selected.');
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

Future<void> _settle(
  NgTestFixture<SweetAlertDirectiveTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
