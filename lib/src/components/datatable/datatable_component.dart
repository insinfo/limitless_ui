//datatable_component.dart
import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math' as math;

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';

import '../../directives/dropdown_menu_directive.dart';
import '../../directives/form_directives.dart';
import '../../directives/css_style_directive.dart';
import '../../directives/safe_html_directive.dart';
import '../popover/popover_component.dart';
import '../pagination/pagination_component.dart';
import '../loading/loading.dart';
import '../tooltip/tooltip_component.dart';
import 'datatable_col.dart';
import 'datatable_row.dart';
import 'datatable_settings.dart';
export 'datatable_models.dart';
import 'datatable_exporter.dart';
import 'datatable_models.dart';
import 'datatable_row_builder.dart';

class LiDatatableHeaderContext {
  LiDatatableHeaderContext({
    required this.search,
    required this.requestData,
    required this.selectSearchField,
    required this.changeItemsPerPage,
    required this.toggleViewMode,
    required this.toggleAllColumnsVisibility,
    required this.exportPdf,
    required this.exportXlsx,
  });

  DataFrame data = DataFrame(items: <dynamic>[], totalRecords: 0);
  List<DatatableRow> rows = <DatatableRow>[];
  List<DatatableRenderedRow> renderedRows = <DatatableRenderedRow>[];
  Filters dataTableFilter = Filters();
  DatatableSettings settings =
      DatatableSettings(colsDefinitions: <DatatableCol>[]);
  List<DatatableSearchField> searchInFields = <DatatableSearchField>[];
  List<int> limitPerPageOptions = <int>[];
  List<DatatableMenuAction> exportMenuActions = <DatatableMenuAction>[];
  String searchLabel = '';
  String searchPlaceholder = '';
  bool gridMode = false;
  bool showExportMenu = false;
  bool disableHeaderPadding = false;
  int totalRecords = 0;
  int currentPage = 1;
  int numPages = 1;
  int? selectedSearchFieldIndex;
  int? limitPerPage;
  bool allColumnsVisible = true;

  final void Function() search;
  final void Function() requestData;
  final void Function(int index) selectSearchField;
  final void Function(int value) changeItemsPerPage;
  final void Function() toggleViewMode;
  final void Function() toggleAllColumnsVisibility;
  final Future<void> Function() exportPdf;
  final Future<void> Function() exportXlsx;
}

class LiDatatableFooterContext {
  LiDatatableFooterContext({
    required this.requestData,
    required this.changePage,
    required this.nextPage,
    required this.prevPage,
    required this.goToFirstPage,
    required this.goToLastPage,
  });

  DataFrame data = DataFrame(items: <dynamic>[], totalRecords: 0);
  List<DatatableRow> rows = <DatatableRow>[];
  List<DatatableRenderedRow> renderedRows = <DatatableRenderedRow>[];
  Filters dataTableFilter = Filters();
  DatatableSettings settings =
      DatatableSettings(colsDefinitions: <DatatableCol>[]);
  int totalRecords = 0;
  int currentPage = 1;
  int numPages = 1;
  int currentTotalItems = 0;
  int pageSize = 0;
  int resolvedPaginationButtonQuantity = 0;

  final void Function() requestData;
  final void Function(int page) changePage;
  final void Function() nextPage;
  final void Function() prevPage;
  final void Function() goToFirstPage;
  final void Function() goToLastPage;
}

@Directive(selector: 'template[li-datatable-header]')
class LiDatatableHeaderDirective {
  LiDatatableHeaderDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[li-datatable-footer]')
class LiDatatableFooterDirective {
  LiDatatableFooterDirective(this.templateRef);

  final TemplateRef templateRef;
}

class LiDatatableCellContext {
  final DatatableRow row;
  final DatatableCol column;
  final Map<String, dynamic> itemMap;
  final dynamic itemInstance;
  final int rowIndex;
  final int columnIndex;

  LiDatatableCellContext({
    required this.row,
    required this.column,
    required this.itemMap,
    required this.itemInstance,
    required this.rowIndex,
    required this.columnIndex,
  });
}

class LiDatatableHeaderCellContext {
  final DatatableCol column;
  final int columnIndex;
  final bool enableSorting;
  final void Function() toggleSort;

  LiDatatableHeaderCellContext({
    required this.column,
    required this.columnIndex,
    required this.enableSorting,
    required this.toggleSort,
  });
}

class LiDatatableCardContext {
  final DatatableRow row;
  final Map<String, dynamic> itemMap;
  final dynamic itemInstance;
  final int rowIndex;
  final List<DatatableCol> bodyColumns;
  final List<DatatableCol> footerColumns;

  LiDatatableCardContext({
    required this.row,
    required this.itemMap,
    required this.itemInstance,
    required this.rowIndex,
    required this.bodyColumns,
    required this.footerColumns,
  });
}

@Directive(selector: 'template[li-datatable-cell]')
class LiDatatableCellDirective {
  LiDatatableCellDirective(this.templateRef);

  final TemplateRef templateRef;

  @Input('li-datatable-cell')
  String columnKey = '';
}

@Directive(selector: 'template[li-datatable-header-cell]')
class LiDatatableHeaderCellDirective {
  LiDatatableHeaderCellDirective(this.templateRef);

  final TemplateRef templateRef;

  @Input('li-datatable-header-cell')
  String columnKey = '';
}

@Directive(selector: 'template[li-datatable-card]')
class LiDatatableCardDirective {
  LiDatatableCardDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Component(
  selector: 'li-datatable',
  styleUrls: ['datatable_component.css', 'grid.css'],
  templateUrl: 'datatable_component.html',
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    DropdownMenuDirective,
    SafeHtmlDirective,
    CssStyleDirective,
    ...liTooltipDirectives,
    ...liPopoverDirectives,
    ...liPaginationDirectives,
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
  exports: [DatatableRowType],
)
class LiDataTableComponent implements AfterChanges, AfterViewInit, OnDestroy {
  LiDataTableComponent(this.rootElement, this._changeDetectorRef) {
    _ensureGlobalResizeListener();
    _headerTemplateContext = LiDatatableHeaderContext(
      search: onSearch,
      requestData: onRequestData,
      selectSearchField: _selectSearchFieldFromTemplate,
      changeItemsPerPage: _changeItemsPerPageFromTemplate,
      toggleViewMode: changeViewMode,
      toggleAllColumnsVisibility: toggleAllColumnsVisibility,
      exportPdf: _exportPdfFromTemplate,
      exportXlsx: _exportXlsxFromTemplate,
    );
    _footerTemplateContext = LiDatatableFooterContext(
      requestData: onRequestData,
      changePage: changePage,
      nextPage: nextPage,
      prevPage: prevPage,
      goToFirstPage: irParaPrimeiraPagina,
      goToLastPage: irParaUltimaPagina,
    );
    _syncTemplateContexts();
  }

  static final StreamController<void> _globalResizeController =
      StreamController<void>.broadcast();
  static StreamSubscription<Event>? _globalWindowResizeSubscription;

  static void _ensureGlobalResizeListener() {
    _globalWindowResizeSubscription ??= window.onResize.listen((_) {
      if (!_globalResizeController.isClosed) {
        _globalResizeController.add(null);
      }
    });
  }

  final Element rootElement;
  final ChangeDetectorRef _changeDetectorRef;
  final DatatableRowBuilder _rowBuilder = DatatableRowBuilder();
  late final LiDatatableHeaderContext _headerTemplateContext;
  late final LiDatatableFooterContext _footerTemplateContext;

  @ContentChild(LiDatatableHeaderDirective)
  LiDatatableHeaderDirective? projectedHeaderTemplateDirective;

  @ContentChild(LiDatatableFooterDirective)
  LiDatatableFooterDirective? projectedFooterTemplateDirective;

  @ContentChildren(LiDatatableCellDirective)
  List<LiDatatableCellDirective>? projectedCellTemplateDirectives;

  @ContentChildren(LiDatatableHeaderCellDirective)
  List<LiDatatableHeaderCellDirective>? projectedHeaderCellTemplateDirectives;

  @ContentChild(LiDatatableCardDirective)
  LiDatatableCardDirective? projectedCardTemplateDirective;

  @Input()
  TemplateRef? headerTemplate;

  @Input()
  TemplateRef? footerTemplate;

  @Input()
  TemplateRef? cardTemplate;

  @ViewChild('card')
  DivElement? card;

  @ViewChild('table')
  HtmlElement? table;

  @ViewChild('scrollContainer')
  HtmlElement? scrollContainer;

  @ViewChild('gridScrollContainer')
  HtmlElement? gridScrollContainer;

  final SimpleLoading _loading = SimpleLoading();
  StreamSubscription<void>? _resizeSubscription;
  Timer? _resizeDebounce;
  int? _drawAnimationFrameId;
  int? _postRenderAnimationFrameId;
  int? _responsiveAutoHideAnimationFrameId;
  int? _visualProbeFrame1Id;
  int? _visualProbeFrame2Id;
  int? _virtualScrollAnimationFrameId;
  bool _isDestroyed = false;
  bool _drawScheduled = false;
  bool _viewInitialized = false;
  int _manualRowsRevision = 0;
  int _instrumentationSequence = 0;
  int _visualProbeToken = 0;
  int _dataInputChangeCount = 0;
  int? _lastRowsSignature;
  int? _cachedTableRowsSignature;
  int? _cachedGridRowsSignature;
  List<DatatableRow>? _cachedTableRows;
  List<DatatableRow>? _cachedGridRows;
  bool _visible = true;
  final Set<int> _virtualSelectedRowKeys = <int>{};
  int _virtualStartIndex = 0;
  int _virtualEndIndex = 0;
  int _virtualTopSpacerHeight = 0;
  int _virtualBottomSpacerHeight = 0;
  bool _pendingVirtualScrollReset = false;
  String resolvedScrollContainerStyleCss = '';
  String resolvedGridScrollContainerStyleCss = '';
  final Map<String, double> _responsiveColumnWidthCache = <String, double>{};
  final Map<int, double> _fixedLeftOffsets = <int, double>{};
  final Map<int, double> _fixedRightOffsets = <int, double>{};
  final Set<String> _autoHiddenColumnKeys = <String>{};
  final Set<String> _forcedVisibleColumnKeys = <String>{};
  double _responsiveCheckboxWidthCache = 44;

  Filters _dataTableFilter = Filters();
  final StreamController<LiDatatableInstrumentationEvent>
      _instrumentationController =
      StreamController<LiDatatableInstrumentationEvent>.broadcast();

  @Input()
  set dataTableFilter(Filters filter) {
    _dataTableFilter = filter;
    _applySelectedSearchFieldToFilter();
  }

  Filters get dataTableFilter => _dataTableFilter;

  @Input()
  bool nullIsEmpty = true;

  @Input()
  bool debugInstrumentation = false;

  @Input()
  String debugInstrumentationLabel = '';

  bool _gridMode = false;

  @Input('gridMode')
  set gridMode(bool value) {
    if (_gridMode == value) {
      _emitInstrumentation(
        'gridMode.noop',
        details: <String, Object?>{
          'value': value,
          'manualRowsRevision': _manualRowsRevision,
        },
      );
      return;
    }

    _gridMode = value;
    if (virtualScroll) {
      _pendingVirtualScrollReset = true;
    }
    _emitInstrumentation(
      'gridMode.changed',
      details: <String, Object?>{
        'value': value,
        'manualRowsRevision': _manualRowsRevision,
      },
    );
    _syncHeaderTemplateContext();
    _syncGridBindingCaches();
    if (_applyCachedModeSwitchIfAvailable(reason: 'gridMode input')) {
      _scheduleModeSwitchVisualProbe('gridMode input');
      _changeDetectorRef.markForCheck();
      return;
    }
    scheduleDraw(force: true, reason: 'gridMode input');
    _scheduleModeSwitchVisualProbe('gridMode input');
    _changeDetectorRef.markForCheck();
  }

  bool get gridMode => _gridMode;

  @Input()
  bool responsiveCollapse = false;

  @Input()
  int responsiveCollapseMaxWidth = 767;

  @Input()
  bool responsiveCollapseByContainer = false;

  @Input()
  int responsiveCollapseContainerMaxWidth = 767;

  @Input()
  bool responsiveAutoHideColumns = false;

  @Input()
  bool deferInitialDrawUntilVisible = false;

  @Input()
  bool deferInitialDrawUntilData = false;

  @Input()
  bool virtualScroll = false;

  @Input()
  bool stickyTableHeaderOnVirtualScroll = false;

