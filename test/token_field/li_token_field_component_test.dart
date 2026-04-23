// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/token_field/li_token_field_component_test.dart
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

import 'li_token_field_component_test.template.dart' as ng;

@Component(
  selector: 'li-token-field-test-host',
  template: '''
    <div style="width: 360px;">
      <li-token-field
          #field
          [filterInput]="true"
          patternAllowed="[0-9/]"
          patternToken="\\d+/\\d+"
          [(ngModel)]="tokens">
      </li-token-field>
    </div>
  ''',
  directives: [coreDirectives, formDirectives, LiTokenFieldComponent],
)
class TokenFieldTestHostComponent {
  @ViewChild('field')
  LiTokenFieldComponent? field;

  List<String> tokens = <String>['35910/2011'];
}

@Component(
  selector: 'li-token-field-config-test-host',
  template: '''
    <li-token-field
        #field
        [showCopyAction]="false"
        [showRemoveButton]="false"
        (clearAction)="clearActionCount = clearActionCount + 1"
        [(ngModel)]="tokens">
    </li-token-field>
  ''',
  directives: [coreDirectives, formDirectives, LiTokenFieldComponent],
)
class TokenFieldConfigTestHostComponent {
  @ViewChild('field')
  LiTokenFieldComponent? field;

  List<String> tokens = <String>['35910/2011'];
  int clearActionCount = 0;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TokenFieldTestHostComponent>(
    ng.TokenFieldTestHostComponentNgFactory,
  );
  final configTestBed = NgTestBed<TokenFieldConfigTestHostComponent>(
    ng.TokenFieldConfigTestHostComponentNgFactory,
  );

  test('adds a token on enter and updates ngModel', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input =
        fixture.rootElement.querySelector('input') as html.InputElement;

    await fixture.update((_) {
      input.value = '40596/2012';
      input.dispatchEvent(createKeyEvent('keyup', key: 'Enter'));
    });
    await _settle(fixture);

    expect(host.tokens, containsAll(<String>['35910/2011', '40596/2012']));
  });

  test('processInput parses multiple tokens and clear resets the model',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((_) {
      host.field!.processInput('12345/2023,67890/2024');
    });
    await _settle(fixture);

    expect(host.tokens, containsAll(<String>['12345/2023', '67890/2024']));

    await fixture.update((_) {
      host.field!.clear();
    });
    await _settle(fixture);

    expect(host.tokens, isEmpty);
  });

  test('mantem o input na mesma linha do token enquanto houver espaço',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final token = fixture.rootElement.querySelector('.tokenfield-set-item')
        as html.Element;
    final input = fixture.rootElement.querySelector('.li-token-field__input')
        as html.InputElement;
    final tokenRect = token.getBoundingClientRect();
    final inputRect = input.getBoundingClientRect();

    expect(inputRect.top, lessThan(tokenRect.bottom - 2));
    expect(inputRect.left, greaterThan(tokenRect.left));
    expect(inputRect.width, greaterThan(120));
  });

  test('allows granular action visibility and emits clearAction', () async {
    final fixture = await configTestBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    expect(fixture.rootElement.querySelector('.item-remove'), isNull);

    await fixture.update((_) {
      host.field!.clear();
    });
    await _settle(fixture);

    expect(host.tokens, isEmpty);
    expect(host.clearActionCount, 1);

    final trigger = fixture.rootElement
        .querySelector('.li-token-field__menu button') as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final menuItems = html.document
        .querySelectorAll(
            '.LiDropdownMenuComponent .li-dropdown-menu__menu.show .dropdown-item')
        .map((element) => (element.text ?? '').trim())
        .toList(growable: false);

    expect(menuItems.any((label) => label.contains('Copy')), isFalse);
    expect(menuItems.any((label) => label.contains('Copiar')), isFalse);
    expect(
      menuItems
          .any((label) => label.contains('Paste') || label.contains('Colar')),
      isTrue,
    );
    expect(
      menuItems
          .any((label) => label.contains('Clear') || label.contains('Limpar')),
      isTrue,
    );
  });
}

Future<void> _settle(
  NgTestFixture<dynamic> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

const _createKeyEventName = '__dart_createLiTokenFieldKeyboardEvent';
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
