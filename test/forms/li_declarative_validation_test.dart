// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_declarative_validation_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_declarative_validation_test.template.dart' as ng;

@Component(
  selector: 'li-declarative-validation-test-host',
  template: '''
    <form liForm #ui="liForm">
      <div id="cpf-field" liFormField="cpf" [liFormFieldOrder]="10">
        <li-input
            id="cpf-input"
            label="CPF"
            liType="cpf"
            [liMessages]="cpfMessages"
            liValidationMode="submitted"
            [(ngModel)]="cpf">
        </li-input>
      </div>

      <div id="department-field" liFormField="departmentId" [liFormFieldOrder]="20">
        <li-select
            [dataSource]="departmentOptions"
            labelKey="label"
            valueKey="id"
            [liRules]="departmentRules"
            [liMessages]="departmentMessages"
            liValidationMode="submitted"
            [(ngModel)]="departmentId">
        </li-select>
      </div>

      <div id="channels-field" liFormField="channels" [liFormFieldOrder]="30">
        <li-multi-select
            [dataSource]="channelOptions"
            labelKey="label"
            valueKey="id"
            [liRules]="channelRules"
            liValidationMode="submitted"
            [(ngModel)]="channelIds">
        </li-multi-select>
      </div>

      <div id="consent-field" liFormField="acceptedTerms" [liFormFieldOrder]="40">
        <li-checkbox
            id="consent-checkbox"
            label="Aceito os termos"
            [required]="true"
            [liMessages]="consentMessages"
            liValidationMode="submitted"
            [(ngModel)]="acceptedTerms">
        </li-checkbox>
      </div>

      <button id="validate-form" type="button" (click)="validate(ui)">Validar</button>
    </form>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    limitlessFormDirectives,
    LiInputComponent,
    LiSelectComponent,
    LiMultiSelectComponent,
    LiCheckboxComponent,
  ],
)
class DeclarativeValidationTestHostComponent {
  String cpf = '';
  String? departmentId;
  List<dynamic> channelIds = <dynamic>[];
  bool acceptedTerms = false;
  bool? lastValidationResult;

  final Map<String, String> cpfMessages = const <String, String>{
    'required': 'Informe o CPF.',
    'cpf': 'Digite um CPF valido.',
  };

  final List<LiRule> departmentRules = const <LiRule>[
    LiRule.required(),
  ];

  final Map<String, String> departmentMessages = const <String, String>{
    'required': 'Escolha um departamento.',
  };

  final List<LiRule> channelRules = <LiRule>[
    LiRule.custom(
      (dynamic value) {
        final total = value is Iterable ? value.length : 0;
        return total >= 2 ? null : 'Selecione ao menos 2 canais.';
      },
      code: 'minItems',
    ),
  ];

  final Map<String, String> consentMessages = const <String, String>{
    'requiredTrue': 'Confirme o aceite.',
  };

  final List<Map<String, dynamic>> departmentOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'eng', 'label': 'Engenharia'},
    <String, dynamic>{'id': 'design', 'label': 'Design'},
  ];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'Email'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
  ];

  Future<void> validate(LiFormDirective ui) async {
    lastValidationResult = await ui.validateAndFocusFirstInvalid();
  }
}

@Component(
  selector: 'li-default-declarative-validation-test-host',
  template: '''
    <form liForm #ui="liForm">
      <div id="default-cpf-field" liFormField="cpf" [liFormFieldOrder]="10">
        <li-input
            id="default-cpf-input"
            label="CPF"
            liType="cpf"
            [liMessages]="cpfMessages"
            [(ngModel)]="cpf">
        </li-input>
      </div>

      <div id="default-department-field" liFormField="departmentId" [liFormFieldOrder]="20">
        <li-select
            [dataSource]="departmentOptions"
            labelKey="label"
            valueKey="id"
            [liRules]="departmentRules"
            [liMessages]="departmentMessages"
            [(ngModel)]="departmentId">
        </li-select>
      </div>

      <div id="default-channels-field" liFormField="channels" [liFormFieldOrder]="30">
        <li-multi-select
            [dataSource]="channelOptions"
            labelKey="label"
            valueKey="id"
            [liRules]="channelRules"
            [(ngModel)]="channelIds">
        </li-multi-select>
      </div>

      <div id="default-consent-field" liFormField="acceptedTerms" [liFormFieldOrder]="40">
        <li-checkbox
            id="default-consent-checkbox"
            label="Aceito os termos"
            [required]="true"
            [liMessages]="consentMessages"
            [(ngModel)]="acceptedTerms">
        </li-checkbox>
      </div>

      <button id="validate-default-form" type="button" (click)="validate(ui)">Validar</button>
    </form>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    limitlessFormDirectives,
    LiInputComponent,
    LiSelectComponent,
    LiMultiSelectComponent,
    LiCheckboxComponent,
  ],
)
class DefaultDeclarativeValidationTestHostComponent {
  String cpf = '';
  String? departmentId;
  List<dynamic> channelIds = <dynamic>[];
  bool acceptedTerms = false;
  bool? lastValidationResult;