  @Input()
  int virtualRowHeight = 44;

  @Input()
  int virtualOverscan = 10;

  @Input()
  String virtualViewportHeight = '70vh';

  @Input()
  int virtualGridItemHeight = 260;

  @Input()
  int virtualGridMinItemWidth = 280;

  @Input()
  set visible(bool value) {
    if (_visible == value) {
      return;
    }

    _visible = value;
    if (_visible) {
      if (virtualScroll) {
        _pendingVirtualScrollReset = true;
      }
      scheduleDraw(force: true, reason: 'visible input');
    }
  }

  bool get visible => _visible;

  @Input()
  bool disableSearchEvent = false;

  @Input()
  bool disableHeaderPadding = false;

  @Input()
  bool disableRowClick = false;

  @Input()
  bool showExportMenu = true;

  @Input()
  DatatableExportPdfCallback? onExportPdf;

  @Input()
  DatatableExportXlsxCallback? onExportXlsx;

  @Input()
  List<DatatableMenuAction> exportMenuActions = [];

  @Input()
  bool showCheckboxToSelectRow = true;

  @Input()
  bool allowSingleSelectionOnly = false;

  @Input()
  bool enableGlobalSorting = true;

  @Input()
  bool enableMultiColumnSorting = false;

  @Input('searchLabel')
  String searchLabel = 'Busca';

  @Input('searchPlaceholder')
  String searchPlaceholder = 'Digite para buscar';

  @Input()
  String searchButtonTitle = 'Clique para buscar';

  @Input()
  String exportMenuButtonTitle = 'Exportar para PDF/Excel';

  @Input()
  String exportPdfLabel = 'Exportar para PDF';

  @Input()
  String exportXlsxLabel = 'Exportar para Excel';

  @Input()
  String toggleViewModeButtonTitle = 'Modo lista ou grade';

  @Input()
  String toggleColumnsButtonTitle = 'Clique para exibir ou ocultar uma coluna';

  @Input()
  String totalRecordsLabel = 'Total:';

  @Input('limitPerPageOptions')
  List<int> limitPerPageOptions = [1, 5, 10, 12, 20, 24, 25];

  List<DatatableSearchField> _searchInFields = <DatatableSearchField>[];

  @Input('searchInFields')
  set searchInFields(List<DatatableSearchField> fields) {
    _searchInFields = fields;
    _applySelectedSearchFieldToFilter();
  }

  List<DatatableSearchField> get searchInFields => _searchInFields;

  TemplateRef? get resolvedHeaderTemplate =>
      headerTemplate ?? projectedHeaderTemplateDirective?.templateRef;

  bool get hasCustomHeader => resolvedHeaderTemplate != null;

  LiDatatableHeaderContext get headerTemplateContext => _headerTemplateContext;

  TemplateRef? get resolvedFooterTemplate =>
      footerTemplate ?? projectedFooterTemplateDirective?.templateRef;

  bool get hasCustomFooter => resolvedFooterTemplate != null;

  LiDatatableFooterContext get footerTemplateContext => _footerTemplateContext;

  TemplateRef? get resolvedCardTemplate =>
      cardTemplate ?? projectedCardTemplateDirective?.templateRef;

  bool get hasCustomCardTemplate => resolvedCardTemplate != null;

  int? get selectedSearchFieldIndex {
    if (_searchInFields.isEmpty) {
      return null;
    }

    _ensureSelectedSearchField();
    final index = _searchInFields.indexWhere((field) => field.selected);
    return index < 0 ? null : index;
  }

  void _ensureSelectedSearchField() {
    if (_searchInFields.isEmpty) {
      return;
    }

    if (!_searchInFields.any((field) => field.selected)) {
      _searchInFields.first.select();
    }
  }

  DatatableSearchField? get _selectedSearchField {
    if (_searchInFields.isEmpty) {
      return null;
    }

    _ensureSelectedSearchField();
    return _searchInFields.firstWhere((field) => field.selected);
  }

  void _applySelectedSearchFieldToFilter() {
    final selectedSearchField = _selectedSearchField;
    if (selectedSearchField == null) {
      dataTableFilter.searchInFields = <FilterSearchField>[];
      return;
    }

    dataTableFilter.searchInFields = <FilterSearchField>[
      FilterSearchField(
        active: true,
        field: selectedSearchField.field,
        operator: selectedSearchField.operator,
        label: selectedSearchField.label,
      ),
    ];
  }

  void _selectSearchFieldByIndex(int index) {
    if (index < 0 || index >= _searchInFields.length) {
      return;
    }

    for (var i = 0; i < _searchInFields.length; i++) {
      _searchInFields[i].selected = i == index;
    }

    _applySelectedSearchFieldToFilter();
  }

  DatatableSettings _settings =
      DatatableSettings(colsDefinitions: <DatatableCol>[]);

  String resolvedGridContainerClass = 'grid-container';
  String resolvedGridContainerStyleCss = '';
  String resolvedGridLayoutStyleCss = '';

  @Input('settings')
  set settings(DatatableSettings value) {
    _settings = value;
    _resetResponsiveMeasurementCache();
    final validKeys = _settings.colsDefinitions
        .map((column) => column.key)
        .where((key) => key.trim().isNotEmpty)
        .toSet();
    _forcedVisibleColumnKeys.removeWhere((key) => !validKeys.contains(key));
    _rowBuilder.applyComputedColumnMetadataToSettings(_settings);
    _syncGridBindingCaches();
    _manualRowsRevision++;
    _emitInstrumentation(
      'settings.changed',
      details: <String, Object?>{
        'columns': _settings.colsDefinitions.length,
        'manualRowsRevision': _manualRowsRevision,
      },
    );
    scheduleDraw(force: true, reason: 'settings input');
  }

  DatatableSettings get settings => _settings;

  DataFrame _data = DataFrame(items: <dynamic>[], totalRecords: 0);

  @Input('data')
  set data(DataFrame value) {
    _data = value;
    _dataInputChangeCount++;
    if (virtualScroll) {
      _pendingVirtualScrollReset = true;
    }
    _resetResponsiveMeasurementCache();
    totalRecords = _data.totalRecords;
    isLoading = false;
    _syncCurrentPageFromOffset();
    _manualRowsRevision++;
    _emitInstrumentation(
      'data.changed',
      details: <String, Object?>{
        'items': _data.items.length,
        'totalRecords': _data.totalRecords,
        'manualRowsRevision': _manualRowsRevision,
      },
    );
    scheduleDraw(force: true, reason: 'data input');
  }

  DataFrame get data => _data;

  List<DatatableRow> rows = <DatatableRow>[];
  List<DatatableRenderedRow> renderedRows = <DatatableRenderedRow>[];
  final Map<DatatableRenderedRow, Map<DatatableCol, LiDatatableCellContext>>
      _cellTemplateContextCache = HashMap<DatatableRenderedRow,
          Map<DatatableCol, LiDatatableCellContext>>.identity();
  final Map<DatatableCol, LiDatatableHeaderCellContext>
      _headerCellTemplateContextCache =
      HashMap<DatatableCol, LiDatatableHeaderCellContext>.identity();
  final Map<DatatableRow, LiDatatableCardContext> _cardTemplateContextCache =
      HashMap<DatatableRow, LiDatatableCardContext>.identity();

  InputElement? get inputSearchElement =>
      rootElement.querySelector('.data-table-search-field') as InputElement?;

  void setInputSearchFocus() {
    inputSearchElement?.focus();
  }

  void showLoading() {
    _loading.show(target: card);
  }

  void hideLoading() {
    _loading.hide();
  }

  int get getCurrentTotalItems {
    if (totalRecords <= 0) {
      return 0;
    }

    final limit = dataTableFilter.limit ?? 0;
    final offset = dataTableFilter.offset ?? 0;
    final total = offset + limit;
    return total > totalRecords ? totalRecords : total;
  }

