// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/sweet_alert/li_sweet_alert_directive_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_sweet_alert_directive_test.template.dart' as ng;

@Component(
  selector: 'li-sweet-alert-directive-test-host',
  template: '''
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

  test('opens confirm dialogs and emits the confirmation result', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final button = fixture.rootElement.querySelector('#confirm-button')
        as html.ButtonElement;

    await fixture.update((_) {
      button.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(html.document.querySelector('.swal2-popup'), isNotNull);

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
        as html.ButtonElement;

    await fixture.update((_) {
      button.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final input =
        html.document.querySelector('.swal2-input') as html.InputElement;
    await fixture.update((_) {
      input.value = 'batch-42';
      input.dispatchEvent(html.Event('input', canBubble: true));
      _click('.swal2-confirm');
    });
    await _settle(fixture);

    final result = host.promptResult as SweetAlertResult<String>;
    expect(result.isConfirmed, isTrue);
    expect(result.value, 'batch-42');
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

Future<void> _settle(
  NgTestFixture<SweetAlertDirectiveTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
