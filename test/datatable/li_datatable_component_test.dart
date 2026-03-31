// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/datatable/li_datatable_component_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html';

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_datatable_component_test.template.dart' as ng;

@Component(
  selector: 'test-host',
  template: '''
    <li-datatable
      [dataTableFilter]="filter"
      [data]="data"
      [settings]="settings"
      [responsiveCollapse]="responsiveCollapse"
      [searchInFields]="searchInFields"
      [allowSingleSelectionOnly]="allowSingleSelectionOnly"
      (dataRequest)="onDataRequest(\$event)"
      (limitChange)="onLimitChange(\$event)"
      (searchRequest)="onSearchRequest(\$event)"
      (selectAll)="onSelectedRows(\$event)">
    </li-datatable>
  ''',
  directives: [coreDirectives, LiDataTableComponent],
)
class TestHostComponent {
  Filters filter = Filters(limit: 10, offset: 0);

  DataFrame<Map<String, dynamic>> data = DataFrame<Map<String, dynamic>>(
    items: <Map<String, dynamic>>[
      <String, dynamic>{'nome': 'Ana', 'idade': 30},
      <String, dynamic>{'nome': 'Bruno', 'idade': 40},
    ],
    totalRecords: 25,
  );

  DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(
        key: 'nome',
        title: 'Nome',
        sortingBy: 'nome',
        enableSorting: true,
        defaultSortDirection: 'asc',
      ),
      DatatableCol(
        key: 'idade',
        title: 'Idade',
        sortingBy: 'idade',
        enableSorting: true,
        hideOnMobile: true,
      ),
    ],
  );

  List<DatatableSearchField> searchInFields = <DatatableSearchField>[
    DatatableSearchField(
      label: 'Nome',
      field: 'nome',
      operator: 'like',
    ),
    DatatableSearchField(
      label: 'Idade',
      field: 'idade',
      operator: '=',
    ),
  ];

  bool allowSingleSelectionOnly = false;
  bool responsiveCollapse = false;
  Filters? lastDataRequest;
  Filters? lastLimitChange;
  Filters? lastSearchRequest;
  List<dynamic>? lastSelectedRows;

  @ViewChild(LiDataTableComponent)
  LiDataTableComponent? table;

  void onDataRequest(Filters filters) {
    lastDataRequest = Filters()..fillFromFilters(filters);
  }

  void onLimitChange(Filters filters) {
    lastLimitChange = Filters()..fillFromFilters(filters);
  }

  void onSearchRequest(Filters filters) {
    lastSearchRequest = Filters()..fillFromFilters(filters);
  }

  void onSelectedRows(List<dynamic> rows) {
    lastSelectedRows = List<dynamic>.from(rows);
  }
}

class _FakeKeyPressEvent {
  _FakeKeyPressEvent(this.keyCode);

  final int keyCode;
  bool stopPropagationCalled = false;

