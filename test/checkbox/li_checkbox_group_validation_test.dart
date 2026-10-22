// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/checkbox/li_checkbox_group_validation_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_checkbox_group_validation_test.template.dart' as ng;

@Component(
  selector: 'li-checkbox-group-validation-test-host',
  template: '''
    <div liForm #ui="liForm">
      <div id="consents-field">
        <li-checkbox-group
            legend="Consents"
            [liRules]="requiredRules"
            [liMessages]="consentMessages"
            liValidationMode="submitted">
          <li-checkbox label="Terms" [(ngModel)]="acceptTerms"></li-checkbox>
          <li-checkbox label="Privacy" [(ngModel)]="acceptPrivacy"></li-checkbox>
        </li-checkbox-group>
      </div>

      <div id="channels-field">
        <li-checkbox-group
            legend="Channels"
            [liRules]="rangeRules"
            liValidationMode="touchedOrDirty">
          <li-checkbox *ngFor="let channel of channels"
              [label]="channel.label"
              [(ngModel)]="channel.checked">
          </li-checkbox>
        </li-checkbox-group>
      </div>

      <div id="external-field">
        <li-checkbox-group
            legend="External"
            [liRules]="rangeRules"
            liValidationMode="touchedOrDirty"
            [invalid]="externalInvalid"
            [errorText]="externalError">
          <li-checkbox label="One" [(ngModel)]="externalOne"></li-checkbox>
          <li-checkbox label="Two" [(ngModel)]="externalTwo"></li-checkbox>
          <li-checkbox label="Three" [(ngModel)]="externalThree"></li-checkbox>
        </li-checkbox-group>
      </div>

      <div id="bound-field">
        <li-checkbox-group
            legend="Bound"
            [value]="selectedIds"
            [liRules]="requiredRules"
            liValidationMode="submitted"
            locale="en_US">
          <li-checkbox label="A" [(ngModel)]="boundA"></li-checkbox>
        </li-checkbox-group>
      </div>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    limitlessFormDirectives,
    LiCheckboxComponent,
    LiCheckboxGroupComponent,
  ],
)
class CheckboxGroupValidationHostComponent {
  static const List<LiRule> requiredRules = <LiRule>[LiRule.required()];
  static const List<LiRule> rangeRules = <LiRule>[
    LiRule.minSelected(2),
    LiRule.maxSelected(3),
  ];
  static const Map<String, String> consentMessages = <String, String>{
    'required': 'Marque ao menos um consentimento.',
  };

  final List<ChannelOption> channels = <ChannelOption>[
    ChannelOption('sms'),
    ChannelOption('email'),
    ChannelOption('push'),
    ChannelOption('fax'),
  ];

  bool acceptTerms = false;
  bool acceptPrivacy = false;
  bool externalOne = true;
  bool externalTwo = true;
  bool externalThree = false;
  bool externalInvalid = false;
  String externalError = '';
  bool boundA = false;
  List<String> selectedIds = <String>[];

  @ViewChild('ui')
  LiFormDirective? form;
}

class ChannelOption {
  ChannelOption(this.label);

  final String label;
  bool checked = false;
}

/// A section of a larger form declared in its own component.
@Component(
  selector: 'li-checkbox-group-child-section',
  template: '''
    <li-checkbox-group id="child-group" legend="Child" [liRules]="requiredRules">
      <li-checkbox label="Only" [(ngModel)]="only"></li-checkbox>
    </li-checkbox-group>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiCheckboxComponent,
    LiCheckboxGroupComponent,
  ],
)
class CheckboxGroupChildSectionComponent {
  static const List<LiRule> requiredRules = <LiRule>[LiRule.required()];

  bool only = false;
}

@Component(
  selector: 'li-checkbox-group-child-host',
  template: '''
    <div liForm #ui="liForm">
      <li-checkbox-group-child-section></li-checkbox-group-child-section>
    </div>
  ''',
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    CheckboxGroupChildSectionComponent,
  ],
)
class CheckboxGroupChildHostComponent {
  @ViewChild('ui')
  LiFormDirective? form;
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<CheckboxGroupValidationHostComponent>(
    ng.CheckboxGroupValidationHostComponentNgFactory,
  );

  html.Element fieldset(NgTestFixture<dynamic> fixture, String fieldId) =>
      fixture.rootElement.querySelector('#$fieldId fieldset')!;

  List<html.InputElement> checkboxes(
    NgTestFixture<dynamic> fixture,
    String fieldId,
  ) =>
      fixture.rootElement
          .querySelectorAll('#$fieldId input[type="checkbox"]')
          .cast<html.InputElement>()
          .toList();

