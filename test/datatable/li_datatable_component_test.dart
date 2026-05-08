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
        [virtualScroll]="virtualScroll"
        [stickyTableHeaderOnVirtualScroll]="stickyTableHeaderOnVirtualScroll"
        [virtualRowHeight]="virtualRowHeight"
        [virtualOverscan]="virtualOverscan"
        [virtualViewportHeight]="virtualViewportHeight"
        [virtualGridItemHeight]="virtualGridItemHeight"
        [virtualGridMinItemWidth]="virtualGridMinItemWidth"
        [performanceProfile]="performanceProfile"
        [onExportPdf]="onExportPdfCallback"
        [onExportXlsx]="onExportXlsxCallback"
        [responsiveCollapse]="responsiveCollapse"
        [responsiveCollapseByContainer]="responsiveCollapseByContainer"
        [responsiveCollapseContainerMaxWidth]="responsiveCollapseContainerMaxWidth"
        [responsiveAutoHideColumns]="responsiveAutoHideColumns"
        [requestDataOnItemsPerPageChange]="requestDataOnItemsPerPageChange"
        [searchInFields]="searchInFields"
        [allowSingleSelectionOnly]="allowSingleSelectionOnly"
        [enableGridMode]="enableGridMode"
        [enableResponsiveFeatures]="enableResponsiveFeatures"
        [fixedTableLayout]="fixedTableLayout"
        [debugInstrumentation]="debugInstrumentation"
        [debugInstrumentationLabel]="debugInstrumentationLabel"
        (dataRequest)="onDataRequest(\$event)"
        (limitChange)="onLimitChange(\$event)"
        (searchRequest)="onSearchRequest(\$event)"
        (instrumentation)="onInstrumentation(\$event)"
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
  bool enableGridMode = true;
  bool enableResponsiveFeatures = true;
  bool fixedTableLayout = false;
  bool virtualScroll = false;
  DatatablePerformanceProfile performanceProfile =
      DatatablePerformanceProfile.flexible;
  bool stickyTableHeaderOnVirtualScroll = false;
  int virtualRowHeight = 44;
  int virtualOverscan = 10;
  String virtualViewportHeight = '70vh';
  int virtualGridItemHeight = 260;
  int virtualGridMinItemWidth = 280;
  bool responsiveCollapse = false;
  bool responsiveCollapseByContainer = false;
  int responsiveCollapseContainerMaxWidth = 767;
  bool responsiveAutoHideColumns = false;
  bool requestDataOnItemsPerPageChange = false;
  bool debugInstrumentation = false;
  String debugInstrumentationLabel = 'datatable-test';
  String tableContainerStyle = '';
  Filters? lastDataRequest;
  Filters? lastLimitChange;
  Filters? lastSearchRequest;
  List<dynamic>? lastSelectedRows;
  final List<LiDatatableInstrumentationEvent> instrumentationEvents =
      <LiDatatableInstrumentationEvent>[];
  DatatableExportPdfCallback? onExportPdfCallback;
  DatatableExportXlsxCallback? onExportXlsxCallback;

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

  void onInstrumentation(LiDatatableInstrumentationEvent event) {
    instrumentationEvents.add(event);
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
      <template li-datatable-cell="acoes" let-ctx>
        <button
          type="button"
          class="cell-action-btn"
          [attr.data-candidate]="ctx.itemMap['nome']"
          (click)="onOpen(ctx.itemMap['nome'])">
          Abrir {{ ctx.itemMap['nome'] }}
        </button>
      </template>
    </li-datatable>
  ''',
  directives: [
    coreDirectives,
    LiDataTableComponent,
    LiDatatableHeaderDirective,
    LiDatatableFooterDirective,
    LiDatatableCellDirective,
  ],
)
class CustomHeaderTestHostComponent extends TestHostComponent {
  String? lastOpenedName;

  CustomHeaderTestHostComponent() {
    settings = DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(key: 'nome', title: 'Nome'),
        DatatableCol(key: 'idade', title: 'Idade'),
        DatatableCol(
          key: 'acoes',
          title: 'Ações',
          customRenderHtml: (itemMap, itemInstance) =>
              SpanElement()..text = 'LEGACY',
        ),
      ],
    );
  }

  void onOpen(String? name) {
    lastOpenedName = name;
  }
}

@Component(
  selector: 'test-header-title-host',
  template: '''
    <div [attr.style]="tableContainerStyle">
      <li-datatable
        [dataTableFilter]="filter"
        [data]="data"
        [settings]="settings"
        [searchInFields]="searchInFields"
        [showCheckboxToSelectRow]="false"
        [responsiveCollapse]="true"
        [responsiveCollapseByContainer]="true"
        [responsiveCollapseContainerMaxWidth]="760"
        [responsiveAutoHideColumns]="true">
        <template li-datatable-header-cell="acoes" let-ctx>
          <span class="header-template-marker" [attr.data-column]="ctx.column.key">
            Cabecalho template
          </span>
        </template>
      </li-datatable>
    </div>
  ''',
  directives: [
    coreDirectives,
    LiDataTableComponent,
    LiDatatableHeaderCellDirective,
  ],
)
class HeaderTitleTestHostComponent extends TestHostComponent {
  HeaderTitleTestHostComponent() {
    searchInFields = <DatatableSearchField>[];
    settings = DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'nome',
          title: 'Nome',
          width: '180px',
          minWidth: '180px',
          customRenderTitleString: (column) => 'Nome exibido',
          titleTooltip: DatatableTitleTooltipConfig(
            text: 'Nome usado para identificar o arquivo original.',
            displayMode: DatatableTitleTooltipDisplayMode.title,
          ),
        ),
        DatatableCol(
          key: 'idade',
          title: 'Idade',
          width: '120px',
          minWidth: '120px',
          titleTooltip: DatatableTitleTooltipConfig(
            text: 'Tooltip nativo do navegador para a idade.',
            displayMode: DatatableTitleTooltipDisplayMode.title,
            useNativeTitle: true,
          ),
          responsiveAutoHidePriority: 20,
          customRenderTitleHtml: (column) => SpanElement()
            ..className = 'header-html-marker'
            ..text = 'Idade HTML',
        ),
        DatatableCol(
          key: 'acoes',
          title: 'Ações',
          width: '110px',
          minWidth: '110px',
          titleTextAlign: 'center',
          responsiveAutoHideRequired: true,
          titlePopover: DatatableTitlePopoverConfig(
            title: 'Ações rápidas',
            body: 'Use esta coluna para editar ou remover o item.',
          ),
          customRenderTitleHtml: (column) => SpanElement()
            ..className = 'header-html-fallback'
            ..text = 'Fallback HTML',
        ),
      ],
      responsiveControlColumnKey: 'nome',
    );
  }
}

@Component(
  selector: 'test-card-template-host',
  template: '''
    <li-datatable
      [dataTableFilter]="filter"
      [data]="data"
      [settings]="settings"
      [searchInFields]="searchInFields"
      [showCheckboxToSelectRow]="false"
      [gridMode]="true">
      <template li-datatable-card let-ctx>
        <article class="grid-card-template-marker" [attr.data-row]="ctx.rowIndex.toString()">
          <h6 class="grid-card-template-name">{{ ctx.itemMap['nome'] }}</h6>
          <div class="grid-card-template-age">{{ ctx.itemMap['idade'] }}</div>
        </article>
      </template>
    </li-datatable>
  ''',
  directives: [
    coreDirectives,
    LiDataTableComponent,
    LiDatatableCardDirective,
  ],
)
class CardTemplateTestHostComponent extends TestHostComponent {
  CardTemplateTestHostComponent() {
    searchInFields = <DatatableSearchField>[];
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
  final customHeaderTestBed = NgTestBed<CustomHeaderTestHostComponent>(
    ng.CustomHeaderTestHostComponentNgFactory,
  );
  final headerTitleTestBed = NgTestBed<HeaderTitleTestHostComponent>(
    ng.HeaderTitleTestHostComponentNgFactory,
  );
  final cardTemplateTestBed = NgTestBed<CardTemplateTestHostComponent>(
    ng.CardTemplateTestHostComponentNgFactory,
  );

  test('renderiza cabecalhos e linhas iniciais', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);

    expect(fixture.text, contains('Nome'));
    expect(fixture.text, contains('Idade'));
    expect(fixture.text, contains('Ana'));
    expect(fixture.text, contains('Bruno'));
  });

  test('customiza titulos com alinhamento, render Dart e TemplateRef',
      () async {
    final fixture = await headerTitleTestBed.create();
    await _settleTable(fixture);

    final nomeHeader = fixture.rootElement.querySelector(
      'thead th[data-key="nome"]',
    );
    final idadeHeader = fixture.rootElement.querySelector(
      'thead th[data-key="idade"]',
    );
    final acoesHeader = fixture.rootElement.querySelector(
      'thead th[data-key="acoes"]',
    );

    expect(nomeHeader, isNotNull);
    expect(nomeHeader!.text, contains('Nome exibido'));

    expect(idadeHeader, isNotNull);
    expect(idadeHeader!.querySelector('.header-html-marker'), isNotNull);
    expect(idadeHeader.text, contains('Idade HTML'));
    expect(
      idadeHeader
          .querySelector('[title="Tooltip nativo do navegador para a idade."]'),
      isNotNull,
    );

    expect(acoesHeader, isNotNull);
    expect(
      acoesHeader!.querySelector('.header-template-marker'),
      isNotNull,
    );
    expect(acoesHeader.getAttribute('style'), contains('text-align: center'));
    expect(acoesHeader.text, isNot(contains('Fallback HTML')));

    final tooltipHost = nomeHeader.querySelector(
      '[data-header-help="tooltip-inline"]',
    ) as HtmlElement?;
    final popoverButton = acoesHeader.querySelector(
      'button[data-header-help="popover"]',
    ) as ButtonElement?;

    expect(tooltipHost, isNotNull);
    expect(popoverButton, isNotNull);

    tooltipHost!.dispatchEvent(MouseEvent('mouseenter'));
    await _settleTable(fixture);

    final tooltip = document.body!.querySelector('.tooltip');
    expect(tooltip, isNotNull);
    expect(tooltip!.text, contains('identificar o arquivo original'));

    popoverButton!.click();
    await _settleTable(fixture);

    final popover = document.body!.querySelector('.popover');
    expect(popover, isNotNull);
    expect(popover!.text, contains('Ações rápidas'));
    expect(popover.text, contains('editar ou remover o item'));
  });

  test('DatatableActionColumn nao entra nas colunas exportaveis por padrao',
      () {
    final settings = DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(key: 'nome', title: 'Nome'),
        DatatableActionColumn(
          key: 'acoes',
          title: 'Ações',
          actions: <DatatableAction>[
            DatatableAction(label: 'Abrir', onTap: (_) {}),
          ],
        ),
      ],
    );

    expect(
        settings.exportColumns.map((column) => column.key), <String>['nome']);
    expect(
      settings.visibleExportColumns.map((column) => column.key),
      <String>['nome'],
    );
  });

  test('renderiza card customizado com TemplateRef no modo grid', () async {
    final fixture = await cardTemplateTestBed.create();
    await _settleTable(fixture);

    final templateCards = fixture.rootElement.querySelectorAll(
      '.grid-card-template-marker',
    );
    final defaultCardBodies = fixture.rootElement.querySelectorAll(
      '.grid-layout .grid-item > .card-body',
    );
    final defaultCardFooters = fixture.rootElement.querySelectorAll(
      '.grid-layout .grid-item > .card-footer',
    );

    expect(templateCards, hasLength(2));
    expect(templateCards.first.text, contains('Ana'));
    expect(templateCards.first.getAttribute('data-row'), '0');
    expect(defaultCardBodies, isEmpty);
    expect(defaultCardFooters, isEmpty);
  });

  test('callbacks de exportacao recebem apenas colunas exportaveis', () async {
    List<String>? xlsxColumns;
    List<String>? pdfColumns;
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableCol(key: 'idade', title: 'Idade', visibility: false),
          DatatableCol(
            key: 'acoes',
            title: 'Ações',
            exportable: false,
          ),
        ],
      );
      component.onExportXlsxCallback = (rows, exportColumns) {
        xlsxColumns = exportColumns.map((column) => column.key).toList();
      };
      component.onExportPdfCallback = (rows, exportColumns) {
        pdfColumns = exportColumns.map((column) => column.key).toList();
      };
    });
    await _settleTable(fixture);

    await fixture.update((component) async {
      await component.table!.exportXlsx();
      await component.table!.exportPdf();
    });

    expect(xlsxColumns, <String>['nome', 'idade']);
    expect(pdfColumns, <String>['nome']);
  });

  test('host de titulos customizados colapsa colunas em container estreito',
      () async {
    final fixture = await headerTitleTestBed.create(beforeChangeDetection: (
      component,
    ) {
      component.tableContainerStyle = 'width: 260px;';
    });
    await _settleTable(fixture);
    await _settleTable(fixture);
    await _settleTable(fixture);

    final host = fixture.assertOnlyInstance;
    final toggleCell = fixture.rootElement.querySelector(
      'tbody tr td.dtr-control',
    ) as TableCellElement?;

    expect(toggleCell, isNotNull);
    expect(host.table!.renderedRows.first.hasResponsiveHiddenColumns, isTrue);
    expect(host.table!.renderedRows.first.responsiveControlColumnKey, 'nome');
    expect(
      host.table!.renderedRows.first.responsiveHiddenColumns
          .map((column) => column.key),
      contains('idade'),
    );
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

  test('renderiza template de célula por chave da coluna e mantém clique',
      () async {
    final fixture = await customHeaderTestBed.create();
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    final buttons = fixture.rootElement.querySelectorAll('.cell-action-btn');
    expect(buttons, isNotEmpty);
    expect(buttons.length, 2);
    expect(buttons.first.text, contains('Ana'));
    expect(fixture.text, isNot(contains('LEGACY')));

    await fixture.update((_) {
      (buttons.first as ButtonElement).click();
    });

    expect(host.lastOpenedName, 'Ana');
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

  test(
      'expande linha filha em desktop quando o container atinge largura de colapso',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.tableContainerStyle = 'width: 360px;';
      component.responsiveCollapse = true;
      component.responsiveCollapseByContainer = true;
      component.responsiveCollapseContainerMaxWidth = 420;
    });
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    final toggleCell = fixture.rootElement.querySelector(
      'tbody tr td.dtr-control',
    ) as TableCellElement?;

    expect(
      host.table!.hasResponsiveHiddenColumns(host.table!.rows.first),
      isTrue,
    );
    expect(toggleCell, isNotNull);
  });

  test('colapsa em desktop por container sem auto-hide por prioridade',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.tableContainerStyle = 'width: 360px;';
      component.responsiveCollapse = true;
      component.responsiveCollapseByContainer = true;
      component.responsiveCollapseContainerMaxWidth = 420;
      component.responsiveAutoHideColumns = false;
      component.debugInstrumentation = true;
      component.debugInstrumentationLabel = 'desktop-collapse-no-priority';
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableCol(
            key: 'idade',
            title: 'Idade',
            hideOnMobile: true,
          ),
          DatatableCol(
            key: 'setor',
            title: 'Setor',
            hideOnMobile: true,
          ),
        ],
      );
    });
    await _settleTable(fixture);
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    final renderedRow = host.table!.renderedRows.first;
    final hiddenKeys =
        renderedRow.responsiveHiddenColumns.map((column) => column.key).toSet();
    final viewportEvents = host.instrumentationEvents
        .where((event) => event.stage == 'responsiveViewportState.sync')
        .toList(growable: false);

    expect(host.table!.hasResponsiveCollapsedColumns, isTrue);
    expect(renderedRow.hasResponsiveHiddenColumns, isTrue);
    expect(hiddenKeys, containsAll(<String>['idade', 'setor']));
    expect(
      fixture.rootElement.querySelector('tbody tr td.dtr-control'),
      isNotNull,
    );
    expect(
      host.instrumentationEvents.any(
        (event) =>
            event.stage.startsWith('responsiveAutoHideSync') &&
            event.stage != 'responsiveAutoHideSync.skipped',
      ),
      isFalse,
    );
    expect(viewportEvents, isNotEmpty);
    expect(
      viewportEvents.any(
        (event) =>
            event.details['collapseContainerActive'] == true &&
            event.details['collapseActive'] == true,
      ),
      isTrue,
    );
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

  test('enableResponsiveFeatures false bloqueia collapse e auto-hide',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component
        ..enableResponsiveFeatures = false
        ..responsiveCollapse = true
        ..responsiveAutoHideColumns = true
        ..tableContainerStyle = 'width: 260px;'
        ..settings = DatatableSettings(
          colsDefinitions: <DatatableCol>[
            DatatableCol(
              key: 'nome',
              title: 'Nome',
              width: '180px',
              hideOnMobile: true,
              responsiveAutoHidePriority: 1,
            ),
            DatatableCol(
              key: 'idade',
              title: 'Idade',
              width: '180px',
              responsiveAutoHidePriority: 2,
            ),
          ],
        );
    });
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.responsiveCollapseMaxWidth = 100000;
    });
    await _settleTable(fixture);

    expect(host.table!.enableResponsiveFeatures, isFalse);
    expect(host.table!.hasResponsiveCollapsedColumns, isFalse);
    expect(host.table!.hasResponsiveHiddenColumns(host.table!.rows.first),
        isFalse);
    expect(host.table!.renderedRows.first.hasResponsiveHiddenColumns, isFalse);
    expect(
        fixture.rootElement.querySelector('tbody tr td.dtr-control'), isNull);
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

  test('nao trata largura percentual como pixels no auto-hide', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.responsiveAutoHideColumns = true;
      component.tableContainerStyle = 'width: 330px;';
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'id',
            title: 'ID',
            width: '70px',
            minWidth: '70px',
            responsiveAutoHideRequired: true,
          ),
          DatatableCol(
            key: 'detalhes',
            title: 'Detalhes',
            width: '120px',
            minWidth: '120px',
            responsiveAutoHidePriority: 10,
          ),
          DatatableCol(
            key: 'responsavel',
            title: 'Responsavel',
            width: '120px',
            minWidth: '120px',
            responsiveAutoHidePriority: 20,
          ),
          DatatableCol(
            key: 'acoes',
            title: 'Acoes',
            width: '1%',
            minWidth: '1%',
            nowrap: true,
            responsiveAutoHideRequired: true,
            customRenderString: (itemMap, itemInstance) => 'Abrir detalhes',
          ),
        ],
      );
      component.searchInFields = <DatatableSearchField>[];
    });
    await _settleTable(fixture);
    await _settleTable(fixture);
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    final hiddenKeys = host.table!.renderedRows.first.responsiveHiddenColumns
        .map((column) => column.key);
    final detalhesHeader = fixture.rootElement.querySelector(
      'thead th[data-key="detalhes"]',
    );
    final acoesHeader = fixture.rootElement.querySelector(
      'thead th[data-key="acoes"]',
    );

    expect(hiddenKeys, contains('detalhes'));
    expect(hiddenKeys, isNot(contains('acoes')));
    expect(detalhesHeader!.classes.contains('hide'), isTrue);
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

  test('permite escolher explicitamente a coluna de controle responsivo',
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
            responsiveAutoHideRequired: true,
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
        responsiveControlColumnKey: 'nome',
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
    expect(toggleCell!.getAttribute('data-label'), 'datatable_col_0');
    expect(host.table!.renderedRows.first.responsiveControlColumnKey, 'nome');
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

  test('enableGridMode false bloqueia grid e remove botao de alternancia',
      () async {
    final fixture = await testBed.create(
      beforeChangeDetection: (component) {
        component.enableGridMode = false;
      },
    );
    await _settleTable(fixture);
    final host = fixture.assertOnlyInstance;

    expect(host.table!.enableGridMode, isFalse);
    expect(host.table!.gridMode, isFalse);
    expect(fixture.rootElement.querySelector('.datatable-grid-scroll'), isNull);
    expect(
      fixture.rootElement.querySelector('.ph-squares-four'),
      isNull,
    );

    await fixture.update((component) {
      component.table!.changeViewMode();
    });
    await _settleTable(fixture);

    expect(host.table!.gridMode, isFalse);
    expect(fixture.rootElement.querySelector('.datatable-scroll'), isNotNull);
    expect(fixture.rootElement.querySelector('.datatable-grid-scroll'), isNull);
  });

  test('enableGridMode false ignora input gridMode true e custom card builder',
      () async {
    var customCardBuilderCalls = 0;
    final fixture = await testBed.create(
      beforeChangeDetection: (component) {
        component
          ..enableGridMode = false
          ..settings = DatatableSettings(
            customCardBuilder: (itemMap, itemInstance, row) {
              customCardBuilderCalls++;
              return DivElement()..text = 'card pesado';
            },
            colsDefinitions: <DatatableCol>[
              DatatableCol(key: 'nome', title: 'Nome'),
            ],
          );
      },
    );
    await _settleTable(fixture);

    await fixture.update((component) {
      component.table!.gridMode = true;
    });
    await _settleTable(fixture);

    final host = fixture.assertOnlyInstance;
    expect(host.table!.gridMode, isFalse);
    expect(customCardBuilderCalls, 0);
    expect(fixture.rootElement.querySelector('.datatable-scroll'), isNotNull);
    expect(fixture.rootElement.querySelector('.datatable-grid-scroll'), isNull);
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
    expect(tableContainer, isNull);
    expect(fixture.text, contains('Ana'));
    expect(fixture.text, contains('Bruno'));
  });

  test('desmonta a view inativa ao alternar entre tabela e grid', () async {
    final fixture = await testBed.create();
    await _settleTable(fixture);

    expect(fixture.rootElement.querySelector('.datatable-scroll'), isNotNull);
    expect(fixture.rootElement.querySelector('.datatable-grid-scroll'), isNull);

    await fixture.update((component) {
      component.table!.changeViewMode();
    });
    await _settleTable(fixture);

    expect(fixture.rootElement.querySelector('.datatable-scroll'), isNull);
    expect(
        fixture.rootElement.querySelector('.datatable-grid-scroll'), isNotNull);

    await fixture.update((component) {
      component.table!.changeViewMode();
    });
    await _settleTable(fixture);

    expect(fixture.rootElement.querySelector('.datatable-scroll'), isNotNull);
    expect(fixture.rootElement.querySelector('.datatable-grid-scroll'), isNull);
  });

  test('modo grid padrao nao herda largura fixa das colunas no card', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'nome',
            title: 'Nome',
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

    await fixture.update((component) {
      component.table!.changeViewMode();
    });
    await _settleTable(fixture);

    final firstCardColumn = fixture.rootElement.querySelector(
      '.grid-layout .datatable-grid-default-card__field',
    ) as HtmlElement?;

    expect(firstCardColumn, isNotNull);
    expect(firstCardColumn!.style.width, isEmpty);
    expect(firstCardColumn.style.minWidth, isEmpty);
    expect(firstCardColumn.style.maxWidth, isEmpty);
    expect(firstCardColumn.style.whiteSpace, isEmpty);
    expect(firstCardColumn.style.textAlign, isEmpty);
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

  test('ignora largura esticada anterior ao recalcular auto-hide no resize',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.responsiveAutoHideColumns = true;
      component.tableContainerStyle = 'width: 1200px;';
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'codigo',
            title: 'Codigo',
            responsiveAutoHideRequired: true,
          ),
          DatatableCol(
            key: 'solicitante',
            title: 'Solicitante',
            responsiveAutoHidePriority: 10,
          ),
          DatatableCol(
            key: 'assunto',
            title: 'Assunto',
            responsiveAutoHidePriority: 20,
          ),
          DatatableCol(
            key: 'situacao',
            title: 'Situacao',
            responsiveAutoHidePriority: 30,
          ),
        ],
      );
      component.data = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[
          <String, dynamic>{
            'codigo': '61109/2016',
            'solicitante': 'Nucleo de Governanca',
            'assunto': 'Revisao documental',
            'situacao': 'Em analise',
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

    expect(host.table!.renderedRows.first.hasResponsiveHiddenColumns, isFalse);

    await fixture.update((component) {
      component.tableContainerStyle = 'width: 300px;';
      window.dispatchEvent(Event('resize'));
    });
    await _settleAfterResize(fixture);
    await _settleAfterResize(fixture);

    expect(host.table!.renderedRows.first.hasResponsiveHiddenColumns, isTrue);
    expect(
      host.table!.renderedRows.first.responsiveHiddenColumns
          .map((column) => column.key),
      contains('solicitante'),
    );

    await fixture.update((component) {
      component.tableContainerStyle = 'width: 720px;';
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

  test('renderiza e executa DatatableActionColumn declarativa', () async {
    var triggered = 0;
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableActionColumn(
            key: 'acoes',
            title: 'Ações',
            actions: <DatatableAction>[
              DatatableAction(
                label: 'Abrir',
                iconClass: 'ph ph-eye',
                onTap: (context) {
                  triggered++;
                },
              ),
            ],
          ),
        ],
      );
    });
    await _settleTable(fixture);

    final actionHeader = fixture.rootElement.querySelector(
      'thead th[data-key="acoes"]',
    ) as TableCellElement?;
    final actionButton = fixture.rootElement.querySelector(
      '.datatable-action-cell button',
    ) as ButtonElement?;
    final actionIcon =
        actionButton?.querySelector('i.ph.ph-eye') as HtmlElement?;
    expect(actionHeader, isNotNull);
    expect(actionHeader!.getAttribute('style'), contains('text-align: center'));
    expect(actionButton, isNotNull);
    expect(
      fixture.rootElement.querySelectorAll(
        '[data-li-datatable-action-cell="true"]',
      ),
      hasLength(2),
    );
    expect(
      fixture.rootElement.querySelectorAll('[data-li-datatable-action="true"]'),
      hasLength(2),
    );
    expect(
      actionButton!.getAttribute('data-li-datatable-action'),
      'true',
    );
    expect(actionButton.text, contains('Abrir'));
    expect(actionIcon, isNotNull);
    expect(actionIcon!.classes.contains('me-2'), isTrue);

    await fixture.update((_) {
      actionButton.click();
    });

    expect(triggered, 1);
  });

  test('instrumenta actions no perfil saliPaged sem depender do visual probe',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.searchInFields = <DatatableSearchField>[];
      component.performanceProfile = DatatablePerformanceProfile.saliPaged;
      component.debugInstrumentation = true;
      component.debugInstrumentationLabel = 'sali-actions-regression';
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableActionColumn(
            key: 'acoes',
            title: 'Ações',
            actions: <DatatableAction>[
              DatatableAction(
                label: 'Abrir',
                iconClass: 'ph ph-eye',
                iconOnly: true,
                onTap: (_) {},
              ),
            ],
          ),
        ],
      );
    });
    await _settleTable(fixture);

    final host = fixture.assertOnlyInstance;

    host.instrumentationEvents.clear();
    await fixture.update((component) {
      component.table!.scheduleDraw(
        force: true,
        reason: 'action instrumentation regression',
      );
    });
    await _settleTable(fixture);

    final drawEvents = host.instrumentationEvents
        .where((event) => event.stage == 'draw.finish')
        .toList(growable: false);

    expect(host.table!.isSaliPagedPerformanceProfile, isTrue);
    expect(
      fixture.rootElement.querySelectorAll(
        '[data-li-datatable-action-cell="true"]',
      ),
      hasLength(2),
    );
    expect(
      fixture.rootElement.querySelectorAll('[data-li-datatable-action="true"]'),
      hasLength(2),
    );
    expect(drawEvents, isNotEmpty);
    expect(_maxDetailInt(drawEvents, 'configuredActionColumns'), 1);
    expect(_maxDetailInt(drawEvents, 'actionCells'), 2);
    expect(_maxDetailInt(drawEvents, 'actionElements'), 2);
    expect(_maxDetailInt(drawEvents, 'actionButtons'), 2);
  });

  test('suporta ação com aparência link-icon sem fundo', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableActionColumn(
            key: 'acoes',
            title: 'Ações',
            actions: <DatatableAction>[
              DatatableAction(
                label: 'Favoritar',
                iconClass: 'ph ph-heart',
                appearance: DatatableActionAppearance.linkIcon,
                iconOnly: true,
                onTap: (_) {},
              ),
            ],
          ),
        ],
      );
    });
    await _settleTable(fixture);

    final actionButton = fixture.rootElement.querySelector(
      '.datatable-action-cell button',
    ) as ButtonElement?;
    expect(actionButton, isNotNull);
    expect(
      actionButton!.classes.contains('btn-link'),
      isTrue,
    );
    expect(actionButton.classes.contains('btn-icon'), isTrue);
    expect(
      actionButton.classes.contains('datatable-action-button--icon-only'),
      isTrue,
    );
    expect(actionButton.querySelector('i.ph-heart'), isNotNull);
    expect(actionButton.text?.trim(), isEmpty);
  });

  test('mantem acoes fixas visiveis e envia excedente para dropdown',
      () async {
    var opened = 0;
    var archived = 0;
    var deleted = 0;

    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableActionColumn(
            key: 'acoes',
            title: 'Ações',
            maxVisibleActions: 1,
            actions: <DatatableAction>[
              DatatableAction(
                label: 'Visualizar',
                iconClass: 'ph ph-eye',
                overflowBehavior:
                    DatatableActionOverflowBehavior.alwaysVisible,
                onTap: (_) {
                  opened++;
                },
              ),
              DatatableAction(
                label: 'Arquivar',
                iconClass: 'ph ph-archive-box',
                onTap: (_) {
                  archived++;
                },
              ),
              DatatableAction(
                label: 'Excluir',
                iconClass: 'ph ph-trash',
                overflowBehavior:
                    DatatableActionOverflowBehavior.overflowMenu,
                onTap: (_) {
                  deleted++;
                },
              ),
            ],
          ),
        ],
      );
    });
    await _settleTable(fixture);

    final visibleButton = fixture.rootElement.querySelector(
      '.datatable-action-cell > button[data-li-datatable-action="true"]',
    ) as ButtonElement?;
    final overflowToggle = fixture.rootElement.querySelector(
      '[data-li-datatable-action-overflow-toggle="true"]',
    ) as ButtonElement?;
    expect(visibleButton, isNotNull);
    expect(visibleButton!.text, contains('Visualizar'));
    expect(overflowToggle, isNotNull);

    await fixture.update((_) {
      overflowToggle!.click();
    });
    await _settleTable(fixture);

    final overflowMenu = document.body?.querySelector(
      '[data-li-datatable-action-overflow-menu="true"]',
    ) as HtmlElement?;

    expect(overflowMenu, isNotNull);
    expect(overflowMenu!.classes.contains('show'), isTrue);
    expect(overflowMenu.text, contains('Arquivar'));
    expect(overflowMenu.text, contains('Excluir'));

    final overflowButtons = overflowMenu.querySelectorAll(
      'button[data-li-datatable-action="true"]',
    );
    expect(overflowButtons, hasLength(2));

    await fixture.update((_) {
      (overflowButtons.first as ButtonElement).click();
    });
    await _settleTable(fixture);

    expect(opened, 0);
    expect(archived, 1);
    expect(deleted, 0);
    final closedOverflowMenu = document.body?.querySelector(
      '[data-li-datatable-action-overflow-menu="true"]',
    ) as HtmlElement?;
    expect(closedOverflowMenu, isNotNull);
    expect(closedOverflowMenu!.classes.contains('show'), isFalse);
  });

  test('permite enviar todas as actions para dropdown com maxVisibleActions zero',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableActionColumn(
            key: 'acoes',
            title: 'Ações',
            maxVisibleActions: 0,
            actions: <DatatableAction>[
              DatatableAction(
                label: 'Visualizar',
                iconClass: 'ph ph-eye',
                onTap: (_) {},
              ),
              DatatableAction(
                label: 'Editar',
                iconClass: 'ph ph-pencil',
                onTap: (_) {},
              ),
            ],
          ),
        ],
      );
    });
    await _settleTable(fixture);

    expect(
      fixture.rootElement.querySelector(
        '.datatable-action-cell > button[data-li-datatable-action="true"]',
      ),
      isNull,
    );
    expect(
      fixture.rootElement.querySelector(
        '[data-li-datatable-action-overflow-toggle="true"]',
      ),
      isNotNull,
    );
  });

  test('suporta ação com texto no desktop e ícone no mobile', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableActionColumn(
            key: 'acoes',
            title: 'Ações',
            actions: <DatatableAction>[
              DatatableAction(
                label: 'Abrir',
                iconClass: 'ph ph-eye',
                appearance: DatatableActionAppearance.linkIcon,
                responsiveMode:
                    DatatableActionResponsiveMode.desktopTextMobileIcon,
                onTap: (_) {},
              ),
            ],
          ),
        ],
      );
    });
    await _settleTable(fixture);

    final actionCell = fixture.rootElement.querySelector(
      '.datatable-action-cell',
    ) as HtmlElement?;
    final actionButtons =
        actionCell!.querySelectorAll('button').cast<ButtonElement>();
    final desktopButton = actionButtons.first;
    final mobileButton = actionButtons.last;

    expect(actionButtons, hasLength(2));
    expect(desktopButton.text?.trim(), 'Abrir');
    expect(desktopButton.classes.contains('d-none'), isTrue);
    expect(desktopButton.classes.contains('d-md-inline-flex'), isTrue);
    expect(desktopButton.querySelector('i'), isNull);
    expect(desktopButton.classes.contains('btn-icon'), isFalse);

    expect(mobileButton.text?.trim(), isEmpty);
    expect(mobileButton.classes.contains('btn-icon'), isTrue);
    expect(mobileButton.classes.contains('d-inline-flex'), isTrue);
    expect(mobileButton.classes.contains('d-md-none'), isTrue);
    expect(mobileButton.querySelector('i.ph.ph-eye'), isNotNull);
  });

  test('suporta ação com ícone e texto no desktop e só ícone no mobile',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableActionColumn(
            key: 'acoes',
            title: 'Ações',
            actions: <DatatableAction>[
              DatatableAction(
                label: 'Abrir',
                iconClass: 'ph ph-eye',
                appearance: DatatableActionAppearance.linkIcon,
                responsiveMode:
                    DatatableActionResponsiveMode.desktopTextAndIconMobileIcon,
                onTap: (_) {},
              ),
            ],
          ),
        ],
      );
    });
    await _settleTable(fixture);

    final actionCell = fixture.rootElement.querySelector(
      '.datatable-action-cell',
    ) as HtmlElement?;
    final actionButtons =
        actionCell!.querySelectorAll('button').cast<ButtonElement>();
    final desktopButton = actionButtons.first;
    final mobileButton = actionButtons.last;
    final desktopIcon =
        desktopButton.querySelector('i.ph.ph-eye') as HtmlElement?;
    final mobileIcon =
        mobileButton.querySelector('i.ph.ph-eye') as HtmlElement?;

    expect(actionButtons, hasLength(2));
    expect(desktopButton.text?.trim(), 'Abrir');
    expect(desktopButton.classes.contains('d-none'), isTrue);
    expect(desktopButton.classes.contains('d-md-inline-flex'), isTrue);
    expect(desktopButton.classes.contains('btn-icon'), isFalse);
    expect(desktopIcon, isNotNull);
    expect(desktopIcon!.classes.contains('me-2'), isTrue);

    expect(mobileButton.text?.trim(), isEmpty);
    expect(mobileButton.classes.contains('btn-icon'), isTrue);
    expect(mobileButton.classes.contains('d-inline-flex'), isTrue);
    expect(mobileButton.classes.contains('d-md-none'), isTrue);
    expect(mobileIcon, isNotNull);
  });

  test('aplica size sm nas actions responsivas de desktop e mobile', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableActionColumn(
            key: 'acoes',
            title: 'Ações',
            actions: <DatatableAction>[
              DatatableAction(
                label: 'Abrir',
                iconClass: 'ph ph-eye',
                appearance: DatatableActionAppearance.linkIcon,
                size: 'sm',
                responsiveMode:
                    DatatableActionResponsiveMode.desktopTextAndIconMobileIcon,
                onTap: (_) {},
              ),
            ],
          ),
        ],
      );
    });
    await _settleTable(fixture);

    final actionCell = fixture.rootElement.querySelector(
      '.datatable-action-cell',
    ) as HtmlElement?;
    final actionButtons =
        actionCell!.querySelectorAll('button').cast<ButtonElement>();

    expect(actionButtons, hasLength(2));
    expect(actionButtons.first.classes.contains('btn-sm'), isTrue);
    expect(actionButtons.last.classes.contains('btn-sm'), isTrue);
  });

  test('permite atualizar DatatableActionColumn via controller', () async {
    final controller = DatatableActionController(
      actions: <DatatableAction>[
        DatatableAction(
          label: 'Visualizar',
          onTap: (_) {},
        ),
      ],
    );

    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableActionColumn(
            key: 'acoes',
            title: 'Ações',
            controller: controller,
          ),
        ],
      );
    });
    await _settleTable(fixture);

    var actionButton = fixture.rootElement.querySelector(
      '.datatable-action-cell button',
    ) as ButtonElement?;
    expect(actionButton, isNotNull);
    expect(actionButton!.text, contains('Visualizar'));

    await fixture.update((component) {
      controller.setActions(<DatatableAction>[
        DatatableAction(
          label: 'Editar',
          onTap: (_) {},
        ),
      ]);
      component.table!.update();
    });
    await _settleTable(fixture);

    actionButton = fixture.rootElement.querySelector(
      '.datatable-action-cell button',
    ) as ButtonElement?;
    expect(actionButton, isNotNull);
    expect(actionButton!.text, contains('Editar'));
  });

  test('virtualiza a tabela renderizando apenas a janela visivel', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.virtualScroll = true;
      component.virtualRowHeight = 40;
      component.virtualOverscan = 2;
      component.virtualViewportHeight = '200px';
      component.searchInFields = <DatatableSearchField>[];
      component.data = DataFrame<Map<String, dynamic>>(
        items: List<Map<String, dynamic>>.generate(
          200,
          (index) => <String, dynamic>{
            'nome': 'Pessoa $index',
            'idade': 20 + (index % 50),
          },
        ),
        totalRecords: 200,
      );
    });
    await _settleTable(fixture);
    await _settleTable(fixture);

    final host = fixture.assertOnlyInstance;
    final bodyRows = fixture.rootElement.querySelectorAll('tbody > tr');

    expect(host.table!.rows.length, lessThan(20));
    expect(bodyRows.length, lessThan(24));
    expect(host.table!.rows.first.index, 0);

    final scrollContainer = fixture.rootElement.querySelector(
      '.datatable-scroll',
    ) as HtmlElement?;
    expect(scrollContainer, isNotNull);

    scrollContainer!.scrollTop = 1200;
    scrollContainer.dispatchEvent(Event('scroll'));
    await _settleAfterScroll(fixture);

    expect(host.table!.rows.first.index, greaterThan(0));
    expect(host.table!.rows.length, lessThan(20));
  });

  test('perfil saliPaged ignora virtual scroll e responsividade rica',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.performanceProfile = DatatablePerformanceProfile.saliPaged;
      component.virtualScroll = true;
      component.responsiveAutoHideColumns = true;
      component.responsiveCollapse = true;
      component.responsiveCollapseByContainer = true;
      component.tableContainerStyle = 'width: 260px;';
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(
            key: 'nome',
            title: 'Nome',
            sortingBy: 'nome',
            enableSorting: true,
          ),
          DatatableCol(
            key: 'digitalLabel',
            title: 'Digital',
            sortingBy: 'digitalOrder',
            enableSorting: true,
            headerStyleCss: 'width: 90px; min-width: 90px; text-align: center;',
          ),
        ],
      );
      component.data = DataFrame<Map<String, dynamic>>(
        items: List<Map<String, dynamic>>.generate(
          30,
          (index) => <String, dynamic>{
            'nome': 'Pessoa $index',
            'idade': 20 + (index % 50),
            'digitalLabel': index.isEven ? 'Sim' : 'Nao',
            'digitalOrder': index.isEven ? 1 : 0,
          },
        ),
        totalRecords: 30,
      );
    });
    await _settleTable(fixture);
    await _settleTable(fixture);

    final host = fixture.assertOnlyInstance;
    final scrollContainer = fixture.rootElement.querySelector(
      '.datatable-scroll',
    ) as HtmlElement?;
    final table = fixture.rootElement.querySelector(
      'table.dataTable',
    ) as HtmlElement?;
    final sortingHeader = fixture.rootElement.querySelector(
      'table.datatable-fast-table thead th.sorting[data-key="digitalLabel"]',
    ) as HtmlElement?;

    expect(host.table!.isVirtualScrollActive, isFalse);
    expect(host.table!.hasResponsiveCollapsedColumns, isFalse);
    expect(host.table!.rows, hasLength(30));
    expect(scrollContainer, isNotNull);
    expect(scrollContainer!.classes.contains('datatable-scroll--virtual'),
        isFalse);
    expect(table, isNotNull);
    expect(table!.classes.contains('datatable-fast-table'), isTrue);
    expect(table.classes.contains('datatable-table-layout-fixed'), isFalse);
    expect(table.getComputedStyle().getPropertyValue('table-layout'), 'auto');
    expect(sortingHeader, isNotNull);

    final titleShell = sortingHeader!.querySelector(
      '.datatable-header-title-shell',
    ) as HtmlElement?;
    final titleContent = sortingHeader.querySelector(
      '.datatable-header-title-content',
    ) as HtmlElement?;
    expect(titleShell, isNotNull);
    expect(titleContent, isNotNull);

    final paddingRight = double.tryParse(
          sortingHeader.getComputedStyle().paddingRight.replaceAll('px', ''),
        ) ??
        0;

    expect(paddingRight, greaterThanOrEqualTo(30));
    expect(titleShell!.getComputedStyle().display, isNot('block'));
    expect(titleContent!.getComputedStyle().overflow, isNot('hidden'));

    await fixture.update((component) {
      component.fixedTableLayout = true;
    });
    await _settleTable(fixture);

    final fixedTable = fixture.rootElement.querySelector(
      'table.datatable-fast-table',
    ) as HtmlElement?;
    final fixedSortingHeader = fixture.rootElement.querySelector(
      'table.datatable-table-layout-fixed thead th.sorting[data-key="digitalLabel"]',
    ) as HtmlElement?;
    expect(fixedSortingHeader, isNotNull);

    final fixedTitleShell = fixedSortingHeader!.querySelector(
      '.datatable-header-title-shell',
    ) as HtmlElement?;
    final fixedTitleContent = fixedSortingHeader.querySelector(
      '.datatable-header-title-content',
    ) as HtmlElement?;
    final fixedHeaderRect = fixedSortingHeader.getBoundingClientRect();
    final fixedShellRect = fixedTitleShell!.getBoundingClientRect();

    expect(fixedTable, isNotNull);
    expect(
        fixedTable!.classes.contains('datatable-table-layout-fixed'), isTrue);
    expect(fixedTable.getComputedStyle().getPropertyValue('table-layout'),
        'fixed');
    expect(fixedTitleShell.getComputedStyle().display, 'block');
    expect(fixedTitleContent!.getComputedStyle().overflow, 'hidden');
    expect(fixedShellRect.right, lessThanOrEqualTo(fixedHeaderRect.right - 20));
  });

  test('mantem selecao virtual por rowKeyResolver apos reordenar dados',
      () async {
    late final List<Map<String, dynamic>> items;
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.virtualScroll = true;
      component.virtualRowHeight = 40;
      component.virtualOverscan = 2;
      component.virtualViewportHeight = '200px';
      component.searchInFields = <DatatableSearchField>[];
      component.settings = DatatableSettings(
        colsDefinitions: <DatatableCol>[
          DatatableCol(key: 'nome', title: 'Nome'),
          DatatableCol(key: 'idade', title: 'Idade'),
        ],
        rowKeyResolver: (itemMap, _, index) => itemMap['id'] ?? index,
      );
      items = List<Map<String, dynamic>>.generate(
        80,
        (index) => <String, dynamic>{
          'id': index,
          'nome': 'Pessoa $index',
          'idade': 20 + (index % 50),
        },
      );
      component.data = DataFrame<Map<String, dynamic>>(
        items: items,
        totalRecords: items.length,
      );
    });
    await _settleTable(fixture);
    await _settleTable(fixture);

    final host = fixture.assertOnlyInstance;

    await fixture.update((component) {
      component.table!.onSelect(MouseEvent('click'), component.table!.rows[0]);
    });

    expect(
      host.table!.getAllSelected<Map<String, dynamic>>().single['id'],
      0,
    );

    await fixture.update((component) {
      component.data = DataFrame<Map<String, dynamic>>(
        items: items.reversed.toList(growable: false),
        totalRecords: items.length,
      );
    });
    await _settleTable(fixture);
    await _settleTable(fixture);

    final selected = host.table!.getAllSelected<Map<String, dynamic>>();
    expect(selected, hasLength(1));
    expect(selected.single['id'], 0);
  });

  test('permite fixar o header quando virtual scroll esta ativo', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.virtualScroll = true;
      component.stickyTableHeaderOnVirtualScroll = true;
      component.virtualRowHeight = 40;
      component.virtualOverscan = 2;
      component.virtualViewportHeight = '200px';
      component.searchInFields = <DatatableSearchField>[];
      component.data = DataFrame<Map<String, dynamic>>(
        items: List<Map<String, dynamic>>.generate(
          80,
          (index) => <String, dynamic>{
            'nome': 'Pessoa $index',
            'idade': 20 + (index % 50),
          },
        ),
        totalRecords: 80,
      );
    });
    await _settleTable(fixture);
    await _settleTable(fixture);

    final scrollContainer = fixture.rootElement.querySelector(
      '.datatable-scroll',
    ) as HtmlElement?;
    final headerCell = fixture.rootElement.querySelector(
      'thead th[data-key="nome"]',
    ) as HtmlElement?;

    expect(scrollContainer, isNotNull);
    expect(
      scrollContainer!.classes.contains('datatable-scroll--sticky-header'),
      isTrue,
    );
    expect(headerCell, isNotNull);
    expect(headerCell!.getComputedStyle().position, 'sticky');
    expect(headerCell.getComputedStyle().top, '0px');
  });

  test('mantem a janela virtual estavel quando o scroll chega ao fim',
      () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.virtualScroll = true;
      component.virtualRowHeight = 40;
      component.virtualOverscan = 2;
      component.virtualViewportHeight = '200px';
      component.searchInFields = <DatatableSearchField>[];
      component.data = DataFrame<Map<String, dynamic>>(
        items: List<Map<String, dynamic>>.generate(
          50,
          (index) => <String, dynamic>{
            'nome': 'Pessoa $index',
            'idade': 20 + (index % 50),
          },
        ),
        totalRecords: 50,
      );
    });
    await _settleTable(fixture);
    await _settleTable(fixture);

    final host = fixture.assertOnlyInstance;
    final scrollContainer = fixture.rootElement.querySelector(
      '.datatable-scroll',
    ) as HtmlElement?;

    expect(scrollContainer, isNotNull);

    scrollContainer!.scrollTop = 999999;
    scrollContainer.dispatchEvent(Event('scroll'));
    await _settleAfterScroll(fixture);
    await _settleAfterScroll(fixture);

    final firstIndexAtBottom = host.table!.rows.first.index;
    final lastIndexAtBottom = host.table!.rows.last.index;
    final rowCountAtBottom = host.table!.rows.length;

    await _settleAfterScroll(fixture);
    await _settleAfterScroll(fixture);

    expect(host.table!.rows.first.index, firstIndexAtBottom);
    expect(host.table!.rows.last.index, lastIndexAtBottom);
    expect(host.table!.rows.length, rowCountAtBottom);
    expect(lastIndexAtBottom, 49);
  });

  test('virtualiza o grid renderizando apenas a janela visivel', () async {
    final fixture = await testBed.create(beforeChangeDetection: (component) {
      component.virtualScroll = true;
      component.virtualOverscan = 1;
      component.virtualViewportHeight = '220px';
      component.virtualGridItemHeight = 140;
      component.virtualGridMinItemWidth = 280;
      component.tableContainerStyle = 'width: 960px;';
      component.searchInFields = <DatatableSearchField>[];
      component.data = DataFrame<Map<String, dynamic>>(
        items: List<Map<String, dynamic>>.generate(
          200,
          (index) => <String, dynamic>{
            'nome': 'Pessoa $index',
            'idade': 20 + (index % 50),
          },
        ),
        totalRecords: 200,
      );
    });
    await _settleTable(fixture);

    await fixture.update((component) {
      component.table!.changeViewMode();
    });
    await _settleTable(fixture);
    await _settleTable(fixture);

    final host = fixture.assertOnlyInstance;
    final gridItems =
        fixture.rootElement.querySelectorAll('.grid-layout .grid-item');
    final gridScrollContainer = fixture.rootElement.querySelector(
      '.datatable-grid-scroll',
    ) as HtmlElement?;

    expect(fixture.rootElement.querySelector('.datatable-scroll'), isNull);
    expect(gridScrollContainer, isNotNull);
    expect(host.table!.rows.length, lessThan(20));
    expect(gridItems.length, lessThan(20));
    expect(host.table!.rows.first.index, 0);

    gridScrollContainer!.scrollTop = 1000;
    gridScrollContainer.dispatchEvent(Event('scroll'));
    await _settleAfterScroll(fixture);

    expect(host.table!.rows.first.index, greaterThan(0));
    expect(host.table!.rows.length, lessThan(20));
  });
}

int _maxDetailInt(
  Iterable<LiDatatableInstrumentationEvent> events,
  String key,
) {
  final values = events
      .map((event) => event.details[key])
      .whereType<int>()
      .toList(growable: false);
  if (values.isEmpty) {
    return 0;
  }
  values.sort();
  return values.last;
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

Future<void> _settleAfterScroll(
    NgTestFixture<TestHostComponent> fixture) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  await fixture.update((_) {});
}