  final Map<String, String> cpfMessages = const <String, String>{
    'required': 'Informe o CPF.',
    'cpf': 'Digite um CPF valido.',
  };

  final List<LiRule> departmentRules = const <LiRule>[
    LiRule.required(),
  ];

  final Map<String, String> departmentMessages = const <String, String>{
    'required': 'Escolha um departamento.',
  };

  final List<LiRule> channelRules = <LiRule>[
    LiRule.custom(
      (dynamic value) {
        final total = value is Iterable ? value.length : 0;
        return total >= 2 ? null : 'Selecione ao menos 2 canais.';
      },
      code: 'minItems',
    ),
  ];

  final Map<String, String> consentMessages = const <String, String>{
    'requiredTrue': 'Confirme o aceite.',
  };

  final List<Map<String, dynamic>> departmentOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'eng', 'label': 'Engenharia'},
    <String, dynamic>{'id': 'design', 'label': 'Design'},
  ];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'Email'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
  ];

  Future<void> validate(LiFormDirective ui) async {
    lastValidationResult = await ui.validateAndFocusFirstInvalid();
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DeclarativeValidationTestHostComponent>(
    ng.DeclarativeValidationTestHostComponentNgFactory,
  );
  final defaultModeTestBed = NgTestBed<DefaultDeclarativeValidationTestHostComponent>(
    ng.DefaultDeclarativeValidationTestHostComponentNgFactory,
  );

  test('aplica validacao declarativa em modo submitted e foca o primeiro campo invalido', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final validateButton =
        fixture.rootElement.querySelector('#validate-form') as html.ButtonElement;

    await fixture.update((_) {
      validateButton.click();
    });
    await _settle(fixture);

    final cpfInput =
        fixture.rootElement.querySelector('input#cpf-input') as html.InputElement;
    final selectButton = fixture.rootElement
        .querySelector('#department-field .dropdown-button') as html.ButtonElement;
    final multiSelectButton = fixture.rootElement
        .querySelector('#channels-field .dropdown-button') as html.ButtonElement;
    final checkboxInput = fixture.rootElement
        .querySelector('#consent-field input[type="checkbox"]') as html.InputElement;

    expect(host.lastValidationResult, isFalse);
    expect(html.document.activeElement?.id, 'cpf-input');
    expect(cpfInput.classes.contains('is-invalid'), isTrue);
    expect(selectButton.classes.contains('is-invalid'), isTrue);
    expect(selectButton.getAttribute('aria-invalid'), 'true');
    expect(multiSelectButton.classes.contains('is-invalid'), isTrue);
    expect(checkboxInput.classes.contains('is-invalid'), isTrue);
    expect(fixture.rootElement.text, contains('Informe o CPF.'));
    expect(fixture.rootElement.text, contains('Escolha um departamento.'));
    expect(fixture.rootElement.text, contains('Selecione ao menos 2 canais.'));
    expect(fixture.rootElement.text, contains('Confirme o aceite.'));
  });

  test('limpa os erros quando os valores passam a atender as regras declarativas', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final validateButton =
        fixture.rootElement.querySelector('#validate-form') as html.ButtonElement;

    await fixture.update((_) {
      validateButton.click();
    });
    await _settle(fixture);

    final cpfInput =
        fixture.rootElement.querySelector('input#cpf-input') as html.InputElement;
    final selectButton = fixture.rootElement
        .querySelector('#department-field .dropdown-button') as html.ButtonElement;
    final multiSelectButton = fixture.rootElement
        .querySelector('#channels-field .dropdown-button') as html.ButtonElement;
    final checkboxInput = fixture.rootElement
        .querySelector('#consent-field input[type="checkbox"]') as html.InputElement;

    await fixture.update((_) {
      cpfInput.value = '52998224725';
      cpfInput.dispatchEvent(html.Event('input', canBubble: true));
      cpfInput.dispatchEvent(html.Event('blur', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      selectButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final designOption = html.document
        .querySelectorAll('.dropdown-container.dropdown-open .dropdown-item')
        .cast<html.Element>()
        .firstWhere((element) => (element.text ?? '').contains('Design'));

    await fixture.update((_) {
      designOption.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      multiSelectButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final multiOptions = html.document
        .querySelectorAll('.dropdown-container.dropdown-open .dropdown-item')
        .cast<html.Element>()
        .toList(growable: false);
    final emailOption = multiOptions.firstWhere(
      (element) => (element.text ?? '').contains('Email'),
    );
    final pushOption = multiOptions.firstWhere(
      (element) => (element.text ?? '').contains('Push'),
    );

    await fixture.update((_) {
      emailOption.dispatchEvent(html.MouseEvent('click', canBubble: true));
      pushOption.dispatchEvent(html.MouseEvent('click', canBubble: true));
      checkboxInput.checked = true;
      checkboxInput.dispatchEvent(html.Event('change', canBubble: true));
      checkboxInput.dispatchEvent(html.Event('blur', canBubble: true));
    });
    await _settle(fixture);

    await fixture.update((_) {
      validateButton.click();
    });
    await _settle(fixture);

    expect(host.lastValidationResult, isTrue);
    expect(host.cpf, '529.982.247-25');
    expect(host.departmentId, 'design');
    expect(host.channelIds, containsAll(<String>['email', 'push']));
    expect(host.acceptedTerms, isTrue);
    expect(cpfInput.classes.contains('is-invalid'), isFalse);
    expect(selectButton.classes.contains('is-invalid'), isFalse);
    expect(multiSelectButton.classes.contains('is-invalid'), isFalse);
    expect(checkboxInput.classes.contains('is-invalid'), isFalse);
    expect(fixture.rootElement.text, isNot(contains('Informe o CPF.')));
    expect(fixture.rootElement.text, isNot(contains('Escolha um departamento.')));
    expect(fixture.rootElement.text, isNot(contains('Selecione ao menos 2 canais.')));
    expect(fixture.rootElement.text, isNot(contains('Confirme o aceite.')));
  });

  test('uses submittedOrTouched by default across declarative form components', () async {
    final fixture = await defaultModeTestBed.create();
    await _settleDefault(fixture);
    final host = fixture.assertOnlyInstance;

    final validateButton = fixture.rootElement
        .querySelector('#validate-default-form') as html.ButtonElement;

    await fixture.update((_) {
      validateButton.click();
    });
    await _settleDefault(fixture);

    final cpfInput = fixture.rootElement
        .querySelector('input#default-cpf-input') as html.InputElement;
    final selectButton = fixture.rootElement
        .querySelector('#default-department-field .dropdown-button') as html.ButtonElement;
    final multiSelectButton = fixture.rootElement
        .querySelector('#default-channels-field .dropdown-button') as html.ButtonElement;
    final checkboxInput = fixture.rootElement
        .querySelector('#default-consent-field input[type="checkbox"]') as html.InputElement;

    expect(host.lastValidationResult, isFalse);
    expect(html.document.activeElement?.id, 'default-cpf-input');
    expect(cpfInput.classes.contains('is-invalid'), isTrue);
    expect(selectButton.classes.contains('is-invalid'), isTrue);
    expect(multiSelectButton.classes.contains('is-invalid'), isTrue);
    expect(checkboxInput.classes.contains('is-invalid'), isTrue);
  });
}

Future<void> _settle(
  NgTestFixture<DeclarativeValidationTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleDefault(
  NgTestFixture<DefaultDeclarativeValidationTestHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}