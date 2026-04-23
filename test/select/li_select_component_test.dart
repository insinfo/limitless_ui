// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/select/li_select_component_test.dart
// ignore_for_file: uri_has_not_been_generated, undefined_prefixed_name

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_select_component_test.template.dart' as ng;

@Component(
  selector: 'li-select-test-host',
  template: '''
    <li-select
        [dataSource]="statusOptions"
        labelKey="label"
        valueKey="id"
        disabledKey="disabled"
        (modelChange)="selectedStatusModel = \$event"
        [(ngModel)]="selectedStatus">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectTestHostComponent {
  String selectedStatus = 'review';
  Map<String, dynamic>? selectedStatusModel;

  final List<Map<String, dynamic>> statusOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'review', 'label': 'Em revisao'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
    <String, dynamic>{'id': 'archived', 'label': 'Arquivado', 'disabled': true},
  ];
}

class SelectCompareValue {
  const SelectCompareValue(this.id, this.label);

  final int id;
  final String label;
}

@Component(
  selector: 'li-select-compare-test-host',
  template: '''
    <li-select
      [dataSource]="categoryOptions"
      labelKey="label"
      valueKey="value"
      [compareWith]="compareById"
      [(ngModel)]="selectedCategory">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectCompareTestHostComponent {
  SelectCompareValue selectedCategory = const SelectCompareValue(2, 'B');

  final List<Map<String, dynamic>> categoryOptions = <Map<String, dynamic>>[
    <String, dynamic>{
      'label': 'Categoria A',
      'value': const SelectCompareValue(1, 'A'),
    },
    <String, dynamic>{
      'label': 'Categoria B',
      'value': const SelectCompareValue(2, 'B atualizado'),
    },
  ];

  bool compareById(dynamic optionValue, dynamic modelValue) {
    return optionValue is SelectCompareValue &&
        modelValue is SelectCompareValue &&
        optionValue.id == modelValue.id;
  }
}

@Component(
  selector: 'li-select-validation-test-host',
  template: '''
    <div id="validation-select-field">
      <li-select
          [dataSource]="statusOptions"
          labelKey="label"
          valueKey="id"
          [showClearButton]="true"
          [liRules]="requiredRules"
          [liMessages]="validationMessages"
          liValidationMode="dirty"
          [(ngModel)]="selectedStatus">
      </li-select>
    </div>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectValidationTestHostComponent {
  String? selectedStatus = 'review';

  final List<LiRule> requiredRules = const <LiRule>[
    LiRule.required(),
  ];

  final Map<String, String> validationMessages = const <String, String>{
    'required': 'Escolha um status.',
  };

  final List<Map<String, dynamic>> statusOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'review', 'label': 'Em revisao'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);
  tearDown(() {
    html.document.documentElement?.attributes.remove('data-color-theme');
  });

  final testBed = NgTestBed<SelectTestHostComponent>(
    ng.SelectTestHostComponentNgFactory,
  );
  final compareTestBed = NgTestBed<SelectCompareTestHostComponent>(
    ng.SelectCompareTestHostComponentNgFactory,
  );
  final validationTestBed = NgTestBed<SelectValidationTestHostComponent>(
    ng.SelectValidationTestHostComponentNgFactory,
  );

  test('selects enabled options and updates ngModel', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final option = html.document
        .querySelectorAll('.dropdown-container .dropdown-item')
        .cast<html.Element>()
        .firstWhere((element) => (element.text ?? '').contains('Aprovado'));

    await fixture.update((_) {
      option.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedStatus, 'approved');
    expect(host.selectedStatusModel?['id'], 'approved');
    expect(host.selectedStatusModel?['label'], 'Aprovado');
    expect(trigger.text, contains('Aprovado'));
  });

  test('ignores disabled options', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final disabledOption = html.document
        .querySelectorAll('.dropdown-container .dropdown-item')
        .cast<html.Element>()
        .firstWhere((element) => (element.text ?? '').contains('Arquivado'));

    await fixture.update((_) {
      disabledOption.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedStatus, 'review');
    expect(trigger.text, contains('Em revisao'));
  });

  test('opens overlay aligned directly below the trigger', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final panel = html.document.querySelector(
      '.dropdown-container.dropdown-open',
    ) as html.Element;
    final triggerRect = trigger.getBoundingClientRect();
    final panelRect = panel.getBoundingClientRect();

    expect((panelRect.left - triggerRect.left).abs(), lessThanOrEqualTo(1.5));
    expect((panelRect.top - triggerRect.bottom).abs(), lessThanOrEqualTo(1.5));
  });

  test('keeps dark theme styling delegated to dropdown-menu classes', () async {
    html.document.documentElement?.setAttribute('data-color-theme', 'dark');

    final fixture = await testBed.create();
    await _settle(fixture);
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    final panel = html.document.querySelector(
      '.dropdown-container.dropdown-open',
    ) as html.Element;

    expect(panel.classes.contains('dropdown-menu'), isTrue);
    expect(panel.style.backgroundColor, isEmpty);
    expect(panel.style.boxShadow, isEmpty);
    expect(panel.style.borderColor, isEmpty);
  });

  test('matches object values with compareWith', () async {
    final fixture = await compareTestBed.create();
    await _settleCompare(fixture);
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    expect(trigger.text, contains('Categoria B'));
  });

  test('applies declarative validation rules and messages', () async {
    final fixture = await validationTestBed.create();
    await _settleValidation(fixture);
    final host = fixture.assertOnlyInstance;
    final field =
        fixture.rootElement.querySelector('#validation-select-field')!;
    final trigger =
        field.querySelector('.dropdown-button') as html.ButtonElement;
    final clearButton = field.querySelector('.dropdown-clear') as html.Element;

    await fixture.update((_) {
      clearButton.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settleValidation(fixture);

    expect(host.selectedStatus, isNull);
    expect(trigger.classes.contains('is-invalid'), isTrue);
    expect(fixture.rootElement.text, contains('Escolha um status.'));

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settleValidation(fixture);

    final option = html.document
        .querySelectorAll('.dropdown-container.dropdown-open .dropdown-item')
        .cast<html.Element>()
        .firstWhere((element) => (element.text ?? '').contains('Aprovado'));

    await fixture.update((_) {
      option.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settleValidation(fixture);

    expect(host.selectedStatus, 'approved');
    expect(trigger.classes.contains('is-invalid'), isFalse);
  });
}

Future<void> _settle(NgTestFixture<SelectTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleCompare(
    NgTestFixture<SelectCompareTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleValidation(
    NgTestFixture<SelectValidationTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