  @override
  void ngAfterViewInit() {
    _viewInitialized = true;

    _resizeSubscription = _globalResizeController.stream.listen((_) {
      _resizeDebounce?.cancel();
      _resizeDebounce = Timer(const Duration(milliseconds: 120), () {
        if (_isDestroyed) {
          return;
        }
        _handleViewportChange();
      });
    });

    drawPagination();
    _syncTemplateContexts();
    if (_canDrawNow) {
      _schedulePostRenderSync();
      scheduleDraw(reason: 'ngAfterViewInit');
    }
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngAfterChanges() {
    _syncCurrentPageFromOffset();
    drawPagination();
    _syncTemplateContexts();
    if (_canDrawNow) {
      _schedulePostRenderSync();
      scheduleDraw(reason: 'ngAfterChanges');
    }
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngOnDestroy() {
    _isDestroyed = true;
    _resizeDebounce?.cancel();
    _resizeSubscription?.cancel();
    if (_drawAnimationFrameId != null) {
      window.cancelAnimationFrame(_drawAnimationFrameId!);
      _drawAnimationFrameId = null;
    }
    if (_postRenderAnimationFrameId != null) {
      window.cancelAnimationFrame(_postRenderAnimationFrameId!);
      _postRenderAnimationFrameId = null;
    }
    if (_responsiveAutoHideAnimationFrameId != null) {
      window.cancelAnimationFrame(_responsiveAutoHideAnimationFrameId!);
      _responsiveAutoHideAnimationFrameId = null;
    }
    if (_visualProbeFrame1Id != null) {
      window.cancelAnimationFrame(_visualProbeFrame1Id!);
      _visualProbeFrame1Id = null;
    }
    if (_visualProbeFrame2Id != null) {
      window.cancelAnimationFrame(_visualProbeFrame2Id!);
      _visualProbeFrame2Id = null;
    }
    if (_virtualScrollAnimationFrameId != null) {
      window.cancelAnimationFrame(_virtualScrollAnimationFrameId!);
      _virtualScrollAnimationFrameId = null;
    }
    _dataRequest.close();
    _limitChangeRequest.close();
    _searchRequest.close();
    _onRowClickStreamController.close();
    _selectAllStreamController.close();
    _selectStreamController.close();
    _instrumentationController.close();
  }

  void update() {
    _manualRowsRevision++;
    _emitInstrumentation(
      'update.called',
      details: <String, Object?>{
        'manualRowsRevision': _manualRowsRevision,
        'items': _data.items.length,
      },
    );
    scheduleDraw(force: true, reason: 'update()');
  }

  bool get _canDrawNow {
    if (_isDestroyed) {
      return false;
    }
    if (deferInitialDrawUntilVisible && !_visible) {
      return false;
    }
    if (_shouldDeferInitialDataDraw) {
      return false;
    }
    return true;
  }

  bool get _shouldDeferInitialDataDraw {
    return deferInitialDrawUntilData &&
        _dataInputChangeCount <= 1 &&
        _data.items.isEmpty &&
        _data.totalRecords <= 0;
  }

  bool get showTableView => !gridMode;

  bool get showGridView => gridMode;

  bool get isTableVirtualScrollActive {
    return virtualScroll &&
        !gridMode &&
        !settings.enableGrouping &&
        !_isResponsiveCollapseActive &&
        _autoHiddenColumnKeys.isEmpty;
  }

  bool get isGridVirtualScrollActive {
    return virtualScroll && gridMode && !settings.enableGrouping;
  }

  bool get isVirtualScrollActive =>
      isTableVirtualScrollActive || isGridVirtualScrollActive;

  bool get isStickyTableHeaderOnVirtualScrollActive {
    return isTableVirtualScrollActive && stickyTableHeaderOnVirtualScroll;
  }

  int get virtualSpacerColspan {
    final visibleColumnCount = settings.colsDefinitions
        .where(
          (column) => column.visibility && !isRuntimeResponsiveHidden(column),
        )
        .length;
    return visibleColumnCount + (showCheckboxToSelectRow ? 1 : 0);
  }

  int get virtualTopSpacerHeight => _virtualTopSpacerHeight;

  int get virtualBottomSpacerHeight => _virtualBottomSpacerHeight;

  HtmlElement? get _activeVirtualScrollContainer =>
      gridMode ? gridScrollContainer : scrollContainer;

  void onVirtualViewportScroll() {
    if (!isVirtualScrollActive || _isDestroyed) {
      return;
    }
    _scheduleVirtualScrollSync();
  }

  void _scheduleVirtualScrollSync() {
    if (_virtualScrollAnimationFrameId != null) {
      return;
    }

    _virtualScrollAnimationFrameId = window.requestAnimationFrame((_) {
      _virtualScrollAnimationFrameId = null;
      if (_isDestroyed || !isVirtualScrollActive) {
        return;
      }

      final windowChanged = _syncVirtualWindow();
      if (!windowChanged) {
        return;
      }

      draw(reason: 'virtual scroll');
    });
  }

  int _resolveVirtualViewportHeightPx() {
    final normalized = virtualViewportHeight.trim().toLowerCase();
    if (normalized.endsWith('px')) {
      return int.tryParse(normalized.replaceAll('px', '').trim()) ?? 0;
    }

    if (normalized.endsWith('vh')) {
      final value = double.tryParse(normalized.replaceAll('vh', '').trim());
      final innerHeight = window.innerHeight;
      if (value == null || innerHeight == null) {
        return 0;
      }
      return ((innerHeight * value) / 100).round();
    }

    return int.tryParse(normalized) ?? 0;
  }

  int _resolveVirtualGridMinItemWidthPx() {
    final configured = math.max(1, virtualGridMinItemWidth);
    final templateColumns = settings.gridTemplateColumns.trim().toLowerCase();
    final minmaxMatch = RegExp(r'minmax\(([^,]+),').firstMatch(templateColumns);
    final parsed = _parseCssLength(minmaxMatch?.group(1));
    if (parsed == null || parsed <= 0) {
      return configured;
    }

    return math.max(1, parsed.round());
  }

  int _resolveVirtualGridColumnCount() {
    final containerWidth =
        (_activeVirtualScrollContainer?.clientWidth ?? rootElement.clientWidth)
            .toDouble();
    if (containerWidth <= 0) {
      return 1;
    }

    final minItemWidth = _resolveVirtualGridMinItemWidthPx().toDouble();
    final gapWidth = _parseCssLength(settings.gridGap) ?? 20.0;
    final columnCount =
        ((containerWidth + gapWidth) / (minItemWidth + gapWidth)).floor();
    return math.max(1, columnCount);
  }

  bool _isVirtualViewportPinnedToEnd({
    required HtmlElement? scrollContainer,
    required int fallbackItemExtent,
    required int totalExtentUnits,
    required int viewportHeight,
  }) {
    if (scrollContainer == null) {
      final maxScrollTop = math.max(
        0,
        (totalExtentUnits * fallbackItemExtent) - viewportHeight,
      );
      return maxScrollTop <= 0;
    }

    final scrollTop = scrollContainer.scrollTop.toDouble();
    final measuredMaxScrollTop = math.max(
      0,
      scrollContainer.scrollHeight - scrollContainer.clientHeight,
    ).toDouble();
    final fallbackMaxScrollTop = math.max(
      0,
      (totalExtentUnits * fallbackItemExtent) - viewportHeight,
    ).toDouble();
    final resolvedMaxScrollTop = measuredMaxScrollTop > 0
        ? measuredMaxScrollTop
        : fallbackMaxScrollTop;
    final tolerance = math.max(2.0, fallbackItemExtent / 4);
    return resolvedMaxScrollTop <= 0 ||
        scrollTop >= (resolvedMaxScrollTop - tolerance);
  }

  bool _syncVirtualWindow() {
    final totalItems = _data.items.length;
    if (!isVirtualScrollActive) {
      final changed = _virtualStartIndex != 0 ||
          _virtualEndIndex != totalItems ||
          _virtualTopSpacerHeight != 0 ||
          _virtualBottomSpacerHeight != 0;
      _virtualStartIndex = 0;
      _virtualEndIndex = totalItems;
      _virtualTopSpacerHeight = 0;
      _virtualBottomSpacerHeight = 0;
      return changed;
    }

    final resolvedOverscan = math.max(0, virtualOverscan);
    final activeScrollContainer = _activeVirtualScrollContainer;

    if (_pendingVirtualScrollReset) {
      activeScrollContainer?.scrollTop = 0;
      _pendingVirtualScrollReset = false;
    }

    var viewportHeight = activeScrollContainer?.clientHeight ?? 0;
    final configuredViewportHeight = _resolveVirtualViewportHeightPx();
    if (viewportHeight <= 0) {
      viewportHeight = configuredViewportHeight;
    } else if (configuredViewportHeight > 0) {
      viewportHeight = math.min(viewportHeight, configuredViewportHeight);
    }
    final scrollTop = activeScrollContainer?.scrollTop ?? 0;

    late final int startIndex;
    late final int endIndex;
    late final int topSpacerHeight;
    late final int bottomSpacerHeight;

    if (isGridVirtualScrollActive) {
      final resolvedItemHeight = math.max(1, virtualGridItemHeight);
      if (viewportHeight <= 0) {
        viewportHeight = resolvedItemHeight * 4;
      }

      final columnsPerRow = _resolveVirtualGridColumnCount();
      final visibleRowCount = math.max(
        1,
        (viewportHeight / resolvedItemHeight).ceil(),
      );
      final totalGridRows =
          columnsPerRow <= 0 ? 0 : (totalItems / columnsPerRow).ceil();

      if (_isVirtualViewportPinnedToEnd(
        scrollContainer: activeScrollContainer,
        fallbackItemExtent: resolvedItemHeight,
        totalExtentUnits: totalGridRows,
        viewportHeight: viewportHeight,
      )) {
        final pinnedStartRow = math.max(
          0,
          totalGridRows - visibleRowCount - resolvedOverscan,
        );
        startIndex = math.min(totalItems, pinnedStartRow * columnsPerRow);
        endIndex = totalItems;
        topSpacerHeight = pinnedStartRow * resolvedItemHeight;
        bottomSpacerHeight = 0;
      } else {
        final firstVisibleRow = scrollTop ~/ resolvedItemHeight;
        final startRow = math.max(0, firstVisibleRow - resolvedOverscan);
        final endRow = firstVisibleRow + visibleRowCount + resolvedOverscan;

        startIndex = math.min(totalItems, startRow * columnsPerRow);
        endIndex = math.min(totalItems, endRow * columnsPerRow);
        topSpacerHeight = startRow * resolvedItemHeight;
        final renderedRowsCount = columnsPerRow <= 0
            ? 0
            : ((math.max(0, totalItems - endIndex)) / columnsPerRow).ceil();
        bottomSpacerHeight =
            math.max(0, renderedRowsCount * resolvedItemHeight);
      }
    } else {
      final resolvedRowHeight = math.max(1, virtualRowHeight);
      if (viewportHeight <= 0) {
        viewportHeight = resolvedRowHeight * 10;
      }

      final visibleCount = math.max(
        1,
        (viewportHeight / resolvedRowHeight).ceil(),
      );

      if (_isVirtualViewportPinnedToEnd(
        scrollContainer: activeScrollContainer,
        fallbackItemExtent: resolvedRowHeight,
        totalExtentUnits: totalItems,
        viewportHeight: viewportHeight,
      )) {
        final pinnedWindowSize = math.max(1, visibleCount + resolvedOverscan);
        startIndex = math.max(0, totalItems - pinnedWindowSize);
        endIndex = totalItems;
        topSpacerHeight = startIndex * resolvedRowHeight;
        bottomSpacerHeight = 0;
      } else {
        final firstVisibleIndex = scrollTop ~/ resolvedRowHeight;

        startIndex = math.max(0, firstVisibleIndex - resolvedOverscan);
        endIndex = math.min(
          totalItems,
          firstVisibleIndex + visibleCount + resolvedOverscan,
        );
        topSpacerHeight = startIndex * resolvedRowHeight;
        bottomSpacerHeight = math.max(
          0,
          (totalItems - endIndex) * resolvedRowHeight,
        );
      }
    }

    final changed = _virtualStartIndex != startIndex ||
        _virtualEndIndex != endIndex ||
        _virtualTopSpacerHeight != topSpacerHeight ||
        _virtualBottomSpacerHeight != bottomSpacerHeight;

    _virtualStartIndex = startIndex;
    _virtualEndIndex = endIndex;
    _virtualTopSpacerHeight = topSpacerHeight;
    _virtualBottomSpacerHeight = bottomSpacerHeight;
    return changed;
  }

  DataFrame _resolvedBuildData() {
    if (!isVirtualScrollActive) {
      return _data;
    }

    final startIndex = math.min(_virtualStartIndex, _data.items.length);
    final endIndex = math.min(_virtualEndIndex, _data.items.length);
    final items = endIndex <= startIndex
        ? <dynamic>[]
        : _data.items.sublist(startIndex, endIndex);

    return DataFrame(items: items, totalRecords: _data.totalRecords);
  }

  int get _resolvedRowBuildOffset =>
      isVirtualScrollActive ? _virtualStartIndex : 0;

  int _selectionKeyForItem(dynamic instance, {required int index}) {
    return Object.hash(instance?.hashCode, index);
  }

  int _selectionKeyForRow(DatatableRow row) {
    return _selectionKeyForItem(row.instance, index: row.index);
  }

  void _applyVirtualSelectionState(List<DatatableRow> rowsToSync) {
    if (!virtualScroll) {
      return;
    }

    for (final row in rowsToSync) {
      if (row.type != DatatableRowType.normal) {
        continue;
      }
      row.selected = _virtualSelectedRowKeys.contains(_selectionKeyForRow(row));
    }
  }

  List<dynamic> _collectVirtualSelectedInstances() {
    final selected = <dynamic>[];
    for (var index = 0; index < _data.items.length; index++) {
      final instance = _data.items[index];
      if (_virtualSelectedRowKeys.contains(
        _selectionKeyForItem(instance, index: index),
      )) {
        selected.add(instance);
      }
    }
    return selected;
  }

  @Output()
  Stream<LiDatatableInstrumentationEvent> get instrumentation =>
      _instrumentationController.stream;

  void scheduleDraw({bool force = false, String reason = 'unspecified'}) {
    if (!_canDrawNow) {
      _emitInstrumentation(
        'scheduleDraw.skipped',
        details: <String, Object?>{
          'reason': reason,
          'force': force,
          'visible': _visible,
          'deferInitialDrawUntilData': deferInitialDrawUntilData,
          'dataInputChangeCount': _dataInputChangeCount,
        },
      );
      return;
    }

    if (_drawScheduled && !force) {
      _emitInstrumentation(
        'scheduleDraw.coalesced',
        details: <String, Object?>{
          'reason': reason,
          'force': force,
        },
      );
      return;
    }

    var canceledPreviousFrame = false;
    if (_drawAnimationFrameId != null) {
      window.cancelAnimationFrame(_drawAnimationFrameId!);
      _drawAnimationFrameId = null;
      canceledPreviousFrame = true;
    }

    _emitInstrumentation(
      'scheduleDraw.queued',
      details: <String, Object?>{
        'reason': reason,
        'force': force,
        'canceledPreviousFrame': canceledPreviousFrame,
        'items': _data.items.length,
        'gridMode': gridMode,
      },
    );

    _drawScheduled = true;
    _drawAnimationFrameId = window.requestAnimationFrame((_) {
      _drawAnimationFrameId = null;
      _drawScheduled = false;
      if (_isDestroyed || !_canDrawNow) {
        _emitInstrumentation(
          'scheduleDraw.frameSkipped',
          details: <String, Object?>{
            'reason': reason,
            'isDestroyed': _isDestroyed,
            'visible': _visible,
          },
        );
        return;
      }
      draw(reason: 'raf:$reason');
    });
  }

  String get _resolvedInstrumentationLabel {
    final normalized = debugInstrumentationLabel.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }

    final elementId = rootElement.id.trim();
    if (elementId.isNotEmpty) {
      return elementId;
    }

    return 'datatable';
  }

  void _emitInstrumentation(
    String stage, {
    int? elapsedMicroseconds,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    if (!debugInstrumentation) {
      return;
    }

    final event = LiDatatableInstrumentationEvent(
      label: _resolvedInstrumentationLabel,
      stage: stage,
      timestamp: DateTime.now(),
      elapsedMicroseconds: elapsedMicroseconds,
      details: <String, Object?>{
        'seq': ++_instrumentationSequence,
        ...details,
      },
    );

    if (!_instrumentationController.isClosed) {
      _instrumentationController.add(event);
    }

    window.console.log(
      '[li-datatable:${event.label}] ${event.formattedMessage}',
    );
  }

  int _countHtmlBackedCells(List<DatatableRow> rowsToInspect) {
    var count = 0;
    for (final row in rowsToInspect) {
      for (final column in row.columns) {
        if (column.htmlElement != null) {
          count++;
        }
      }
    }
    return count;
  }

  int _countHiddenResponsiveColumns(List<DatatableRenderedRow> views) {
    var count = 0;
    for (final view in views) {
      count += view.responsiveHiddenColumns.length;
    }
    return count;
  }

  Map<String, Object?> _collectVisibleDomStats() {
    final tableElement = table;
    final tableScrollContainer = scrollContainer;
    final gridScrollViewport = gridScrollContainer;
    final gridLayout = rootElement.querySelector('.grid-layout');
    final visibleBodyRows =
        tableElement?.querySelectorAll('tbody > tr').length ?? 0;
    final visibleBodyCells =
        tableElement?.querySelectorAll('tbody td').length ?? 0;
    final gridItems = gridLayout == null
        ? 0
        : gridLayout.children
            .where((child) => child.classes.contains('grid-item'))
            .length;
    final actionButtons = rootElement
        .querySelectorAll(
            '.datatable-action-cell button, [data-label="datatable"] .btn-icon')
        .length;

    return <String, Object?>{
      'tableVisible': tableElement != null && showTableView,
      'gridVisible': gridLayout != null,
      'tbodyRows': visibleBodyRows,
      'tbodyCells': visibleBodyCells,
      'gridItems': gridItems,
      'actionButtons': actionButtons,
      'tableDomPresent': tableElement != null,
      'gridDomPresent': gridLayout != null,
      'tableHiddenClass': false,
      'tableViewportPresent': tableScrollContainer != null,
      'gridViewportPresent': gridScrollViewport != null,
      'virtualScroll': isVirtualScrollActive,
      'virtualStartIndex': _virtualStartIndex,
      'virtualEndIndex': _virtualEndIndex,
    };
  }

  void _scheduleModeSwitchVisualProbe(String reason) {
    if (!debugInstrumentation || _isDestroyed) {
      return;
    }

    final token = ++_visualProbeToken;
    final stopwatch = Stopwatch()..start();

    if (_visualProbeFrame1Id != null) {
      window.cancelAnimationFrame(_visualProbeFrame1Id!);
      _visualProbeFrame1Id = null;
    }
    if (_visualProbeFrame2Id != null) {
      window.cancelAnimationFrame(_visualProbeFrame2Id!);
      _visualProbeFrame2Id = null;
    }

    _emitInstrumentation(
      'modeSwitch.visualProbeQueued',
      details: <String, Object?>{
        'reason': reason,
        'gridMode': gridMode,
        'token': token,
      },
    );

    _visualProbeFrame1Id = window.requestAnimationFrame((_) {
      _visualProbeFrame1Id = null;
      if (_isDestroyed || token != _visualProbeToken) {
        return;
      }

      _emitInstrumentation(
        'modeSwitch.visualFrame1',
        elapsedMicroseconds: stopwatch.elapsedMicroseconds,
        details: <String, Object?>{
          'reason': reason,
          'token': token,
          ..._collectVisibleDomStats(),
        },
      );

      _visualProbeFrame2Id = window.requestAnimationFrame((_) {
        _visualProbeFrame2Id = null;
        if (_isDestroyed || token != _visualProbeToken) {
          return;
        }

        stopwatch.stop();
        _emitInstrumentation(
          'modeSwitch.visualFrame2',
          elapsedMicroseconds: stopwatch.elapsedMicroseconds,
          details: <String, Object?>{
            'reason': reason,
            'token': token,
            ..._collectVisibleDomStats(),
          },
        );
      });
    });
  }

  int _computeRowsSignature() {
    return Object.hash(
      _data,
      _data.totalRecords,
      _data.items.length,
      _settings,
      _settings.colsDefinitions.length,
      nullIsEmpty,
      gridMode,
      responsiveCollapse,
      responsiveCollapseMaxWidth,
      responsiveCollapseByContainer,
      responsiveCollapseContainerMaxWidth,
      responsiveAutoHideColumns,
      isVirtualScrollActive,
      isGridVirtualScrollActive,
      _virtualStartIndex,
      _virtualEndIndex,
      virtualGridItemHeight,
      virtualGridMinItemWidth,
      _manualRowsRevision,
    );
  }

  int _computeRowBuildSignature() {
    return Object.hash(
      _data,
      _data.totalRecords,
      _data.items.length,
      _settings,
      _settings.colsDefinitions.length,
      nullIsEmpty,
      isVirtualScrollActive,
      isGridVirtualScrollActive,
      _virtualStartIndex,
      _virtualEndIndex,
      virtualGridItemHeight,
      virtualGridMinItemWidth,
      _manualRowsRevision,
    );
  }

  List<DatatableRow>? _resolveCachedRowsForMode(
    bool targetGridMode,
    int buildSignature,
  ) {
    if (targetGridMode) {
      if (_cachedGridRowsSignature == buildSignature) {
        return _cachedGridRows;
      }
      return null;
    }

    if (_cachedTableRowsSignature == buildSignature) {
      return _cachedTableRows;
    }

    return null;
  }

  List<DatatableRow>? _resolveCachedRowsForCurrentMode(int buildSignature) {
    return _resolveCachedRowsForMode(gridMode, buildSignature);
  }

  void _cacheRowsForCurrentMode(int buildSignature, List<DatatableRow> rows) {
    if (gridMode) {
      _cachedGridRowsSignature = buildSignature;
      _cachedGridRows = rows;
      return;
    }

    _cachedTableRowsSignature = buildSignature;
    _cachedTableRows = rows;
  }

  bool _applyCachedModeSwitchIfAvailable({required String reason}) {
    _syncVirtualWindow();
    resolvedScrollContainerStyleCss = isTableVirtualScrollActive
        ? 'max-height: $virtualViewportHeight; overflow-y: auto;'
        : '';
    resolvedGridScrollContainerStyleCss = isGridVirtualScrollActive
        ? 'max-height: $virtualViewportHeight; overflow-y: auto;'
        : '';

    final buildSignature = _computeRowBuildSignature();
    final cachedRows = _resolveCachedRowsForMode(_gridMode, buildSignature);
    if (cachedRows == null) {
      _emitInstrumentation(
        'modeSwitch.cacheMiss',
        details: <String, Object?>{
          'reason': reason,
          'gridMode': _gridMode,
          'buildSignature': buildSignature,
        },
      );
      return false;
    }

    rows = cachedRows;
    renderedRows = _rebuildRenderedRows(
      reason: 'modeSwitch:$reason',
      rowsToRender: rows,
    );
    _lastRowsSignature = _computeRowsSignature();
    drawPagination();
    _syncTemplateContexts();
    _syncFixedColumnOffsets();
    _schedulePostRenderSync();
    _emitInstrumentation(
      'modeSwitch.cacheHit',
      details: <String, Object?>{
        'reason': reason,
        'gridMode': _gridMode,
        'rows': rows.length,
        'renderedRows': renderedRows.length,
      },
    );
    return true;
  }

  DatatableRowBuildResult _buildRows({required String reason}) {
    if (!debugInstrumentation) {
      return _rowBuilder.build(
        data: _resolvedBuildData(),
        settings: settings,
        nullIsEmpty: nullIsEmpty,
        gridMode: gridMode,
        responsiveCollapse: responsiveCollapse,
        responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
        rowIndexOffset: _resolvedRowBuildOffset,
        responsiveCollapseActive: _isResponsiveCollapseActive,
        autoHiddenColumnKeys: _autoHiddenColumnKeys,
      );
    }

    final stopwatch = Stopwatch()..start();
    final result = _rowBuilder.build(
      data: _resolvedBuildData(),
      settings: settings,
      nullIsEmpty: nullIsEmpty,
      gridMode: gridMode,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      rowIndexOffset: _resolvedRowBuildOffset,
      responsiveCollapseActive: _isResponsiveCollapseActive,
      autoHiddenColumnKeys: _autoHiddenColumnKeys,
    );
    stopwatch.stop();

    _emitInstrumentation(
      'draw.buildRows',
      elapsedMicroseconds: stopwatch.elapsedMicroseconds,
      details: <String, Object?>{
        'reason': reason,
        'items': _data.items.length,
        'windowItems': _resolvedBuildData().items.length,
        'rows': result.rows.length,
        'renderedRows': result.renderedRows.length,
        'htmlCells': _countHtmlBackedCells(result.rows),
        'gridMode': gridMode,
      },
    );

    return result;
  }

  List<DatatableRenderedRow> _rebuildRenderedRows({
    required String reason,
    required List<DatatableRow> rowsToRender,
  }) {
    if (!debugInstrumentation) {
      return _rowBuilder.rebuildRenderedRows(
        rows: rowsToRender,
        responsiveCollapse: responsiveCollapse,
        responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
        responsiveCollapseActive: _isResponsiveCollapseActive,
        responsiveControlColumnKey: settings.responsiveControlColumnKey,
        autoHiddenColumnKeys: _autoHiddenColumnKeys,
      );
    }

    final stopwatch = Stopwatch()..start();
    final result = _rowBuilder.rebuildRenderedRows(
      rows: rowsToRender,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      responsiveCollapseActive: _isResponsiveCollapseActive,
      responsiveControlColumnKey: settings.responsiveControlColumnKey,
      autoHiddenColumnKeys: _autoHiddenColumnKeys,
    );
    stopwatch.stop();

    _emitInstrumentation(
      'draw.rebuildRenderedRows',
      elapsedMicroseconds: stopwatch.elapsedMicroseconds,
      details: <String, Object?>{
        'reason': reason,
        'rows': rowsToRender.length,
        'renderedRows': result.length,
        'hiddenColumns': _countHiddenResponsiveColumns(result),
        'autoHiddenColumns': _autoHiddenColumnKeys.length,
        'gridMode': gridMode,
      },
    );

    return result;
  }

  void draw({String reason = 'manual'}) {
    final totalStopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    _syncVirtualWindow();
    resolvedScrollContainerStyleCss = isTableVirtualScrollActive
        ? 'max-height: $virtualViewportHeight; overflow-y: auto;'
        : '';
    resolvedGridScrollContainerStyleCss = isGridVirtualScrollActive
        ? 'max-height: $virtualViewportHeight; overflow-y: auto;'
        : '';
    final signature = _computeRowsSignature();

    _emitInstrumentation(
      'draw.start',
      details: <String, Object?>{
        'reason': reason,
        'signature': signature,
        'lastSignature': _lastRowsSignature,
        'items': _data.items.length,
        'gridMode': gridMode,
        'manualRowsRevision': _manualRowsRevision,
      },
    );

    if (_lastRowsSignature == signature) {
      renderedRows = _rebuildRenderedRows(
        reason: '$reason:signature-match',
        rowsToRender: rows,
      );
      drawPagination();
      _syncTemplateContexts();
      _syncFixedColumnOffsets();
      _schedulePostRenderSync();
      _changeDetectorRef.markForCheck();
      totalStopwatch?.stop();
      _emitInstrumentation(
        'draw.finish',
        elapsedMicroseconds: totalStopwatch?.elapsedMicroseconds,
        details: <String, Object?>{
          'reason': reason,
          'path': 'signature-match',
          'rows': rows.length,
          'renderedRows': renderedRows.length,
        },
      );
      return;
    }

    rows = <DatatableRow>[];
    renderedRows = <DatatableRenderedRow>[];

    if (settings.colsDefinitions.isEmpty) {
      _lastRowsSignature = signature;
      drawPagination();
      _syncTemplateContexts();
      _syncFixedColumnOffsets();
      _schedulePostRenderSync();
      _changeDetectorRef.markForCheck();
      totalStopwatch?.stop();
      _emitInstrumentation(
        'draw.finish',
        elapsedMicroseconds: totalStopwatch?.elapsedMicroseconds,
        details: <String, Object?>{
          'reason': reason,
          'path': 'empty-columns',
        },
      );
      return;
    }

    final buildSignature = _computeRowBuildSignature();
    final cachedRows = _resolveCachedRowsForCurrentMode(buildSignature);
    if (cachedRows != null) {
      rows = cachedRows;
      _applyVirtualSelectionState(rows);
      renderedRows = _rebuildRenderedRows(
        reason: '$reason:rows-cache-hit',
        rowsToRender: rows,
      );

      _lastRowsSignature = signature;
      drawPagination();
      _syncTemplateContexts();
      _syncFixedColumnOffsets();
      _schedulePostRenderSync();
      _changeDetectorRef.markForCheck();
      totalStopwatch?.stop();
      _emitInstrumentation(
        'draw.finish',
        elapsedMicroseconds: totalStopwatch?.elapsedMicroseconds,
        details: <String, Object?>{
          'reason': reason,
          'path': 'rows-cache-hit',
          'rows': rows.length,
          'renderedRows': renderedRows.length,
        },
      );
      return;
    }

    final buildResult = _buildRows(reason: reason);
    rows = buildResult.rows;
    _applyVirtualSelectionState(rows);
    renderedRows = buildResult.renderedRows;
    _cacheRowsForCurrentMode(buildSignature, rows);

    _lastRowsSignature = signature;
    drawPagination();
    _syncTemplateContexts();
    _syncFixedColumnOffsets();
    _schedulePostRenderSync();

    _changeDetectorRef.markForCheck();
    totalStopwatch?.stop();
    _emitInstrumentation(
      'draw.finish',
      elapsedMicroseconds: totalStopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'reason': reason,
        'path': 'build',
        'rows': rows.length,
        'renderedRows': renderedRows.length,
        'htmlCells': _countHtmlBackedCells(rows),
      },
    );
  }

  void _handleViewportChange() {
    if (isVirtualScrollActive) {
      scheduleDraw(force: true, reason: 'viewport change');
      return;
    }

    _syncResponsiveColumnWidthCache();

    final autoHideChanged = _syncResponsiveAutoHideNow();

    if (!_isResponsiveCollapseActive && _autoHiddenColumnKeys.isEmpty) {
      for (final row in rows) {
        row.isExpanded = false;
      }
    }

    if (autoHideChanged) {
      return;
    }

    renderedRows = _rebuildRenderedRows(
      reason: 'viewport change',
      rowsToRender: rows,
    );
    _syncTemplateContexts();
    _syncFixedColumnOffsets();
    _schedulePostRenderSync();
    _changeDetectorRef.markForCheck();
  }

  void _schedulePostRenderSync() {
    if (!_viewInitialized || _isDestroyed) {
      _emitInstrumentation(
        'postRenderSync.skipped',
        details: <String, Object?>{
          'viewInitialized': _viewInitialized,
          'isDestroyed': _isDestroyed,
        },
      );
      return;
    }

    var canceledPreviousFrame = false;
    if (_postRenderAnimationFrameId != null) {
      window.cancelAnimationFrame(_postRenderAnimationFrameId!);
      _postRenderAnimationFrameId = null;
      canceledPreviousFrame = true;
    }

    _emitInstrumentation(
      'postRenderSync.queued',
      details: <String, Object?>{
        'canceledPreviousFrame': canceledPreviousFrame,
        'rows': rows.length,
        'renderedRows': renderedRows.length,
      },
    );

    _postRenderAnimationFrameId = window.requestAnimationFrame((_) {
      _postRenderAnimationFrameId = null;
      if (_isDestroyed) {
        _emitInstrumentation('postRenderSync.frameSkipped');
        return;
      }
      final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
      _syncSortingIndicators();
      _syncResponsiveColumnWidthCache();
      _syncFixedColumnOffsets();
      _scheduleResponsiveAutoHideSync();
      _changeDetectorRef.markForCheck();
      stopwatch?.stop();
      _emitInstrumentation(
        'postRenderSync.frame',
        elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
        details: <String, Object?>{
          'rows': rows.length,
          'renderedRows': renderedRows.length,
        },
      );
    });
  }

  int totalRecords = 0;
  int _currentPage = 1;

  int get getCurrentPage => _currentPage;

  int get numPages {
    final limit = dataTableFilter.limit ?? 1;
    if (limit <= 0) {
      return 1;
    }

    final totalPages = (totalRecords / limit).ceil();
    return totalPages <= 0 ? 1 : totalPages;
  }

  @Input()
  int paginationButtonQuantity = 5;

  @Input()
  int compactPaginationButtonQuantity = 2;

  @Input()
  int compactPaginationMaxWidth = 767;

  /// When enabled, changing the page size emits [dataRequest] and recalculates
  /// the offset like a regular page navigation instead of only emitting
  /// [limitChange].
  @Input()
  bool requestDataOnItemsPerPageChange = false;

  bool get isCompactPaginationViewport =>
      window.innerWidth != null &&
      window.innerWidth! <= compactPaginationMaxWidth;

  int get resolvedPaginationButtonQuantity => isCompactPaginationViewport
      ? compactPaginationButtonQuantity
      : paginationButtonQuantity;

  void _syncCurrentPageFromOffset() {
    final resolvedLimit = dataTableFilter.limit ?? 1;
    final resolvedOffset = dataTableFilter.offset ?? 0;
    if (resolvedLimit <= 0) {
      _currentPage = 1;
      return;
    }

    final currentPage = (resolvedOffset ~/ resolvedLimit) + 1;
    _currentPage = currentPage <= 0 ? 1 : currentPage;
  }

  void drawPagination() {
    _syncFooterTemplateContext();
    _changeDetectorRef.markForCheck();
  }

  void prevPage() {
    if (_currentPage > 1) {
      _currentPage--;
      changePage(_currentPage);
    }
  }

  void nextPage() {
    if (_currentPage < numPages) {
      _currentPage++;
      changePage(_currentPage);
    }
  }

  void changePage(int page) {
    if (page != _currentPage) {
      _currentPage = page;
    }
    _syncTemplateContexts();
    onRequestData();
    _changeDetectorRef.markForCheck();
  }

  void irParaUltimaPagina() {
    final lastPage = numPages;
    _currentPage = lastPage;
    changePage(lastPage);
  }

  void irParaPrimeiraPagina() {
    _currentPage = 1;
    changePage(1);
  }

  final _dataRequest = StreamController<Filters>();

  @Output()
  Stream<Filters> get dataRequest => _dataRequest.stream;

  bool isLoading = true;

  void onRequestData() {
    isLoading = true;
    final currentPage = _currentPage == 1 ? 0 : _currentPage - 1;
    dataTableFilter.offset = currentPage * (dataTableFilter.limit ?? 0);
    _settings.setOrdemStartIndex(dataTableFilter.offset ?? 0);
    _syncTemplateContexts();
    _dataRequest.add(dataTableFilter);
    _changeDetectorRef.markForCheck();
  }

  final _limitChangeRequest = StreamController<Filters>();

  @Output()
  Stream<Filters> get limitChange => _limitChangeRequest.stream;

  void changeItemsPerPageHandler(SelectElement select) {
    final li = int.tryParse(select.selectedOptions.first.value);
    _changeItemsPerPage(li);
  }

  void _changeItemsPerPage(int? limit) {
    if (limit == null) {
      return;
    }

    _currentPage = 1;
    dataTableFilter.limit = limit;
    if (requestDataOnItemsPerPageChange) {
      onRequestData();
    } else {
      _syncTemplateContexts();
      _limitChangeRequest.add(dataTableFilter);
    }
    _changeDetectorRef.markForCheck();
  }

  final _searchRequest = StreamController<Filters>();

  @Output()
  Stream<Filters> get searchRequest => _searchRequest.stream;

  void onSearch() {
    _currentPage = 1;
    _syncTemplateContexts();
    _searchRequest.add(dataTableFilter);
    _changeDetectorRef.markForCheck();
    onRequestData();
  }

  void handleSearchInputKeypress(dynamic e) {
    if (disableSearchEvent != true) {
      e.stopPropagation();
      if (e.keyCode == KeyCode.ENTER) {
        onSearch();
      }
    }
  }

  void handleSearchFieldSelectChange(dynamic event, String? index) {
    if (index == null) {
      return;
    }

    final parsedIndex = int.tryParse(index);
    if (parsedIndex == null) {
      return;
    }

    _selectSearchFieldByIndex(parsedIndex);
    _syncTemplateContexts();
    _changeDetectorRef.markForCheck();
  }

  final _onRowClickStreamController = StreamController<dynamic>();

  @Output()
  Stream<dynamic> get onRowClick => _onRowClickStreamController.stream;

  void rowClickHandler(DatatableRow row) {
    if (disableRowClick) {
      return;
    }
    if (_onRowClickStreamController.isClosed) {
      return;
    }
    if (row.type == DatatableRowType.normal) {
      _onRowClickStreamController.add(row.instance);
    }
  }

  final _selectAllStreamController = StreamController<List<dynamic>>();
  final _selectStreamController = StreamController<dynamic>();

  @Output()
  Stream<List<dynamic>> get selectAll => _selectAllStreamController.stream;

  @Output()
  Stream<dynamic> get select => _selectStreamController.stream;

  bool isSelectAll = false;

  Iterable<DatatableRow> get _selectableRows =>
      rows.where((row) => row.type == DatatableRowType.normal);

  List<T> getAllSelected<T>() {
    if (virtualScroll) {
      return _collectVirtualSelectedInstances().cast<T>();
    }

    return _selectableRows
        .where((row) => row.selected)
        .map<T>((row) => row.instance as T)
        .toList();
  }

  void onSelectAll(Event event) {
    if (allowSingleSelectionOnly) {
      event.preventDefault();
      return;
    }

    final checkbox = event.target as InputElement;
    isSelectAll = checkbox.checked ?? false;

    if (virtualScroll) {
      _virtualSelectedRowKeys.clear();
      if (isSelectAll) {
        for (var index = 0; index < _data.items.length; index++) {
          _virtualSelectedRowKeys.add(
            _selectionKeyForItem(_data.items[index], index: index),
          );
        }
      }
    }

    for (final row in _selectableRows) {
      row.selected = isSelectAll;
    }

    _emitSelectedRows();
    _changeDetectorRef.markForCheck();
  }

  void unSelectAll() {
    _virtualSelectedRowKeys.clear();
    for (final row in _selectableRows) {
      row.selected = false;
    }
    isSelectAll = false;
    _changeDetectorRef.markForCheck();
  }

  void syncSelection(bool Function(dynamic instance) predicate) {
    final selectableRows = _selectableRows.toList(growable: false);

    if (virtualScroll) {
      _virtualSelectedRowKeys.clear();
      for (var index = 0; index < _data.items.length; index++) {
        final instance = _data.items[index];
        if (predicate(instance)) {
          _virtualSelectedRowKeys.add(
            _selectionKeyForItem(instance, index: index),
          );
        }
      }
    }

    for (final row in selectableRows) {
      row.selected = predicate(row.instance);
    }

    isSelectAll = selectableRows.isNotEmpty &&
        selectableRows.every((row) => row.selected);
    _changeDetectorRef.markForCheck();
  }

  void unSelectItemInstance(dynamic item) {
    if (virtualScroll) {
      for (var index = 0; index < _data.items.length; index++) {
        if (_data.items[index] == item) {
          _virtualSelectedRowKeys.remove(
            _selectionKeyForItem(item, index: index),
          );
        }
      }
    }

    for (final row in rows) {
      if (row.instance == item) {
        row.selected = false;
      }
    }
    _changeDetectorRef.markForCheck();
  }

  void onSelect(MouseEvent event, DatatableRow item) {
    event.stopPropagation();
    if (item.type != DatatableRowType.normal) {
      return;
    }

    final intendedSelectionState = !item.selected;

    if (allowSingleSelectionOnly) {
      if (intendedSelectionState) {
        if (virtualScroll) {
          _virtualSelectedRowKeys
            ..clear()
            ..add(_selectionKeyForRow(item));
        }
        for (final row in _selectableRows) {
          if (!identical(row, item)) {
            row.selected = false;
          }
        }
        item.selected = true;
        isSelectAll = false;
        _selectStreamController.add(item.instance);
      } else {
        if (virtualScroll) {
          _virtualSelectedRowKeys.remove(_selectionKeyForRow(item));
        }
        item.selected = false;
      }
    } else {
      item.selected = intendedSelectionState;
      if (item.selected) {
        if (virtualScroll) {
          _virtualSelectedRowKeys.add(_selectionKeyForRow(item));
        }
        _selectStreamController.add(item.instance);
        final selectableRows = _selectableRows.toList(growable: false);
        isSelectAll = selectableRows.isNotEmpty &&
            selectableRows.every((row) => row.selected);
      } else {
        if (virtualScroll) {
          _virtualSelectedRowKeys.remove(_selectionKeyForRow(item));
        }
        isSelectAll = false;
      }
    }

    _emitSelectedRows();
    _changeDetectorRef.markForCheck();
  }

  void _emitSelectedRows() {
    if (virtualScroll) {
      _selectAllStreamController.add(_collectVirtualSelectedInstances());
      return;
    }

    _selectAllStreamController.add(
      _selectableRows
          .where((row) => row.selected)
          .map((row) => row.instance)
          .toList(),
    );
  }

  void onOrder(DatatableCol colDefinition) {
    if (!enableGlobalSorting) {
      return;
    }

    final sortingBy = colDefinition.sortingBy;
    if (colDefinition.enableSorting != true || sortingBy == null) {
      return;
    }

    final nextDirection = _nextSortDirection(
      sortingBy,
      colDefinition.defaultSortDirection,
    );

    if (enableMultiColumnSorting) {
      final orderFields = _resolvedOrderFields().toList(growable: true);
      final existingIndex =
          orderFields.indexWhere((field) => field.field == sortingBy);
      if (existingIndex >= 0) {
        orderFields[existingIndex] = FilterOrderField(
          field: sortingBy,
          direction: nextDirection,
        );
      } else {
        orderFields.add(
          FilterOrderField(
            field: sortingBy,
            direction: colDefinition.defaultSortDirection,
          ),
        );
      }
      dataTableFilter.orderFields = orderFields;
    } else {
      dataTableFilter.orderBy = sortingBy;
      dataTableFilter.orderDir = nextDirection;
      dataTableFilter.orderFields = <FilterOrderField>[];
    }

    _syncSortingIndicators();
    onRequestData();
    _changeDetectorRef.markForCheck();
  }

  List<FilterOrderField> _resolvedOrderFields() {
    if (enableMultiColumnSorting && dataTableFilter.orderFields.isNotEmpty) {
      return List<FilterOrderField>.from(dataTableFilter.orderFields);
    }

    final orderBy = dataTableFilter.orderBy;
    if (orderBy == null || orderBy.trim().isEmpty) {
      return <FilterOrderField>[];
    }

    return <FilterOrderField>[
      FilterOrderField(
        field: orderBy,
        direction: dataTableFilter.orderDir ?? 'desc',
      ),
    ];
  }

  String _nextSortDirection(String sortingBy, String defaultSortDirection) {
    for (final orderField in _resolvedOrderFields()) {
      if (orderField.field == sortingBy) {
        return orderField.direction == 'asc' ? 'desc' : 'asc';
      }
    }

    return defaultSortDirection;
  }

  void _syncSortingIndicators() {
    final headerElements = table?.querySelectorAll('th[data-sort-key]');
    if (headerElements == null) {
      return;
    }

    final orderFields = _resolvedOrderFields();
    for (final element in headerElements) {
      if (element is! HtmlElement) {
        continue;
      }

      element.classes.removeAll(<String>['sorting_asc', 'sorting_desc']);
      final sortKey = element.getAttribute('data-sort-key');
      if (sortKey == null || sortKey.isEmpty) {
        element.attributes.remove('title');
        continue;
      }

      FilterOrderField? currentOrder;
      var sortIndex = 0;
      for (final orderField in orderFields) {
        if (orderField.field == sortKey) {
          currentOrder = orderField;
          break;
        }
        sortIndex++;
      }

      if (currentOrder == null) {
        element.attributes.remove('title');
        continue;
      }

      element.classes.add(
        currentOrder.direction == 'asc' ? 'sorting_asc' : 'sorting_desc',
      );
      if (enableMultiColumnSorting && orderFields.length > 1) {
        final title = element.text?.trim() ?? '';
        element.title = '$title (${sortIndex + 1}o criterio)';
      } else {
        element.attributes.remove('title');
      }
    }
  }

  void changeVisibilityOfCol(DatatableCol col) {
    final shouldShowColumn = !isColumnEffectivelyVisible(col);
    final columnKey = col.key.trim();

    col.visibility = shouldShowColumn;
    col.visibilityOnCard = shouldShowColumn;

    if (columnKey.isNotEmpty) {
      if (shouldShowColumn) {
        _forcedVisibleColumnKeys.add(columnKey);
      } else {
        _forcedVisibleColumnKeys.remove(columnKey);
      }
    }

    for (final row in rows) {
      for (final column in row.columns) {
        if (column.key == col.key) {
          column.visibility = col.visibility;
          column.visibilityOnCard = col.visibilityOnCard;
        }
      }
    }

    _syncResponsiveAutoHideNow();

    renderedRows = _rebuildRenderedRows(
      reason: 'change column visibility:${col.key}',
      rowsToRender: rows,
    );
    _syncTemplateContexts();
    _syncFixedColumnOffsets();
    _schedulePostRenderSync();
    _changeDetectorRef.markForCheck();
  }

  bool get allColumnsVisible =>
      settings.colsDefinitions.every(isColumnEffectivelyVisible);

  void toggleAllColumnsVisibility() {
    final newVisibility = !allColumnsVisible;
    for (final col in settings.colsDefinitions) {
      col.visibility = newVisibility;
      col.visibilityOnCard = newVisibility;
      final columnKey = col.key.trim();
      if (columnKey.isEmpty) {
        continue;
      }

      if (newVisibility) {
        _forcedVisibleColumnKeys.add(columnKey);
      } else {
        _forcedVisibleColumnKeys.remove(columnKey);
      }
    }

    for (final row in rows) {
      for (final column in row.columns) {
        column.visibility = newVisibility;
        column.visibilityOnCard = newVisibility;
      }
    }

    _syncResponsiveAutoHideNow();

    renderedRows = _rebuildRenderedRows(
      reason: 'toggle all columns visibility',
      rowsToRender: rows,
    );
    _syncTemplateContexts();
    _syncFixedColumnOffsets();
    _schedulePostRenderSync();
    _changeDetectorRef.markForCheck();
  }

  void _syncTemplateContexts() {
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    _syncHeaderTemplateContext();
    _syncFooterTemplateContext();
    _syncGridBindingCaches();
    _syncProjectedTemplateContextCaches();
    stopwatch?.stop();
    _emitInstrumentation(
      'syncTemplateContexts',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'rows': rows.length,
        'renderedRows': renderedRows.length,
      },
    );
  }

