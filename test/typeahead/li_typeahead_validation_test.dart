// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/typeahead/li_typeahead_validation_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_typeahead_validation_test.template.dart' as ng;

@Component(
  selector: 'li-typeahead-validation-test-host',
  template: '''
    <div liForm #ui="liForm">
      <div id="strict-field">
        <li-typeahead
            container="inline"
            [dataSource]="states"
            [debounceMs]="0"
            [editable]="false"
            [liRules]="requiredRules"
            [liMessages]="stateMessages"
            liValidationMode="submitted"
            [(ngModel)]="strictState">
        </li-typeahead>
      </div>

      <div id="free-field">
        <li-typeahead
            container="inline"
            [dataSource]="states"
            [debounceMs]="0"
            [liRules]="freeRules"
            liValidationMode="touchedOrDirty"
            [invalid]="externalInvalid"
            [validationErrorText]="externalError"
            [(ngModel)]="freeState">
        </li-typeahead>
      </div>

      <div id="failing-field">
        <li-typeahead
            container="inline"
            [searchCallback]="failingSearch"
            [debounceMs]="0"
            errorText="Search failed."
            [(ngModel)]="failingState">
        </li-typeahead>
      </div>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    limitlessFormDirectives,
    LiTypeaheadComponent,
  ],
)
class TypeaheadValidationHostComponent {
  static const List<LiRule> requiredRules = <LiRule>[LiRule.required()];
  static const List<LiRule> freeRules = <LiRule>[
    LiRule.required(),
    LiRule.minLength(3),
  ];
  static const Map<String, String> stateMessages = <String, String>{
    'required': 'Escolha um estado da lista.',
  };

  final List<String> states = const <String>[
    'Alabama',
    'Alaska',
    'Arizona',
  ];

  dynamic strictState;
  dynamic freeState;
  dynamic failingState;
  bool externalInvalid = false;
  String externalError = '';

  @ViewChild('ui')
  LiFormDirective? form;

  Future<List<String>> failingSearch(String term) async {
    throw StateError('backend down');
  }
}

/// A section of a larger form declared in its own component.
@Component(
  selector: 'li-typeahead-child-section',
  template: '''
    <li-typeahead
        id="child-typeahead"
        container="inline"
        [dataSource]="states"
        [liRules]="requiredRules"
        [(ngModel)]="state">
    </li-typeahead>
  ''',
  directives: [coreDirectives, formDirectives, LiTypeaheadComponent],
)
class TypeaheadChildSectionComponent {
  static const List<LiRule> requiredRules = <LiRule>[LiRule.required()];

  final List<String> states = const <String>['Alabama'];
  dynamic state;
}

@Component(
  selector: 'li-typeahead-child-host',
  template: '''
    <div liForm #ui="liForm">
      <li-typeahead-child-section></li-typeahead-child-section>
    </div>
  ''',
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    TypeaheadChildSectionComponent,
  ],
)
class TypeaheadChildHostComponent {
  @ViewChild('ui')
  LiFormDirective? form;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TypeaheadValidationHostComponent>(
    ng.TypeaheadValidationHostComponentNgFactory,
  );

  html.InputElement inputOf(NgTestFixture<dynamic> fixture, String fieldId) =>
      fixture.rootElement.querySelector('#$fieldId input') as html.InputElement;

  test('with editable=false, typed text without a suggestion counts as empty',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input = inputOf(fixture, 'strict-field');

    await fixture.update((_) {
      input.focus();
      _type(input, 'Texas');
      input.dispatchEvent(html.Event('blur'));
    });
    await _settle(fixture);

    expect(host.strictState, isNull,
        reason: 'editable=false never puts free text in the model.');
    expect(input.classes, isNot(contains('is-invalid')),
        reason: 'liValidationMode="submitted" waits for the submit.');

    input.blur();
    final valid = await host.form!.validateAndFocusFirstInvalid();
    await _settle(fixture);

    expect(valid, isFalse);
    expect(input.classes, contains('is-invalid'));
    expect(input.attributes['data-invalid'], 'true');
    expect(input.attributes['aria-invalid'], 'true');
    expect(fixture.rootElement.text, contains('Escolha um estado da lista.'));
    expect(html.document.activeElement, same(input),
        reason: 'The form focuses the inner input of the typeahead.');

    await fixture.update((_) => _type(input, 'Alas'));
    await _settle(fixture);
    final item = fixture.rootElement
        .querySelector('#strict-field .li-typeahead__item') as html.Element;
    await fixture.update((_) => item.click());
    await _settle(fixture);

    expect(host.strictState, 'Alaska');
    expect(input.classes, isNot(contains('is-invalid')));
    expect(input.classes, contains('is-valid'));
  });

  test('rules run on the typed text when editable is on', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final input = inputOf(fixture, 'free-field');

    await fixture.update((_) => _type(input, 'Al'));
    await _settle(fixture);
    expect(host.freeState, 'Al');
    expect(input.classes, contains('is-invalid'));
    expect(fixture.rootElement.text, contains('Informe pelo menos 3 caracteres.'));

    await fixture.update((_) => _type(input, 'Alabama'));
    await _settle(fixture);
    expect(input.classes, isNot(contains('is-invalid')));
  });

  test('external invalid and validationErrorText win over the rules',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final input = inputOf(fixture, 'free-field');

    await fixture.update((_) => _type(input, 'Alabama'));
    await _settle(fixture);
    expect(input.classes, isNot(contains('is-invalid')));

    await fixture.update((host) {
      host.externalInvalid = true;
      host.externalError = 'Estado bloqueado pelo servidor.';
    });
    await _settle(fixture);
    expect(input.classes, contains('is-invalid'));
    expect(fixture.rootElement.text, contains('Estado bloqueado pelo servidor.'));

    await fixture.update((_) => _type(input, 'Al'));
    await _settle(fixture);
    final feedback = fixture.rootElement
        .querySelector('#free-field [data-label="li_ta_feedback"]')!;
    expect(feedback.text!.trim(), 'Estado bloqueado pelo servidor.');
  });

  test('errorText keeps meaning a failed search, not a field error', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final input = inputOf(fixture, 'failing-field');

    await fixture.update((_) {
      input.focus();
      _type(input, 'any');
    });
    await _settle(fixture, milliseconds: 80);

    expect(fixture.rootElement.querySelector('#failing-field .li-typeahead__status')
        ?.text, contains('Search failed.'));
    expect(input.classes, isNot(contains('is-invalid')));
    expect(fixture.rootElement.querySelector('#failing-field [data-label="li_ta_feedback"]'),
        isNull);
  });

  test('a typeahead inside a child component takes part in the page form',
      () async {
    final fixture = await NgTestBed<TypeaheadChildHostComponent>(
      ng.TypeaheadChildHostComponentNgFactory,
    ).create();
    await _settle(fixture);

    final valid = await fixture.assertOnlyInstance.form!
        .validateAndFocusFirstInvalid();
    await _settle(fixture);

    expect(valid, isFalse);
    final input = fixture.rootElement.querySelector('#child-typeahead input')
        as html.InputElement;
    expect(input.classes, contains('is-invalid'));
    expect(html.document.activeElement, same(input));
  });
}

void _type(html.InputElement input, String text) {
  input.value = text;
  input.dispatchEvent(html.Event('input', canBubble: true));
}

Future<void> _settle(
  NgTestFixture<dynamic> fixture, {
  int milliseconds = 30,
}) async {
  for (var i = 0; i < 2; i++) {
    await Future<void>.delayed(Duration(milliseconds: milliseconds));
    await fixture.update((_) {});
  }
}
