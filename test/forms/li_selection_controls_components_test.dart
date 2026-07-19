// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_selection_controls_components_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:web/web.dart' as web;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import '../support/web_event_factories.dart';
import '../support/web_node_list.dart';

import 'li_selection_controls_components_test.template.dart' as ng;

@Component(
  selector: 'selection-controls-test-host',
  template: '''
    <li-checkbox
        label="Audit"
        [(ngModel)]="checkboxValue">
    </li-checkbox>

    <li-checkbox
      id="required-checkbox"
      label="Terms"
      [required]="true"
      [liMessages]="checkboxMessages"
      liValidationMode="touchedOrDirty"
      [(ngModel)]="requiredCheckboxValue">
    </li-checkbox>

    <li-radio
        name="visibility"
        label="Team"
        value="team"
        [(ngModel)]="radioValue">
    </li-radio>

    <li-radio
        name="visibility"
        label="Public"
        value="public"
        [uncheckable]="allowRadioUncheck"
        [(ngModel)]="radioValue">
    </li-radio>

    <li-toggle
        label="Automation"
        trueValue="enabled"
        falseValue="paused"
        [(ngModel)]="toggleValue">
    </li-toggle>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiCheckboxComponent,
    LiRadioComponent,
    LiToggleComponent,
  ],
)
class SelectionControlsTestHostComponent {
  bool checkboxValue = false;
  bool requiredCheckboxValue = false;
  String? radioValue = 'team';
  String toggleValue = 'paused';
  bool allowRadioUncheck = false;

  final Map<String, String> checkboxMessages = const <String, String>{
    'requiredTrue': 'Confirme o aceite.',
  };
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<SelectionControlsTestHostComponent>(
    ng.SelectionControlsTestHostComponentNgFactory,
  );

  test('checkbox updates boolean ngModel', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final checkbox = fixture.rootElement.querySelector('li-checkbox input')
        as web.HTMLInputElement;

    await fixture.update((_) {
      checkbox.checked = true;
      checkbox.dispatchEvent(bubblingEvent('change', bubbles: true));
    });
    await _settle(fixture);

    expect(host.checkboxValue, isTrue);
  });

  test('checkbox supports declarative requiredTrue validation', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final checkbox = fixture.rootElement
        .querySelector('input#required-checkbox') as web.HTMLInputElement;

    await fixture.update((_) {
      checkbox.dispatchEvent(bubblingEvent('blur', bubbles: true));
    });
    await _settle(fixture);

    expect(host.requiredCheckboxValue, isFalse);
    expect(checkbox.classList.contains('is-invalid'), isTrue);
    expect(fixture.rootElement.textContent, contains('Confirme o aceite.'));

    await fixture.update((_) {
      checkbox.checked = true;
      checkbox.dispatchEvent(bubblingEvent('change', bubbles: true));
      checkbox.dispatchEvent(bubblingEvent('blur', bubbles: true));
    });
    await _settle(fixture);

    expect(host.requiredCheckboxValue, isTrue);
    expect(checkbox.classList.contains('is-invalid'), isFalse);
  });

  test('radio keeps the current value when clicked again by default', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final radios =
        fixture.rootElement.querySelectorAll('li-radio input').toElementList();
    final publicRadio = radios[1] as web.HTMLInputElement;

    await fixture.update((_) {
      publicRadio.checked = true;
      publicRadio.dispatchEvent(bubblingEvent('change', bubbles: true));
    });
    await _settle(fixture);

    expect(host.radioValue, 'public');

    await fixture.update((_) {
      publicRadio.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.radioValue, 'public');
  });

  test('radio clears the current value when uncheckable is enabled', () async {
    final fixture = await testBed.create();
    await fixture.update((host) {
      host.allowRadioUncheck = true;
    });
    await _settle(fixture);

    final host = fixture.assertOnlyInstance;
    final radios =
        fixture.rootElement.querySelectorAll('li-radio input').toElementList();
    final publicRadio = radios[1] as web.HTMLInputElement;

    await fixture.update((_) {
      publicRadio.checked = true;
      publicRadio.dispatchEvent(bubblingEvent('change', bubbles: true));
    });
    await _settle(fixture);

    expect(host.radioValue, 'public');

    await fixture.update((_) {
      publicRadio.dispatchEvent(bubblingMouseEvent('click', bubbles: true));
    });
    await _settle(fixture);

    expect(host.radioValue, isNull);
  });

  test('radio change updates the checked state for the selected option',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final radios =
        fixture.rootElement.querySelectorAll('li-radio input').toElementList();
    final teamRadio = radios[0] as web.HTMLInputElement;
    final publicRadio = radios[1] as web.HTMLInputElement;

    expect(teamRadio.checked, isTrue);
    expect(publicRadio.checked, isFalse);

    await fixture.update((_) {
      publicRadio.checked = true;
      publicRadio.dispatchEvent(bubblingEvent('change', bubbles: true));
    });
    await _settle(fixture);

    expect(teamRadio.checked, isFalse);
    expect(publicRadio.checked, isTrue);
  });

  test('toggle maps boolean interaction to custom trueValue/falseValue',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final toggle = fixture.rootElement.querySelector('li-toggle input')
        as web.HTMLInputElement;

    await fixture.update((_) {
      toggle.checked = true;
      toggle.dispatchEvent(bubblingEvent('change', bubbles: true));
    });
    await _settle(fixture);

    expect(host.toggleValue, 'enabled');

    await fixture.update((_) {
      toggle.checked = false;
      toggle.dispatchEvent(bubblingEvent('change', bubbles: true));
    });
    await _settle(fixture);

    expect(host.toggleValue, 'paused');
  });
}

Future<void> _settle(
  NgTestFixture<SelectionControlsTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}