  test('required on a group waits for the submit and passes once one is checked',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final consents = checkboxes(fixture, 'consents-field');

    await fixture.update((_) {
      _toggle(consents.first);
    });
    await _settle(fixture);
    await fixture.update((_) {
      _toggle(consents.first);
    });
    await _settle(fixture);

    expect(fieldset(fixture, 'consents-field').classes, isNot(contains('is-invalid')),
        reason: 'liValidationMode="submitted" keeps a dirty group quiet.');

    final valid = await fixture.assertOnlyInstance.form!
        .validateAndFocusFirstInvalid();
    await _settle(fixture);

    expect(valid, isFalse);
    expect(fieldset(fixture, 'consents-field').classes, contains('is-invalid'));
    expect(fieldset(fixture, 'consents-field').attributes['data-invalid'], 'true');
    expect(fixture.rootElement.text, contains('Marque ao menos um consentimento.'));
    expect(html.document.activeElement, same(consents.first),
        reason: 'The first checkbox of the first invalid group gets the focus.');

    await fixture.update((_) {
      _toggle(consents.last);
    });
    await _settle(fixture);

    expect(fixture.assertOnlyInstance.acceptPrivacy, isTrue);
    expect(fieldset(fixture, 'consents-field').classes, isNot(contains('is-invalid')));
    expect(fieldset(fixture, 'consents-field').classes, contains('is-valid'));
  });

  test('minSelected and maxSelected bound the count of checked boxes',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final channels = checkboxes(fixture, 'channels-field');
    expect(channels, hasLength(4));

    expect(fieldset(fixture, 'channels-field').classes, isNot(contains('is-invalid')),
        reason: 'An untouched group shows nothing.');

    await fixture.update((_) => _toggle(channels[0]));
    await _settle(fixture);
    expect(fieldset(fixture, 'channels-field').classes, contains('is-invalid'));
    expect(fixture.rootElement.text, contains('Selecione pelo menos 2 opções.'));

    await fixture.update((_) => _toggle(channels[1]));
    await _settle(fixture);
    expect(fieldset(fixture, 'channels-field').classes, isNot(contains('is-invalid')));

    await fixture.update((_) {
      _toggle(channels[2]);
      _toggle(channels[3]);
    });
    await _settle(fixture);
    expect(fieldset(fixture, 'channels-field').classes, contains('is-invalid'));
    expect(fixture.rootElement.text, contains('Selecione no máximo 3 opções.'));

    await fixture.update((_) => _toggle(channels[3]));
    await _settle(fixture);
    expect(fieldset(fixture, 'channels-field').classes, isNot(contains('is-invalid')));
  });

  test('external invalid and errorText win over the automatic validation',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final external = checkboxes(fixture, 'external-field');

    // Two of three checked: the automatic rules pass.
    await fixture.update((_) => _toggle(external[2]));
    await _settle(fixture);
    await fixture.update((_) => _toggle(external[2]));
    await _settle(fixture);
    expect(fieldset(fixture, 'external-field').classes, isNot(contains('is-invalid')));

    await fixture.update((host) {
      host.externalInvalid = true;
      host.externalError = 'Recusado pelo servidor.';
    });
    await _settle(fixture);
    expect(fieldset(fixture, 'external-field').classes, contains('is-invalid'));
    expect(fixture.rootElement.text, contains('Recusado pelo servidor.'));

    // Now the automatic rule fails too: the external message still wins.
    await fixture.update((_) => _toggle(external[0]));
    await _settle(fixture);
    final feedback = fixture.rootElement
        .querySelector('#external-field .invalid-feedback')!;
    expect(feedback.text!.trim(), 'Recusado pelo servidor.');
  });

  test('a bound [value] replaces the selection read from the checkboxes',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    // The projected checkbox is checked, but the bound list is empty.
    await fixture.update((_) => _toggle(checkboxes(fixture, 'bound-field').first));
    await _settle(fixture);

    await fixture.assertOnlyInstance.form!.validateAndFocusFirstInvalid();
    await _settle(fixture);
    expect(fieldset(fixture, 'bound-field').classes, contains('is-invalid'));
    expect(fixture.rootElement.text, contains('This field is required.'),
        reason: 'locale="en_US" picks the English default message.');

    await fixture.update((host) {
      host.selectedIds = <String>['a'];
    });
    await _settle(fixture);
    expect(fieldset(fixture, 'bound-field').classes, isNot(contains('is-invalid')));
  });

  test('a group inside a child component takes part in the page form',
      () async {
    final fixture = await NgTestBed<CheckboxGroupChildHostComponent>(
      ng.CheckboxGroupChildHostComponentNgFactory,
    ).create();
    await _settle(fixture);

    final valid = await fixture.assertOnlyInstance.form!
        .validateAndFocusFirstInvalid();
    await _settle(fixture);

    expect(valid, isFalse);
    final group = fixture.rootElement.querySelector('#child-group fieldset')!;
    expect(group.classes, contains('is-invalid'));
    expect(html.document.activeElement,
        same(fixture.rootElement.querySelector('#child-group input')));
  });
}

void _toggle(html.InputElement checkbox) {
  checkbox.checked = !(checkbox.checked ?? false);
  checkbox.dispatchEvent(html.Event('change', canBubble: true));
}

Future<void> _settle(NgTestFixture<dynamic> fixture) async {
  for (var i = 0; i < 2; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await fixture.update((_) {});
  }
}
