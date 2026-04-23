import 'dart:html';

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/messages_en.i18n.dart' as en;
import 'package:limitless_ui_example/limitless_ui_example.dart';

import 'datatable_demo_service.dart';

@Component(
  selector: 'datatable-page',
  templateUrl: 'datatable_page.html',
  styleUrls: ['datatable_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DemoPageBreadcrumbComponent,
    LiAccordionComponent,
    LiAccordionBodyDirective,
    LiAccordionItemComponent,
    LiDatatableHeaderDirective,
    LiHighlightComponent,
    LiModalComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiDataTableComponent,
  ],
)
class DatatablePageComponent implements OnInit {
  DatatablePageComponent(this.i18n, this._changeDetectorRef)
      : _datatableDemoServicePt =
            DatatableDemoService(_buildSeedRecords(Messages())),
        _datatableDemoServiceEn =
            DatatableDemoService(_buildSeedRecords(en.MessagesEn())),
        _groupedDemoService = DatatableDemoService(_buildGroupedSeedRecords()),
        _multiSortDemoService =
            DatatableDemoService(_buildMultiSortSeedRecords()),
        _stickyColumnsDemoService =
            DatatableDemoService(_buildStickyColumnsSeedRecords()) {
    tableData = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[], totalRecords: 0);
    readonlyTableData = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[], totalRecords: 0);
    gridPreviewTableData = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[], totalRecords: 0);
    customTableData = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[], totalRecords: 0);
    customGridData = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[], totalRecords: 0);
    modalTableData = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[], totalRecords: 0);
    processLookupTableData = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[], totalRecords: 0);
    groupedTableData = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[], totalRecords: 0);
    multiSortTableData = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[], totalRecords: 0);
    stickyColumnsTableData = DataFrame<Map<String, dynamic>>(
        items: <Map<String, dynamic>>[], totalRecords: 0);

    _tableSettingsPt = _buildTableSettings(Messages());
    _tableSettingsEn = _buildTableSettings(en.MessagesEn());
    _advancedTableSettingsPt = _buildAdvancedTableSettings(Messages());
    _advancedTableSettingsEn = _buildAdvancedTableSettings(en.MessagesEn());
    _advancedGridSettingsPt = _buildAdvancedGridSettings(Messages());
    _advancedGridSettingsEn = _buildAdvancedGridSettings(en.MessagesEn());
    _processLookupTableSettings = _buildProcessLookupTableSettings();
    _groupedTableSettings = _buildGroupedTableSettings();
    _multiSortTableSettings = _buildMultiSortTableSettings();
    _stickyColumnsTableSettingsPt = _buildStickyColumnsTableSettings(true);
    _stickyColumnsTableSettingsEn = _buildStickyColumnsTableSettings(false);
    _searchFieldsPt = _buildSearchFields(Messages());
    _searchFieldsEn = _buildSearchFields(en.MessagesEn());
    _processLookupSearchFields = _buildProcessLookupSearchFields();
    _groupedSearchFields = _buildGroupedSearchFields();
    _multiSortSearchFields = _buildMultiSortSearchFields();
    _stickyColumnsSearchFieldsPt = _buildStickyColumnsSearchFields(true);
    _stickyColumnsSearchFieldsEn = _buildStickyColumnsSearchFields(false);
    multiSortFilters.setOrderFields(_buildDefaultMultiSortOrderFields());
  }

  final DemoI18nService i18n;
  final ChangeDetectorRef _changeDetectorRef;
  final DatatableDemoService _datatableDemoServicePt;
  final DatatableDemoService _datatableDemoServiceEn;
  final DatatableDemoService _groupedDemoService;
  final DatatableDemoService _multiSortDemoService;
  final DatatableDemoService _stickyColumnsDemoService;
  Messages get t => i18n.t;

  late final DatatableSettings _tableSettingsPt;
  late final DatatableSettings _tableSettingsEn;
  late final DatatableSettings _advancedTableSettingsPt;
  late final DatatableSettings _advancedTableSettingsEn;
  late final DatatableSettings _advancedGridSettingsPt;
  late final DatatableSettings _advancedGridSettingsEn;
  late final DatatableSettings _processLookupTableSettings;
  late final DatatableSettings _groupedTableSettings;
  late final DatatableSettings _multiSortTableSettings;
  late final DatatableSettings _stickyColumnsTableSettingsPt;
  late final DatatableSettings _stickyColumnsTableSettingsEn;
  late final List<DatatableSearchField> _searchFieldsPt;
  late final List<DatatableSearchField> _searchFieldsEn;
  late final List<DatatableSearchField> _processLookupSearchFields;
  late final List<DatatableSearchField> _groupedSearchFields;
  late final List<DatatableSearchField> _multiSortSearchFields;
  late final List<DatatableSearchField> _stickyColumnsSearchFieldsPt;
  late final List<DatatableSearchField> _stickyColumnsSearchFieldsEn;

  DatatableSettings get tableSettings =>
      i18n.isPortuguese ? _tableSettingsPt : _tableSettingsEn;

  DatatableSettings get advancedTableSettings =>
      i18n.isPortuguese ? _advancedTableSettingsPt : _advancedTableSettingsEn;

  DatatableSettings get advancedGridSettings =>
      i18n.isPortuguese ? _advancedGridSettingsPt : _advancedGridSettingsEn;

  DatatableSettings get groupedTableSettings => _groupedTableSettings;

  DatatableSettings get multiSortTableSettings => _multiSortTableSettings;

  DatatableSettings get processLookupTableSettings =>
      _processLookupTableSettings;

  DatatableSettings get stickyColumnsTableSettings => i18n.isPortuguese
      ? _stickyColumnsTableSettingsPt
      : _stickyColumnsTableSettingsEn;

  List<DatatableSearchField> get searchFields =>
      i18n.isPortuguese ? _searchFieldsPt : _searchFieldsEn;

  List<DatatableSearchField> get groupedSearchFields => _groupedSearchFields;

  List<DatatableSearchField> get multiSortSearchFields =>
      _multiSortSearchFields;

  List<DatatableSearchField> get processLookupSearchFields =>
      _processLookupSearchFields;

  List<DatatableSearchField> get stickyColumnsSearchFields => i18n.isPortuguese
      ? _stickyColumnsSearchFieldsPt
      : _stickyColumnsSearchFieldsEn;

  DatatableDemoService get _datatableDemoService =>
      i18n.isPortuguese ? _datatableDemoServicePt : _datatableDemoServiceEn;

  DatatableSettings _buildTableSettings(dynamic t) {
    return DatatableSettings(
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
  }

  DatatableSettings _buildAdvancedTableSettings(dynamic t) {
    return DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'feature',
          title: t.pages.datatable.featureCol,
          enableSorting: true,
          sortingBy: 'feature',
          width: '260px',
          minWidth: '260px',
          nowrap: true,
          headerClass: 'datatable-doc-col-feature',
        ),
        DatatableCol(
          key: 'owner',
          title: t.pages.datatable.ownerCol,
          minWidth: '180px',
          hideOnMobile: true,
        ),
        DatatableCol(
          key: 'status',
          title: t.pages.datatable.statusCol,
          width: '160px',
          minWidth: '160px',
          textAlign: 'center',
          nowrap: true,
          cellClass: 'datatable-doc-cell-emphasis',
          cellStyleResolver: _statusCellStyleResolver,
        ),
        DatatableCol(
          key: 'health',
          title: t.pages.datatable.healthCol,
          width: '140px',
          textAlign: 'center',
          cellStyleResolver: _healthCellStyleResolver,
        ),
      ],
      rowStyleResolver: _advancedRowStyleResolver,
    );
  }

  DatatableSettings _buildAdvancedGridSettings(dynamic t) {
    return DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'feature',
          title: t.pages.datatable.featureCol,
          width: '240px',
          minWidth: '240px',
          nowrap: true,
        ),
        DatatableCol(key: 'owner', title: t.pages.datatable.ownerCol),
        DatatableCol(key: 'status', title: t.pages.datatable.statusCol),
        DatatableCol(key: 'health', title: t.pages.datatable.healthCol),
      ],
      gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
      gridGap: '1.25rem',
      gridContainerStyle: 'background: #fff; padding: .75rem 0 .5rem;',
      customCardBuilder: _buildCustomCard,
    );
  }

  DatatableSettings _buildGroupedTableSettings() {
    return DatatableSettings(
      enableGrouping: true,
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'groupLabel',
          title: 'Classificação',
          visibility: false,
          enableGrouping: true,
          groupByKey: 'groupId',
        ),
        DatatableCol(
          key: 'subjectLabel',
          title: 'Assunto',
          visibility: false,
          enableGrouping: true,
          groupByKey: 'subjectId',
        ),
        DatatableCol(
          key: 'passages',
          title: 'Passagens',
          width: '120px',
          textAlign: 'center',
        ),
        DatatableCol(
          key: 'order',
          title: 'Ordem',
          width: '110px',
          textAlign: 'center',
        ),
        DatatableCol(
          key: 'orgChart',
          title: 'Organograma',
          minWidth: '240px',
        ),
        DatatableCol(
          key: 'description',
          title: 'Descrição',
          minWidth: '220px',
        ),
        DatatableCol(
          key: 'days',
          title: 'Qtd. dias',
          width: '120px',
          textAlign: 'center',
        ),
      ],
    );
  }

  DatatableSettings _buildProcessLookupTableSettings() {
    return DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'processCode',
          title: 'Código',
          enableSorting: true,
          sortingBy: 'processCode',
          width: '110px',
          minWidth: '110px',
          nowrap: true,
          responsiveAutoHideRequired: true,
        ),
        DatatableCol(
          key: 'requester',
          title: 'Requerente',
          enableSorting: true,
          sortingBy: 'requester',
          minWidth: '270px',
          headerClass: 'datatable-process-lookup-table__requester-col',
          responsiveAutoHidePriority: 40,
        ),
        DatatableCol(
          key: 'personType',
          title: 'Tipo Cgm',
          enableSorting: true,
          sortingBy: 'personType',
          width: '120px',
          minWidth: '120px',
          responsiveAutoHidePriority: 10,
        ),
        DatatableCol(
          key: 'classification',
          title: 'Classificação',
          enableSorting: true,
          sortingBy: 'classification',
          minWidth: '130px',
          responsiveAutoHidePriority: 20,
        ),
        DatatableCol(
          key: 'subject',
          title: 'Assunto',
          enableSorting: true,
          sortingBy: 'subject',
          minWidth: '170px',
          responsiveAutoHidePriority: 30,
        ),
        DatatableCol(
          key: 'createdAt',
          title: 'Inclusão',
          enableSorting: true,
          sortingBy: 'createdAtOrder',
          minWidth: '155px',
          nowrap: true,
          responsiveAutoHidePriority: 15,
        ),
        DatatableCol(
          key: 'status',
          title: 'Situação',
          enableSorting: true,
          sortingBy: 'status',
          minWidth: '170px',
          responsiveAutoHidePriority: 50,
        ),
        DatatableCol(
          key: 'digitalLabel',
          title: 'Digital',
          enableSorting: true,
          sortingBy: 'digitalOrder',
          width: '90px',
          minWidth: '90px',
          textAlign: 'center',
          responsiveAutoHidePriority: 5,
          customRenderHtml: _buildProcessLookupDigitalBadge,
        ),
        DatatableCol(
          key: 'actions',
          title: 'Ações',
          width: '90px',
          minWidth: '90px',
          textAlign: 'center',
          responsiveAutoHideRequired: true,
          customRenderHtml: _buildProcessLookupActionsCell,
        ),
      ],
    );
  }

  DatatableSettings _buildMultiSortTableSettings() {
    return DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'candidate',
          title: 'Nome',
          enableSorting: true,
          sortingBy: 'candidate',
          defaultSortDirection: 'asc',
          minWidth: '260px',
        ),
        DatatableCol(
          key: 'people',
          title: 'Pessoas',
          enableSorting: true,
          sortingBy: 'people',
          defaultSortDirection: 'desc',
          width: '120px',
          textAlign: 'center',
        ),
        DatatableCol(
          key: 'incomeDisplay',
          title: 'Renda per capita',
          enableSorting: true,
          sortingBy: 'incomeMinorUnits',
          defaultSortDirection: 'asc',
          width: '180px',
          textAlign: 'center',
        ),
        DatatableCol(
          key: 'finalScore',
          title: 'Pontuação final',
          enableSorting: true,
          sortingBy: 'finalScore',
          defaultSortDirection: 'desc',
          width: '160px',
          textAlign: 'center',
        ),
        DatatableCol(
          key: 'status',
          title: 'Status',
          width: '150px',
          hideOnMobile: true,
          textAlign: 'center',
          cellStyleResolver: _multiSortStatusStyleResolver,
        ),
      ],
    );
  }

  DatatableSettings _buildStickyColumnsTableSettings(bool isPortuguese) {
    return DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'protocol',
          title: isPortuguese ? 'Protocolo' : 'Protocol',
          enableSorting: true,
          sortingBy: 'protocol',
          width: '132px',
          minWidth: '132px',
          nowrap: true,
          fixedPosition: DatatableFixedColumnPosition.left,
        ),
        DatatableCol(
          key: 'requester',
          title: isPortuguese ? 'Requerente' : 'Requester',
          enableSorting: true,
          sortingBy: 'requester',
          minWidth: '250px',
        ),
        DatatableCol(
          key: 'subject',
          title: isPortuguese ? 'Assunto' : 'Subject',
          enableSorting: true,
          sortingBy: 'subject',
          minWidth: '300px',
        ),
        DatatableCol(
          key: 'queue',
          title: isPortuguese ? 'Fila' : 'Queue',
          minWidth: '180px',
        ),
        DatatableCol(
          key: 'owner',
          title: isPortuguese ? 'Responsável' : 'Owner',
          minWidth: '180px',
        ),
        DatatableCol(
          key: 'updatedAt',
          title: isPortuguese ? 'Atualizado em' : 'Updated at',
          enableSorting: true,
          sortingBy: 'updatedAtOrder',
          width: '170px',
          minWidth: '170px',
          nowrap: true,
        ),
        DatatableCol(
          key: 'status',
          title: 'Status',
          width: '150px',
          minWidth: '150px',
          textAlign: 'center',
          nowrap: true,
        ),
        DatatableCol(
          key: 'actions',
          title: isPortuguese ? 'Ações' : 'Actions',
          width: '132px',
          minWidth: '132px',
          textAlign: 'center',
          nowrap: true,
          fixedPosition: DatatableFixedColumnPosition.right,
          customRenderHtml: _buildStickyColumnsActionsCell,
        ),
      ],
    );
  }

  List<DatatableSearchField> _buildSearchFields(dynamic t) {
    return <DatatableSearchField>[
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
  }

  List<DatatableSearchField> _buildGroupedSearchFields() {
    return <DatatableSearchField>[
      DatatableSearchField(
        label: 'Descrição',
        field: 'description',
        operator: 'like',
      ),
      DatatableSearchField(
        label: 'Classificação',
        field: 'groupLabel',
        operator: 'like',
      ),
      DatatableSearchField(
        label: 'Assunto',
        field: 'subjectLabel',
        operator: 'like',
      ),
    ];
  }

  List<DatatableSearchField> _buildProcessLookupSearchFields() {
    return <DatatableSearchField>[
      DatatableSearchField(
        label: 'Nº Processo',
        field: 'processCode',
        operator: 'like',
        selected: true,
      ),
      DatatableSearchField(
        label: 'Objeto/Observações',
        field: 'detail',
        operator: 'like',
      ),
      DatatableSearchField(
        label: 'Assunto Reduzido',
        field: 'subject',
        operator: 'like',
      ),
      DatatableSearchField(
        label: 'CGM requerente',
        field: 'requester',
        operator: 'like',
      ),
    ];
  }

  List<DatatableSearchField> _buildMultiSortSearchFields() {
    return <DatatableSearchField>[
      DatatableSearchField(
        label: 'Nome',
        field: 'candidate',
        operator: 'like',
      ),
      DatatableSearchField(
        label: 'Status',
        field: 'status',
        operator: '=',
      ),
    ];
  }

  List<DatatableSearchField> _buildStickyColumnsSearchFields(
    bool isPortuguese,
  ) {
    return <DatatableSearchField>[
      DatatableSearchField(
        label: isPortuguese ? 'Protocolo' : 'Protocol',
        field: 'protocol',
        operator: 'like',
        selected: true,
      ),
      DatatableSearchField(
        label: isPortuguese ? 'Requerente' : 'Requester',
        field: 'requester',
        operator: 'like',
      ),
      DatatableSearchField(
        label: isPortuguese ? 'Assunto' : 'Subject',
        field: 'subject',
        operator: 'like',
      ),
      DatatableSearchField(
        label: isPortuguese ? 'Fila' : 'Queue',
        field: 'queue',
        operator: 'like',
      ),
    ];
  }

  @override
  Future<void> ngOnInit() async {
    await _loadMainTable();
    await _loadProcessLookupTable();
    await _loadGroupedTable();
  }

  @ViewChild('demoTable')
  LiDataTableComponent? demoTable;

  @ViewChild('readonlyDemoTable')
  LiDataTableComponent? readonlyDemoTable;

  @ViewChild('gridPreviewDemoTable')
  LiDataTableComponent? gridPreviewDemoTable;

  @ViewChild('customTableDemoTable')
  LiDataTableComponent? customTableDemoTable;

  @ViewChild('customGridDemoTable')
  LiDataTableComponent? customGridDemoTable;

  @ViewChild('groupedDemoTable')
  LiDataTableComponent? groupedDemoTable;

  @ViewChild('processLookupDemoTable')
  LiDataTableComponent? processLookupDemoTable;

  @ViewChild('multiSortDemoTable')
  LiDataTableComponent? multiSortDemoTable;

  @ViewChild('stickyColumnsDemoTable')
  LiDataTableComponent? stickyColumnsDemoTable;

  @ViewChild('lazyDatatableModal')
  LiModalComponent? lazyDatatableModal;

  final Filters filters = Filters(limit: 5, offset: 0);
  final Filters readonlyFilters = Filters(limit: 3, offset: 0);
  final Filters gridPreviewFilters = Filters(limit: 4, offset: 0);
  final Filters customTableFilters = Filters(limit: 4, offset: 0);
  final Filters customGridFilters = Filters(limit: 4, offset: 0);
  final Filters modalTableFilters = Filters(limit: 4, offset: 0);
  final Filters processLookupFilters = Filters(limit: 12, offset: 0);
  final Filters groupedFilters = Filters(limit: 8, offset: 0);
  final Filters multiSortFilters = Filters(limit: 8, offset: 0);
  final Filters stickyColumnsFilters = Filters(limit: 5, offset: 0);
  final List<int> customGridLimitOptions = const <int>[4, 8, 12];
  final List<int> processLookupLimitOptions = const <int>[12, 24, 48];
  final List<int> stickyColumnsLimitOptions = const <int>[5, 10, 15];
  String processLookupRequesterFilter = '';
  String processLookupDigitalFilter = '';
  bool showReadonlyDemo = false;
  bool showGridPreviewDemo = false;
  bool showCustomTableDemo = false;
  bool showCustomGridDemo = false;
  bool showMultiSortDemo = false;
  bool showStickyColumnsDemo = false;
  bool datatableGridMode = false;
  bool singleSelectionOnly = false;
  String datatableEventLog = '';
  final String overviewSnippet = '''<li-datatable
  [dataTableFilter]="filters"
  [data]="tableData"
  [settings]="tableSettings"
  [searchInFields]="searchFields"
  [responsiveCollapse]="true"
  (dataRequest)="onTableRequest(\$event)">
</li-datatable>''';
  final String groupedSnippet =
      '''final groupedTableSettings = DatatableSettings(
  enableGrouping: true,
  colsDefinitions: [
    DatatableCol(
      key: 'groupLabel',
      title: 'Classificação',
      visibility: false,
      enableGrouping: true,
      groupByKey: 'groupId',
    ),
    DatatableCol(
      key: 'subjectLabel',
      title: 'Assunto',
      visibility: false,
      enableGrouping: true,
      groupByKey: 'subjectId',
    ),
  ],
);''';
  final String columnStylesSnippet = '''DatatableCol(
  key: 'status',
  title: 'Status',
  width: '160px',
  textAlign: 'center',
  nowrap: true,
  cellStyleResolver: (itemMap, itemInstance) {
    final status = itemMap['status']?.toString() ?? '';
    return status == 'Bloqueado'
        ? 'color: #b91c1c; font-weight: 700;'
        : 'color: #0f766e; font-weight: 700;';
  },
)''';
  final String rowStyleGridSnippet = '''DatatableSettings(
  colsDefinitions: cols,
  rowStyleResolver: (itemMap, itemInstance) {
    if (itemMap['health'] == 'Crítica') {
      return 'background-color: rgba(239, 68, 68, 0.08);';
    }
    return null;
  },
  gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
  gridGap: '1rem',
  customCardBuilder: (itemMap, itemInstance, row) {
    final root = DivElement()..classes.add('my-card');
    root.text = itemMap['feature']?.toString() ?? '';
    return root;
  },
)''';
  final String processLookupHeaderSnippet = '''<li-datatable
    [dataTableFilter]="processLookupFilters"
    [data]="processLookupTableData"
    [settings]="processLookupTableSettings"
    [searchInFields]="processLookupSearchFields"
    [limitPerPageOptions]="processLookupLimitOptions"
    [responsiveAutoHideColumns]="true"
    [showCheckboxToSelectRow]="false">
  <template li-datatable-header let-ctx>
    <!-- header inspirado em uma tela de consulta de processos -->
  </template>
</li-datatable>''';
  final String multiSortSnippet =
      '''final filters = Filters(limit: 8, offset: 0)
  ..setOrderFields([
    FilterOrderField(field: 'finalScore', direction: 'desc'),
    FilterOrderField(field: 'candidate', direction: 'asc'),
    FilterOrderField(field: 'people', direction: 'desc'),
    FilterOrderField(field: 'incomeMinorUnits', direction: 'asc'),
  ]);

<li-datatable
    [dataTableFilter]="filters"
    [data]="multiSortTableData"
    [settings]="multiSortTableSettings"
    [enableMultiColumnSorting]="true"
    (dataRequest)="onMultiSortTableRequest(\$event)">
</li-datatable>''';
  final String stickyColumnsSnippet = '''final settings = DatatableSettings(
  colsDefinitions: <DatatableCol>[
    DatatableCol(
      key: 'protocol',
      title: 'Protocolo',
      width: '132px',
      minWidth: '132px',
      nowrap: true,
      fixedPosition: DatatableFixedColumnPosition.left,
    ),
    DatatableCol(
      key: 'actions',
      title: 'Ações',
      width: '132px',
      minWidth: '132px',
      textAlign: 'center',
      fixedPosition: DatatableFixedColumnPosition.right,
      customRenderHtml: buildActionsCell,
    ),
  ],
);

<li-datatable
    [dataTableFilter]="stickyColumnsFilters"
    [data]="stickyColumnsTableData"
    [settings]="settings"
    [showCheckboxToSelectRow]="false"
    [disableRowClick]="true">
</li-datatable>''';
  final String productModelSnippet = '''import 'serialize_base.dart';

class Product implements SerializeBase {
  static const tableName = 'products';
  static const fqtn = 'public.\$tableName';
  static const idCol = 'id';
  static const nameCol = 'name';
  static const priceCol = 'price';
  static const statusCol = 'status';

  int id;
  String name;
  double price;
  String status;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.status,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      idCol: id,
      nameCol: name,
      priceCol: price,
      statusCol: status,
    };
  }

  Map<String, dynamic> toInsertMap() => toMap()..remove(idCol);

  Map<String, dynamic> toUpdateMap() => toMap()..remove(idCol);

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map[idCol] as int,
      name: map[nameCol] as String,
      price: (map[priceCol] as num).toDouble(),
      status: map[statusCol] as String,
    );
  }
}''';
  final String backendSnippet = '''class ProductRepository {
  final Connection db;

  ProductRepository(this.db);

  Future<DataFrame<Map<String, dynamic>>> list({Filters? filtros}) async {
    final query = db.table(Product.fqtn);
    query.selectRaw('*');

    if (filtros?.isSearch == true) {
      final search = '%\${filtros!.searchString!.toLowerCase()}%';
      query.whereRaw('unaccent(name) ilike unaccent(?)', [search]);
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      query.orderBy(Product.nameCol, 'asc');
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    final rows = await query.get();
    return DataFrame<Map<String, dynamic>>(
      items: rows,
      totalRecords: totalRecords,
    );
  }
}

class ProductController {
  static Future<Response> list(Request req) async {
    final filtros = Filters.fromMap(req.url.queryParameters);
    final repo = req.make<ProductRepository>();
    final data = await repo.list(filtros: filtros);
    return responseDataFrame(data);
  }
}''';
  final String frontendServiceSnippet =
      '''class ProductService extends RestServiceBase {
  ProductService(RestConfig conf) : super(conf);

  final String path = '/products';

  Future<DataFrame<Product>> list(Filters filtros) async {
    return getDataFrame<Product>(
      path,
      builder: Product.fromMap,
      filtros: filtros,
    );
  }
}''';
  final String angularPageSnippet =
      '''class ListaProdutoPage implements OnActivate {
  ListaProdutoPage(this.hostElement, this.productService);

  final Element hostElement;
  final ProductService productService;

  final filtro = Filters(limit: 12, offset: 0);
  DataFrame<Product> items = DataFrame<Product>.newClear();

  final DatatableSettings dtSettings = DatatableSettings(
    colsDefinitions: [
      DatatableCol(key: 'id', title: 'Id', sortingBy: 'id', enableSorting: true),
      DatatableCol(key: 'name', title: 'Nome', sortingBy: 'name', enableSorting: true),
      DatatableCol(key: 'price', title: 'Preço'),
      DatatableCol(key: 'status', title: 'Status', hideOnMobile: true),
    ],
  );

  final List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'name', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'status', operator: '=', label: 'Status'),
  ];

  Future<void> load() async {
    final loading = SimpleLoading();
    try {
      loading.show(target: hostElement);
      items = await productService.list(filtro);
    } finally {
      loading.hide();
    }
  }
}''';
  final String angularTemplateSnippet = '''<div class="card">
  <li-datatable
      [dataTableFilter]="filtro"
      [data]="items"
      [settings]="dtSettings"
      [searchInFields]="sInFields"
      (dataRequest)="onDtRequestData(\$event)">
  </li-datatable>
</div>''';
  late DataFrame<Map<String, dynamic>> tableData;
  late DataFrame<Map<String, dynamic>> readonlyTableData;
  late DataFrame<Map<String, dynamic>> gridPreviewTableData;
  late DataFrame<Map<String, dynamic>> customTableData;
  late DataFrame<Map<String, dynamic>> customGridData;
  late DataFrame<Map<String, dynamic>> modalTableData;
  late DataFrame<Map<String, dynamic>> processLookupTableData;
  late DataFrame<Map<String, dynamic>> groupedTableData;
  late DataFrame<Map<String, dynamic>> multiSortTableData;
  late DataFrame<Map<String, dynamic>> stickyColumnsTableData;
  String groupedSelectionLog = 'Nenhum item selecionado.';

  List<DatatableSearchField> get readonlySearchFields => searchFields;
  String get initialEventLog => t.pages.datatable.ready;

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

  Future<void> onGroupedTableRequest(Filters nextFilters) async {
    groupedFilters.fillFromFilters(nextFilters);
    await _loadGroupedTable();
  }

  Future<void> onProcessLookupTableRequest(Filters nextFilters) async {
    processLookupFilters.fillFromFilters(nextFilters);
    await _loadProcessLookupTable();
  }

  Future<void> onProcessLookupHeaderSearchFieldChange(
    LiDatatableHeaderContext ctx,
    String? value,
  ) async {
    final index = int.tryParse(value ?? '');
    if (index == null) {
      return;
    }

    ctx.selectSearchField(index);
    await onProcessLookupTableRequest(ctx.dataTableFilter);
  }

  Future<void> onProcessLookupHeaderLimitChange(
    LiDatatableHeaderContext ctx,
    String? value,
  ) async {
    final limit = int.tryParse(value ?? '');
    if (limit == null) {
      return;
    }

    ctx.changeItemsPerPage(limit);
    await onProcessLookupTableRequest(ctx.dataTableFilter);
  }

  Future<void> onProcessLookupRequesterFilterInput(String value) async {
    processLookupRequesterFilter = value;
    processLookupFilters.offset = 0;
    await _loadProcessLookupTable();
  }

  Future<void> onProcessLookupDigitalFilterChange(String? value) async {
    processLookupDigitalFilter = value ?? '';
    processLookupFilters.offset = 0;
    await _loadProcessLookupTable();
  }

  Future<void> clearProcessLookupHeaderFilters() async {
    processLookupRequesterFilter = '';
    processLookupDigitalFilter = '';
    processLookupFilters
      ..offset = 0
      ..searchString = '';
    await _loadProcessLookupTable();
  }

  Future<void> onMultiSortTableRequest(Filters nextFilters) async {
    multiSortFilters.fillFromFilters(nextFilters);
    await _loadMultiSortTable();
  }

  Future<void> onStickyColumnsTableRequest(Filters nextFilters) async {
    stickyColumnsFilters.fillFromFilters(nextFilters);
    await _loadStickyColumnsTable();
  }

  void onGroupedSelectionChange(List<dynamic> selectedRows) {
    groupedSelectionLog = selectedRows.isEmpty
        ? 'Nenhum item selecionado.'
        : '${selectedRows.length} item(ns) selecionado(s).';
  }

  Future<void> onReadonlyDemoExpanded(bool expanded) async {
    if (expanded) {
      await _loadReadonlyTable();
      showReadonlyDemo = true;
      _flushView();
      return;
    }

    showReadonlyDemo = false;
    _flushView();
  }

  Future<void> onGridPreviewDemoExpanded(bool expanded) async {
    if (expanded) {
      await _loadGridPreviewTable();
      showGridPreviewDemo = true;
      _flushView();
      return;
    }

    showGridPreviewDemo = false;
    _flushView();
  }

  Future<void> onCustomTableDemoExpanded(bool expanded) async {
    if (expanded) {
      await _loadCustomTable();
      showCustomTableDemo = true;
      _flushView();
      return;
    }

    showCustomTableDemo = false;
    _flushView();
  }

  Future<void> onCustomGridDemoExpanded(bool expanded) async {
    if (expanded) {
      await _loadCustomGrid();
      showCustomGridDemo = true;
      _flushView();
      return;
    }

    showCustomGridDemo = false;
    _flushView();
  }

  Future<void> onMultiSortDemoExpanded(bool expanded) async {
    if (expanded) {
      await _loadMultiSortTable();
      showMultiSortDemo = true;
      _flushView();
      return;
    }

    showMultiSortDemo = false;
    _flushView();
  }

  Future<void> onStickyColumnsDemoExpanded(bool expanded) async {
    if (expanded) {
      await _loadStickyColumnsTable();
      showStickyColumnsDemo = true;
      _flushView();
      return;
    }

    showStickyColumnsDemo = false;
    _flushView();
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

  Future<void> onModalTableRequest(Filters nextFilters) async {
    modalTableFilters.fillFromFilters(nextFilters);
    await _loadModalTable();
  }

  Future<void> openLazyDatatableModal() async {
    lazyDatatableModal?.open();
    _flushView();
    await Future<void>.delayed(Duration.zero);
    await _loadModalTable();
    _flushView();
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
    _syncAccordionTable(readonlyDemoTable, readonlyTableData);
    _flushView();
  }

  Future<void> _loadGridPreviewTable() async {
    gridPreviewTableData =
        await _datatableDemoService.query(gridPreviewFilters);
    _syncAccordionTable(gridPreviewDemoTable, gridPreviewTableData);
    _flushView();
  }

  Future<void> _loadCustomTable() async {
    customTableData = await _datatableDemoService.query(customTableFilters);
    _syncAccordionTable(customTableDemoTable, customTableData);
    _flushView();
  }

  Future<void> _loadCustomGrid() async {
    customGridData = await _datatableDemoService.query(customGridFilters);
    _syncAccordionTable(customGridDemoTable, customGridData);
    _flushView();
  }

  Future<void> _loadModalTable() async {
    modalTableData = await _datatableDemoService.query(modalTableFilters);
    _flushView();
  }

  Future<void> _loadProcessLookupTable() async {
    processLookupDemoTable?.showLoading();
    try {
      var records = _buildProcessLookupSeedRecords();

      final requesterFilter = processLookupRequesterFilter.trim().toLowerCase();
      if (requesterFilter.isNotEmpty) {
        records = records
            .where((record) =>
                (record['requester']?.toString().toLowerCase() ?? '')
                    .contains(requesterFilter))
            .toList(growable: false);
      }

      final digitalFilter = processLookupDigitalFilter.trim().toLowerCase();
      if (digitalFilter.isNotEmpty) {
        records = records
            .where((record) =>
                (record['digitalLabel']?.toString().toLowerCase() ?? '') ==
                digitalFilter)
            .toList(growable: false);
      }

      processLookupTableData =
          await DatatableDemoService(records).query(processLookupFilters);
    } finally {
      processLookupDemoTable?.hideLoading();
      _flushView();
    }
  }

  Future<void> _loadGroupedTable() async {
    groupedDemoTable?.showLoading();
    try {
      groupedTableData = await _groupedDemoService.query(groupedFilters);
    } finally {
      groupedDemoTable?.hideLoading();
      _flushView();
    }
  }

  Future<void> _loadMultiSortTable() async {
    multiSortTableData = await _multiSortDemoService.query(multiSortFilters);
    _syncAccordionTable(multiSortDemoTable, multiSortTableData);
    _flushView();
  }

  Future<void> _loadStickyColumnsTable() async {
    stickyColumnsTableData =
        await _stickyColumnsDemoService.query(stickyColumnsFilters);
    _syncAccordionTable(stickyColumnsDemoTable, stickyColumnsTableData);
    _flushView();
  }

  // ignore: deprecated_member_use
  void _flushView() => _changeDetectorRef.detectChanges();

  void _syncAccordionTable(
    LiDataTableComponent? table,
    DataFrame<Map<String, dynamic>> frame,
  ) {
    if (table == null) {
      return;
    }

    table.data = frame;
    table.update();
  }

  static List<Map<String, dynamic>> _buildSeedRecords(Messages t) {
    final features = <String>[
      t.pages.datatable.featureRow1,
      t.pages.datatable.featureRow2,
      t.pages.datatable.featureRow3,
      t.pages.datatable.featureRow4,
      t.pages.datatable.featureRow5,
      t.pages.datatable.featureRow6,
      t.pages.datatable.featureRow7,
      t.pages.datatable.featureRow8,
    ];
    final owners = <String>[
      t.pages.datatable.ownerProduct,
      t.pages.datatable.ownerBackoffice,
      t.pages.datatable.ownerOperations,
      t.pages.datatable.ownerInfra,
      t.pages.datatable.ownerFinance,
      t.pages.datatable.ownerSupport,
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

  static List<Map<String, dynamic>> _buildGroupedSeedRecords() {
    const groupedEntries = <Map<String, dynamic>>[
      {
        'groupId': 10,
        'groupLabel': 'Compras',
        'subjectId': 101,
        'subjectLabel': 'Compra direta',
        'passages': 1,
        'order': 1,
        'orgChart': 'Chefia de Gabinete - 1059',
        'description': 'Solicitar coleta de preços',
        'days': 2,
      },
      {
        'groupId': 10,
        'groupLabel': 'Compras',
        'subjectId': 101,
        'subjectLabel': 'Compra direta',
        'passages': 2,
        'order': 2,
        'orgChart': 'Diretoria Administrativa - 2010',
        'description': 'Validar dotação orçamentária',
        'days': 1,
      },
      {
        'groupId': 10,
        'groupLabel': 'Compras',
        'subjectId': 102,
        'subjectLabel': 'Registro de preço',
        'passages': 1,
        'order': 1,
        'orgChart': 'Coordenadoria de Compras - 1072',
        'description': 'Abrir ata vigente',
        'days': 3,
      },
      {
        'groupId': 10,
        'groupLabel': 'Compras',
        'subjectId': 102,
        'subjectLabel': 'Registro de preço',
        'passages': 2,
        'order': 2,
        'orgChart': 'Assessoria Jurídica - 1033',
        'description': 'Emitir parecer do processo',
        'days': 4,
      },
      {
        'groupId': 20,
        'groupLabel': 'Pessoal',
        'subjectId': 201,
        'subjectLabel': 'Férias',
        'passages': 1,
        'order': 1,
        'orgChart': 'Recursos Humanos - 3011',
        'description': 'Conferir período aquisitivo',
        'days': 2,
      },
      {
        'groupId': 20,
        'groupLabel': 'Pessoal',
        'subjectId': 201,
        'subjectLabel': 'Férias',
        'passages': 2,
        'order': 2,
        'orgChart': 'Departamento Pessoal - 3020',
        'description': 'Registrar afastamento',
        'days': 1,
      },
      {
        'groupId': 20,
        'groupLabel': 'Pessoal',
        'subjectId': 202,
        'subjectLabel': 'Licença',
        'passages': 1,
        'order': 1,
        'orgChart': 'Recursos Humanos - 3011',
        'description': 'Analisar documentação médica',
        'days': 5,
      },
      {
        'groupId': 20,
        'groupLabel': 'Pessoal',
        'subjectId': 202,
        'subjectLabel': 'Licença',
        'passages': 2,
        'order': 2,
        'orgChart': 'Perícia Oficial - 4015',
        'description': 'Agendar perícia',
        'days': 7,
      },
    ];

    return groupedEntries
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList(growable: false);
  }

  static List<Map<String, dynamic>> _buildProcessLookupSeedRecords() {
    return <Map<String, dynamic>>[
      _buildProcessLookupRecord(
        processCode: '1860/96',
        requester: 'TEREZINHA GROLA',
        personType: 'Padrão',
        classification: 'Solicitação, faz',
        subject: 'Solicitação',
        detail: 'Solicitação do processo',
        createdAt: '21/10/2016 15:29:33',
        createdAtOrder: 20161021152933,
        status: 'Anexado',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildProcessLookupRecord(
        processCode: '16269/2026',
        requester: 'CINTIA MARIA PIMENTEL HERMIDA DOS SANTOS',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Abono de permanência - requerimento principal',
        createdAt: '20/04/2026 15:55:28',
        createdAtOrder: 20260420155528,
        status: 'Em andamento, recebido',
        digitalLabel: 'Sim',
        digitalOrder: 1,
      ),
      _buildProcessLookupRecord(
        processCode: '16268/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Observações do abono de permanência',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Em andamento, recebido',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildProcessLookupRecord(
        processCode: '16267/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Processo aguardando conferência',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Em andamento, a receber',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildProcessLookupRecord(
        processCode: '16266/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Recebimento pendente de digitalização',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Em andamento, a receber',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildProcessLookupRecord(
        processCode: '16265/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Fluxo recebido na unidade',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Em andamento, recebido',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildProcessLookupRecord(
        processCode: '16264/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Processo anexado ao volume principal',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Anexado',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildProcessLookupRecord(
        processCode: '16263/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Recebimento pela unidade de protocolo',
        createdAt: '18/04/2026 01:00:34',
        createdAtOrder: 20260418010034,
        status: 'Em andamento, recebido',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildProcessLookupRecord(
        processCode: '16262/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Tramitação em andamento',
        createdAt: '18/04/2026 01:00:33',
        createdAtOrder: 20260418010033,
        status: 'Em andamento, recebido',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildProcessLookupRecord(
        processCode: '16261/2026',
        requester: 'Isaque Neves Sant\'ana',
        personType: 'Padrão',
        classification: 'Abono',
        subject: 'Abono de Permanência',
        detail: 'Arquivado definitivamente',
        createdAt: '18/04/2026 01:00:33',
        createdAtOrder: 20260418010033,
        status: 'Arquivado definitivo',
        digitalLabel: 'Não',
        digitalOrder: 0,
      ),
      _buildProcessLookupRecord(
        processCode: '16260/2026',
        requester: 'Jorgito Inocencio Santos',
        personType: 'Padrão',
        classification: 'Cadastro',
        subject: 'Atualização cadastral',
        detail: 'Objeto e observações do cadastro',
        createdAt: '16/04/2026 10:12:20',
        createdAtOrder: 20260416101220,
        status: 'Em análise',
        digitalLabel: 'Sim',
        digitalOrder: 1,
      ),
      _buildProcessLookupRecord(
        processCode: '16259/2026',
        requester: 'JULIA RAMOS',
        personType: 'Padrão',
        classification: 'Licença',
        subject: 'Licença especial',
        detail: 'Observações sobre licença especial',
        createdAt: '15/04/2026 09:05:10',
        createdAtOrder: 20260415090510,
        status: 'Em andamento, recebido',
        digitalLabel: 'Sim',
        digitalOrder: 1,
      ),
    ];
  }

  static Map<String, dynamic> _buildProcessLookupRecord({
    required String processCode,
    required String requester,
    required String personType,
    required String classification,
    required String subject,
    required String detail,
    required String createdAt,
    required int createdAtOrder,
    required String status,
    required String digitalLabel,
    required int digitalOrder,
  }) {
    return <String, dynamic>{
      'processCode': processCode,
      'requester': requester,
      'personType': personType,
      'classification': classification,
      'subject': subject,
      'detail': detail,
      'createdAt': createdAt,
      'createdAtOrder': createdAtOrder,
      'status': status,
      'digitalLabel': digitalLabel,
      'digitalOrder': digitalOrder,
    };
  }

  static List<Map<String, dynamic>> _buildMultiSortSeedRecords() {
    return <Map<String, dynamic>>[
      _buildMultiSortRecord(
        candidate: 'Ana Almeida',
        people: 6,
        incomeMinorUnits: 15000,
        finalScore: 85,
        status: 'Classificado',
      ),
      _buildMultiSortRecord(
        candidate: 'Ana Beatriz',
        people: 4,
        incomeMinorUnits: 18000,
        finalScore: 85,
        status: 'Classificado',
      ),
      _buildMultiSortRecord(
        candidate: 'Ana Clara',
        people: 4,
        incomeMinorUnits: 20000,
        finalScore: 85,
        status: 'Classificado',
      ),
      _buildMultiSortRecord(
        candidate: 'Bruno Alves',
        people: 5,
        incomeMinorUnits: 14000,
        finalScore: 72,
        status: 'Classificado',
      ),
      _buildMultiSortRecord(
        candidate: 'Bruno Lima',
        people: 5,
        incomeMinorUnits: 18000,
        finalScore: 72,
        status: 'Classificado',
      ),
      _buildMultiSortRecord(
        candidate: 'Bruno Rocha',
        people: 3,
        incomeMinorUnits: 18000,
        finalScore: 72,
        status: 'Classificado',
      ),
      _buildMultiSortRecord(
        candidate: 'Carlos Mendes',
        people: 3,
        incomeMinorUnits: 16000,
        finalScore: 72,
        status: 'Classificado',
      ),
      _buildMultiSortRecord(
        candidate: 'Daniela Rocha',
        people: 4,
        incomeMinorUnits: 21000,
        finalScore: 61,
        status: 'Classificado',
      ),
      _buildMultiSortRecord(
        candidate: 'Daniela Souza',
        people: 4,
        incomeMinorUnits: 21000,
        finalScore: 61,
        status: 'Classificado',
      ),
      _buildMultiSortRecord(
        candidate: 'Eduardo Lima',
        people: 2,
        incomeMinorUnits: 18000,
        finalScore: 61,
        status: 'Classificado',
      ),
      _buildMultiSortRecord(
        candidate: 'Fernanda Alves',
        people: 2,
        incomeMinorUnits: 18000,
        finalScore: 61,
        status: 'Suplente',
      ),
      _buildMultiSortRecord(
        candidate: 'Gabriel Costa',
        people: 4,
        incomeMinorUnits: 15000,
        finalScore: 52,
        status: 'Suplente',
      ),
      _buildMultiSortRecord(
        candidate: 'Helena Martins',
        people: 1,
        incomeMinorUnits: 30000,
        finalScore: 52,
        status: 'Suplente',
      ),
      _buildMultiSortRecord(
        candidate: 'Igor Nunes',
        people: 1,
        incomeMinorUnits: 32000,
        finalScore: 52,
        status: 'Suplente',
      ),
      _buildMultiSortRecord(
        candidate: 'Julia Ramos',
        people: 3,
        incomeMinorUnits: 23000,
        finalScore: 45,
        status: 'Em análise',
      ),
      _buildMultiSortRecord(
        candidate: 'Karen Teixeira',
        people: 3,
        incomeMinorUnits: 23000,
        finalScore: 45,
        status: 'Em análise',
      ),
      _buildMultiSortRecord(
        candidate: 'Lucas Pereira',
        people: 2,
        incomeMinorUnits: 19000,
        finalScore: 45,
        status: 'Em análise',
      ),
      _buildMultiSortRecord(
        candidate: 'Mariana Costa',
        people: 2,
        incomeMinorUnits: 25000,
        finalScore: 38,
        status: 'Em análise',
      ),
    ];
  }

  static List<Map<String, dynamic>> _buildStickyColumnsSeedRecords() {
    return <Map<String, dynamic>>[
      _buildStickyColumnsRecord(
        protocol: '2026/00451',
        requester: 'Ana Paula Nogueira',
        subject:
            'Revisão de contrato com aditivo operacional e anexos complementares',
        queue: 'Contratos e Convênios',
        owner: 'Marcelo Dias',
        updatedAt: '22/04/2026 14:35',
        updatedAtOrder: 202604221435,
        status: 'Em análise',
      ),
      _buildStickyColumnsRecord(
        protocol: '2026/00438',
        requester: 'Bruna Costa Lima',
        subject: 'Solicitação de empenho para manutenção preventiva da frota',
        queue: 'Execução Orçamentária',
        owner: 'Fernanda Melo',
        updatedAt: '22/04/2026 11:10',
        updatedAtOrder: 202604221110,
        status: 'Aguardando assinatura',
      ),
      _buildStickyColumnsRecord(
        protocol: '2026/00412',
        requester: 'Carlos Eduardo Martins',
        subject: 'Abertura de processo para aquisição de licenças corporativas',
        queue: 'Tecnologia da Informação',
        owner: 'Juliana Rocha',
        updatedAt: '21/04/2026 18:42',
        updatedAtOrder: 202604211842,
        status: 'Pendente',
      ),
      _buildStickyColumnsRecord(
        protocol: '2026/00397',
        requester: 'Daniela Prado Alves',
        subject: 'Reequilíbrio financeiro de ata de registro de preços vigente',
        queue: 'Compras Estratégicas',
        owner: 'Rafael Borges',
        updatedAt: '21/04/2026 16:08',
        updatedAtOrder: 202604211608,
        status: 'Em análise',
      ),
      _buildStickyColumnsRecord(
        protocol: '2026/00381',
        requester: 'Elisa Santos Moraes',
        subject:
            'Prestação de contas parcial com ajustes de documentos fiscais',
        queue: 'Convênios',
        owner: 'Patrícia Gomes',
        updatedAt: '21/04/2026 09:27',
        updatedAtOrder: 202604210927,
        status: 'Concluído',
      ),
      _buildStickyColumnsRecord(
        protocol: '2026/00370',
        requester: 'Felipe Moura Souza',
        subject:
            'Inclusão de termo de referência complementar para contratação direta',
        queue: 'Planejamento de Compras',
        owner: 'Camila Ribeiro',
        updatedAt: '20/04/2026 17:55',
        updatedAtOrder: 202604201755,
        status: 'Aguardando assinatura',
      ),
      _buildStickyColumnsRecord(
        protocol: '2026/00354',
        requester: 'Gabriela Farias Teixeira',
        subject: 'Solicitação de reserva orçamentária para projeto educacional',
        queue: 'Planejamento Financeiro',
        owner: 'Luciano Tavares',
        updatedAt: '20/04/2026 13:22',
        updatedAtOrder: 202604201322,
        status: 'Pendente',
      ),
      _buildStickyColumnsRecord(
        protocol: '2026/00326',
        requester: 'Henrique Pires Costa',
        subject:
            'Análise final de prestação de serviços com glosa e reapresentação',
        queue: 'Fiscalização Contratual',
        owner: 'Marina Lopes',
        updatedAt: '19/04/2026 10:05',
        updatedAtOrder: 202604191005,
        status: 'Em análise',
      ),
    ];
  }

  static Map<String, dynamic> _buildStickyColumnsRecord({
    required String protocol,
    required String requester,
    required String subject,
    required String queue,
    required String owner,
    required String updatedAt,
    required int updatedAtOrder,
    required String status,
  }) {
    return <String, dynamic>{
      'protocol': protocol,
      'requester': requester,
      'subject': subject,
      'queue': queue,
      'owner': owner,
      'updatedAt': updatedAt,
      'updatedAtOrder': updatedAtOrder,
      'status': status,
    };
  }

  static Map<String, dynamic> _buildMultiSortRecord({
    required String candidate,
    required int people,
    required int incomeMinorUnits,
    required int finalScore,
    required String status,
  }) {
    return <String, dynamic>{
      'candidate': candidate,
      'people': people,
      'incomeMinorUnits': incomeMinorUnits,
      'incomeDisplay': _formatCurrencyBr(incomeMinorUnits),
      'finalScore': finalScore,
      'status': status,
    };
  }

  static String _formatCurrencyBr(int minorUnits) {
    final reais = minorUnits ~/ 100;
    final cents = minorUnits % 100;
    final groupedReais = reais.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
        );
    return 'R\$ $groupedReais,${cents.toString().padLeft(2, '0')}';
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

  String? _multiSortStatusStyleResolver(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    switch (itemMap['status']?.toString() ?? '') {
      case 'Classificado':
        return 'color: #059669; font-weight: 700;';
      case 'Suplente':
        return 'color: #b45309; font-weight: 700;';
      case 'Em análise':
        return 'color: #1d4ed8; font-weight: 700;';
      default:
        return 'color: #334155; font-weight: 600;';
    }
  }

  String? _advancedRowStyleResolver(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    switch (itemMap['health']?.toString() ?? '') {
      case var health when health == t.pages.datatable.healthCritical:
        return 'background-color: rgba(239, 68, 68, 0.08); border-left: 3px solid #ef4444;';
      case var health when health == t.pages.datatable.healthWarning:
        return 'background-color: rgba(245, 134, 70, 0.08); border-left: 3px solid #f58646;';
      case var health when health == t.pages.datatable.healthOk:
        return 'background-color: rgba(5, 150, 105, 0.06); border-left: 3px solid #059669;';
      default:
        return null;
    }
  }

  Element _buildCustomCard(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
    DatatableRow row,
  ) {
    final root = DivElement()
      ..classes.addAll(<String>[
        'datatable-api-card',
        _customCardToneClass(itemMap['health']?.toString() ?? ''),
      ]);

    final header = DivElement()..classes.add('datatable-api-card__header');

    final eyebrow = SpanElement()
      ..classes.add('datatable-api-card__eyebrow')
      ..text = t.pages.datatable.customCardEyebrow;

    final title = HeadingElement.h6()
      ..classes.add('datatable-api-card__title')
      ..text = itemMap['feature']?.toString() ?? '';

    final owner = DivElement()
      ..classes.add('datatable-api-card__meta')
      ..text = '${t.pages.datatable.ownerPrefix}: ${itemMap['owner']}';

    final badgeRow = DivElement()..classes.add('datatable-api-card__badges');

    final body = DivElement()..classes.add('datatable-api-card__body');

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
      ..text = t.pages.datatable.customCardSummary;

    final footer = DivElement()..classes.add('datatable-api-card__footer');

    final ownerMetric = DivElement()..classes.add('datatable-api-card__metric');
    final ownerMetricLabel = SpanElement()
      ..classes.add('datatable-api-card__metric-label')
      ..text = 'Owner';
    final ownerMetricValue = SpanElement()
      ..classes.add('datatable-api-card__metric-value')
      ..text = itemMap['owner']?.toString() ?? '';

    final healthMetric = DivElement()
      ..classes.add('datatable-api-card__metric');
    final healthMetricLabel = SpanElement()
      ..classes.add('datatable-api-card__metric-label')
      ..text = 'Health';
    final healthMetricValue = SpanElement()
      ..classes.add('datatable-api-card__metric-value')
      ..text = itemMap['health']?.toString() ?? '';

    ownerMetric.children.addAll(<Element>[ownerMetricLabel, ownerMetricValue]);
    healthMetric.children
        .addAll(<Element>[healthMetricLabel, healthMetricValue]);

    header.children.addAll(<Element>[eyebrow, title]);
    badgeRow.children.addAll(<Element>[statusBadge, healthBadge]);
    body.children.addAll(<Element>[owner, badgeRow, summary]);
    footer.children.addAll(<Element>[ownerMetric, healthMetric]);
    root.children.addAll(<Element>[header, body, footer]);

    return root;
  }

  Element _buildProcessLookupDigitalBadge(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    final isDigital = (itemMap['digitalLabel']?.toString() ?? '') == 'Sim';
    final badge = SpanElement()
      ..classes.addAll(<String>[
        'datatable-process-lookup-badge',
        isDigital
            ? 'datatable-process-lookup-badge--primary'
            : 'datatable-process-lookup-badge--muted',
      ])
      ..text = itemMap['digitalLabel']?.toString() ?? '';
    return badge;
  }

  Element _buildProcessLookupActionsCell(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    final root = DivElement()..classes.add('datatable-process-lookup-actions');

    final documentAction = SpanElement()
      ..classes
          .addAll(<String>['datatable-process-lookup-action', 'ph', 'ph-file'])
      ..title = 'Abrir processo';

    final favoriteAction = SpanElement()
      ..classes
          .addAll(<String>['datatable-process-lookup-action', 'ph', 'ph-star'])
      ..title = 'Favoritar';

    root
      ..append(documentAction)
      ..append(favoriteAction);

    return root;
  }

  Element _buildStickyColumnsActionsCell(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    final root = DivElement()..classes.add('datatable-sticky-demo-actions');

    final openAction = ButtonElement()
      ..type = 'button'
      ..classes.addAll(<String>[
        'btn',
        'btn-flat-primary',
        'border-transparent',
        'btn-icon',
        'btn-sm',
      ])
      ..title = i18n.isPortuguese ? 'Abrir processo' : 'Open process';
    openAction.append(
      SpanElement()..classes.addAll(<String>['ph', 'ph-folder-open']),
    );

    final timelineAction = ButtonElement()
      ..type = 'button'
      ..classes.addAll(<String>[
        'btn',
        'btn-flat-primary',
        'border-transparent',
        'btn-icon',
        'btn-sm',
      ])
      ..title = i18n.isPortuguese ? 'Ver histórico' : 'Open timeline';
    timelineAction.append(
      SpanElement()
        ..classes.addAll(<String>['ph', 'ph-clock-counter-clockwise']),
    );

    root.children.addAll(<Element>[openAction, timelineAction]);
    return root;
  }

  String get processLookupDemoTitle => i18n.isPortuguese
      ? 'Layout de consulta de processos'
      : 'Process lookup layout';

  String get processLookupDemoIntro => i18n.isPortuguese
      ? 'Demonstra como usar header customizado via TemplateRef para reproduzir a busca em duas linhas, filtros auxiliares e barra de ações da tela de consultar processo.'
      : 'Shows how to use a custom TemplateRef header to reproduce the two-row search area, helper filters, and action bar from a process lookup screen.';

  String get processLookupRequesterLabel =>
      i18n.isPortuguese ? 'Requerente:' : 'Requester:';

  String get processLookupRequesterPlaceholder =>
      i18n.isPortuguese ? 'Clique para buscar...' : 'Click to search...';

  String get processLookupDigitalLabel => 'Digital:';

  String get processLookupClearLabel => i18n.isPortuguese ? 'Limpar' : 'Clear';

  String get processLookupSearchPlaceholder =>
      i18n.isPortuguese ? 'Digite para buscar' : 'Type to search';

  String get processLookupSearchCaption =>
      i18n.isPortuguese ? 'Pesquisa rápida por campo' : 'Quick field search';

  String get processLookupHeaderEventLog => i18n.isPortuguese
      ? 'A demo usa header customizado e filtros externos sem substituir a paginação, ordenação e renderização do li-datatable.'
      : 'This demo uses a custom header and external filters without replacing li-datatable pagination, sorting, or rendering.';

  String get stickyColumnsDemoTitle => i18n.isPortuguese
      ? 'Colunas fixadas com rolagem horizontal'
      : 'Frozen columns with horizontal scroll';

  String get stickyColumnsDemoDescription => i18n.isPortuguese
      ? 'Mantém protocolo à esquerda e ações à direita enquanto as colunas centrais deslizam.'
      : 'Keeps the protocol on the left and actions on the right while middle columns scroll.';

  String get stickyColumnsDemoIntro => i18n.isPortuguese
      ? 'Use fixedPosition para prender colunas críticas nas extremidades quando a tabela precisa de scroll horizontal e o auto-hide responsivo está desligado.'
      : 'Use fixedPosition to pin critical edge columns when the table needs horizontal scroll and responsive auto-hide is disabled.';

  String get stickyColumnsSearchPlaceholder => i18n.isPortuguese
      ? 'Busque por protocolo, requerente ou assunto'
      : 'Search by protocol, requester, or subject';

  String get stickyColumnsDemoNote => i18n.isPortuguese
      ? 'Role horizontalmente dentro da grade: a primeira coluna continua ancorada à esquerda e a coluna de ações permanece visível à direita.'
      : 'Scroll horizontally inside the grid: the first column stays pinned on the left and the actions column remains visible on the right.';

  String _statusColor(String status) {
    switch (status) {
      case var value when value == t.pages.datatable.statusDone:
        return '#0f766e';
      case var value when value == t.pages.datatable.statusBlocked:
        return '#b91c1c';
      case var value when value == t.pages.datatable.statusPlanned:
        return '#1d4ed8';
      case var value when value == t.pages.datatable.statusInProgress:
        return '#b45309';
      default:
        return '#334155';
    }
  }

  String _healthColor(String health) {
    switch (health) {
      case var value when value == t.pages.datatable.healthCritical:
        return '#b91c1c';
      case var value when value == t.pages.datatable.healthWarning:
        return '#b45309';
      case var value when value == t.pages.datatable.healthOk:
        return '#0f766e';
      default:
        return '#334155';
    }
  }

  String _statusBadgeClass(String status) {
    switch (status) {
      case var value when value == t.pages.datatable.statusDone:
        return 'datatable-api-card__badge--success';
      case var value when value == t.pages.datatable.statusBlocked:
        return 'datatable-api-card__badge--danger';
      case var value when value == t.pages.datatable.statusPlanned:
        return 'datatable-api-card__badge--info';
      case var value when value == t.pages.datatable.statusInProgress:
        return 'datatable-api-card__badge--warning';
      default:
        return 'datatable-api-card__badge--muted';
    }
  }

  String _healthBadgeClass(String health) {
    switch (health) {
      case var value when value == t.pages.datatable.healthCritical:
        return 'datatable-api-card__badge--danger';
      case var value when value == t.pages.datatable.healthWarning:
        return 'datatable-api-card__badge--warning';
      case var value when value == t.pages.datatable.healthOk:
        return 'datatable-api-card__badge--success';
      default:
        return 'datatable-api-card__badge--muted';
    }
  }

  String _customCardToneClass(String health) {
    switch (health) {
      case var value when value == t.pages.datatable.healthCritical:
        return 'datatable-api-card--danger';
      case var value when value == t.pages.datatable.healthWarning:
        return 'datatable-api-card--warning';
      case var value when value == t.pages.datatable.healthOk:
        return 'datatable-api-card--success';
      default:
        return 'datatable-api-card--muted';
    }
  }

  List<FilterOrderField> _buildDefaultMultiSortOrderFields() {
    return <FilterOrderField>[
      FilterOrderField(field: 'finalScore', direction: 'desc'),
      FilterOrderField(field: 'candidate', direction: 'asc'),
      FilterOrderField(field: 'people', direction: 'desc'),
      FilterOrderField(field: 'incomeMinorUnits', direction: 'asc'),
    ];
  }

  List<FilterOrderField> get multiSortOrderFields {
    if (multiSortFilters.orderFields.isNotEmpty) {
      return multiSortFilters.orderFields;
    }

    final orderBy = multiSortFilters.orderBy;
    if (orderBy == null || orderBy.trim().isEmpty) {
      return <FilterOrderField>[];
    }

    return <FilterOrderField>[
      FilterOrderField(
        field: orderBy,
        direction: multiSortFilters.orderDir ?? 'asc',
      ),
    ];
  }

  String multiSortFieldLabel(String field) {
    switch (field) {
      case 'finalScore':
        return 'Pontuação final';
      case 'candidate':
        return 'Nome';
      case 'people':
        return 'Pessoas';
      case 'incomeMinorUnits':
        return 'Renda per capita';
      case 'status':
        return 'Status';
      default:
        return field;
    }
  }

  String multiSortDirectionArrow(String direction) =>
      direction == 'desc' ? '↓' : '↑';

  String multiSortDirectionLabel(String direction) =>
      direction == 'desc' ? 'Decrescente' : 'Crescente';
}
