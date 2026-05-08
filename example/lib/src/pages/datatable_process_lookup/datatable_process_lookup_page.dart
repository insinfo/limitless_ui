import 'dart:html';

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

import '../datatable/datatable_demo_service.dart';
import 'datatable_process_lookup_support.dart';

@Component(
  selector: 'datatable-process-lookup-page',
  templateUrl: 'datatable_process_lookup_page.html',
  //styleUrls: ['datatable_process_lookup_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiDatatableCardDirective,
    LiDatatableCellDirective,
    LiDatatableHeaderDirective,
    LiDataTableComponent,
  ],
)
class DatatableProcessLookupPageComponent implements OnInit {
  DatatableProcessLookupPageComponent(this.i18n)
      : processLookupTableData = DataFrame<Map<String, dynamic>>(
          items: <Map<String, dynamic>>[],
          totalRecords: 0,
        ),
        processLookupTableSettings =
            DatatableProcessLookupExampleSupport.buildSettings(
          digitalBadgeBuilder: _buildDigitalBadge,
        ),
        processLookupSearchFields =
            DatatableProcessLookupExampleSupport.buildSearchFields();

  final DemoI18nService i18n;

  @ViewChild('processLookupStandaloneTable')
  LiDataTableComponent? processLookupStandaloneTable;

  final Filters processLookupFilters = Filters(limit: 12, offset: 0);
  final List<int> processLookupLimitOptions = const <int>[
    1,
    5,
    12,
    24,
    48,
    50,
    100,
    200,
    300,
    500,
    1000,
    1500,
    2000,
    2500,
  ];
  final DatatableSettings processLookupTableSettings;
  final List<DatatableSearchField> processLookupSearchFields;
  final DatatablePerformanceProfile processLookupPerformanceProfile =
      DatatablePerformanceProfile.saliPaged;
  final Set<String> _favoritedProcessCodes = <String>{};

  late DataFrame<Map<String, dynamic>> processLookupTableData;

  String processLookupRequesterFilter = '';
  String processLookupDigitalFilter = '';

//   final String processLookupSnippet = '''<li-datatable
//     [dataTableFilter]="processLookupFilters"
//     [data]="processLookupTableData"
//     [settings]="processLookupTableSettings"
//     [searchInFields]="processLookupSearchFields"
//     [limitPerPageOptions]="processLookupLimitOptions"
//     [deferInitialDrawUntilData]="true"
//     [responsiveAutoHideColumns]="true"
//     [responsiveCollapse]="true"
//     [responsiveCollapseByContainer]="true"
//     [showCheckboxToSelectRow]="false">
//   <template li-datatable-header let-ctx>
//     <!-- header inspirado em uma tela de consulta de processos -->
//   </template>
//   <template li-datatable-cell="actions" let-ctx>
//     <!-- ações customizadas em HTML -->
//   </template>
//   <template li-datatable-card let-ctx>
//     <!-- card customizado para o modo grid -->
//   </template>
// </li-datatable>''';

  Messages get t => i18n.t;

  String get pageTitle => 'Datatable de Processos';

  String get pageSubtitle => 'Cenário isolado para instrumentação';

  String get breadcrumbLabel => 'Datatable Processos';

  String get demoIntro =>
      'Esta página isola apenas o layout de consulta de processos com header customizado, ações em template e card customizado, deixando os logs do li-datatable focados nesse fluxo direto no console.';

  @override
  Future<void> ngOnInit() async {
    await _loadProcessLookupTable();
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

  Future<void> _loadProcessLookupTable() async {
    processLookupStandaloneTable?.showLoading();
    try {
      var records = DatatableProcessLookupExampleSupport.buildSeedRecords();

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

      _stampProcessLookupDerivedFields(records);

      processLookupTableData =
          await DatatableDemoService(records).query(processLookupFilters);
      _stampProcessLookupDerivedFields(processLookupTableData.items);
    } finally {
      processLookupStandaloneTable?.hideLoading();
    }
  }

  void openProcessLookupItem(Map<String, dynamic> itemMap) {
    final code = itemMap['processCode']?.toString() ?? '';
    if (code.isEmpty) {
      return;
    }
  }

  void toggleProcessLookupFavorite(Map<String, dynamic> itemMap) {
    final code = itemMap['processCode']?.toString() ?? '';
    if (code.isEmpty) {
      return;
    }

    if (_favoritedProcessCodes.contains(code)) {
      _favoritedProcessCodes.remove(code);
    } else {
      _favoritedProcessCodes.add(code);
    }

    _stampProcessLookupDerivedFields(processLookupTableData.items);
    processLookupStandaloneTable?.update();
  }

  String processLookupOpenActionLabel(Map<String, dynamic> itemMap) =>
      'Abrir processo ${itemMap['processCode'] ?? ''}';

  String get processLookupFavoriteActionLabel =>
      'Alternar favorito do processo';

  void _stampProcessLookupDerivedFields(
      Iterable<Map<String, dynamic>> records) {
    for (final record in records) {
      final code = record['processCode']?.toString() ?? '';
      record['isFavorited'] =
          code.isNotEmpty && _favoritedProcessCodes.contains(code);
      record['isDigital'] = (record['digitalLabel']?.toString() ?? '') == 'Sim';
    }
  }

  static Element _buildDigitalBadge(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    final isDigital = (itemMap['digitalLabel']?.toString() ?? '') == 'Sim';
    return SpanElement()
      ..classes.addAll(<String>[
        'badge',
        'rounded-pill',
        isDigital ? 'bg-primary' : 'bg-light',
        isDigital ? 'text-white' : 'text-body',
      ])
      ..text = itemMap['digitalLabel']?.toString() ?? '';
  }
}
