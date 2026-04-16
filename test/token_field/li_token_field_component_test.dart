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
    <li-token-field
        #field
        [filterInput]="true"
        patternAllowed="[0-9/]"
        patternToken="\\d+/\\d+"
        [(ngModel)]="tokens">
    </li-token-field>
  ''',
  directives: [coreDirectives, formDirectives, LiTokenFieldComponent],
)
class TokenFieldTestHostComponent {
  @ViewChild('field')
  LiTokenFieldComponent? field;

  List<String> tokens = <String>['35910/2011'];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TokenFieldTestHostComponent>(
    ng.TokenFieldTestHostComponentNgFactory,
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
}

Future<void> _settle(
  NgTestFixture<TokenFieldTestHostComponent> fixture,
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