  void stopPropagation() {
    stopPropagationCalled = true;
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<TestHostComponent>(
    ng.TestHostComponentNgFactory,
  );

  test('renderiza cabecalhos e linhas iniciais', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);

    expect(fixture.text, contains('Nome'));
    expect(fixture.text, contains('Idade'));
    expect(fixture.text, contains('Ana'));
    expect(fixture.text, contains('Bruno'));
  });

  test('seleciona automaticamente o primeiro campo de busca', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.table, isNotNull);
    expect(host.table!.searchInFields.first.selected, isTrue);
    expect(host.table!.dataTableFilter.searchInFields, isNotEmpty);
    expect(host.table!.dataTableFilter.searchInFields.first.field, 'nome');
    expect(host.table!.dataTableFilter.searchInFields.first.operator, 'like');
  });

  test('emite dataRequest ao ir para a proxima pagina', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.nextPage();
    });

    expect(host.lastDataRequest, isNotNull);
    expect(host.lastDataRequest!.offset, 10);
    expect(host.lastDataRequest!.limit, 10);
  });

  test('configura ordenacao e emite dataRequest', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.onOrder(component.settings.colsDefinitions.first);
    });

    expect(host.lastDataRequest, isNotNull);
    expect(host.lastDataRequest!.orderBy, 'nome');
    expect(host.lastDataRequest!.orderDir, 'asc');
  });

  test('mantem apenas uma linha selecionada em modo single selection', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.allowSingleSelectionOnly = true;
    });
    await _settleTable(fixture);

    await fixture.update((component) {
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[0]);
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[1]);
    });

    expect(host.table!.rows[0].selected, isFalse);
    expect(host.table!.rows[1].selected, isTrue);
    expect(host.table!.getAllSelected<Map<String, dynamic>>(), hasLength(1));
    expect(
      host.table!.getAllSelected<Map<String, dynamic>>().single['nome'],
      'Bruno',
    );
  });

  test('dispara busca ao pressionar Enter no campo de pesquisa', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.nextPage();
    });

    await fixture.update((component) {
      component.table!.dataTableFilter.searchString = 'Ana';
      component.table!.handleSearchInputKeypress(_FakeKeyPressEvent(KeyCode.ENTER));
    });

    expect(host.lastSearchRequest, isNotNull);
    expect(host.lastSearchRequest!.searchString, 'Ana');
    expect(host.lastDataRequest, isNotNull);
    expect(host.lastDataRequest!.offset, 0);
    expect(host.table!.getCurrentPage, 1);
  });

  test('permite selecionar varias linhas quando single selection esta desabilitado', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[0]);
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[1]);
    });

    expect(host.table!.rows[0].selected, isTrue);
    expect(host.table!.rows[1].selected, isTrue);
    expect(host.table!.getAllSelected<Map<String, dynamic>>(), hasLength(2));
    expect(host.lastSelectedRows, isNotNull);
    expect(host.lastSelectedRows, hasLength(2));
  });

  test('seleção individual atualiza a lista agregada de selecionados', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[0]);
    });

    expect(host.lastSelectedRows, isNotNull);
    expect(host.lastSelectedRows, hasLength(1));
    expect((host.lastSelectedRows!.single as Map<String, dynamic>)['nome'], 'Ana');

    await fixture.update((component) {
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[0]);
    });

    expect(host.lastSelectedRows, isNotNull);
    expect(host.lastSelectedRows, isEmpty);
  });

  test('toggle de visibilidade propaga para definicoes e linhas renderizadas', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;
    final nomeCol = host.settings.colsDefinitions.first;

    expect(nomeCol.visibility, isTrue);
    expect(host.table!.rows.first.columns.first.visibility, isTrue);

    await fixture.update((component) {
      component.table!.changeVisibilityOfCol(nomeCol);
    });

    expect(nomeCol.visibility, isFalse);
    expect(nomeCol.visibilityOnCard, isFalse);
    expect(host.table!.rows.first.columns.first.visibility, isFalse);
    expect(host.table!.rows.first.columns.first.visibilityOnCard, isFalse);
  });

  test('expande linha filha para colunas ocultas no mobile', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.responsiveCollapse = true;
      component.table!.responsiveCollapseMaxWidth = 100000;
    });
    await _settleTable(fixture);

    final toggleCell = fixture.rootElement.querySelector(
      'tbody tr td.dtr-control',
    ) as TableCellElement?;

    expect(host.table!.hasResponsiveHiddenColumns(host.table!.rows.first), isTrue);
    expect(host.table!.rows.first.isExpanded, isFalse);
    expect(toggleCell, isNotNull);

    await fixture.update((_) {
      toggleCell!.click();
    });

    expect(host.table!.rows.first.isExpanded, isTrue);
    expect(fixture.text, contains('Idade'));
    expect(fixture.text, contains('30'));
    expect(fixture.rootElement.querySelector('tbody tr.child'), isNotNull);
  });

  test('não expande linha quando não há colunas configuradas para mobile', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'nome',
            title: 'Nome',
            sortingBy: 'nome',
            enableSorting: true,
          ),
          DatatableCol(
            key: 'idade',
            title: 'Idade',
            sortingBy: 'idade',
            enableSorting: true,
            hideOnMobile: false,
          ),
        ],
      );
    });
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.responsiveCollapse = true;
      component.table!.responsiveCollapseMaxWidth = 100000;
    });
    await _settleTable(fixture);

    final toggleCell = fixture.rootElement.querySelector('tbody tr td.dtr-control');

    expect(host.table!.hasResponsiveHiddenColumns(host.table!.rows.first), isFalse);
    expect(toggleCell, isNull);

    await fixture.update((component) {
      component.table!.onResponsiveControlClick(
        MouseEvent('click'),
        component.table!.rows.first,
      );
    });

    expect(host.table!.rows.first.isExpanded, isFalse);
    expect(fixture.rootElement.querySelector('tbody tr.child'), isNull);
  });

  test('onSelectAll marca e desmarca todas as linhas pelo checkbox do header', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;
    final selectAllCheckbox = fixture.rootElement.querySelector(
      'thead .datatable-first-col input.form-check-input',
    ) as CheckboxInputElement?;

    expect(selectAllCheckbox, isNotNull);

    await fixture.update((_) {
      selectAllCheckbox!.click();
    });

    expect(host.table!.isSelectAll, isTrue);
    expect(host.table!.rows.every((row) => row.selected), isTrue);
    expect(host.table!.getAllSelected<Map<String, dynamic>>(), hasLength(2));

    await fixture.update((_) {
      selectAllCheckbox!.click();
    });

    expect(host.table!.isSelectAll, isFalse);
    expect(host.table!.rows.every((row) => !row.selected), isTrue);
  });

  test('unSelectAll limpa selecao existente', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[0]);
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[1]);
      component.table!.unSelectAll();
    });

    expect(host.table!.rows.every((row) => !row.selected), isTrue);
    expect(host.table!.getAllSelected<Map<String, dynamic>>(), isEmpty);
  });

  test('handleSearchFieldSelectChange atualiza o campo pesquisado', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.handleSearchFieldSelectChange(null, '1');
    });

    expect(host.table!.dataTableFilter.searchInFields, hasLength(1));
    expect(host.table!.dataTableFilter.searchInFields.first.field, 'idade');
    expect(host.table!.dataTableFilter.searchInFields.first.operator, '=');
    expect(host.table!.dataTableFilter.searchInFields.first.label, 'Idade');
  });

  test('ordenação multi-coluna acumula criterios distintos', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.enableMultiColumnSorting = true;
      component.table!.onOrder(component.settings.colsDefinitions.first);
      component.table!.onOrder(component.settings.colsDefinitions[1]);
    });

    expect(host.lastDataRequest, isNotNull);
    expect(host.table!.dataTableFilter.orderFields, hasLength(2));
    expect(host.table!.dataTableFilter.orderFields[0].field, 'nome');
    expect(host.table!.dataTableFilter.orderFields[0].direction, 'asc');
    expect(host.table!.dataTableFilter.orderFields[1].field, 'idade');
    expect(host.table!.dataTableFilter.orderFields[1].direction, 'asc');
  });

  test('changeItemsPerPageHandler atualiza limit e emite limitChange', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;
    final select = SelectElement()
      ..append(OptionElement(data: '20', value: '20')..selected = true);

    await fixture.update((component) {
      component.table!.nextPage();
      component.table!.changeItemsPerPageHandler(select);
    });

    expect(host.table!.getCurrentPage, 1);
    expect(host.table!.dataTableFilter.limit, 20);
    expect(host.lastLimitChange, isNotNull);
    expect(host.lastLimitChange!.limit, 20);
  });

  test('prevPage, primeira e ultima pagina atualizam offset corretamente', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.irParaUltimaPagina();
    });

    expect(host.table!.getCurrentPage, 3);
    expect(host.lastDataRequest, isNotNull);
    expect(host.lastDataRequest!.offset, 20);

    await fixture.update((component) {
      component.table!.prevPage();
    });

    expect(host.table!.getCurrentPage, 2);
    expect(host.lastDataRequest!.offset, 10);

    await fixture.update((component) {
      component.table!.irParaPrimeiraPagina();
    });

    expect(host.table!.getCurrentPage, 1);
    expect(host.lastDataRequest!.offset, 0);
  });

  test('changeViewMode alterna gridMode', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.table!.gridMode, isFalse);

    await fixture.update((component) {
      component.table!.changeViewMode();
    });

    expect(host.table!.gridMode, isTrue);

    await fixture.update((component) {
      component.table!.changeViewMode();
    });

    expect(host.table!.gridMode, isFalse);
  });

  test('renderiza layout de grid quando gridMode esta ativo', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.changeViewMode();
    });
    await _settleTable(fixture);

    final gridContainer = fixture.rootElement.querySelector('.grid-container');
    final gridItems = fixture.rootElement.querySelectorAll('.grid-layout .grid-item');
    final tableContainer = fixture.rootElement.querySelector('.datatable-scroll');

    expect(host.table!.gridMode, isTrue);
    expect(gridContainer, isNotNull);
    expect(gridItems.length, 2);
    expect(tableContainer, isNotNull);
    expect((tableContainer as HtmlElement).classes.contains('hide'), isTrue);
    expect(fixture.text, contains('Ana'));
    expect(fixture.text, contains('Bruno'));
  });

  test('aplica classes e estilos customizados nas colunas', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'nome',
            title: 'Nome',
            headerClass: 'nome-header',
            cellClass: 'nome-cell',
            width: '220px',
            minWidth: '220px',
            textAlign: 'center',
            nowrap: true,
          ),
          DatatableCol(
            key: 'idade',
            title: 'Idade',
          ),
        ],
      );
    });
    await _settleTable(fixture);

    final headerCell = fixture.rootElement.querySelector(
      'thead th[data-key="nome"]',
    ) as TableCellElement?;
    final dataCell = fixture.rootElement.querySelector(
      'tbody tr td[data-label="datatable_col_0"]',
    ) as TableCellElement?;

    expect(headerCell, isNotNull);
    expect(dataCell, isNotNull);
    expect(headerCell!.classes.contains('nome-header'), isTrue);
    expect(dataCell!.classes.contains('nome-cell'), isTrue);
    expect(headerCell.style.width, '220px');
    expect(headerCell.style.minWidth, '220px');
    expect(headerCell.style.textAlign, 'center');
    expect(dataCell.style.width, '220px');
    expect(dataCell.style.minWidth, '220px');
    expect(dataCell.style.textAlign, 'center');
    expect(dataCell.style.whiteSpace, 'nowrap');
  });

  test('renderiza card customizado no modo grid', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableCol(key: 'idade', title: 'Idade'),
        ],
        gridTemplateColumns: 'repeat(2, minmax(0, 1fr))',
        gridGap: '2rem',
        customCardBuilder: (itemMap, itemInstance, row) {
          return DivElement()
            ..classes.add('custom-grid-card')
            ..text = '${itemMap['nome']} (${itemMap['idade']})';
        },
      );
    });
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.changeViewMode();
    });
    await _settleTable(fixture);

    final customCards = fixture.rootElement.querySelectorAll('.custom-grid-card');
    final customCardWrappers = fixture.rootElement.querySelectorAll('.datatable-custom-card');

    expect(customCards, hasLength(2));
    expect(customCardWrappers, hasLength(2));
    expect(host.table, isNotNull);
    expect(host.table!.settings.gridGap, equals('2rem'));
    expect(
      host.table!.settings.gridTemplateColumns,
      equals('repeat(2, minmax(0, 1fr))'),
    );
    expect(fixture.text, contains('Ana (30)'));
    expect(fixture.text, contains('Bruno (40)'));
  });
}

Future<void> _settleTable(NgTestFixture<TestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}