  void _syncGridBindingCaches() {
    final customClass = _settings.gridContainerClass?.trim();
    resolvedGridContainerClass = customClass == null || customClass.isEmpty
        ? 'grid-container'
        : 'grid-container $customClass';

    resolvedGridContainerStyleCss = _settings.gridContainerStyle?.trim() ?? '';

    final gridStyleParts = <String>[];
    final gridTemplateColumns = _settings.gridTemplateColumns.trim();
    if (gridTemplateColumns.isNotEmpty) {
      gridStyleParts.add('grid-template-columns: $gridTemplateColumns');
    }

    final gridGap = _settings.gridGap.trim();
    if (gridGap.isNotEmpty) {
      gridStyleParts.add('gap: $gridGap');
    }

    resolvedGridLayoutStyleCss =
        gridStyleParts.isEmpty ? '' : '${gridStyleParts.join('; ')};';
  }

  void _syncProjectedTemplateContextCaches() {
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    if (showTableView) {
      _syncHeaderCellTemplateContexts();
      _syncCellTemplateContexts();
    } else {
      _headerCellTemplateContextCache.clear();
      _cellTemplateContextCache.clear();
    }

    if (showGridView && hasCustomCardTemplate) {
      _syncCardTemplateContexts();
    } else {
      _cardTemplateContextCache.clear();
    }
    stopwatch?.stop();
    _emitInstrumentation(
      'syncProjectedTemplateContextCaches',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'headerContexts': _headerCellTemplateContextCache.length,
        'cellContextRows': _cellTemplateContextCache.length,
        'cardContexts': _cardTemplateContextCache.length,
      },
    );
  }

