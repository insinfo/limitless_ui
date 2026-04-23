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
    <div [attr.style]="tableContainerStyle">
      <li-datatable
        [dataTableFilter]="filter"
        [data]="data"
        [settings]="settings"
        [responsiveCollapse]="responsiveCollapse"
        [responsiveAutoHideColumns]="responsiveAutoHideColumns"
        [requestDataOnItemsPerPageChange]="requestDataOnItemsPerPageChange"
        [searchInFields]="searchInFields"
        [allowSingleSelectionOnly]="allowSingleSelectionOnly"
        (dataRequest)="onDataRequest(\$event)"
        (limitChange)="onLimitChange(\$event)"
        (searchRequest)="onSearchRequest(\$event)"
        (selectAll)="onSelectedRows(\$event)">
      </li-datatable>
    </div>
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
  bool responsiveAutoHideColumns = false;
  bool requestDataOnItemsPerPageChange = false;
  String tableContainerStyle = '';
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

@Component(
  selector: 'test-custom-header-host',
  template: '''
    <li-datatable
      [dataTableFilter]="filter"
      [data]="data"
      [settings]="settings"
      [searchInFields]="searchInFields"
      [showCheckboxToSelectRow]="false"
      (dataRequest)="onDataRequest(\$event)"
      (limitChange)="onLimitChange(\$event)"
      (searchRequest)="onSearchRequest(\$event)">
      <template li-datatable-header let-ctx>
        <div class="custom-header-marker">
          <span>{{ ctx.searchPlaceholder }}</span>
          <button id="custom-header-search" type="button" (click)="ctx.search()">Buscar</button>
        </div>
      </template>
      <template li-datatable-footer let-ctx>
        <div class="custom-footer-marker">
          <span>{{ ctx.currentPage }}/{{ ctx.numPages }}</span>
          <button id="custom-footer-next" type="button" (click)="ctx.nextPage()">Proxima</button>
        </div>
      </template>
    </li-datatable>
  ''',
  directives: [
    coreDirectives,
    LiDataTableComponent,
    LiDatatableHeaderDirective,
    LiDatatableFooterDirective,
  ],
)
class CustomHeaderTestHostComponent extends TestHostComponent {}

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
  final customHeaderTestBed = NgTestBed<CustomHeaderTestHostComponent>(
    ng.CustomHeaderTestHostComponentNgFactory,
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

  test('changePage usa a pagina nova ao calcular offset', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.changePage(2);
    });

    expect(host.table!.getCurrentPage, 2);
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

  test(
      'ordenacao simples ignora orderFields preexistente e limpa criterios avancados',
      () async {
    final fixture = await testBed.create();

    await fixture.update((component) {
      component.filter = Filters(
        limit: 10,
        offset: 0,
        orderFields: const <FilterOrderField>[
          FilterOrderField(field: 'nome', direction: 'asc'),
          FilterOrderField(field: 'idade', direction: 'desc'),
        ],
      );
    });

    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.onOrder(component.settings.colsDefinitions.first);
    });

    expect(host.lastDataRequest, isNotNull);
    expect(host.lastDataRequest!.orderBy, 'nome');
    expect(host.lastDataRequest!.orderDir, 'asc');
    expect(host.lastDataRequest!.orderFields, isEmpty);
    expect(host.table!.dataTableFilter.orderFields, isEmpty);
  });

  test('mantem apenas uma linha selecionada em modo single selection',
      () async {
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
      component.table!
          .handleSearchInputKeypress(_FakeKeyPressEvent(KeyCode.ENTER));
    });

    expect(host.lastSearchRequest, isNotNull);
    expect(host.lastSearchRequest!.searchString, 'Ana');
    expect(host.lastDataRequest, isNotNull);
    expect(host.lastDataRequest!.offset, 0);
    expect(host.table!.getCurrentPage, 1);
  });

  test('renderiza header customizado e remove toolbar padrao', () async {
    final fixture = await customHeaderTestBed.create();
    await _settleTable(fixture);

    expect(
      fixture.rootElement.querySelector('.custom-header-marker'),
      isNotNull,
    );
    expect(
      fixture.rootElement.querySelector('.datatable-search-toolbar'),
      isNull,
    );
  });

  test('renderiza footer customizado e permite paginacao via contexto',
      () async {
    final fixture = await customHeaderTestBed.create();
    await _settleTable(fixture);
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    expect(
      fixture.rootElement.querySelector('.custom-footer-marker'),
      isNotNull,
    );
    expect(
      fixture.rootElement.querySelector('.dataTables_info'),
      isNull,
    );

    final nextButton = fixture.rootElement.querySelector('#custom-footer-next')
        as ButtonElement?;
    expect(nextButton, isNotNull);

    await fixture.update((_) {
      nextButton!.click();
    });

    expect(host.lastDataRequest, isNotNull);
    expect(host.lastDataRequest!.offset, 10);
    expect(host.lastDataRequest!.limit, 10);
  });

  test(
      'permite selecionar varias linhas quando single selection esta desabilitado',
      () async {
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

  test('seleção individual atualiza a lista agregada de selecionados',
      () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[0]);
    });

    expect(host.lastSelectedRows, isNotNull);
    expect(host.lastSelectedRows, hasLength(1));
    expect(
        (host.lastSelectedRows!.single as Map<String, dynamic>)['nome'], 'Ana');

    await fixture.update((component) {
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[0]);
    });

    expect(host.lastSelectedRows, isNotNull);
    expect(host.lastSelectedRows, isEmpty);
  });

  test('toggle de visibilidade propaga para definicoes e linhas renderizadas',
      () async {
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

    expect(
        host.table!.hasResponsiveHiddenColumns(host.table!.rows.first), isTrue);
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

  test('não expande linha quando não há colunas configuradas para mobile',
      () async {
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

    final toggleCell =
        fixture.rootElement.querySelector('tbody tr td.dtr-control');

    expect(host.table!.hasResponsiveHiddenColumns(host.table!.rows.first),
        isFalse);
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

  test('esconde colunas por prioridade antes de gerar rolagem horizontal',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.responsiveAutoHideColumns = true;
      component.tableContainerStyle = 'width: 280px;';
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'nome',
            title: 'Nome',
            width: '160px',
            minWidth: '160px',
            responsiveAutoHidePriority: 1,
          ),
          DatatableCol(
            key: 'idade',
            title: 'Idade',
            width: '110px',
            minWidth: '110px',
            responsiveAutoHidePriority: 2,
          ),
          DatatableCol(
            key: 'acoes',
            title: 'Ações',
            width: '110px',
            minWidth: '110px',
            responsiveAutoHideRequired: true,
            customRenderString: (itemMap, itemInstance) => 'Ver',
          ),
        ],
      );
      component.searchInFields = <DatatableSearchField>[];
    });
    await _settleTable(fixture);
    await _settleTable(fixture);
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    final renderedRow = host.table!.renderedRows.first;
    final nomeHeader =
        fixture.rootElement.querySelector('thead th[data-key="nome"]');
    final idadeHeader =
        fixture.rootElement.querySelector('thead th[data-key="idade"]');
    final acoesHeader =
        fixture.rootElement.querySelector('thead th[data-key="acoes"]');

    expect(renderedRow.hasResponsiveHiddenColumns, isTrue);
    expect(
      renderedRow.responsiveHiddenColumns.map((column) => column.key),
      contains('nome'),
    );
    expect(
      renderedRow.responsiveHiddenColumns.map((column) => column.key),
      isNot(contains('acoes')),
    );
    expect(nomeHeader!.classes.contains('hide'), isTrue);
    expect(idadeHeader!.classes.contains('hide'), isFalse);
    expect(acoesHeader!.classes.contains('hide'), isFalse);
  });

  test('trata coluna auto-ocultada como desmarcada e permite forcar exibicao',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.responsiveAutoHideColumns = true;
      component.tableContainerStyle = 'width: 280px;';
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'nome',
            title: 'Nome',
            width: '160px',
            minWidth: '160px',
            responsiveAutoHidePriority: 1,
          ),
          DatatableCol(
            key: 'idade',
            title: 'Idade',
            width: '110px',
            minWidth: '110px',
            responsiveAutoHidePriority: 2,
          ),
          DatatableCol(
            key: 'acoes',
            title: 'Ações',
            width: '110px',
            minWidth: '110px',
            responsiveAutoHideRequired: true,
            customRenderString: (itemMap, itemInstance) => 'Ver',
          ),
        ],
      );
      component.searchInFields = <DatatableSearchField>[];
    });
    await _settleTable(fixture);
    await _settleTable(fixture);
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    final nomeCol = host.settings.colsDefinitions.first;
    var nomeHeader = fixture.rootElement.querySelector(
      'thead th[data-key="nome"]',
    );

    expect(host.table!.isColumnEffectivelyVisible(nomeCol), isFalse);
    expect(host.table!.isRuntimeResponsiveHidden(nomeCol), isTrue);
    expect(nomeHeader, isNotNull);
    expect(nomeHeader!.classes.contains('hide'), isTrue);

    await fixture.update((component) {
      component.table!.changeVisibilityOfCol(nomeCol);
    });
    await _settleTable(fixture);

    nomeHeader = fixture.rootElement.querySelector('thead th[data-key="nome"]');

    expect(nomeCol.visibility, isTrue);
    expect(host.table!.isColumnEffectivelyVisible(nomeCol), isTrue);
    expect(host.table!.isRuntimeResponsiveHidden(nomeCol), isFalse);
    expect(nomeHeader, isNotNull);
    expect(nomeHeader!.classes.contains('hide'), isFalse);
  });

  test(
      'usa a primeira coluna obrigatória visível como controle do detalhe auto-hide',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.responsiveAutoHideColumns = true;
      component.tableContainerStyle = 'width: 260px;';
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'nome',
            title: 'Nome',
            width: '180px',
            minWidth: '180px',
            responsiveAutoHidePriority: 1,
          ),
          DatatableCol(
            key: 'idade',
            title: 'Idade',
            width: '120px',
            minWidth: '120px',
            responsiveAutoHidePriority: 2,
          ),
          DatatableCol(
            key: 'acoes',
            title: 'Ações',
            width: '110px',
            minWidth: '110px',
            responsiveAutoHideRequired: true,
            customRenderString: (itemMap, itemInstance) => 'Ver',
          ),
        ],
      );
      component.searchInFields = <DatatableSearchField>[];
    });
    await _settleTable(fixture);
    await _settleTable(fixture);
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    final toggleCell = fixture.rootElement.querySelector(
      'tbody tr td.dtr-control',
    ) as TableCellElement?;

    expect(toggleCell, isNotNull);
    expect(host.table!.renderedRows.first.responsiveControlColumnKey, 'acoes');

    await fixture.update((_) {
      toggleCell!.click();
    });

    expect(host.table!.rows.first.isExpanded, isTrue);
    expect(fixture.rootElement.querySelector('tbody tr.child'), isNotNull);
    expect(fixture.text, contains('Nome'));
    expect(fixture.text, contains('Ana'));
  });

  test('onSelectAll marca e desmarca todas as linhas pelo checkbox do header',
      () async {
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

  test('agrupamento não renderiza checkbox na linha divisora', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.data = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[
          <String, dynamic>{
            'grupoId': 1,
            'grupoNome': 'Compras',
            'assuntoId': 10,
            'assuntoNome': 'Compra direta',
            'nome': 'Ana',
            'idade': 30,
          },
          <String, dynamic>{
            'grupoId': 1,
            'grupoNome': 'Compras',
            'assuntoId': 10,
            'assuntoNome': 'Compra direta',
            'nome': 'Bruno',
            'idade': 40,
          },
        ],
        totalRecords: 2,
      );
      component.settings = DatatableSettings(
        enableGrouping: true,
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'grupoNome',
            title: 'Grupo',
            visibility: false,
            enableGrouping: true,
            groupByKey: 'grupoId',
          ),
          DatatableCol(
            key: 'assuntoNome',
            title: 'Assunto',
            visibility: false,
            enableGrouping: true,
            groupByKey: 'assuntoId',
          ),
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableCol(key: 'idade', title: 'Idade'),
        ],
      );
    });
    await _settleTable(fixture);

    final groupRow = fixture.rootElement.querySelector(
      'tbody tr.datatable-group-title-row',
    ) as TableRowElement?;

    expect(groupRow, isNotNull);
    expect(groupRow!.querySelector('input.form-check-input'), isNull);
    expect(groupRow.querySelectorAll('td'), hasLength(1));
    expect(groupRow.text, contains('Compras'));
    expect(groupRow.text, contains('Compra direta'));
  });

  test('select all com agrupamento seleciona apenas linhas normais', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.data = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[
          <String, dynamic>{
            'grupoId': 1,
            'grupoNome': 'Compras',
            'assuntoId': 10,
            'assuntoNome': 'Compra direta',
            'nome': 'Ana',
            'idade': 30,
          },
          <String, dynamic>{
            'grupoId': 2,
            'grupoNome': 'Pessoal',
            'assuntoId': 20,
            'assuntoNome': 'Férias',
            'nome': 'Bruno',
            'idade': 40,
          },
        ],
        totalRecords: 2,
      );
      component.settings = DatatableSettings(
        enableGrouping: true,
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'grupoNome',
            title: 'Grupo',
            visibility: false,
            enableGrouping: true,
            groupByKey: 'grupoId',
          ),
          DatatableCol(
            key: 'assuntoNome',
            title: 'Assunto',
            visibility: false,
            enableGrouping: true,
            groupByKey: 'assuntoId',
          ),
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableCol(key: 'idade', title: 'Idade'),
        ],
      );
    });
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;
    final selectAllCheckbox = fixture.rootElement.querySelector(
      'thead .datatable-first-col input.form-check-input',
    ) as CheckboxInputElement?;

    expect(selectAllCheckbox, isNotNull);
    expect(
        host.table!.rows
            .where((row) => row.type == DatatableRowType.groupTitle),
        hasLength(2));
    expect(host.table!.rows.where((row) => row.type == DatatableRowType.normal),
        hasLength(2));

    await fixture.update((_) {
      selectAllCheckbox!.click();
    });

    expect(
      host.table!.rows
          .where((row) => row.type == DatatableRowType.groupTitle)
          .every((row) => row.selected == false),
      isTrue,
    );
    expect(
      host.table!.rows
          .where((row) => row.type == DatatableRowType.normal)
          .every((row) => row.selected),
      isTrue,
    );
    expect(host.table!.getAllSelected<Map<String, dynamic>>(), hasLength(2));
    expect(host.lastSelectedRows, hasLength(2));
  });

  test('onSelect ignora linha de agrupamento', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.data = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[
          <String, dynamic>{
            'grupoId': 1,
            'grupoNome': 'Compras',
            'assuntoId': 10,
            'assuntoNome': 'Compra direta',
            'nome': 'Ana',
            'idade': 30,
          },
          <String, dynamic>{
            'grupoId': 1,
            'grupoNome': 'Compras',
            'assuntoId': 10,
            'assuntoNome': 'Compra direta',
            'nome': 'Bruno',
            'idade': 40,
          },
        ],
        totalRecords: 2,
      );
      component.settings = DatatableSettings(
        enableGrouping: true,
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'grupoNome',
            title: 'Grupo',
            visibility: false,
            enableGrouping: true,
            groupByKey: 'grupoId',
          ),
          DatatableCol(
            key: 'assuntoNome',
            title: 'Assunto',
            visibility: false,
            enableGrouping: true,
            groupByKey: 'assuntoId',
          ),
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableCol(key: 'idade', title: 'Idade'),
        ],
      );
    });
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;
    final groupRow = host.table!.rows.firstWhere(
      (row) => row.type == DatatableRowType.groupTitle,
    );

    await fixture.update((component) {
      component.table!.onSelect(MouseEvent('click'), groupRow);
    });

    expect(groupRow.selected, isFalse);
    expect(host.table!.getAllSelected<Map<String, dynamic>>(), isEmpty);
    expect(host.lastSelectedRows, anyOf(isNull, isEmpty));
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
    expect(host.table!.searchInFields.first.selected, isFalse);
    expect(host.table!.searchInFields[1].selected, isTrue);
  });

  test('reaplica campo de busca selecionado quando dataTableFilter muda',
      () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.handleSearchFieldSelectChange(null, '1');
    });

    await fixture.update((component) {
      component.filter = Filters(limit: 5, offset: 0);
    });
    await _settleTable(fixture);

    expect(host.table!.dataTableFilter, same(host.filter));
    expect(host.filter.searchInFields, hasLength(1));
    expect(host.filter.searchInFields.first.field, 'idade');
    expect(host.filter.searchInFields.first.operator, '=');
    expect(host.filter.searchInFields.first.label, 'Idade');
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

  test(
      'ordenação multi-coluna alterna a direção ao ordenar a mesma coluna novamente',
      () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.enableMultiColumnSorting = true;
      component.table!.onOrder(component.settings.colsDefinitions.first);
      component.table!.onOrder(component.settings.colsDefinitions.first);
    });

    expect(host.lastDataRequest, isNotNull);
    expect(host.table!.dataTableFilter.orderFields, hasLength(1));
    expect(host.table!.dataTableFilter.orderFields.first.field, 'nome');
    expect(host.table!.dataTableFilter.orderFields.first.direction, 'desc');
  });

  test('changeItemsPerPageHandler atualiza limit e emite limitChange',
      () async {
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

  test(
      'changeItemsPerPageHandler pode emitir dataRequest quando a opção estiver habilitada',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.requestDataOnItemsPerPageChange = true;
    });
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;
    final select = SelectElement()
      ..append(OptionElement(data: '20', value: '20')..selected = true);

    await fixture.update((component) {
      component.table!.nextPage();
      host.lastDataRequest = null;
      host.lastLimitChange = null;
      component.table!.changeItemsPerPageHandler(select);
    });

    expect(host.table!.getCurrentPage, 1);
    expect(host.table!.dataTableFilter.limit, 20);
    expect(host.lastDataRequest, isNotNull);
    expect(host.lastDataRequest!.limit, 20);
    expect(host.lastDataRequest!.offset, 0);
    expect(host.lastLimitChange, isNull);
  });

  test('prevPage, primeira e ultima pagina atualizam offset corretamente',
      () async {
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
    final gridItems =
        fixture.rootElement.querySelectorAll('.grid-layout .grid-item');
    final tableContainer =
        fixture.rootElement.querySelector('.datatable-scroll');

    expect(host.table!.gridMode, isTrue);
    expect(gridContainer, isNotNull);
    expect(gridItems.length, 2);
    expect(tableContainer, isNotNull);
    expect((tableContainer as HtmlElement).classes.contains('hide'), isTrue);
    expect(fixture.text, contains('Ana'));
    expect(fixture.text, contains('Bruno'));
  });

  test('preserva a classe padrao do grid-container sem customização', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);

    await fixture.update((component) {
      component.table!.changeViewMode();
    });
    await _settleTable(fixture);

    final gridContainer = fixture.rootElement.querySelector('.grid-container');

    expect(gridContainer, isNotNull);
    expect(gridContainer!.className, contains('grid-container'));
  });

  test(
      'adiciona classe customizada ao grid-container sem remover a classe padrao',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableCol(key: 'idade', title: 'Idade'),
        ],
        gridContainerClass: 'grid-shell-demo',
      );
    });
    await _settleTable(fixture);

    await fixture.update((component) {
      component.table!.changeViewMode();
    });
    await _settleTable(fixture);

    final gridContainer = fixture.rootElement.querySelector('.grid-container');

    expect(gridContainer, isNotNull);
    expect(gridContainer!.className, contains('grid-container'));
    expect(gridContainer.className, contains('grid-shell-demo'));
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

    final customCards =
        fixture.rootElement.querySelectorAll('.custom-grid-card');
    final customCardWrappers =
        fixture.rootElement.querySelectorAll('.datatable-custom-card');

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

  test('restaura colunas auto-ocultadas ao ampliar a largura e disparar resize',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.responsiveAutoHideColumns = true;
      component.tableContainerStyle = 'width: 360px;';
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'nome',
            title: 'Nome',
            width: '160px',
            minWidth: '160px',
            responsiveAutoHideRequired: true,
          ),
          DatatableCol(
            key: 'solicitante',
            title: 'Solicitante',
            responsiveAutoHidePriority: 10,
            customRenderString: (itemMap, itemInstance) =>
                'Solicitante com descricao longa',
          ),
          DatatableCol(
            key: 'assunto',
            title: 'Assunto',
            responsiveAutoHidePriority: 20,
            customRenderString: (itemMap, itemInstance) =>
                'Assunto administrativo detalhado',
          ),
          DatatableCol(
            key: 'digital',
            title: 'Digital',
            width: '96px',
            minWidth: '96px',
            responsiveAutoHidePriority: 30,
            customRenderString: (itemMap, itemInstance) => 'Sim',
          ),
          DatatableCol(
            key: 'acoes',
            title: 'Ações',
            width: '110px',
            minWidth: '110px',
            responsiveAutoHideRequired: true,
            customRenderString: (itemMap, itemInstance) => 'Ver',
          ),
        ],
      );
      component.data = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[
          <String, dynamic>{
            'nome': '61109/2016',
            'solicitante': 'Nucleo de Governanca',
            'assunto': 'Revisao documental',
            'digital': 'Sim',
            'acoes': 'Ver',
          },
        ],
        totalRecords: 1,
      );
      component.searchInFields = <DatatableSearchField>[];
    });
    await _settleTable(fixture);
    await _settleTable(fixture);
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.table!.renderedRows.first.hasResponsiveHiddenColumns, isTrue);
    expect(
      host.table!.renderedRows.first.responsiveHiddenColumns
          .map((column) => column.key),
      contains('solicitante'),
    );

    await fixture.update((component) {
      component.tableContainerStyle = 'width: 960px;';
      window.dispatchEvent(Event('resize'));
    });
    await _settleAfterResize(fixture);
    await _settleAfterResize(fixture);

    final solicitanteHeader = fixture.rootElement.querySelector(
      'thead th[data-key="solicitante"]',
    );
    final assuntoHeader = fixture.rootElement.querySelector(
      'thead th[data-key="assunto"]',
    );

    expect(host.table!.renderedRows.first.hasResponsiveHiddenColumns, isFalse);
    expect(solicitanteHeader, isNotNull);
    expect(assuntoHeader, isNotNull);
    expect(solicitanteHeader!.classes.contains('hide'), isFalse);
    expect(assuntoHeader!.classes.contains('hide'), isFalse);
  });

  test('mantem a coluna de acoes fixada a direita durante scroll horizontal',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.tableContainerStyle = 'width: 480px;';
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'processo',
            title: 'Processo',
            width: '180px',
            minWidth: '180px',
          ),
          DatatableCol(
            key: 'solicitante',
            title: 'Solicitante',
            width: '220px',
            minWidth: '220px',
          ),
          DatatableCol(
            key: 'assunto',
            title: 'Assunto',
            width: '240px',
            minWidth: '240px',
          ),
          DatatableCol(
            key: 'status',
            title: 'Status',
            width: '140px',
            minWidth: '140px',
          ),
          DatatableCol(
            key: 'acoes',
            title: 'Ações',
            width: '128px',
            minWidth: '128px',
            fixedPosition: DatatableFixedColumnPosition.right,
            customRenderString: (itemMap, itemInstance) => 'Abrir',
          ),
        ],
      );
      component.data = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[
          <String, dynamic>{
            'processo': '61109/2016',
            'solicitante': 'Nucleo de Governanca',
            'assunto': 'Revisao documental extensa',
            'status': 'Em analise',
            'acoes': 'Abrir',
          },
        ],
        totalRecords: 1,
      );
      component.searchInFields = <DatatableSearchField>[];
    });

    await _settleTable(fixture);
    await _settleTable(fixture);
    await _settleTable(fixture);

    final headerCell = fixture.rootElement.querySelector(
      'thead th[data-key="acoes"]',
    ) as TableCellElement?;
    final dataCell = fixture.rootElement.querySelector(
      'tbody tr td[data-label="datatable_col_4"]',
    ) as TableCellElement?;

    expect(headerCell, isNotNull);
    expect(dataCell, isNotNull);
    expect(headerCell!.classes.contains('datatable-fixed-col'), isTrue);
    expect(headerCell.classes.contains('datatable-fixed-col--right'), isTrue);
    expect(dataCell!.classes.contains('datatable-fixed-col'), isTrue);
    expect(dataCell.classes.contains('datatable-fixed-col--right'), isTrue);
    expect(headerCell.style.right, '0px');
    expect(dataCell.style.right, '0px');
    expect(headerCell.getComputedStyle().position, 'sticky');
    expect(dataCell.getComputedStyle().position, 'sticky');
  });
}

Future<void> _settleTable(NgTestFixture<TestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await fixture.update((_) {});
}

Future<void> _settleAfterResize(
    NgTestFixture<TestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 180));
  await fixture.update((_) {});
}
