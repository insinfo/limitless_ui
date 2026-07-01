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
        [searchable]="searchable"
        (modelChange)="selectedStatusModel = \$event"
        (userValueChange)="userSelectedStatus = \$event"
        [(ngModel)]="selectedStatus">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectTestHostComponent {
  String selectedStatus = 'review';
  String? userSelectedStatus;
  Map<String, dynamic>? selectedStatusModel;
  bool searchable = true;

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

@Component(
  selector: 'li-select-async-source-test-host',
  template: '''
    <li-select
        [dataSource]="statusOptions"
        labelKey="label"
        valueKey="id"
        (currentValueChange)="currentValueEvents.add(\$event)"
        (modelChange)="modelEvents.add(\$event)"
        [(ngModel)]="selectedStatus">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectAsyncSourceTestHostComponent {
  String selectedStatus = 'approved';
  List<Map<String, dynamic>> statusOptions = <Map<String, dynamic>>[];
  final List<dynamic> currentValueEvents = <dynamic>[];
  final List<dynamic> modelEvents = <dynamic>[];

  void loadOptions() {
    statusOptions = <Map<String, dynamic>>[
      <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
      <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
    ];
  }
}

@Component(
  selector: 'li-select-null-model-test-host',
  template: '''
    <li-select
        [dataSource]="statusOptions"
        labelKey="label"
        valueKey="id"
        [(ngModel)]="selectedStatus">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectNullModelTestHostComponent {
  String? selectedStatus;

  final List<Map<String, dynamic>> statusOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
  ];
}

@Component(
  selector: 'li-select-empty-placeholder-test-host',
  template: '''
    <li-select
        [dataSource]="statusOptions"
        labelKey="label"
        valueKey="id"
        [placeholder]="emptyPlaceholder"
        [(ngModel)]="selectedStatus">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectEmptyPlaceholderTestHostComponent {
  String emptyPlaceholder = '';
  String? selectedStatus;

  final List<Map<String, dynamic>> statusOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
  ];
}

@Component(
  selector: 'li-select-auto-first-test-host',
  template: '''
    <li-select
        [dataSource]="statusOptions"
        labelKey="label"
        valueKey="id"
        [autoSelectFirstOption]="true"
        [(ngModel)]="selectedStatus">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectAutoFirstTestHostComponent {
  String? selectedStatus;

  final List<Map<String, dynamic>> statusOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
  ];
}

@Component(
  selector: 'li-select-programmatic-api-test-host',
  template: '''
    <li-select
        #select
        [dataSource]="statusOptions"
        labelKey="label"
        valueKey="id"
        (currentValueChange)="currentValueEvents.add(\$event)"
        (modelChange)="modelEvents.add(\$event)"
        (userValueChange)="userValueEvents.add(\$event)"
        [(ngModel)]="selectedStatus">
    </li-select>
  ''',
  directives: [coreDirectives, formDirectives, LiSelectComponent],
)
class SelectProgrammaticApiTestHostComponent {
  @ViewChild('select')
  LiSelectComponent? select;

  String? selectedStatus = 'review';
  final List<dynamic> currentValueEvents = <dynamic>[];
  final List<dynamic> modelEvents = <dynamic>[];
  final List<dynamic> userValueEvents = <dynamic>[];

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
  final asyncSourceTestBed = NgTestBed<SelectAsyncSourceTestHostComponent>(
    ng.SelectAsyncSourceTestHostComponentNgFactory,
  );
  final nullModelTestBed = NgTestBed<SelectNullModelTestHostComponent>(
    ng.SelectNullModelTestHostComponentNgFactory,
  );
  final emptyPlaceholderTestBed =
      NgTestBed<SelectEmptyPlaceholderTestHostComponent>(
    ng.SelectEmptyPlaceholderTestHostComponentNgFactory,
  );
  final autoFirstTestBed = NgTestBed<SelectAutoFirstTestHostComponent>(
    ng.SelectAutoFirstTestHostComponentNgFactory,
  );
  final programmaticApiTestBed =
      NgTestBed<SelectProgrammaticApiTestHostComponent>(
    ng.SelectProgrammaticApiTestHostComponentNgFactory,
  );

  test('selects enabled options and updates ngModel', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    expect(host.userSelectedStatus, isNull);

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
    expect(host.userSelectedStatus, 'approved');
    expect(host.selectedStatusModel?['id'], 'approved');
    expect(host.selectedStatusModel?['label'], 'Aprovado');
    expect(trigger.text, contains('Aprovado'));

    await fixture.update((component) {
      component.selectedStatus = 'draft';
    });
    await _settle(fixture);

    expect(host.selectedStatus, 'draft');
    expect(host.userSelectedStatus, 'approved');
    expect(trigger.text, contains('Rascunho'));
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

  test('hides the search field when searchable is false and still selects',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    await fixture.update((component) {
      component.searchable = false;
    });
    await _settle(fixture);

    await fixture.update((_) {
      trigger.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(
      html.document.querySelector(
        '.dropdown-container.dropdown-open .dropdown-search',
      ),
      isNull,
    );

    final option = html.document
        .querySelectorAll('.dropdown-container.dropdown-open .dropdown-item')
        .cast<html.Element>()
        .firstWhere((element) => (element.text ?? '').contains('Aprovado'));

    await fixture.update((_) {
      option.dispatchEvent(html.MouseEvent('click', canBubble: true));
    });
    await _settle(fixture);

    expect(host.selectedStatus, 'approved');
    expect(trigger.text, contains('Aprovado'));
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

  test('reconciles a written model value when dataSource arrives later',
      () async {
    final fixture = await asyncSourceTestBed.create();
    await _settleAsyncSource(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    expect(host.selectedStatus, 'approved');
    expect(trigger.text, contains('Selecione'));

    await fixture.update((component) {
      component.loadOptions();
    });
    await _settleAsyncSource(fixture);

    expect(host.selectedStatus, 'approved');
    expect(trigger.text, contains('Aprovado'));
    expect(host.currentValueEvents, isEmpty);
    expect(host.modelEvents, isEmpty);
  });

  test('keeps null model empty instead of selecting the first option',
      () async {
    final fixture = await nullModelTestBed.create();
    await _settleNullModel(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    expect(host.selectedStatus, isNull);
    expect(trigger.text, contains('Selecione'));
    expect(trigger.text, isNot(contains('Rascunho')));
  });

  test('allows a blank placeholder for null model values', () async {
    final fixture = await emptyPlaceholderTestBed.create();
    await _settleEmptyPlaceholder(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    expect(host.selectedStatus, isNull);
    expect(trigger.text?.trim(), isEmpty);
    expect(trigger.text, isNot(contains('Rascunho')));
  });

  test('autoSelectFirstOption keeps the old first-option behavior', () async {
    final fixture = await autoFirstTestBed.create();
    await _settleAutoFirst(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    expect(host.selectedStatus, isNull);
    expect(trigger.text, contains('Rascunho'));
  });

  test('supports silent programmatic set and clear APIs', () async {
    final fixture = await programmaticApiTestBed.create();
    await _settleProgrammaticApi(fixture);
    final host = fixture.assertOnlyInstance;
    final trigger = fixture.rootElement.querySelector('.dropdown-button')
        as html.ButtonElement;

    await fixture.update((component) {
      component.select!.setSelectedItemByValue(
        'approved',
        isCallNgModelChange: false,
        isCallCurrentValueChange: false,
      );
    });
    await _settleProgrammaticApi(fixture);

    expect(host.selectedStatus, 'review');
    expect(trigger.text, contains('Aprovado'));
    expect(host.currentValueEvents, isEmpty);
    expect(host.modelEvents, isEmpty);
    expect(host.userValueEvents, isEmpty);

    await fixture.update((component) {
      component.select!.clearSelectedItem(
        isCallNgModelChange: false,
        isCallCurrentValueChange: false,
      );
    });
    await _settleProgrammaticApi(fixture);

    expect(host.selectedStatus, 'review');
    expect(trigger.text, contains('Selecione'));
    expect(host.currentValueEvents, isEmpty);
    expect(host.modelEvents, isEmpty);
    expect(host.userValueEvents, isEmpty);

    await fixture.update((component) {
      component.select!.setSelectedItemByValue('draft');
    });
    await _settleProgrammaticApi(fixture);

    expect(host.selectedStatus, 'draft');
    expect(trigger.text, contains('Rascunho'));
    expect(host.currentValueEvents, <dynamic>['draft']);
    expect(
      host.modelEvents
          .map((dynamic item) => (item as Map<String, dynamic>)['id'])
          .toList(),
      <dynamic>['draft'],
    );
    expect(host.userValueEvents, isEmpty);

    await fixture.update((component) {
      component.select!.clearSelectedItem();
    });
    await _settleProgrammaticApi(fixture);

    expect(host.selectedStatus, isNull);
    expect(trigger.text, contains('Selecione'));
    expect(host.currentValueEvents, <dynamic>['draft', null]);
    expect(host.modelEvents.last, isNull);
    expect(host.userValueEvents, isEmpty);
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

Future<void> _settleAsyncSource(
    NgTestFixture<SelectAsyncSourceTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleNullModel(
    NgTestFixture<SelectNullModelTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleEmptyPlaceholder(
    NgTestFixture<SelectEmptyPlaceholderTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleAutoFirst(
    NgTestFixture<SelectAutoFirstTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}

Future<void> _settleProgrammaticApi(
    NgTestFixture<SelectProgrammaticApiTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