  void _syncHeaderTemplateContext() {
    _headerTemplateContext
      ..data = _data
      ..rows = rows
      ..renderedRows = renderedRows
      ..dataTableFilter = dataTableFilter
      ..settings = settings
      ..searchInFields = _searchInFields
      ..limitPerPageOptions = limitPerPageOptions
      ..exportMenuActions = exportMenuActions
      ..searchLabel = searchLabel
      ..searchPlaceholder = searchPlaceholder
      ..gridMode = gridMode
      ..showExportMenu = showExportMenu
      ..disableHeaderPadding = disableHeaderPadding
      ..totalRecords = totalRecords
      ..currentPage = _currentPage
      ..numPages = numPages
      ..selectedSearchFieldIndex = selectedSearchFieldIndex
      ..limitPerPage = dataTableFilter.limit
      ..allColumnsVisible = allColumnsVisible;
  }

  void _syncFooterTemplateContext() {
    _footerTemplateContext
      ..data = _data
      ..rows = rows
      ..renderedRows = renderedRows
      ..dataTableFilter = dataTableFilter
      ..settings = settings
      ..totalRecords = totalRecords
      ..currentPage = _currentPage
      ..numPages = numPages
      ..currentTotalItems = getCurrentTotalItems
      ..pageSize = dataTableFilter.limit ?? 0
      ..resolvedPaginationButtonQuantity = resolvedPaginationButtonQuantity;
  }

