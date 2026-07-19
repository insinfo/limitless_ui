// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/forms/li_custom_trigger_template_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_custom_trigger_template_test.template.dart' as ng;

@Component(
  selector: 'li-custom-trigger-template-host',
  template: '''
    <div id="select-custom">
      <li-select
          [dataSource]="options"
          labelKey="label"
          valueKey="id"
          [(ngModel)]="selectedStatus">
        <template liSelectTrigger let-ctx>
          <span id="select-trigger" class="badge bg-primary">
            {{ ctx.displayValue }}
          </span>
        </template>
      </li-select>
    </div>

    <div id="multi-custom">
      <li-multi-select
          [dataSource]="options"
          labelKey="label"
          valueKey="id"
          [(ngModel)]="selectedStatuses">
        <template liMultiSelectTrigger let-ctx>
          <span id="multi-trigger" class="badge bg-info">
            {{ ctx.displayValue }}
          </span>
        </template>
      </li-multi-select>
    </div>

    <div id="datatable-custom">
      <li-datatable-select
          [settings]="settings"
          [dataTableFilter]="filter"
          [data]="data"
          [searchInFields]="searchFields"
          labelKey="name"
          valueKey="id"
          [(ngModel)]="selectedPersonId">
        <template liDatatableSelectCustomTrigger let-ctx>
          <span id="datatable-trigger" class="badge bg-success">
            {{ ctx.displayValue }}
          </span>
        </template>
      </li-datatable-select>
    </div>

    <div id="date-custom">
      <li-date-picker
          [value]="dateValue"
          (valueChange)="dateValue = \$event">
        <template liDatePickerTrigger let-ctx>
          <span id="date-trigger" class="badge bg-warning">
            {{ ctx.hasValue ? ctx.displayValue : ctx.placeholder }}
          </span>
        </template>
      </li-date-picker>
    </div>

    <div id="range-custom">
      <li-date-range-picker
          [inicio]="rangeStart"
          [fim]="rangeEnd"
          (inicioChange)="rangeStart = \$event"
          (fimChange)="rangeEnd = \$event">
        <template liDateRangePickerTrigger let-ctx>
          <span id="range-trigger" class="badge bg-primary">
            {{ ctx.hasValue ? ctx.displayValue : ctx.placeholder }}
          </span>
        </template>
      </li-date-range-picker>
    </div>

    <div id="time-custom">
      <li-time-picker
          [value]="timeValue"
          [use24Hour]="true"
          (valueChange)="timeValue = \$event">
        <template liTimePickerTrigger let-ctx>
          <span id="time-trigger" class="badge bg-teal">
            {{ ctx.hasValue ? ctx.displayValue : ctx.placeholder }}
          </span>
        </template>
      </li-time-picker>
    </div>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiSelectComponent,
    LiSelectTriggerDirective,
    LiMultiSelectComponent,
    LiMultiSelectTriggerDirective,
    LiDatatableSelectComponent,
    LiDatatableSelectCustomTriggerDirective,
    LiDatePickerComponent,
    LiDatePickerTriggerDirective,
    LiDateRangePickerComponent,
    LiDateRangePickerTriggerDirective,
    LiTimePickerComponent,
    LiTimePickerTriggerDirective,
  ],
)
class CustomTriggerTemplateHostComponent {
  String selectedStatus = 'draft';
  List<dynamic> selectedStatuses = <dynamic>['draft'];
  int selectedPersonId = 1;
  DateTime? dateValue = DateTime(2026, 6, 10);
  DateTime? rangeStart = DateTime(2026, 6, 1);
  DateTime? rangeEnd = DateTime(2026, 6, 5);
  Duration? timeValue = const Duration(hours: 9, minutes: 30);

  final List<Map<String, dynamic>> options = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
  ];

  final Filters filter = Filters(limit: 5, offset: 0);

  final DataFrame<Map<String, dynamic>> data = DataFrame<Map<String, dynamic>>(
    items: <Map<String, dynamic>>[
      <String, dynamic>{'id': 1, 'name': 'Ana Souza'},
      <String, dynamic>{'id': 2, 'name': 'Maria Silva'},
    ],
    totalRecords: 2,
  );

  final DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'name', title: 'Nome'),
    ],
  );

  final List<DatatableSearchField> searchFields = <DatatableSearchField>[
    DatatableSearchField(label: 'Nome', field: 'name', operator: 'like'),
  ];
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<CustomTriggerTemplateHostComponent>(
    ng.CustomTriggerTemplateHostComponentNgFactory,
  );

  test('select custom trigger opens and selects an option', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await _click(
        fixture, fixture.rootElement.querySelector('#select-trigger')!);
    await _settle(fixture);
    await _click(
      fixture,
      html.document.querySelector(
        '[data-label^="li_select_item_"][data-value="approved"]',
      )!,
    );
    await _settle(fixture);

    expect(host.selectedStatus, 'approved');
    expect(fixture.rootElement.querySelector('#select-trigger')!.text,
        contains('Aprovado'));
  });

  test('select custom trigger keeps the dropdown wider than a small badge',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final trigger = fixture.rootElement.querySelector('#select-trigger')!;
    await _click(fixture, trigger);
    await _settle(fixture);

    final dropdown = html.document
        .querySelector('.LiSelectComponent .dropdown-container.dropdown-open');
    expect(dropdown, isNotNull);
    expect(dropdown!.getBoundingClientRect().width,
        greaterThan(trigger.getBoundingClientRect().width));
  });

  test('multi-select custom trigger opens and toggles an option', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await _click(fixture, fixture.rootElement.querySelector('#multi-trigger')!);
    await _settle(fixture);
    await _click(
      fixture,
      html.document.querySelector(
        '[data-label^="li_ms_item_"][data-value="approved"]',
      )!,
    );
    await _settle(fixture);

    expect(host.selectedStatuses, contains('approved'));
    expect(fixture.rootElement.querySelector('#multi-trigger')!.text,
        contains('Aprovado'));
  });

  test('datatable custom trigger opens the selection modal', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    await _click(
        fixture, fixture.rootElement.querySelector('#datatable-trigger')!);
    await _settle(fixture, milliseconds: 140);

    expect(
        html.document.querySelector('.modal.show .modal-content'), isNotNull);
    expect(html.document.querySelector('.modal.show')!.text,
        contains('Maria Silva'));
  });

  test('date picker custom trigger selects a day through the panel', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await _click(fixture, fixture.rootElement.querySelector('#date-trigger')!);
    await _settle(fixture);
    await _click(
      fixture,
      html.document.querySelector(
        '[data-label="li_dp_day"][data-value="2026-06-15"]',
      )!,
    );
    await _settle(fixture);

    expect(host.dateValue, DateTime(2026, 6, 15));
    expect(fixture.rootElement.querySelector('#date-trigger')!.text,
        contains('15/06/2026'));
  });

  test('date range custom trigger applies a clicked range', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await _click(fixture, fixture.rootElement.querySelector('#range-trigger')!);
    await _settle(fixture);
    await _click(
      fixture,
      html.document.querySelector(
        '[data-label="li_drp_day"][data-calendar="left"][data-value="2026-06-03"]',
      )!,
    );
    await _click(
      fixture,
      html.document.querySelector(
        '[data-label="li_drp_day"][data-calendar="left"][data-value="2026-06-07"]',
      )!,
    );
    await _click(
      fixture,
      html.document.querySelector('[data-label="li_drp_apply"]')!,
    );
    await _settle(fixture);

    expect(host.rangeStart, DateTime(2026, 6, 3));
    expect(host.rangeEnd, DateTime(2026, 6, 7));
    expect(fixture.rootElement.querySelector('#range-trigger')!.text,
        contains('03/06/2026 - 07/06/2026'));
  });

  test('time picker custom trigger applies a clicked hour', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    await _click(fixture, fixture.rootElement.querySelector('#time-trigger')!);
    await _settle(fixture);
    await _click(
      fixture,
      html.document.querySelector(
        '[data-label="li_tp_dial_label"][data-value="10"]',
      )!,
    );
    await _click(
      fixture,
      html.document.querySelector('[data-label="li_tp_apply"]')!,
    );
    await _settle(fixture);

    expect(host.timeValue, const Duration(hours: 10, minutes: 30));
    expect(fixture.rootElement.querySelector('#time-trigger')!.text,
        contains('10:30'));
  });
}

Future<void> _click(
  NgTestFixture<CustomTriggerTemplateHostComponent> fixture,
  html.Element element,
) async {
  await fixture.update((_) {
    element.dispatchEvent(html.MouseEvent('click', canBubble: true));
  });
}

Future<void> _settle(
  NgTestFixture<CustomTriggerTemplateHostComponent> fixture, {
  int milliseconds = 40,
}) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
  await fixture.update((_) {});
}
