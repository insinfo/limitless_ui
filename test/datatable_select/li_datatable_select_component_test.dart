// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/datatable_select/li_datatable_select_component_test.dart
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

import 'li_datatable_select_component_test.template.dart' as ng;

class PersonRecord {
  const PersonRecord(this.id, this.name, this.email);

  final int id;
  final String name;
  final String email;
}

class SelectedPersonRef {
  const SelectedPersonRef(this.id);

  final int id;
}

@Component(
  selector: 'li-datatable-select-test-host',
  template: '''
    <li-datatable-select
      #selectWithBuilders
      [settings]="settings"
      [dataTableFilter]="filter"
      [data]="data"
      [searchInFields]="searchFields"
      [itemLabelBuilder]="personLabel"
      [itemValueBuilder]="personValue"
      [compareWith]="compareById"
      [(ngModel)]="selectedPerson">
    </li-datatable-select>

    <li-datatable-select
      #selectWithCustomContent
      [title]="'Selecionar pessoa'"
      [placeholder]="'Abrir lista customizada'">
      <template liDatatableSelectModalContent let-ctx>
        <div class="p-3">
          <button id="pick-custom-person" type="button"
            (click)="ctx.selectItem('Maria Silva', 99)">
            Selecionar Maria
          </button>
        </div>
      </template>
    </li-datatable-select>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiDatatableSelectComponent,
    LiDatatableSelectModalContentDirective,
  ],
)
class DatatableSelectTestHostComponent {
  Filters filter = Filters(limit: 5, offset: 0);

  DataFrame<PersonRecord> data = DataFrame<PersonRecord>(
    items: const <PersonRecord>[
      PersonRecord(1, 'Ana Souza', 'ana@example.com'),
      PersonRecord(2, 'Maria Silva', 'maria@example.com'),
    ],
    totalRecords: 2,
  );

  DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'name', title: 'Nome'),
      DatatableCol(key: 'email', title: 'E-mail'),
    ],
  );

  List<DatatableSearchField> searchFields = <DatatableSearchField>[
    DatatableSearchField(label: 'Nome', field: 'name', operator: 'like'),
  ];

  dynamic selectedPerson = const SelectedPersonRef(2);

  @ViewChild('selectWithBuilders')
  LiDatatableSelectComponent? selectWithBuilders;

  @ViewChild('selectWithCustomContent')
  LiDatatableSelectComponent? selectWithCustomContent;

  String personLabel(dynamic instance) => (instance as PersonRecord).name;

  dynamic personValue(dynamic instance) =>
      SelectedPersonRef((instance as PersonRecord).id);

  bool compareById(dynamic itemValue, dynamic selectedValue) {
    return itemValue is SelectedPersonRef &&
        selectedValue is SelectedPersonRef &&
        itemValue.id == selectedValue.id;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DatatableSelectTestHostComponent>(
    ng.DatatableSelectTestHostComponentNgFactory,
  );

  test('syncs trigger label from typed rows using builders and compareWith', () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final triggers = fixture.rootElement.querySelectorAll('.datatable-select-trigger');
    expect(triggers.first.text, contains('Maria Silva'));
  });

  test('allows arbitrary modal content to set label and value explicitly', () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final triggers = fixture.rootElement.querySelectorAll('.datatable-select-trigger');
    final customTrigger = triggers.last as html.ButtonElement;

    await fixture.update((_) {
      customTrigger.click();
    });
    await _settle(fixture);

    final customButton = html.document.querySelector('#pick-custom-person')
        as html.ButtonElement?;
    expect(customButton, isNotNull);

    await fixture.update((_) {
      customButton!.click();
    });
    await _settle(fixture);

    expect(host.selectWithCustomContent!.selectedValue, 99);
    expect(host.selectWithCustomContent!.selectedLabel, 'Maria Silva');
    expect(customTrigger.text, contains('Maria Silva'));
  });
}

Future<void> _settle(
    NgTestFixture<DatatableSelectTestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await fixture.update((_) {});
}
