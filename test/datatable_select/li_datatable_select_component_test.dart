// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/datatable_select/li_datatable_select_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'package:limitless_ui/web_compat.dart' as html;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_datatable_select_component_test.template.dart' as ng;

class PersonRecord {
  const PersonRecord(this.id, this.name, this.email);

  final int id;
  final String name;
  final String email;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
    };
  }
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
      [locale]="locale"
      [mobileResponsiveCollapse]="mobileResponsiveCollapse"
      [mobileResponsiveCollapseMaxWidth]="mobileResponsiveCollapseMaxWidth"
      (userValueChange)="userSelectedPerson = \$event"
      [(ngModel)]="selectedPerson">
    </li-datatable-select>

    <li-datatable-select
      #selectWithCustomContent
      [title]="'Selecionar pessoa'"
      [placeholder]="'Abrir lista customizada'"
      (userValueChange)="userSelectedCustomPerson = \$event">
      <template liDatatableSelectModalContent let-ctx>
        <div class="p-3">
          <button id="pick-custom-person" type="button"
            (click)="ctx.selectItem('Maria Silva', 99)">
            Selecionar Maria
          </button>
        </div>
      </template>
    </li-datatable-select>

    <li-datatable-select
      #selectMultiple
      [settings]="settings"
      [dataTableFilter]="filter"
      [data]="data"
      [searchInFields]="searchFields"
      [itemLabelBuilder]="personLabel"
      [itemValueBuilder]="personValue"
      [compareWith]="compareById"
      [multiple]="true"
      (userValueChange)="userSelectedPeople = \$event"
      [(ngModel)]="selectedPeople">
    </li-datatable-select>

    <li-datatable-select
      #selectWithCustomHeader
      [settings]="settings"
      [dataTableFilter]="filter"
      [data]="data"
      [searchInFields]="searchFields"
      [modalCompactHeader]="true"
      [modalSmallHeader]="true">
      <template li-datatable-header let-ctx>
        <div class="custom-datatable-select-header">
          <span>{{ ctx.searchPlaceholder }}</span>
        </div>
      </template>
      <template li-datatable-footer let-ctx>
        <div class="custom-datatable-select-footer">
          <span>{{ ctx.currentPage }}/{{ ctx.numPages }}</span>
        </div>
      </template>
    </li-datatable-select>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    LiDatatableSelectComponent,
    LiDatatableSelectModalContentDirective,
    LiDatatableHeaderDirective,
    LiDatatableFooterDirective,
  ],
)
class DatatableSelectTestHostComponent {
  Filters filter = Filters(limit: 5, offset: 0);

  DataFrame<PersonRecord> data = DataFrame<PersonRecord>(
    items: const <PersonRecord>[
      PersonRecord(1, 'Ana Souza', 'ana@example.com'),
      PersonRecord(2, 'Maria Silva', 'maria@example.com'),
      PersonRecord(3, 'Pedro Santos', 'pedro@example.com'),
    ],
    totalRecords: 3,
  );

  DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(
        key: 'name',
        title: 'Nome',
        customRenderString: (Map<String, dynamic> _, dynamic row) =>
            (row as PersonRecord).name,
      ),
      DatatableCol(
        key: 'email',
        title: 'E-mail',
        hideOnMobile: true,
        customRenderString: (Map<String, dynamic> _, dynamic row) =>
            (row as PersonRecord).email,
      ),
    ],
  );

  List<DatatableSearchField> searchFields = <DatatableSearchField>[
    DatatableSearchField(label: 'Nome', field: 'name', operator: 'like'),
  ];

  dynamic selectedPerson = const SelectedPersonRef(2);
  dynamic userSelectedPerson;
  dynamic userSelectedCustomPerson;
  List<dynamic> selectedPeople = <dynamic>[];
  List<dynamic>? userSelectedPeople;
  String locale = 'pt_BR';
  bool mobileResponsiveCollapse = false;
  int mobileResponsiveCollapseMaxWidth = 767;

  @ViewChild('selectWithBuilders')
  LiDatatableSelectComponent? selectWithBuilders;

  @ViewChild('selectWithCustomContent')
  LiDatatableSelectComponent? selectWithCustomContent;

  @ViewChild('selectMultiple')
  LiDatatableSelectComponent? selectMultiple;

  @ViewChild('selectWithCustomHeader')
  LiDatatableSelectComponent? selectWithCustomHeader;

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

  test('syncs trigger label from typed rows using builders and compareWith',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final triggers = fixture.rootElement.queryAll('.datatable-select-trigger');
    expect(triggers.first.text, contains('Maria Silva'));
    expect(fixture.assertOnlyInstance.userSelectedPerson, isNull);
  });

  test('opens the typed modal with the configured datatable structure and rows',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final triggers = fixture.rootElement.queryAll('.datatable-select-trigger');
    final typedTrigger = triggers.first as html.ButtonElement;

    await fixture.update((_) {
      typedTrigger.click();
    });
    await _settle(fixture, milliseconds: 140);

    final modalText =
        html.document.querySelector('.modal.show .modal-content')?.text ?? '';
    final modalRows = html.document.queryAll('.modal.show tbody tr');

    expect(modalText, contains('Nome'));
    expect(modalText, contains('E-mail'));
    expect(modalText, contains('Mostrando de 0 a 3 de 3'));
    expect(modalRows, isNotEmpty);
    expect(modalText, contains('Ana Souza'));
    expect(modalText, contains('Maria Silva'));
  });

  test('supports raw no-padding modal body and mobile responsive row selection',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.mobileResponsiveCollapse = true;
      component.mobileResponsiveCollapseMaxWidth = 100000;
    });
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;

    final typedTrigger = fixture.rootElement
        .querySelector('.datatable-select-trigger') as html.ButtonElement;

    await fixture.update((_) {
      typedTrigger.click();
    });
    await _settle(fixture, milliseconds: 180);

    final modalBody =
        html.document.querySelector('.modal.show .modal-header + div');
    expect(modalBody, isNotNull);
    expect(modalBody!.classes.contains('modal-body'), isFalse);
    expect(modalBody.classes.contains('li-modal-body'), isFalse);
    expect(modalBody.classes.contains('position-relative'), isFalse);
    expect(modalBody.classes.contains('datatable-select-modal-body'), isFalse);
    expect(modalBody.getComputedStyle().paddingTop, '0px');

    expect(host.selectWithBuilders!.datatable!.responsiveCollapse, isTrue);
    expect(
      host.selectWithBuilders!.datatable!.responsiveCollapseMaxWidth,
      100000,
    );
    expect(
      host.selectWithBuilders!.datatable!.hasResponsiveCollapsedColumns,
      isTrue,
    );

    final toggleCell = html.document.querySelector(
      '.modal.show tbody tr td.dtr-control',
    ) as html.TableCellElement?;
    expect(toggleCell, isNotNull);

    await fixture.update((_) {
      toggleCell!.click();
    });
    await _settle(fixture, milliseconds: 80);

    expect(host.userSelectedPerson, isNull);
    expect(
      html.document.querySelector('.modal.show tbody tr.child'),
      isNotNull,
    );

    final firstRow = html.document.querySelector(
      '.modal.show [data-label="li_dt_row_0"]',
    ) as html.TableRowElement?;
    expect(firstRow, isNotNull);

    await fixture.update((_) {
      firstRow!.click();
    });
    await _settle(fixture, milliseconds: 120);

    final selected = host.userSelectedPerson as SelectedPersonRef?;
    expect(selected?.id, 1);
    expect(host.selectWithBuilders!.selectedLabel, 'Ana Souza');
  });

  test('passes locale to inner datatable pagination summary', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.locale = 'en';
    });
    await _settle(fixture);

    final triggers = fixture.rootElement.queryAll('.datatable-select-trigger');
    final typedTrigger = triggers.first as html.ButtonElement;

    await fixture.update((_) {
      typedTrigger.click();
    });
    await _settle(fixture, milliseconds: 140);

    final modalText =
        html.document.querySelector('.modal.show .modal-content')?.text ?? '';

    expect(modalText, contains('Showing 0 to 3 of 3 entries, 1 page(s)'));
  });

  test('allows arbitrary modal content to set label and value explicitly',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final triggers = fixture.rootElement.queryAll('.datatable-select-trigger');
    final customTrigger = triggers[1] as html.ButtonElement;

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
    expect(host.userSelectedCustomPerson, 99);
    expect(host.selectWithCustomContent!.selectedLabel, 'Maria Silva');
    expect(customTrigger.text, contains('Maria Silva'));
  });

  test(
      'supports multiple selection with datatable checkboxes and commits on modal close',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);
    final host = fixture.assertOnlyInstance;
    final triggers = fixture.rootElement.queryAll('.datatable-select-trigger');
    final multipleTrigger = triggers[2] as html.ButtonElement;

    await fixture.update((_) {
      multipleTrigger.click();
    });
    await _settle(fixture, milliseconds: 140);

    expect(host.selectMultiple!.useCheckboxSelection, isTrue);

    await fixture.update((_) {
      host.selectMultiple!.onDatatableSelectionChange(
        host.data.items.toList(growable: false),
      );
    });
    await _settle(fixture, milliseconds: 140);

    await fixture.update((_) {
      host.selectMultiple!.modal?.close();
    });
    await _settle(fixture);

    expect(host.selectedPeople, hasLength(3));
    expect(host.userSelectedPeople, hasLength(3));
    expect(
      host.selectedPeople
          .map((item) => (item as SelectedPersonRef).id)
          .toList(growable: false),
      <int>[1, 2, 3],
    );
    expect(
        host.selectMultiple!.selectedLabels,
        containsAll(<String>[
          'Ana Souza',
          'Maria Silva',
          'Pedro Santos',
        ]));
    expect(multipleTrigger.text, contains('Ana Souza'));

    final chips = multipleTrigger
        .queryAll('.datatable-select-chip')
        .toList(growable: false);
    final visibleValueChips = chips
        .where((chip) =>
            !chip.classes.contains('datatable-select-chip--hidden') &&
            !chip.classes.contains('datatable-select-chip--muted'))
        .toList(growable: false);
    final hiddenValueChips = chips
        .where(
          (chip) => chip.classes.contains('datatable-select-chip--hidden'),
        )
        .toList(growable: false);
    final summaryChips = chips
        .where((chip) => chip.classes.contains('datatable-select-chip--muted'))
        .toList(growable: false);

    expect(visibleValueChips, hasLength(2));
    expect(hiddenValueChips, hasLength(1));
    expect(summaryChips, hasLength(1));
    expect(summaryChips.single.text.trim(), '+1');
  });

  test('passes custom datatable header and compact modal header to inner modal',
      () async {
    final fixture = await testBed.create();
    await _settle(fixture);

    final triggers = fixture.rootElement.queryAll('.datatable-select-trigger');
    final customHeaderTrigger = triggers[3] as html.ButtonElement;

    await fixture.update((_) {
      customHeaderTrigger.click();
    });
    await _settle(fixture, milliseconds: 140);

    expect(
      html.document
          .querySelector('.modal.show .custom-datatable-select-header'),
      isNotNull,
    );
    expect(
      html.document.querySelector('.modal.show .datatable-search-toolbar'),
      isNull,
    );
    expect(
      html.document
          .querySelector('.modal.show .custom-datatable-select-footer'),
      isNotNull,
    );
    expect(
      html.document.querySelector('.modal.show .dataTables_info'),
      isNull,
    );
    expect(
      html.document
          .querySelector('.modal.show .modal-header.modal-header-compact'),
      isNotNull,
    );
    expect(
      html.document
          .querySelector('.modal.show .modal-header.modal-header-small'),
      isNotNull,
    );
  });
}

Future<void> _settle(
  NgTestFixture<DatatableSelectTestHostComponent> fixture, {
  int milliseconds = 30,
}) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
  await fixture.update((_) {});
}