  void _syncHeaderCellTemplateContexts() {
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    _headerCellTemplateContextCache.clear();

    final visibleColumns = settings.visibleColumns;
    for (var columnIndex = 0;
        columnIndex < visibleColumns.length;
        columnIndex++) {
      final column = visibleColumns[columnIndex];
      _headerCellTemplateContextCache[column] = LiDatatableHeaderCellContext(
        column: column,
        columnIndex: columnIndex,
        enableSorting: column.enableSorting,
        toggleSort: () => onOrder(column),
      );
    }

    stopwatch?.stop();
    _emitInstrumentation(
      'syncHeaderCellTemplateContexts',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'visibleColumns': visibleColumns.length,
      },
    );
  }

  void _syncCellTemplateContexts() {
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    _cellTemplateContextCache.clear();

    var totalColumnContexts = 0;

    for (var rowIndex = 0; rowIndex < renderedRows.length; rowIndex++) {
      final view = renderedRows[rowIndex];
      final columnContexts =
          HashMap<DatatableCol, LiDatatableCellContext>.identity();

      for (var columnIndex = 0;
          columnIndex < view.row.columns.length;
          columnIndex++) {
        final column = view.row.columns[columnIndex];
        columnContexts[column] = LiDatatableCellContext(
          row: view.row,
          column: column,
          itemMap: view.row.itemMap ?? const <String, dynamic>{},
          itemInstance: view.row.instance,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
        totalColumnContexts++;
      }

      _cellTemplateContextCache[view] = columnContexts;
    }

    stopwatch?.stop();
    _emitInstrumentation(
      'syncCellTemplateContexts',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'renderedRows': renderedRows.length,
        'cellContexts': totalColumnContexts,
      },
    );
  }

  void _syncCardTemplateContexts() {
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    _cardTemplateContextCache.clear();

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      _cardTemplateContextCache[row] = LiDatatableCardContext(
        row: row,
        itemMap: row.itemMap ?? const <String, dynamic>{},
        itemInstance: row.instance,
        rowIndex: rowIndex,
        bodyColumns: row.columnsCardBody,
        footerColumns: row.columnsCardFooter,
      );
    }

