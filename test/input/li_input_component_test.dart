// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/input/li_input_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;
import 'dart:js';

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_input_component_test.template.dart' as ng;

@Component(
  selector: 'li-input-test-host',
  template: '''
    <li-input
        id="name-input"
        label="Name"
        helperText="Required field"
        invalidFeedbackText="Name is required"
        validFeedbackText="Looks good"
        [required]="true"
        (inputBlur)="onBlur(\$event)"
        (inputFocus)="onFocus(\$event)"
        (inputClick)="onClick(\$event)"
        (inputKeydown)="onKeydown(\$event)"
        (inputEnter)="onEnter(\$event)"
        [(ngModel)]="name">
    </li-input>

    <li-input
        id="search-input"
        label="Search"
        [floatingLabel]="true"
        prefixIconClass="ph-magnifying-glass"
        [(ngModel)]="search">
    </li-input>

    <li-input
        id="cpf-input"
        label="CPF"
        mask="xxx.xxx.xxx-xx"
        inputMode="numeric"
        [maxLength]="14"
        [(ngModel)]="cpf">
    </li-input>

    <li-input
        id="quantity-input"
        label="Quantity"
        type="number"
        min="1"
        max="99"
        step="1"
        [(ngModel)]="quantity">
    </li-input>

    <li-input
      id="password-input"
      label="Password"
      type="password"
      [passwordToggle]="true"
      [passwordToggleOverlay]="true"
      autocomplete="new-password"
      autocorrect="off"
      autocapitalize="off"
      spellcheck="false"
      dataLpignore="true"
      data1pIgnore="true"
      dataBwignore="true"
      enterKeyHint="done"
      titleText="Password field"
      [minLength]="8"
      [(ngModel)]="password">
    </li-input>
  ''',
  directives: [coreDirectives, formDirectives, LiInputComponent],
)
class InputTestHostComponent {
  String name = '';
  String search = '';
  String cpf = '';
  String quantity = '1';
  String password = 'Secret@123';
  int blurCount = 0;
  int focusCount = 0;
  int clickCount = 0;
  int keydownCount = 0;
  int enterCount = 0;

  void onBlur(dynamic _) => blurCount++;

  void onFocus(dynamic _) => focusCount++;

  void onClick(dynamic _) => clickCount++;

  void onKeydown(dynamic _) => keydownCount++;

  void onEnter(dynamic _) => enterCount++;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<InputTestHostComponent>(
    ng.InputTestHostComponentNgFactory,
  );

  test('updates ngModel when the user types', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input =
        fixture.rootElement.querySelector('input#name-input') as dynamic;

    await fixture.update((_) {
      input.value = 'Maria';
      input.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    expect(host.name, 'Maria');
    expect(fixture.rootElement.text, contains('Required field'));
  });

  test('applies and clears required validation classes after blur', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final input =
        fixture.rootElement.querySelector('input#name-input') as dynamic;

    await fixture.update((_) {
      input.dispatchEvent(html.Event('blur', canBubble: true));
    });
    await _settle(fixture);

    expect(input.classes.contains('is-invalid'), isTrue);
    expect(fixture.rootElement.text, contains('Name is required'));

    await fixture.update((_) {
      input.value = 'Joao';
      input.dispatchEvent(html.Event('input', canBubble: true));
      input.dispatchEvent(html.Event('blur', canBubble: true));
    });
    await _settle(fixture);

    expect(input.classes.contains('is-invalid'), isFalse);
    expect(fixture.rootElement.text, contains('Looks good'));
  });

  test('applies the declarative mask while updating ngModel', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input =
        fixture.rootElement.querySelector('input#cpf-input') as dynamic;

    await fixture.update((_) {
      input.value = '12345678901';
      input.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    expect(host.cpf, '123.456.789-01');
    expect(input.value, '123.456.789-01');
  });

  test('renders numeric attributes for number inputs', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input = fixture.rootElement.querySelector('input#quantity-input')
        as html.InputElement;

    expect(input.getAttribute('min'), '1');
    expect(input.getAttribute('max'), '99');
    expect(input.getAttribute('step'), '1');

    await fixture.update((_) {
      input.value = '12';
      input.dispatchEvent(html.Event('input', canBubble: true));
    });
    await _settle(fixture);

    expect(host.quantity, '12');
  });

  test('toggles password visibility when configured', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final input = fixture.rootElement.querySelector('input#password-input')
        as html.InputElement;
    final toggle = fixture.rootElement
        .querySelector('.li-input__password-toggle') as html.ButtonElement;

    expect(input.type, 'password');
    expect(toggle.getAttribute('aria-label'), 'Mostrar senha');
    expect(input.getAttribute('autocomplete'), 'new-password');
    expect(input.getAttribute('autocorrect'), 'off');
    expect(input.getAttribute('autocapitalize'), 'off');
    expect(input.getAttribute('spellcheck'), 'false');
    expect(input.getAttribute('data-lpignore'), 'true');
    expect(input.getAttribute('data-1p-ignore'), 'true');
    expect(input.getAttribute('data-bwignore'), 'true');
    expect(input.getAttribute('enterkeyhint'), 'done');
    expect(input.getAttribute('title'), 'Password field');
    expect(input.getAttribute('minlength'), '8');
    expect(
        toggle.classes.contains('li-input__password-toggle--overlay'), isTrue);

    await fixture.update((_) {
      toggle.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(input.type, 'text');
    expect(toggle.getAttribute('aria-label'), 'Ocultar senha');
  });

  test('delegates host focus to the inner control', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final hostElement =
        fixture.rootElement.querySelectorAll('li-input').last;
    final input = fixture.rootElement.querySelector('input#password-input')
        as html.InputElement;

    await fixture.update((_) {
      hostElement.focus();
    });
    await _settle(fixture);

    expect(html.document.activeElement, same(input));
  });

  test('emits focus, click, blur, keydown and enter outputs', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input =
        fixture.rootElement.querySelector('input#name-input') as html.InputElement;

    await fixture.update((_) {
      input.dispatchEvent(html.Event('focus', canBubble: true));
      input.dispatchEvent(html.MouseEvent('click', canBubble: true));
      input.dispatchEvent(createKeyEvent('keydown', key: 'A'));
      input.dispatchEvent(createKeyEvent('keydown', key: 'Enter', code: 'Enter'));
      input.dispatchEvent(html.Event('blur', canBubble: true));
    });
    await _settle(fixture);

    expect(host.focusCount, greaterThanOrEqualTo(1));
    expect(host.clickCount, 1);
    expect(host.keydownCount, 2);
    expect(host.enterCount, 1);
    expect(host.blurCount, 1);
  });
}

Future<void> _settle(NgTestFixture<InputTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

const _createKeyEventName = '__dart_createLiInputKeyboardEvent';
const _createKeyEventScript = '''
window['$_createKeyEventName'] = function(type, key, code) {
  return new KeyboardEvent(type, {
    key: key,
    code: code || key,
    bubbles: true
  });
}
''';

html.Event createKeyEvent(
  String type, {
  required String key,
  String? code,
}) {
  if (!context.hasProperty(_createKeyEventName)) {
    final script = html.document.createElement('script')
      ..setAttribute('type', 'text/javascript')
      ..text = _createKeyEventScript;
    html.document.body!.append(script);
  }

  return context.callMethod(
    _createKeyEventName,
    <Object>[type, key, code ?? key],
  ) as html.Event;
}
