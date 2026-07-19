// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_form_control_size_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_form_control_size_test.template.dart' as ng;

@Component(
  selector: 'li-form-control-size-host',
  template: '''
    <div>
      <div id="select-sm">
        <li-select
            size="sm"
            name="status"
            triggerIconMode="addon"
            [dataSource]="options"
            labelKey="label"
            valueKey="id">
        </li-select>
      </div>

      <div id="multi-lg">
        <li-multi-select
            size="lg"
            name="channels"
            [dataSource]="options"
            labelKey="label"
            valueKey="id">
        </li-multi-select>
      </div>

      <div id="datatable-sm">
        <li-datatable-select
            size="sm"
            name="person"
            triggerIconMode="addon"
            [settings]="settings"
            [dataTableFilter]="filter"
            [data]="data"
            [searchInFields]="searchFields"
            labelKey="name"
            valueKey="id">
        </li-datatable-select>
      </div>

      <div id="date-lg">
        <li-date-picker size="lg" name="start_date" [value]="dateValue"></li-date-picker>
      </div>

      <div id="date-range-sm">
        <li-date-range-picker size="sm" name="period" [inicio]="startDate" [fim]="endDate"></li-date-range-picker>
      </div>

      <div id="time-lg">
        <li-time-picker size="lg" name="hour" [value]="timeValue"></li-time-picker>
      </div>

      <div id="tree-sm">
        <li-treeview-select
            size="sm"
            name="tree_node"
            triggerIconMode="addon"
            container="inline"
            [data]="treeNodes">
        </li-treeview-select>
      </div>

      <div id="typeahead-lg">
        <li-typeahead
            size="lg"
            name="state"
            container="inline"
            [dataSource]="typeaheadOptions"
            [debounceMs]="0"
            [minLength]="1">
        </li-typeahead>
      </div>

      <div id="currency-sm">
        <li-currency-input size="sm" name="amount"></li-currency-input>
      </div>

      <div id="tag-lg">
        <li-tag-filter size="lg" name="tags" [dataSource]="tagOptions"></li-tag-filter>
      </div>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiSelectComponent,
    LiMultiSelectComponent,
    LiDatatableSelectComponent,
    LiDatePickerComponent,
    LiDateRangePickerComponent,
    LiTimePickerComponent,
    LiTreeviewSelectComponent,
    LiTypeaheadComponent,
    LiCurrencyInputComponent,
    LiTagFilterComponent,
  ],
)
class FormControlSizeHostComponent {
  final List<Map<String, dynamic>> options = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
  ];

  final Filters filter = Filters(limit: 5, offset: 0);

  final DataFrame<Map<String, dynamic>> data = DataFrame<Map<String, dynamic>>(
    items: <Map<String, dynamic>>[
      <String, dynamic>{'id': 1, 'name': 'Ana Souza'},
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

  final DateTime dateValue = DateTime(2026, 6, 29);
  final DateTime startDate = DateTime(2026, 6, 1);
  final DateTime endDate = DateTime(2026, 6, 29);
  final Duration timeValue = const Duration(hours: 9, minutes: 30);

  final List<TreeViewNode> treeNodes = <TreeViewNode>[
    TreeViewNode(
      treeViewNodeLabel: 'Atendimento',
      treeViewNodeLevel: 0,
      value: 'service',
    ),
  ];

  final List<String> typeaheadOptions = <String>[
    'Alabama',
    'Alaska',
  ];

  final List<Map<String, dynamic>> tagOptions = <Map<String, dynamic>>[
    <String, dynamic>{
      'label': 'Urgente',
      'value': 'urgent',
      'color': '#ef4444',
    },
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<FormControlSizeHostComponent>(
    ng.FormControlSizeHostComponentNgFactory,
  );

  test('applies Bootstrap form-control and form-select sizing classes',
      () async {
    final fixture = await testBed.create();
    await fixture.update((_) {});

    expect(
      _classes(fixture, '#select-sm .input-group'),
      contains('input-group-sm'),
    );
    expect(
      _classes(fixture, '#select-sm .dropdown-button'),
      contains('form-select-sm'),
    );

    expect(
      _classes(fixture, '#multi-lg .dropdown-button'),
      contains('form-select-lg'),
    );

    expect(
      _classes(fixture, '#datatable-sm .input-group'),
      contains('input-group-sm'),
    );
    expect(
      _classes(fixture, '#datatable-sm .datatable-select-trigger'),
      contains('form-select-sm'),
    );

    expect(
        _classes(fixture, '#date-lg .input-group'), contains('input-group-lg'));
    expect(
      _classes(fixture, '#date-lg input.form-control'),
      contains('form-control-lg'),
    );

    expect(
      _classes(fixture, '#date-range-sm .input-group'),
      contains('input-group-sm'),
    );
    expect(
      _classes(fixture, '#date-range-sm input.form-control'),
      contains('form-control-sm'),
    );

    expect(
        _classes(fixture, '#time-lg .input-group'), contains('input-group-lg'));
    expect(
      _classes(fixture, '#time-lg input.form-control'),
      contains('form-control-lg'),
    );

    expect(
        _classes(fixture, '#tree-sm .input-group'), contains('input-group-sm'));
    expect(
      _classes(fixture, '#tree-sm .treeview-dropdown-select__trigger'),
      contains('form-select-sm'),
    );

    expect(
      _classes(fixture, '#typeahead-lg input.form-control'),
      contains('form-control-lg'),
    );
    expect(
      _classes(fixture, '#currency-sm input.form-control'),
      contains('form-control-sm'),
    );
    expect(
      _classes(fixture, '#tag-lg .li-tag-filter__button'),
      contains('form-select-lg'),
    );
  });

  test('reflects name on interactive form control elements', () async {
    final fixture = await testBed.create();
    await fixture.update((_) {});

    expect(_attr(fixture, '#select-sm .dropdown-button', 'name'), 'status');
    expect(_attr(fixture, '#multi-lg .dropdown-button', 'name'), 'channels');
    expect(
      _attr(fixture, '#datatable-sm .datatable-select-trigger', 'name'),
      'person',
    );
    expect(_attr(fixture, '#date-lg input.form-control', 'name'), 'start_date');
    expect(
      _attr(fixture, '#date-range-sm input.form-control', 'name'),
      'period',
    );
    expect(_attr(fixture, '#time-lg input.form-control', 'name'), 'hour');
    expect(
      _attr(fixture, '#tree-sm .treeview-dropdown-select__trigger', 'name'),
      'tree_node',
    );
    expect(_attr(fixture, '#typeahead-lg input.form-control', 'name'), 'state');
    expect(_attr(fixture, '#currency-sm input.form-control', 'name'), 'amount');
    expect(_attr(fixture, '#tag-lg .li-tag-filter__button', 'name'), 'tags');
  });
}

Set<String> _classes(
  NgTestFixture<FormControlSizeHostComponent> fixture,
  String selector,
) {
  final element = fixture.rootElement.querySelector(selector);
  expect(element, isNotNull, reason: 'Missing element: $selector');
  return element!.classes.toSet();
}

String? _attr(
  NgTestFixture<FormControlSizeHostComponent> fixture,
  String selector,
  String name,
) {
  final element = fixture.rootElement.querySelector(selector);
  expect(element, isNotNull, reason: 'Missing element: $selector');
  return element!.getAttribute(name);
}
