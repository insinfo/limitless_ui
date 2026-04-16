// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_advanced_field_validation_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_advanced_field_validation_test.template.dart' as ng;

@Component(
  selector: 'li-advanced-field-validation-host',
  template: '''
    <div liForm #formApi="liForm">
      <div id="currency-field">
        <li-currency-input
            [liRules]="currencyRules"
            [liMessages]="currencyMessages"
            liValidationMode="submittedOrTouchedOrDirty"
            [(ngModel)]="amount">
        </li-currency-input>
      </div>

      <div id="reviewer-field">
        <li-datatable-select
            [settings]="settings"
            [dataTableFilter]="filter"
            [data]="data"
            [searchInFields]="searchFields"
            [labelKey]="'name'"
            [valueKey]="'id'"
            [title]="'Responsável'"
            [liRules]="requiredRule"
            [liMessages]="reviewerMessages"
            liValidationMode="submittedOrTouchedOrDirty"
            [(ngModel)]="reviewerId">
        </li-datatable-select>
      </div>

      <div id="primary-reviewer-field">
        <li-datatable-select
            [settings]="settings"
            [dataTableFilter]="filter"
            [data]="data"
            [searchInFields]="searchFields"
            [labelKey]="'name'"
            [valueKey]="'id'"
            [title]="'Responsável principal'"
            [liRules]="primaryReviewerRules"
            liValidationMode="submittedOrTouchedOrDirty"
            [(ngModel)]="primaryReviewerId">
        </li-datatable-select>
      </div>

      <div id="workflow-field">
        <li-treeview-select
            [data]="workflowNodes"
            [liRules]="requiredRule"
            [liMessages]="workflowMessages"
            liValidationMode="submittedOrTouchedOrDirty"
            [(ngModel)]="workflowNode">
        </li-treeview-select>
      </div>

      <div id="workflow-stages-field">
        <li-treeview-select
            [data]="workflowNodes"
            [multiple]="true"
            [liRules]="workflowStagesRules"
            liValidationMode="submittedOrTouchedOrDirty"
            [(ngModel)]="workflowNodeIds">
        </li-treeview-select>
      </div>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiFormDirective,
    LiCurrencyInputComponent,
    LiDatatableSelectComponent,
    LiTreeviewSelectComponent,
  ],
)
class AdvancedFieldValidationHostComponent {
  @ViewChild('formApi')
  LiFormDirective? formApi;

  int? amount;
  dynamic reviewerId;
  dynamic primaryReviewerId;
  dynamic workflowNode;
  List<dynamic> workflowNodeIds = <dynamic>[];

  final List<LiRule> currencyRules = <LiRule>[LiRule.required()];
  final List<LiRule> requiredRule = <LiRule>[LiRule.required()];
  final List<LiRule> primaryReviewerRules = <LiRule>[
    LiRule.custom(
      (value) {
        final normalized = value == null ? '' : '$value'.trim();
        if (normalized.isNotEmpty) {
          return null;
        }
        return 'Selecione um responsável principal.';
      },
      code: 'primaryReviewer',
    ),
  ];
  final List<LiRule> workflowStagesRules = <LiRule>[
    LiRule.custom(
      (value) {
        final selections = value is Iterable ? value.length : 0;
        if (selections > 0) {
          return null;
        }
        return 'Selecione ao menos uma etapa paralela.';
      },
      code: 'workflowStages',
    ),
  ];

  final Map<String, String> currencyMessages = const <String, String>{
    'required': 'Informe a pretensão salarial.',
  };

  final Map<String, String> reviewerMessages = const <String, String>{
    'required': 'Selecione um responsável.',
  };

  final Map<String, String> workflowMessages = const <String, String>{
    'required': 'Selecione uma etapa do workflow.',
  };

  final Filters filter = Filters(limit: 5, offset: 0);

  final DataFrame<Map<String, dynamic>> data = DataFrame<Map<String, dynamic>>(
    items: <Map<String, dynamic>>[
      <String, dynamic>{'id': '1', 'name': 'Maria Silva'},
    ],
    totalRecords: 1,
  );

  final DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'name', title: 'Nome'),
    ],
  );

  final List<DatatableSearchField> searchFields = <DatatableSearchField>[
    DatatableSearchField(label: 'Nome', field: 'name', operator: 'like'),
  ];

  final List<TreeViewNode> workflowNodes = <TreeViewNode>[
    TreeViewNode(
      treeViewNodeLabel: 'Triagem inicial',
      treeViewNodeLevel: 0,
      value: 'triagem',
    ),
    TreeViewNode(
      treeViewNodeLabel: 'Ajustes pendentes',
      treeViewNodeLevel: 0,
      value: 'ajustes',
    ),
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<AdvancedFieldValidationHostComponent>(
    ng.AdvancedFieldValidationHostComponentNgFactory,
  );

  test('liForm submission marks currency, datatable and treeview fields invalid',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final isValid = await host.formApi!.validateAndFocusFirstInvalid();
    await _settle(fixture);

    final currencyInput =
        fixture.rootElement.querySelector('#currency-field li-currency-input input')
            as html.InputElement;
    final datatableTrigger =
        fixture.rootElement.querySelector('#reviewer-field .datatable-select-trigger')
            as html.ButtonElement;
    final primaryReviewerTrigger = fixture.rootElement
            .querySelector('#primary-reviewer-field .datatable-select-trigger')
        as html.ButtonElement;
    final treeviewTrigger =
        fixture.rootElement.querySelector('#workflow-field .treeview-dropdown-select__trigger')
            as html.ButtonElement;
    final workflowStagesTrigger = fixture.rootElement
            .querySelector('#workflow-stages-field .treeview-dropdown-select__trigger')
            as html.ButtonElement;

    expect(isValid, isFalse);
    expect(currencyInput.classes.contains('is-invalid'), isTrue);
    expect(datatableTrigger.classes.contains('is-invalid'), isTrue);
    expect(primaryReviewerTrigger.classes.contains('is-invalid'), isTrue);
    expect(treeviewTrigger.classes.contains('is-invalid'), isTrue);
    expect(workflowStagesTrigger.classes.contains('is-invalid'), isTrue);
    expect(fixture.rootElement.text, contains('Informe a pretensão salarial.'));
    expect(fixture.rootElement.text, contains('Selecione um responsável.'));
    expect(
      fixture.rootElement.text,
      contains('Selecione um responsável principal.'),
    );
    expect(
      fixture.rootElement.text,
      contains('Selecione uma etapa do workflow.'),
    );
    expect(
      fixture.rootElement.text,
      contains('Selecione ao menos uma etapa paralela.'),
    );
    expect(html.document.activeElement, same(currencyInput));
  });

  test('clears validation once the three components receive valid values',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await host.formApi!.validateAndFocusFirstInvalid();
    await _settle(fixture);

    await fixture.update((component) {
      component.amount = 125000;
      component.reviewerId = '1';
      component.primaryReviewerId = '1';
      component.workflowNode = 'triagem';
      component.workflowNodeIds = <dynamic>['ajustes'];
    });
    await _settle(fixture);

    final currencyInput =
        fixture.rootElement.querySelector('#currency-field li-currency-input input')
            as html.InputElement;
    final datatableTrigger =
        fixture.rootElement.querySelector('#reviewer-field .datatable-select-trigger')
            as html.ButtonElement;
    final primaryReviewerTrigger = fixture.rootElement
            .querySelector('#primary-reviewer-field .datatable-select-trigger')
        as html.ButtonElement;
    final treeviewTrigger =
        fixture.rootElement.querySelector('#workflow-field .treeview-dropdown-select__trigger')
            as html.ButtonElement;
    final workflowStagesTrigger = fixture.rootElement
            .querySelector('#workflow-stages-field .treeview-dropdown-select__trigger')
            as html.ButtonElement;

    expect(currencyInput.classes.contains('is-invalid'), isFalse);
    expect(datatableTrigger.classes.contains('is-invalid'), isFalse);
    expect(primaryReviewerTrigger.classes.contains('is-invalid'), isFalse);
    expect(treeviewTrigger.classes.contains('is-invalid'), isFalse);
    expect(workflowStagesTrigger.classes.contains('is-invalid'), isFalse);
    expect(currencyInput.classes.contains('is-valid'), isTrue);
    expect(datatableTrigger.classes.contains('is-valid'), isTrue);
    expect(primaryReviewerTrigger.classes.contains('is-valid'), isTrue);
    expect(treeviewTrigger.classes.contains('is-valid'), isTrue);
    expect(workflowStagesTrigger.classes.contains('is-valid'), isTrue);
  });
}

Future<void> _settle(
  NgTestFixture<AdvancedFieldValidationHostComponent> fixture,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}