// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/token_field/li_token_field_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/web_compat.dart' as html;
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_token_field_component_test.template.dart' as ng;

@Component(
  selector: 'li-token-field-test-host',
  template: '''
    <div [style.width.px]="wrapperWidth">
      <li-token-field
          #field
          [filterInput]="true"
          patternAllowed="[0-9/]"
          patternToken="\\d+/\\d+"
          [wrapTokens]="wrapTokens"
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
  int wrapperWidth = 360;
  bool wrapTokens = false;
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

  test('permite quebrar tokens em múltiplas linhas quando configurado',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.wrapperWidth = 180;
      component.wrapTokens = true;
      component.tokens = <String>[
        '10/2026',
        '10/2025',
        '10/2024',
        '10/2023',
      ];
    });
    await _settle(fixture);

    final field =
        fixture.rootElement.querySelector('.li-token-field') as html.Element;
    final input = fixture.rootElement.querySelector('.li-token-field__input')
        as html.InputElement;
    final tokens = fixture.rootElement.queryAll('.tokenfield-set-item');
    final tokenRows = tokens
        .map((element) => element.getBoundingClientRect().top.round())
        .toSet();

    expect(field.classes.contains('li-token-field--wrap'), isTrue);
    expect(input.style.width, isEmpty);
    expect(tokenRows.length, greaterThan(1));
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
      trigger.dispatchEvent(html.liMouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final menuItems = html.document
        .queryAll(
            '.LiDropdownMenuComponent .li-dropdown-menu__menu.show .dropdown-item')
        .map((element) => (element.text).trim())
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

html.Event createKeyEvent(
  String type, {
  required String key,
  String? code,
}) =>
    html.liKeyboardEvent(type, key: key, code: code ?? key);
