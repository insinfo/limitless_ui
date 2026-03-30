import 'dart:html';

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

import 'datatable_demo_service.dart';

@Component(
  selector: 'datatable-page',
  templateUrl: 'datatable_page.html',
  styleUrls: ['datatable_page.css'],
  directives: [
    coreDirectives,
    LiAccordionComponent,
    LiAccordionBodyDirective,
    LiAccordionItemComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiDataTableComponent,
  ],
)
class DatatablePageComponent implements OnInit {
  DatatablePageComponent(this.i18n)
      : _datatableDemoService = DatatableDemoService(_buildSeedRecords(i18n.t)) {
    tableData = DataFrame<Map<String, dynamic>>(items: <Map<String, dynamic>>[], totalRecords: 0);
    readonlyTableData = DataFrame<Map<String, dynamic>>(items: <Map<String, dynamic>>[], totalRecords: 0);
    gridPreviewTableData = DataFrame<Map<String, dynamic>>(items: <Map<String, dynamic>>[], totalRecords: 0);
    customTableData = DataFrame<Map<String, dynamic>>(items: <Map<String, dynamic>>[], totalRecords: 0);
    customGridData = DataFrame<Map<String, dynamic>>(items: <Map<String, dynamic>>[], totalRecords: 0);

    tableSettings = DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'feature',
          title: t.pages.datatable.featureCol,
          enableSorting: true,
          sortingBy: 'feature',
        ),
        DatatableCol(
          key: 'owner',
          title: t.pages.datatable.ownerCol,
          enableSorting: true,
          sortingBy: 'owner',
          hideOnMobile: true,
        ),
        DatatableCol(
          key: 'status',
          title: t.pages.datatable.statusCol,
          enableSorting: true,
          sortingBy: 'status',
          hideOnMobile: true,
        ),
        DatatableCol(
          key: 'health',
          title: t.pages.datatable.healthCol,
          hideOnMobile: true,
        ),
      ],
    );

    advancedTableSettings = DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'feature',
          title: 'Funcionalidade',
          enableSorting: true,
          sortingBy: 'feature',
          width: '260px',
          minWidth: '260px',
          nowrap: true,
          headerClass: 'datatable-doc-col-feature',
        ),
        DatatableCol(
          key: 'owner',
          title: 'Responsável',
          minWidth: '180px',
          hideOnMobile: true,
        ),
        DatatableCol(
          key: 'status',
          title: 'Status',
          width: '160px',
          minWidth: '160px',
          textAlign: 'center',
          nowrap: true,
          cellClass: 'datatable-doc-cell-emphasis',
          cellStyleResolver: _statusCellStyleResolver,
        ),
        DatatableCol(
          key: 'health',
          title: 'Saúde',
          width: '140px',
          textAlign: 'center',
          cellStyleResolver: _healthCellStyleResolver,
        ),
      ],
    );

    advancedGridSettings = DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'feature',
          title: 'Funcionalidade',
          width: '240px',
          minWidth: '240px',
          nowrap: true,
        ),
        DatatableCol(key: 'owner', title: 'Responsável'),
        DatatableCol(key: 'status', title: 'Status'),
        DatatableCol(key: 'health', title: 'Saúde'),
      ],
      gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
      gridGap: '1rem',
      customCardBuilder: _buildCustomCard,
    );

    searchFields = <DatatableSearchField>[
      DatatableSearchField(
        label: t.pages.datatable.featureCol,
        field: 'feature',
        operator: 'like',
      ),
      DatatableSearchField(
        label: t.pages.datatable.ownerCol,
        field: 'owner',
        operator: 'like',
      ),
      DatatableSearchField(
        label: t.pages.datatable.statusCol,
        field: 'status',
        operator: '=',
      ),
    ];

    initialEventLog = t.pages.datatable.ready;
  }

  final DemoI18nService i18n;
  final DatatableDemoService _datatableDemoService;
  Messages get t => i18n.t;

  @override
  Future<void> ngOnInit() async {
    await _loadMainTable();
  }

  @ViewChild('demoTable')
  LiDataTableComponent? demoTable;

  final Filters filters = Filters(limit: 5, offset: 0);
  final Filters readonlyFilters = Filters(limit: 3, offset: 0);
  final Filters gridPreviewFilters = Filters(limit: 4, offset: 0);
  final Filters customTableFilters = Filters(limit: 4, offset: 0);
  final Filters customGridFilters = Filters(limit: 4, offset: 0);
  bool showReadonlyDemo = false;
  bool showGridPreviewDemo = false;
  bool showCustomTableDemo = false;
  bool showCustomGridDemo = false;
  bool datatableGridMode = false;
  bool singleSelectionOnly = false;
  String datatableEventLog = '';
  late DataFrame<Map<String, dynamic>> tableData;
  late DataFrame<Map<String, dynamic>> readonlyTableData;
  late DataFrame<Map<String, dynamic>> gridPreviewTableData;
  late DataFrame<Map<String, dynamic>> customTableData;
  late DataFrame<Map<String, dynamic>> customGridData;
  late final DatatableSettings tableSettings;
  late final DatatableSettings advancedTableSettings;
  late final DatatableSettings advancedGridSettings;
  late final List<DatatableSearchField> searchFields;
  late final String initialEventLog;

  List<DatatableSearchField> get readonlySearchFields => searchFields;

  Future<void> onTableRequest(Filters nextFilters) async {
    filters.fillFromFilters(nextFilters);
    await _loadMainTable();
  }

  void toggleGridMode() {
    datatableGridMode = !datatableGridMode;
    datatableEventLog = datatableGridMode
        ? t.pages.datatable.gridMode
        : t.pages.datatable.tableMode;
  }

  void toggleSingleSelection() {
    singleSelectionOnly = !singleSelectionOnly;
    datatableEventLog = singleSelectionOnly
        ? t.pages.datatable.singleMode
        : t.pages.datatable.multiMode;
  }

  void exportXlsx() {
    demoTable?.exportXlsx();
    datatableEventLog = t.pages.datatable.exportXlsx;
  }

  Future<void> exportPdf() async {
    await demoTable?.exportPdf(false, true);
    datatableEventLog = t.pages.datatable.exportPdf;
  }

  void onRowClick(dynamic row) {
    final map = row as Map<String, dynamic>;
    datatableEventLog = t.pages.datatable.rowClicked(map['feature'].toString());
  }

  void onSelectionChange(List<dynamic> selectedRows) {
    datatableEventLog = t.pages.datatable.selectedItems(selectedRows.length);
  }

  Future<void> onReadonlyDemoExpanded(bool expanded) async {
    showReadonlyDemo = expanded;
    if (expanded) {
      await _loadReadonlyTable();
    }
  }

  Future<void> onGridPreviewDemoExpanded(bool expanded) async {
    showGridPreviewDemo = expanded;
    if (expanded) {
      await _loadGridPreviewTable();
    }
  }

  Future<void> onCustomTableDemoExpanded(bool expanded) async {
    showCustomTableDemo = expanded;
    if (expanded) {
      await _loadCustomTable();
    }
  }

  Future<void> onCustomGridDemoExpanded(bool expanded) async {
    showCustomGridDemo = expanded;
    if (expanded) {
      await _loadCustomGrid();
    }
  }

  Future<void> onReadonlyTableRequest(Filters nextFilters) async {
    readonlyFilters.fillFromFilters(nextFilters);
    await _loadReadonlyTable();
  }

  Future<void> onGridPreviewTableRequest(Filters nextFilters) async {
    gridPreviewFilters.fillFromFilters(nextFilters);
    await _loadGridPreviewTable();
  }

  Future<void> onCustomTableRequest(Filters nextFilters) async {
    customTableFilters.fillFromFilters(nextFilters);
    await _loadCustomTable();
  }

  Future<void> onCustomGridRequest(Filters nextFilters) async {
    customGridFilters.fillFromFilters(nextFilters);
    await _loadCustomGrid();
  }

  Future<void> _loadMainTable() async {
    demoTable?.showLoading();
    try {
      tableData = await _datatableDemoService.query(filters);
    } finally {
      demoTable?.hideLoading();
    }
  }

  Future<void> _loadReadonlyTable() async {
    readonlyTableData = await _datatableDemoService.query(readonlyFilters);
  }

  Future<void> _loadGridPreviewTable() async {
    gridPreviewTableData = await _datatableDemoService.query(gridPreviewFilters);
  }

  Future<void> _loadCustomTable() async {
    customTableData = await _datatableDemoService.query(customTableFilters);
  }

  Future<void> _loadCustomGrid() async {
    customGridData = await _datatableDemoService.query(customGridFilters);
  }

  static List<Map<String, dynamic>> _buildSeedRecords(Messages t) {
    final features = <String>[
      t.pages.datatable.featureRow1,
      t.pages.datatable.featureRow2,
      t.pages.datatable.featureRow3,
      t.pages.datatable.featureRow4,
      'Sincronizar cadastro com ERP',
      'Publicar relatório operacional',
      'Revisar fila de integração',
      'Atualizar painel de atendimento',
    ];
    final owners = <String>[
      t.pages.datatable.ownerProduct,
      t.pages.datatable.ownerBackoffice,
      t.pages.datatable.ownerOperations,
      t.pages.datatable.ownerInfra,
      'Financeiro',
      'Atendimento',
    ];
    final statuses = <String>[
      t.pages.datatable.statusInProgress,
      t.pages.datatable.statusDone,
      t.pages.datatable.statusPlanned,
      t.pages.datatable.statusBlocked,
    ];
    final healths = <String>[
      t.pages.datatable.healthWarning,
      t.pages.datatable.healthOk,
      t.pages.datatable.healthCritical,
    ];

    final records = <Map<String, dynamic>>[];
    for (var index = 0; index < 36; index++) {
      records.add(<String, dynamic>{
        'id': index + 1,
        'feature': '${features[index % features.length]} ${index + 1}',
        'owner': owners[index % owners.length],
        'status': statuses[index % statuses.length],
        'health': healths[index % healths.length],
      });
    }
    return records;
  }

  String? _statusCellStyleResolver(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    final color = _statusColor(itemMap['status']?.toString() ?? '');
    return 'color: $color; font-weight: 700; letter-spacing: .01em;';
  }

  String? _healthCellStyleResolver(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    final color = _healthColor(itemMap['health']?.toString() ?? '');
    return 'color: $color; font-weight: 600;';
  }

  Element _buildCustomCard(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
    DatatableRow row,
  ) {
    final root = DivElement()..classes.add('datatable-api-card');

    final eyebrow = SpanElement()
      ..classes.add('datatable-api-card__eyebrow')
      ..text = 'CustomCardBuilder';

    final title = HeadingElement.h6()
      ..classes.add('datatable-api-card__title')
      ..text = itemMap['feature']?.toString() ?? '';

    final owner = DivElement()
      ..classes.add('datatable-api-card__meta')
      ..text = 'Responsável: ${itemMap['owner']}';

    final badgeRow = DivElement()..classes.add('datatable-api-card__badges');

    final statusBadge = SpanElement()
      ..classes.addAll(<String>[
        'datatable-api-card__badge',
        _statusBadgeClass(itemMap['status']?.toString() ?? ''),
      ])
      ..text = itemMap['status']?.toString() ?? '';

    final healthBadge = SpanElement()
      ..classes.addAll(<String>[
        'datatable-api-card__badge',
        _healthBadgeClass(itemMap['health']?.toString() ?? ''),
      ])
      ..text = itemMap['health']?.toString() ?? '';

    final summary = ParagraphElement()
      ..classes.add('datatable-api-card__summary')
      ..text = 'O card foi montado manualmente para combinar título, estado e metadados sem depender do layout padrão.';

    badgeRow.children.addAll(<Element>[statusBadge, healthBadge]);
    root.children.addAll(<Element>[eyebrow, title, owner, badgeRow, summary]);

    return root;
  }

  String _statusColor(String status) {
    switch (status) {
      case 'Concluído':
        return '#0f766e';
      case 'Bloqueado':
        return '#b91c1c';
      case 'Planejado':
        return '#1d4ed8';
      case 'Em andamento':
        return '#b45309';
      default:
        return '#334155';
    }
  }

  String _healthColor(String health) {
    switch (health) {
      case 'Crítica':
        return '#b91c1c';
      case 'Atenção':
        return '#b45309';
      case 'Saudável':
        return '#0f766e';
      default:
        return '#334155';
    }
  }

  String _statusBadgeClass(String status) {
    switch (status) {
      case 'Concluído':
        return 'datatable-api-card__badge--success';
      case 'Bloqueado':
        return 'datatable-api-card__badge--danger';
      case 'Planejado':
        return 'datatable-api-card__badge--info';
      case 'Em andamento':
        return 'datatable-api-card__badge--warning';
      default:
        return 'datatable-api-card__badge--muted';
    }
  }

  String _healthBadgeClass(String health) {
    switch (health) {
      case 'Crítica':
        return 'datatable-api-card__badge--danger';
      case 'Atenção':
        return 'datatable-api-card__badge--warning';
      case 'Saudável':
        return 'datatable-api-card__badge--success';
      default:
        return 'datatable-api-card__badge--muted';
    }
  }
}