    stopwatch?.stop();
    _emitInstrumentation(
      'syncCardTemplateContexts',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'rows': rows.length,
      },
    );
  }

  void _selectSearchFieldFromTemplate(int index) {
    _selectSearchFieldByIndex(index);
    _syncTemplateContexts();
    _changeDetectorRef.markForCheck();
  }

  void _changeItemsPerPageFromTemplate(int value) {
    _changeItemsPerPage(value);
  }

  Future<void> _exportPdfFromTemplate() {
    return exportPdf();
  }

  Future<void> _exportXlsxFromTemplate() {
    return exportXlsx();
  }

  Object? trackByRenderedRow(int index, dynamic item) {
    if (item is! DatatableRenderedRow) {
      return index;
    }

    final instance = item.row.instance;
    return Object.hash(
      item.row.type.index,
      instance == null ? -1 : instance.hashCode,
      item.row.index,
    );
  }

  Object? trackByColumnKey(int index, dynamic column) {
    if (column is! DatatableCol) {
      return index;
    }

    if (column.key.trim().isNotEmpty) {
      return column.key;
    }

    return Object.hash(column.title, column.type.index, index);
  }

  Object? trackByRow(int index, dynamic item) {
    if (item is! DatatableRow) {
      return index;
    }

    final instance = item.instance;
    return Object.hash(
      item.type.index,
      instance == null ? -1 : instance.hashCode,
      item.index,
    );
  }

  bool hasResponsiveHiddenColumns(DatatableRow row) {
    return _rowBuilder
        .rebuildRenderedRows(
          rows: <DatatableRow>[row],
          responsiveCollapse: responsiveCollapse,
          responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
          responsiveCollapseActive: _isResponsiveCollapseActive,
          responsiveControlColumnKey: settings.responsiveControlColumnKey,
          autoHiddenColumnKeys: _autoHiddenColumnKeys,
        )
        .first
        .hasResponsiveHiddenColumns;
  }

  Iterable<DatatableCol> responsiveHiddenColumns(DatatableRow row) {
    return _rowBuilder
        .rebuildRenderedRows(
          rows: <DatatableRow>[row],
          responsiveCollapse: responsiveCollapse,
          responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
          responsiveCollapseActive: _isResponsiveCollapseActive,
          responsiveControlColumnKey: settings.responsiveControlColumnKey,
          autoHiddenColumnKeys: _autoHiddenColumnKeys,
        )
        .first
        .responsiveHiddenColumns;
  }

  bool hasCellTemplateFor(DatatableCol column) {
    return _resolveCellTemplate(column) != null;
  }

  TemplateRef? resolveCellTemplateFor(DatatableCol column) {
    return _resolveCellTemplate(column);
  }

  LiDatatableCellContext resolveCellTemplateContext(
    DatatableRenderedRow view,
    DatatableCol column,
    int rowIndex,
    int columnIndex,
  ) {
    final cachedContext = _cellTemplateContextCache[view]?[column];
    if (cachedContext != null) {
      return cachedContext;
    }

    return LiDatatableCellContext(
      row: view.row,
      column: column,
      itemMap: view.row.itemMap ?? const <String, dynamic>{},
      itemInstance: view.row.instance,
      rowIndex: rowIndex,
      columnIndex: columnIndex,
    );
  }

  bool hasHeaderCellTemplateFor(DatatableCol column) {
    return _resolveHeaderCellTemplate(column) != null;
  }

  TemplateRef? resolveHeaderCellTemplateFor(DatatableCol column) {
    return _resolveHeaderCellTemplate(column);
  }

  LiDatatableHeaderCellContext resolveHeaderCellTemplateContext(
    DatatableCol column,
    int columnIndex,
  ) {
    final cachedContext = _headerCellTemplateContextCache[column];
    if (cachedContext != null) {
      return cachedContext;
    }

    return LiDatatableHeaderCellContext(
      column: column,
      columnIndex: columnIndex,
      enableSorting: column.enableSorting,
      toggleSort: () => onOrder(column),
    );
  }

  LiDatatableCardContext resolveCardTemplateContext(
    DatatableRow row,
    int rowIndex,
  ) {
    final cachedContext = _cardTemplateContextCache[row];
    if (cachedContext != null) {
      return cachedContext;
    }

    return LiDatatableCardContext(
      row: row,
      itemMap: row.itemMap ?? const <String, dynamic>{},
      itemInstance: row.instance,
      rowIndex: rowIndex,
      bodyColumns: row.columnsCardBody,
      footerColumns: row.columnsCardFooter,
    );
  }

  bool hasRenderedTitleHtml(DatatableCol column) {
    return column.titleHtmlElement != null;
  }

  String resolveRenderedTitle(DatatableCol column) {
    return column.renderedTitle;
  }

  bool hasTitleTooltip(DatatableCol column) {
    return column.titleTooltip != null;
  }

  bool isTitleTooltipInline(DatatableCol column) {
    return column.titleTooltip?.displayMode ==
        DatatableTitleTooltipDisplayMode.title;
  }

  bool useNativeTitleTooltip(DatatableCol column) {
    return column.titleTooltip?.useNativeTitle ?? false;
  }

  bool hasTitlePopover(DatatableCol column) {
    return column.titlePopover != null;
  }

  Object? resolveTitleTooltipText(DatatableCol column) {
    return column.titleTooltip?.text;
  }

  String resolveTitleTooltipPlacement(DatatableCol column) {
    return column.titleTooltip?.placement ?? 'top';
  }

  String resolveTitleTooltipTrigger(DatatableCol column) {
    return column.titleTooltip?.trigger ?? 'hover focus';
  }

  bool resolveTitleTooltipAllowHtml(DatatableCol column) {
    return column.titleTooltip?.allowHtml ?? false;
  }

  String? resolveTitleTooltipClass(DatatableCol column) {
    return column.titleTooltip?.tooltipClass;
  }

  String? resolveTitleTooltipContainer(DatatableCol column) {
    return column.titleTooltip?.container;
  }

  int resolveTitleTooltipOpenDelay(DatatableCol column) {
    return column.titleTooltip?.openDelay ?? 0;
  }

  int resolveTitleTooltipCloseDelay(DatatableCol column) {
    return column.titleTooltip?.closeDelay ?? 0;
  }

  String resolveTitleTooltipIconClass(DatatableCol column) {
    return column.titleTooltip?.iconClass ?? 'ph ph-info';
  }

  String resolveTitleTooltipButtonClass(DatatableCol column) {
    return column.titleTooltip?.buttonClass ??
        'btn btn-link btn-icon p-0 border-0 bg-transparent datatable-title-help-button';
  }

  String resolveTitleTooltipAriaLabel(DatatableCol column) {
    return column.titleTooltip?.ariaLabel ?? 'Ajuda da coluna ${column.title}';
  }

  String? resolveNativeTitleTooltipText(DatatableCol column) {
    if (!useNativeTitleTooltip(column)) {
      return null;
    }

    final text = column.titleTooltip?.text;
    return text?.toString();
  }

  Object? resolveTitlePopoverBody(DatatableCol column) {
    return column.titlePopover?.body;
  }

  Object? resolveTitlePopoverTitle(DatatableCol column) {
    return column.titlePopover?.title;
  }

  String resolveTitlePopoverPlacement(DatatableCol column) {
    return column.titlePopover?.placement ?? 'top';
  }

  String resolveTitlePopoverTrigger(DatatableCol column) {
    return column.titlePopover?.trigger ?? 'click';
  }

  bool resolveTitlePopoverAllowHtml(DatatableCol column) {
    return column.titlePopover?.allowHtml ?? false;
  }

  String? resolveTitlePopoverClass(DatatableCol column) {
    return column.titlePopover?.popoverClass;
  }

  String? resolveTitlePopoverContainer(DatatableCol column) {
    return column.titlePopover?.container;
  }

  Object resolveTitlePopoverAutoClose(DatatableCol column) {
    return column.titlePopover?.autoClose ?? 'outside';
  }

  int resolveTitlePopoverOpenDelay(DatatableCol column) {
    return column.titlePopover?.openDelay ?? 0;
  }

  int resolveTitlePopoverCloseDelay(DatatableCol column) {
    return column.titlePopover?.closeDelay ?? 0;
  }

  String resolveTitlePopoverIconClass(DatatableCol column) {
    return column.titlePopover?.iconClass ?? 'ph ph-question';
  }

  String resolveTitlePopoverButtonClass(DatatableCol column) {
    return column.titlePopover?.buttonClass ??
        'btn btn-link btn-icon p-0 border-0 bg-transparent datatable-title-help-button';
  }

  String resolveTitlePopoverAriaLabel(DatatableCol column) {
    return column.titlePopover?.ariaLabel ??
        'Mais informações da coluna ${column.title}';
  }

  void onHeaderCellClick(MouseEvent event, DatatableCol colDefinition) {
    final target = event.target;
    if (target is Element &&
        target.closest('.datatable-header-help-control') != null) {
      return;
    }

    onOrder(colDefinition);
  }

  TemplateRef? _resolveCellTemplate(DatatableCol column) {
    final columnKey = column.key.trim();
    if (columnKey.isEmpty) {
      return null;
    }

    final directives = projectedCellTemplateDirectives;
    if (directives == null || directives.isEmpty) {
      return null;
    }

    for (final directive in directives) {
      if (directive.columnKey.trim() == columnKey) {
        return directive.templateRef;
      }
    }

    return null;
  }

  TemplateRef? _resolveHeaderCellTemplate(DatatableCol column) {
    final columnKey = column.key.trim();
    if (columnKey.isEmpty) {
      return null;
    }

    final directives = projectedHeaderCellTemplateDirectives;
    if (directives == null || directives.isEmpty) {
      return null;
    }

    for (final directive in directives) {
      if (directive.columnKey.trim() == columnKey) {
        return directive.templateRef;
      }
    }

    return null;
  }

  bool get _isResponsiveCollapseViewportActive =>
      window.innerWidth != null &&
      window.innerWidth! <= responsiveCollapseMaxWidth &&
      responsiveCollapse;

  bool get _isResponsiveCollapseContainerActive {
    if (!responsiveCollapse || !responsiveCollapseByContainer) {
      return false;
    }

    final availableWidth = _resolveResponsiveAvailableWidth();
    return availableWidth > 0 &&
        availableWidth <= responsiveCollapseContainerMaxWidth;
  }

  bool get _isResponsiveCollapseActive =>
      _isResponsiveCollapseViewportActive ||
      _isResponsiveCollapseContainerActive;

  bool get hasResponsiveCollapsedColumns =>
      _isResponsiveCollapseActive || _autoHiddenColumnKeys.isNotEmpty;

  bool isFixedColumn(DatatableCol column) {
    return column.fixedPosition != null && isColumnEffectivelyVisible(column);
  }

  bool isLeftFixedColumn(DatatableCol column) {
    return column.fixedPosition == DatatableFixedColumnPosition.left &&
        isFixedColumn(column);
  }

  bool isRightFixedColumn(DatatableCol column) {
    return column.fixedPosition == DatatableFixedColumnPosition.right &&
        isFixedColumn(column);
  }

  String resolvedHeaderStyleCss(DatatableCol column, int index) {
    return _mergeCssDeclarations(
          column.headerStyleCss,
          _fixedColumnStyleCss(column, index),
        ) ??
        '';
  }

  String resolvedCellStyleCss(DatatableCol column, int index) {
    return _mergeCssDeclarations(
          column.styleCss,
          _fixedColumnStyleCss(column, index),
        ) ??
        '';
  }

  bool isColumnEffectivelyVisible(DatatableCol column) {
    return column.visibility && !isRuntimeResponsiveHidden(column);
  }

  bool isRuntimeResponsiveHidden(DatatableCol column) {
    if (_isColumnForcedVisible(column)) {
      return false;
    }

    final hiddenOnMobile = _isResponsiveCollapseActive && column.hideOnMobile;
    final hiddenByPriority = _autoHiddenColumnKeys.contains(column.key);
    return hiddenOnMobile || hiddenByPriority;
  }

  bool _isColumnForcedVisible(DatatableCol column) {
    final columnKey = column.key.trim();
    if (columnKey.isEmpty) {
      return false;
    }

    return _forcedVisibleColumnKeys.contains(columnKey);
  }

  bool isResponsiveControlColumn(
      DatatableRenderedRow view, DatatableCol column) {
    if (!view.hasResponsiveHiddenColumns) {
      return false;
    }

    return view.responsiveControlColumnKey == column.key;
  }

  void onResponsiveControlClick(MouseEvent event, dynamic viewOrRow) {
    event.stopPropagation();
    final DatatableRenderedRow view;
    if (viewOrRow is DatatableRenderedRow) {
      view = viewOrRow;
    } else if (viewOrRow is DatatableRow) {
      view = _rowBuilder.rebuildRenderedRows(
        rows: <DatatableRow>[viewOrRow],
        responsiveCollapse: responsiveCollapse,
        responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
        responsiveCollapseActive: _isResponsiveCollapseActive,
        responsiveControlColumnKey: settings.responsiveControlColumnKey,
        autoHiddenColumnKeys: _autoHiddenColumnKeys,
      ).first;
    } else {
      return;
    }

    if (!view.hasResponsiveHiddenColumns) {
      rowClickHandler(view.row);
      return;
    }

    view.row.toggleExpanded();
    _changeDetectorRef.markForCheck();
  }

  void changeViewMode() {
    _gridMode = !_gridMode;
    if (virtualScroll) {
      _pendingVirtualScrollReset = true;
    }
    _emitInstrumentation(
      'changeViewMode',
      details: <String, Object?>{
        'gridMode': _gridMode,
        'rows': rows.length,
        'renderedRows': renderedRows.length,
      },
    );
    _syncHeaderTemplateContext();
    _syncGridBindingCaches();
    if (_applyCachedModeSwitchIfAvailable(reason: 'changeViewMode()')) {
      _scheduleModeSwitchVisualProbe('changeViewMode()');
      _changeDetectorRef.markForCheck();
      return;
    }
    scheduleDraw(force: true, reason: 'changeViewMode()');
    _scheduleModeSwitchVisualProbe('changeViewMode()');
    _changeDetectorRef.markForCheck();
  }

  Future<void> exportXlsx() async {
    if (onExportXlsx != null) {
      await onExportXlsx!(rows, settings.exportColumns);
      return;
    }
    DatatableExporter.exportXlsx(
      settings: settings,
      rows: rows,
      card: card,
    );
  }

  Future<void> exportPdf([bool isPrint = false, bool isDownload = true]) async {
    if (onExportPdf != null) {
      await onExportPdf!(rows, settings.visibleExportColumns);
      return;
    }
    await DatatableExporter.exportPdf(
      settings: settings,
      rows: rows,
      card: card,
      isPrint: isPrint,
      isDownload: isDownload,
    );
  }

  int removeItem(dynamic element) {
    final idx = _data.removeItem(element);
    if (idx >= 0 && idx < rows.length) {
      rows.removeAt(idx);
    }
    _manualRowsRevision++;
    _emitInstrumentation(
      'removeItem',
      details: <String, Object?>{
        'index': idx,
        'manualRowsRevision': _manualRowsRevision,
        'rows': rows.length,
      },
    );
    renderedRows = _rebuildRenderedRows(
      reason: 'removeItem',
      rowsToRender: rows,
    );
    _syncTemplateContexts();
    _syncFixedColumnOffsets();
    _changeDetectorRef.markForCheck();
    return idx;
  }

  void _syncResponsiveColumnWidthCache() {
    final tableElement = table;
    if (tableElement == null) {
      return;
    }

    final headerCells = tableElement.querySelectorAll('thead th[data-key]');
    for (final cell in headerCells.whereType<TableCellElement>()) {
      if (cell.classes.contains('hide')) {
        continue;
      }

      final key = cell.getAttribute('data-key')?.trim() ?? '';
      if (key.isEmpty) {
        continue;
      }

      final rectWidth = cell.getBoundingClientRect().width.toDouble();
      final measuredWidth =
          rectWidth > 0 ? rectWidth : cell.offsetWidth.toDouble();
      if (measuredWidth > 0) {
        final cachedWidth = _responsiveColumnWidthCache[key];
        _responsiveColumnWidthCache[key] = cachedWidth == null
            ? measuredWidth
            : (measuredWidth < cachedWidth ? measuredWidth : cachedWidth);
      }
    }

    if (!showCheckboxToSelectRow) {
      return;
    }

    final checkboxCell =
        tableElement.querySelector('thead th.datatable-first-col');
    if (checkboxCell is! TableCellElement) {
      return;
    }

    final rectWidth = checkboxCell.getBoundingClientRect().width.toDouble();
    final measuredWidth =
        rectWidth > 0 ? rectWidth : checkboxCell.offsetWidth.toDouble();
    if (measuredWidth > 0) {
      _responsiveCheckboxWidthCache =
          measuredWidth < _responsiveCheckboxWidthCache
              ? measuredWidth
              : _responsiveCheckboxWidthCache;
    }
  }

  void _resetResponsiveMeasurementCache() {
    _responsiveColumnWidthCache.clear();
    _responsiveCheckboxWidthCache = 44;
  }

  void _scheduleResponsiveAutoHideSync() {
    if (_isDestroyed) {
      _emitInstrumentation('responsiveAutoHideSync.skipped');
      return;
    }

    var canceledPreviousFrame = false;
    if (_responsiveAutoHideAnimationFrameId != null) {
      window.cancelAnimationFrame(_responsiveAutoHideAnimationFrameId!);
      _responsiveAutoHideAnimationFrameId = null;
      canceledPreviousFrame = true;
    }

    _emitInstrumentation(
      'responsiveAutoHideSync.queued',
      details: <String, Object?>{
        'canceledPreviousFrame': canceledPreviousFrame,
        'gridMode': gridMode,
        'rows': rows.length,
      },
    );

    _responsiveAutoHideAnimationFrameId = window.requestAnimationFrame((_) {
      _responsiveAutoHideAnimationFrameId = null;
      if (_isDestroyed) {
        _emitInstrumentation('responsiveAutoHideSync.frameSkipped');
        return;
      }

      final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
      _syncResponsiveColumnWidthCache();
      _syncResponsiveAutoHideNow();
      stopwatch?.stop();
      _emitInstrumentation(
        'responsiveAutoHideSync.frame',
        elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
        details: <String, Object?>{
          'autoHiddenColumns': _autoHiddenColumnKeys.length,
        },
      );
    });
  }

  bool _syncResponsiveAutoHideNow() {
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    final availableWidth = _resolveResponsiveAvailableWidth();
    final nextKeys = _computeResponsiveAutoHiddenColumnKeys(
      availableWidth: availableWidth,
    );
    if (_setEquals(nextKeys, _autoHiddenColumnKeys)) {
      stopwatch?.stop();
      _emitInstrumentation(
        'responsiveAutoHideSync.noChange',
        elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
        details: <String, Object?>{
          'availableWidth': availableWidth,
          'autoHiddenColumns': _autoHiddenColumnKeys.length,
        },
      );
      return false;
    }

    _autoHiddenColumnKeys
      ..clear()
      ..addAll(nextKeys);
    _manualRowsRevision++;
    stopwatch?.stop();
    _emitInstrumentation(
      'responsiveAutoHideSync.changed',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'availableWidth': availableWidth,
        'autoHiddenColumns': _autoHiddenColumnKeys.length,
        'manualRowsRevision': _manualRowsRevision,
      },
    );
    scheduleDraw(force: true, reason: 'responsive auto-hide');
    return true;
  }

  Set<String> _computeResponsiveAutoHiddenColumnKeys({
    double? availableWidth,
  }) {
    if (!responsiveAutoHideColumns || gridMode) {
      return const <String>{};
    }

    final resolvedAvailableWidth =
        availableWidth ?? _resolveResponsiveAvailableWidth();
    if (resolvedAvailableWidth <= 0) {
      return const <String>{};
    }

    final baseVisibleColumns = settings.colsDefinitions.where((column) {
      final hiddenOnMobile = _isResponsiveCollapseActive &&
          column.hideOnMobile &&
          !_isColumnForcedVisible(column);
      return column.visibility && !hiddenOnMobile;
    }).toList(growable: false);

    if (baseVisibleColumns.isEmpty) {
      return const <String>{};
    }

    final totalWidth = baseVisibleColumns.fold<double>(
      showCheckboxToSelectRow ? _responsiveCheckboxWidthCache : 0,
      (sum, column) => sum + _resolveResponsiveAutoHideColumnWidth(column),
    );

    if (totalWidth <= resolvedAvailableWidth) {
      return const <String>{};
    }

    final candidates = baseVisibleColumns
        .where((column) =>
            !column.responsiveAutoHideRequired &&
            column.fixedPosition == null &&
            !_isColumnForcedVisible(column) &&
            column.responsiveAutoHidePriority != null)
        .toList(growable: false);

    if (candidates.isEmpty) {
      return const <String>{};
    }

    candidates.sort((left, right) {
      final priorityCompare = left.responsiveAutoHidePriority!
          .compareTo(right.responsiveAutoHidePriority!);
      if (priorityCompare != 0) {
        return priorityCompare;
      }

      final widthCompare = _resolveResponsiveAutoHideColumnWidth(right)
          .compareTo(_resolveResponsiveAutoHideColumnWidth(left));
      if (widthCompare != 0) {
        return widthCompare;
      }

      return settings.colsDefinitions
          .indexOf(left)
          .compareTo(settings.colsDefinitions.indexOf(right));
    });

    final hiddenKeys = <String>{};
    var remainingWidth = totalWidth;
    for (final candidate in candidates) {
      if (remainingWidth <= resolvedAvailableWidth) {
        break;
      }

      hiddenKeys.add(candidate.key);
      remainingWidth -= _resolveResponsiveAutoHideColumnWidth(candidate);
    }

    return hiddenKeys;
  }

  double _resolveResponsiveAvailableWidth() {
    final scrollElement = scrollContainer;
    if (scrollElement != null && scrollElement.clientWidth > 0) {
      return scrollElement.clientWidth.toDouble();
    }

    final rootRectWidth = rootElement.getBoundingClientRect().width.toDouble();
    if (rootRectWidth > 0) {
      return rootRectWidth;
    }

    return 0;
  }

  double _resolveResponsiveAutoHideColumnWidth(DatatableCol column) {
    final configuredWidth = _parseCssLength(column.width) ??
        _parseCssLength(column.minWidth) ??
        _parseCssLength(column.maxWidth);
    if (configuredWidth != null && configuredWidth > 0) {
      return configuredWidth;
    }

    return column.nowrap ? 140.0 : 120.0;
  }

  void _syncFixedColumnOffsets() {
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    _fixedLeftOffsets.clear();
    _fixedRightOffsets.clear();

    if (gridMode || settings.colsDefinitions.isEmpty) {
      stopwatch?.stop();
      _emitInstrumentation(
        'syncFixedColumnOffsets.skipped',
        elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
        details: <String, Object?>{
          'gridMode': gridMode,
          'columns': settings.colsDefinitions.length,
        },
      );
      return;
    }

    var leftOffset = 0.0;
    for (var index = 0; index < settings.colsDefinitions.length; index++) {
      final column = settings.colsDefinitions[index];
      if (!isLeftFixedColumn(column)) {
        continue;
      }

      _fixedLeftOffsets[index] = leftOffset;
      leftOffset += _resolveFixedColumnWidth(column);
    }

    var rightOffset = 0.0;
    for (var index = settings.colsDefinitions.length - 1; index >= 0; index--) {
      final column = settings.colsDefinitions[index];
      if (!isRightFixedColumn(column)) {
        continue;
      }

      _fixedRightOffsets[index] = rightOffset;
      rightOffset += _resolveFixedColumnWidth(column);
    }

    stopwatch?.stop();
    _emitInstrumentation(
      'syncFixedColumnOffsets',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'leftFixed': _fixedLeftOffsets.length,
        'rightFixed': _fixedRightOffsets.length,
      },
    );
  }

  double _resolveFixedColumnWidth(DatatableCol column) {
    final cachedWidth = _responsiveColumnWidthCache[column.key];
    if (cachedWidth != null && cachedWidth > 0) {
      return cachedWidth;
    }

    return _parseCssLength(column.width) ??
        _parseCssLength(column.minWidth) ??
        _parseCssLength(column.maxWidth) ??
        (column.nowrap ? 140.0 : 120.0);
  }

  String? _fixedColumnStyleCss(DatatableCol column, int index) {
    if (!isFixedColumn(column)) {
      return null;
    }

    if (column.fixedPosition == DatatableFixedColumnPosition.left) {
      final offset = _fixedLeftOffsets[index] ?? 0;
      return 'left: ${_formatPixelValue(offset)}';
    }

    if (column.fixedPosition == DatatableFixedColumnPosition.right) {
      final offset = _fixedRightOffsets[index] ?? 0;
      return 'right: ${_formatPixelValue(offset)}';
    }

    return null;
  }

  String _formatPixelValue(double value) {
    final roundedValue = value.roundToDouble();
    if ((value - roundedValue).abs() < 0.01) {
      return '${roundedValue.toInt()}px';
    }

    return '${value.toStringAsFixed(2)}px';
  }

  String? _mergeCssDeclarations(String? baseStyle, String? extraStyle) {
    final parts = <String>[];
    final normalizedBase = baseStyle?.trim();
    final normalizedExtra = extraStyle?.trim();

    if (normalizedBase != null && normalizedBase.isNotEmpty) {
      parts.add(normalizedBase);
    }

    if (normalizedExtra != null && normalizedExtra.isNotEmpty) {
      parts.add(normalizedExtra);
    }

    if (parts.isEmpty) {
      return null;
    }

    return parts.join('; ');
  }

  double? _parseCssLength(String? rawValue) {
    if (rawValue == null) {
      return null;
    }

    final normalized = rawValue.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    final numericValue =
        double.tryParse(normalized.replaceAll(RegExp(r'[^0-9\.-]'), ''));
    if (numericValue == null) {
      return null;
    }

    if (normalized.endsWith('rem') || normalized.endsWith('em')) {
      return numericValue * 16;
    }

    if (normalized.endsWith('px')) {
      return numericValue;
    }

    return numericValue;
  }

  bool _setEquals(Set<String> left, Set<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (final value in left) {
      if (!right.contains(value)) {
        return false;
      }
    }

    return true;
  }
}
