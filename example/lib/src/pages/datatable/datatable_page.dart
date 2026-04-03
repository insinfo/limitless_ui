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
    DemoPageBreadcrumbComponent,
    LiAccordionComponent,
    LiAccordionBodyDirective,
    LiAccordionItemComponent,
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
            DatatableDemoService(_buildSeedRecords(en.MessagesEn())) {
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

    _tableSettingsPt = _buildTableSettings(Messages());
    _tableSettingsEn = _buildTableSettings(en.MessagesEn());
    _advancedTableSettingsPt = _buildAdvancedTableSettings(Messages());
    _advancedTableSettingsEn = _buildAdvancedTableSettings(en.MessagesEn());
    _advancedGridSettingsPt = _buildAdvancedGridSettings(Messages());
    _advancedGridSettingsEn = _buildAdvancedGridSettings(en.MessagesEn());
    _searchFieldsPt = _buildSearchFields(Messages());
    _searchFieldsEn = _buildSearchFields(en.MessagesEn());
  }

  final DemoI18nService i18n;
  final ChangeDetectorRef _changeDetectorRef;
  final DatatableDemoService _datatableDemoServicePt;
  final DatatableDemoService _datatableDemoServiceEn;
  Messages get t => i18n.t;

  late final DatatableSettings _tableSettingsPt;
  late final DatatableSettings _tableSettingsEn;
  late final DatatableSettings _advancedTableSettingsPt;
  late final DatatableSettings _advancedTableSettingsEn;
  late final DatatableSettings _advancedGridSettingsPt;
  late final DatatableSettings _advancedGridSettingsEn;
  late final List<DatatableSearchField> _searchFieldsPt;
  late final List<DatatableSearchField> _searchFieldsEn;

  DatatableSettings get tableSettings =>
      i18n.isPortuguese ? _tableSettingsPt : _tableSettingsEn;

  DatatableSettings get advancedTableSettings =>
      i18n.isPortuguese ? _advancedTableSettingsPt : _advancedTableSettingsEn;

  DatatableSettings get advancedGridSettings =>
      i18n.isPortuguese ? _advancedGridSettingsPt : _advancedGridSettingsEn;

  List<DatatableSearchField> get searchFields =>
      i18n.isPortuguese ? _searchFieldsPt : _searchFieldsEn;

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
      gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
      gridGap: '1rem',
      customCardBuilder: _buildCustomCard,
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

  @override
  Future<void> ngOnInit() async {
    await _loadMainTable();
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

  @ViewChild('lazyDatatableModal')
  LiModalComponent? lazyDatatableModal;

  final Filters filters = Filters(limit: 5, offset: 0);
  final Filters readonlyFilters = Filters(limit: 3, offset: 0);
  final Filters gridPreviewFilters = Filters(limit: 4, offset: 0);
  final Filters customTableFilters = Filters(limit: 4, offset: 0);
  final Filters customGridFilters = Filters(limit: 4, offset: 0);
  final Filters modalTableFilters = Filters(limit: 4, offset: 0);
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
  late DataFrame<Map<String, dynamic>> modalTableData;

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
    final root = DivElement()..classes.add('datatable-api-card');

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

    badgeRow.children.addAll(<Element>[statusBadge, healthBadge]);
    root.children.addAll(<Element>[eyebrow, title, owner, badgeRow, summary]);

    return root;
  }

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
}
