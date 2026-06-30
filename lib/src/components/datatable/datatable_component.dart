//datatable_component.dart
import 'dart:async';
import 'dart:collection';
import 'dart:html';

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
import 'datatable_css_utils.dart';
import 'datatable_export_controller.dart';
import 'datatable_instrumentation_controller.dart';
import 'datatable_models.dart';
import 'datatable_pagination_controller.dart';
import 'datatable_responsive_controller.dart';
import 'datatable_row.dart';
import 'datatable_row_builder.dart';
import 'datatable_search_controller.dart';
import 'datatable_selection_controller.dart';
import 'datatable_settings.dart';
import 'datatable_sort_controller.dart';
import 'datatable_template_contexts.dart';
import 'datatable_template_directives.dart';
import 'datatable_title_help_controller.dart';
import 'datatable_virtual_scroll_controller.dart';

export 'datatable_models.dart';
export 'datatable_template_contexts.dart';
export 'datatable_template_directives.dart';

/// High-performance AngularDart datatable with table/grid rendering, server-side
/// data requests, selection, sorting, responsive columns, export, and virtual
/// scroll support.
///
/// The component deliberately keeps DOM-sensitive orchestration local while
/// delegating stateless template/context and CSS helper responsibilities to
/// smaller files. That keeps the public API compatible and avoids additional
/// work in the render path.
@Component(
  selector: 'li-datatable',
  styleUrls: ['datatable_component.css', 'grid.css'],
  templateUrl: 'datatable_component.html',
  directives: [
    coreDirectives,
    limitlessFormDirectives,
    LiDropdownMenuPositionDirective,
    LiSafeHtmlDirective,
    LiCssStyleDirective,
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
  final DatatableSortController _sortController = DatatableSortController();
  final DatatableVirtualScrollController _virtualScrollController =
      DatatableVirtualScrollController();
  final DatatableTitleHelpController titleHelp = DatatableTitleHelpController();
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

  final LiSimpleLoading _loading = LiSimpleLoading();
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
  int _visualProbeToken = 0;
  int _dataInputChangeCount = 0;
  int? _lastRowsSignature;
  int? _cachedTableRowsSignature;
  int? _cachedGridRowsSignature;
  List<DatatableRow>? _cachedTableRows;
  List<DatatableRow>? _cachedGridRows;
  bool _visible = true;
  double _responsiveAvailableWidthCache = 0;
  bool _responsiveCollapseViewportActiveCache = false;
  bool _responsiveCollapseContainerActiveCache = false;
  bool _responsiveCollapseActiveCache = false;
  final DatatableSelectionController _selectionController =
      DatatableSelectionController();
  final DatatableResponsiveController _responsiveController =
      DatatableResponsiveController();
  final DatatableSearchController _searchController =
      DatatableSearchController();
  final DatatablePaginationController _paginationController =
      DatatablePaginationController();
  final DatatableExportController _exportController =
      DatatableExportController();
  final DatatableInstrumentationController _instrumentationController =
      DatatableInstrumentationController();
  String resolvedScrollContainerStyleCss = '';
  String resolvedGridScrollContainerStyleCss = '';

  Set<String> get _autoHiddenColumnKeys =>
      _responsiveController.autoHiddenColumnKeys;

  Filters _dataTableFilter = Filters();
  @Input()
  set dataTableFilter(Filters filter) {
    _dataTableFilter = filter;
    _applySelectedSearchFieldToFilter();
  }

  Filters get dataTableFilter => _dataTableFilter;

  @Input()
  bool nullIsEmpty = true;

  @Input()
  set debugInstrumentation(bool value) {
    _instrumentationController.enabled = value;
  }

  bool get debugInstrumentation => _instrumentationController.enabled;

  @Input()
  set debugInstrumentationLabel(String value) {
    _instrumentationController.label = value;
  }

  String get debugInstrumentationLabel => _instrumentationController.label;

  bool _enableGridMode = true;
  bool _requestedGridMode = false;
  bool _gridMode = false;

  /// Enables the grid/card view and its toggle button.
  ///
  /// Set this to `false` for table-only datatables. In that mode the component
  /// coerces [gridMode] to `false`, skips grid layout binding work, avoids grid
  /// row caches, ignores custom card templates/builders, and keeps virtual
  /// scroll calculations on the lighter table path.
  @Input()
  set enableGridMode(bool value) {
    if (_enableGridMode == value) {
      return;
    }

    _enableGridMode = value;

    if (!_enableGridMode) {
      _clearGridRuntimeState();
      if (_gridMode) {
        _setGridMode(false, reason: 'enableGridMode input');
        return;
      }
    } else if (_requestedGridMode && !_gridMode) {
      _setGridMode(true, reason: 'enableGridMode input');
      return;
    }

    _syncHeaderTemplateContext();
    _syncGridBindingCaches();
    _syncProjectedTemplateContextCaches();
    _changeDetectorRef.markForCheck();
  }

  bool get enableGridMode => _enableGridMode;

  /// Requests grid/card rendering when [enableGridMode] allows it.
  ///
  /// When grid mode is disabled this setter accepts the input for API
  /// compatibility, but keeps the component in table mode to avoid grid-specific
  /// work.
  @Input('gridMode')
  set gridMode(bool value) {
    _requestedGridMode = value;

    if (!_enableGridMode && value) {
      _emitInstrumentation(
        'gridMode.disabled',
        details: <String, Object?>{
          'requestedValue': value,
          'manualRowsRevision': _manualRowsRevision,
        },
      );
    }

    _setGridMode(
      _enableGridMode ? value : false,
      reason: 'gridMode input',
      requestedValue: value,
    );
  }

  bool get gridMode => _enableGridMode && _gridMode;

  void _setGridMode(
    bool value, {
    required String reason,
    bool? requestedValue,
  }) {
    if (_gridMode == value) {
      _emitInstrumentation(
        'gridMode.noop',
        details: <String, Object?>{
          'value': value,
          'requestedValue': requestedValue,
          'reason': reason,
          'manualRowsRevision': _manualRowsRevision,
        },
      );
      return;
    }

    _gridMode = value;
    if (virtualScroll) {
      _virtualScrollController.requestReset();
    }
    _emitInstrumentation(
      'gridMode.changed',
      details: <String, Object?>{
        'value': value,
        'requestedValue': requestedValue,
        'reason': reason,
        'manualRowsRevision': _manualRowsRevision,
      },
    );
    _syncHeaderTemplateContext();
    _syncGridBindingCaches();
    if (_applyCachedModeSwitchIfAvailable(reason: reason)) {
      _scheduleModeSwitchVisualProbe(reason);
      _changeDetectorRef.markForCheck();
      return;
    }
    scheduleDraw(force: true, reason: reason);
    _scheduleModeSwitchVisualProbe(reason);
    _changeDetectorRef.markForCheck();
  }

  bool _enableResponsiveFeatures = true;

  /// Enables responsive collapse and responsive auto-hide features.
  ///
  /// Set this to `false` for fixed-layout tables. It keeps the legacy
  /// `[responsiveCollapse]` and `[responsiveAutoHideColumns]` inputs accepted,
  /// but prevents them from hiding columns, measuring widths for auto-hide, or
  /// rebuilding rows during resize.
  @Input()
  set enableResponsiveFeatures(bool value) {
    if (_enableResponsiveFeatures == value) {
      return;
    }

    _enableResponsiveFeatures = value;
    if (!_enableResponsiveFeatures) {
      _cancelResponsiveAutoHideFrame();
      _responsiveController.clearRuntimeState();
    }

    _manualRowsRevision++;
    scheduleDraw(force: true, reason: 'enableResponsiveFeatures input');
    _syncTemplateContexts();
    _changeDetectorRef.markForCheck();
  }

  bool get enableResponsiveFeatures => _enableResponsiveFeatures;

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

  /// Opt-in for CSS `table-layout: fixed`.
  ///
  /// The default remains `auto` because small paginated tables keep good
  /// performance without clipping column titles or cell content.
  @Input()
  bool fixedTableLayout = false;

  DatatablePerformanceProfile _performanceProfile =
      DatatablePerformanceProfile.flexible;

  @Input()
  set performanceProfile(DatatablePerformanceProfile value) {
    if (_performanceProfile == value) {
      return;
    }

    _performanceProfile = value;
    _manualRowsRevision++;
    if (virtualScroll) {
      _virtualScrollController.requestReset();
    }
    scheduleDraw(force: true, reason: 'performanceProfile input');
  }

  DatatablePerformanceProfile get performanceProfile => _performanceProfile;

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
        _virtualScrollController.requestReset();
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
  String showAllColumnsLabel = 'Exibir tudo';

  @Input()
  String hideAllColumnsLabel = 'Ocultar tudo';

  @Input()
  String totalRecordsLabel = 'Total:';

  @Input()
  String locale = 'pt_BR';

  @Input()
  String emptyStateLabel = '';

  @Input('limitPerPageOptions')
  List<int> limitPerPageOptions = [1, 5, 10, 12, 20, 24, 25];

  @Input('searchInFields')
  set searchInFields(List<DatatableSearchField> fields) {
    _searchController.setFields(fields, dataTableFilter);
  }

  List<DatatableSearchField> get searchInFields => _searchController.fields;

  TemplateRef? get resolvedHeaderTemplate =>
      headerTemplate ?? projectedHeaderTemplateDirective?.templateRef;

  bool get hasCustomHeader => resolvedHeaderTemplate != null;

  LiDatatableHeaderContext get headerTemplateContext => _headerTemplateContext;

  TemplateRef? get resolvedFooterTemplate =>
      footerTemplate ?? projectedFooterTemplateDirective?.templateRef;

  bool get hasCustomFooter => resolvedFooterTemplate != null;

  LiDatatableFooterContext get footerTemplateContext => _footerTemplateContext;

  TemplateRef? get resolvedCardTemplate => enableGridMode
      ? cardTemplate ?? projectedCardTemplateDirective?.templateRef
      : null;

  bool get hasCustomCardTemplate => resolvedCardTemplate != null;

  int? get selectedSearchFieldIndex {
    return _searchController.selectedSearchFieldIndex;
  }

  void _applySelectedSearchFieldToFilter() {
    _searchController.applySelectedFieldToFilter(dataTableFilter);
  }

  void _selectSearchFieldByIndex(int index) {
    _searchController.selectSearchFieldByIndex(index, dataTableFilter);
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
    _responsiveController.removeInvalidForcedKeys(validKeys);
    _rowBuilder.applyComputedColumnMetadataToSettings(_settings);
    _syncGridBindingCaches();
    _manualRowsRevision++;
    _emitInstrumentation(
      'settings.changed',
      details: <String, Object?>{
        'columns': _settings.colsDefinitions.length,
        'performanceProfile': performanceProfile.name,
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
      _virtualScrollController.requestReset();
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
    return _paginationController.currentTotalItems(
      dataTableFilter,
      totalRecords,
    );
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
    _cancelResponsiveAutoHideFrame();
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
    _paginationController.close();
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

  bool get showTableView => !showGridView;

  bool get showGridView => enableGridMode && gridMode;

  bool get _isSaliPagedPerformanceProfile =>
      performanceProfile == DatatablePerformanceProfile.saliPaged;

  bool get isSaliPagedPerformanceProfile => _isSaliPagedPerformanceProfile;

  bool get _isFastPerformanceProfile =>
      performanceProfile == DatatablePerformanceProfile.fast ||
      _isSaliPagedPerformanceProfile;

  bool get _areResponsiveFeaturesActive =>
      enableResponsiveFeatures && !_isSaliPagedPerformanceProfile;

  int get _effectiveVirtualOverscan {
    final requestedOverscan = virtualOverscan < 0 ? 0 : virtualOverscan;
    if (!_isFastPerformanceProfile) {
      return requestedOverscan;
    }
    return requestedOverscan > 6 ? 6 : requestedOverscan;
  }

  bool get isTableVirtualScrollActive {
    if (_isSaliPagedPerformanceProfile) {
      return false;
    }

    return virtualScroll &&
        !showGridView &&
        !settings.enableGrouping &&
        !_isResponsiveCollapseActive &&
        (_autoHiddenColumnKeys.isEmpty || _isFastPerformanceProfile);
  }

  bool get isGridVirtualScrollActive {
    if (_isSaliPagedPerformanceProfile) {
      return false;
    }

    return virtualScroll && showGridView && !settings.enableGrouping;
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

  int get virtualTopSpacerHeight => _virtualScrollController.topSpacerHeight;

  int get virtualBottomSpacerHeight =>
      _virtualScrollController.bottomSpacerHeight;

  HtmlElement? get _activeVirtualScrollContainer =>
      showGridView ? gridScrollContainer : scrollContainer;

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

  bool _syncVirtualWindow() {
    return _virtualScrollController.sync(
      isActive: isVirtualScrollActive,
      isGridActive: isGridVirtualScrollActive,
      totalItems: _data.items.length,
      scrollContainer: _activeVirtualScrollContainer,
      fallbackContainerWidth: rootElement.clientWidth,
      windowInnerHeight: window.innerHeight ?? 0,
      viewportHeight: virtualViewportHeight,
      overscan: _effectiveVirtualOverscan,
      rowHeight: virtualRowHeight,
      gridItemHeight: virtualGridItemHeight,
      gridMinItemWidth: virtualGridMinItemWidth,
      gridTemplateColumns: settings.gridTemplateColumns,
      gridGap: settings.gridGap,
    );
  }

  int get _resolvedBuildStartIndex {
    if (!isVirtualScrollActive) {
      return 0;
    }

    final startIndex = _virtualScrollController.startIndex;
    if (startIndex < 0) {
      return 0;
    }
    return startIndex > _data.items.length ? _data.items.length : startIndex;
  }

  int get _resolvedBuildEndIndex {
    if (!isVirtualScrollActive) {
      return _data.items.length;
    }

    final endIndex = _virtualScrollController.endIndex;
    if (endIndex < _resolvedBuildStartIndex) {
      return _resolvedBuildStartIndex;
    }
    return endIndex > _data.items.length ? _data.items.length : endIndex;
  }

  void _applyVirtualSelectionState(List<DatatableRow> rowsToSync) {
    if (!virtualScroll) {
      return;
    }

    _selectionController.applyVirtualSelectionState(
      rowsToSync,
      rowKeyResolver: settings.rowKeyResolver,
    );
  }

  List<dynamic> _collectVirtualSelectedInstances() {
    return _selectionController.collectVirtualSelectedInstances(
      _data.items,
      itemMaps: _data.itemsAsMap,
      rowKeyResolver: settings.rowKeyResolver,
    );
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

  void _emitInstrumentation(
    String stage, {
    int? elapsedMicroseconds,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    _instrumentationController.emit(
      stage,
      rootElement: rootElement,
      elapsedMicroseconds: elapsedMicroseconds,
      details: details,
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
    final legacyActionButtons = rootElement
        .querySelectorAll(
            '.datatable-action-cell button, [data-label="datatable"] .btn-icon')
        .length;
    final actionCells = rootElement
        .querySelectorAll(
            '.datatable-action-cell, [data-li-datatable-action-cell="true"]')
        .length;
    final actionElements = rootElement
        .querySelectorAll(
          '[data-li-datatable-action="true"], '
          '.datatable-action-cell button, '
          '.datatable-action-cell a, '
          '.datatable-action-cell [role="button"], '
          '.datatable-action-cell .btn',
        )
        .length;
    final visibleDomNodes = rootElement.querySelectorAll('*').length;

    return <String, Object?>{
      'tableVisible': tableElement != null && showTableView,
      'gridVisible': gridLayout != null,
      'tbodyRows': visibleBodyRows,
      'tbodyCells': visibleBodyCells,
      'gridItems': gridItems,
      'visibleDomNodes': visibleDomNodes,
      'legacyActionButtons': legacyActionButtons,
      'actionCells': actionCells,
      'actionElements': actionElements,
      'actionButtons': actionElements,
      'configuredActionColumns': _configuredActionColumnCount,
      'tableDomPresent': tableElement != null,
      'gridDomPresent': gridLayout != null,
      'tableHiddenClass': false,
      'tableViewportPresent': tableScrollContainer != null,
      'gridViewportPresent': gridScrollViewport != null,
      'virtualScroll': isVirtualScrollActive,
      'virtualStartIndex': _virtualScrollController.startIndex,
      'virtualEndIndex': _virtualScrollController.endIndex,
    };
  }

  int get _configuredActionColumnCount {
    var count = 0;
    for (final column in settings.colsDefinitions) {
      final columnKey = column.key.trim().toLowerCase();
      if (column is DatatableActionColumn ||
          columnKey == 'actions' ||
          columnKey == 'acoes') {
        count++;
      }
    }
    return count;
  }

  Map<String, Object?> _collectDrawPerformanceDetails(Stopwatch? stopwatch) {
    final elapsedMilliseconds = stopwatch == null
        ? null
        : stopwatch.elapsedMicroseconds / Duration.microsecondsPerMillisecond;
    final visibleDomStats = _collectVisibleDomStats();

    return <String, Object?>{
      ...visibleDomStats,
      'frameBudgetExceeded':
          elapsedMilliseconds != null && elapsedMilliseconds > 16.7,
      'highRefreshBudgetExceeded':
          elapsedMilliseconds != null && elapsedMilliseconds > 8.3,
      'longDraw': elapsedMilliseconds != null && elapsedMilliseconds > 50,
    };
  }

  void _scheduleModeSwitchVisualProbe(String reason) {
    if (!debugInstrumentation ||
        _isDestroyed ||
        _isSaliPagedPerformanceProfile) {
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
    return Object.hashAll(<Object?>[
      _data,
      _data.totalRecords,
      _data.items.length,
      _settings,
      _settings.colsDefinitions.length,
      nullIsEmpty,
      gridMode,
      performanceProfile,
      enableResponsiveFeatures,
      responsiveCollapse,
      responsiveCollapseMaxWidth,
      responsiveCollapseByContainer,
      responsiveCollapseContainerMaxWidth,
      _responsiveCollapseActiveCache,
      responsiveAutoHideColumns,
      isVirtualScrollActive,
      isGridVirtualScrollActive,
      _virtualScrollController.startIndex,
      _virtualScrollController.endIndex,
      virtualGridItemHeight,
      virtualGridMinItemWidth,
      _manualRowsRevision,
    ]);
  }

  int _computeRowBuildSignature() {
    return Object.hashAll(<Object?>[
      _data,
      _data.totalRecords,
      _data.items.length,
      _settings,
      _settings.colsDefinitions.length,
      nullIsEmpty,
      performanceProfile,
      enableResponsiveFeatures,
      _responsiveCollapseActiveCache,
      isVirtualScrollActive,
      isGridVirtualScrollActive,
      _virtualScrollController.startIndex,
      _virtualScrollController.endIndex,
      virtualGridItemHeight,
      virtualGridMinItemWidth,
      _manualRowsRevision,
    ]);
  }

  List<DatatableRow>? _resolveCachedRowsForMode(
    bool targetGridMode,
    int buildSignature,
  ) {
    if (targetGridMode) {
      if (!enableGridMode) {
        return null;
      }
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
    if (showGridView) {
      _cachedGridRowsSignature = buildSignature;
      _cachedGridRows = rows;
      return;
    }

    _cachedTableRowsSignature = buildSignature;
    _cachedTableRows = rows;
  }

  bool _applyCachedModeSwitchIfAvailable({required String reason}) {
    _syncResponsiveViewportState(reason: 'modeSwitch:$reason');
    _syncVirtualWindow();
    resolvedScrollContainerStyleCss = isTableVirtualScrollActive
        ? 'max-height: $virtualViewportHeight; overflow-y: auto;'
        : '';
    resolvedGridScrollContainerStyleCss = isGridVirtualScrollActive
        ? 'max-height: $virtualViewportHeight; overflow-y: auto;'
        : '';

    final buildSignature = _computeRowBuildSignature();
    final cachedRows = _resolveCachedRowsForMode(gridMode, buildSignature);
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
    final buildStartIndex = _resolvedBuildStartIndex;
    final buildEndIndex = _resolvedBuildEndIndex;
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    final result = _rowBuilder.buildRange(
      data: _data,
      settings: settings,
      nullIsEmpty: nullIsEmpty,
      gridMode: gridMode,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      startIndex: buildStartIndex,
      endIndex: buildEndIndex,
      responsiveCollapseActive: _isResponsiveCollapseActive,
      autoHiddenColumnKeys: _autoHiddenColumnKeys,
    );

    if (!debugInstrumentation) {
      return result;
    }

    stopwatch?.stop();

    _emitInstrumentation(
      'draw.buildRows',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'reason': reason,
        'items': _data.items.length,
        'windowItems': buildEndIndex - buildStartIndex,
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
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    final result = _rowBuilder.rebuildRenderedRows(
      rows: rowsToRender,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      responsiveCollapseActive: _isResponsiveCollapseActive,
      responsiveControlColumnKey: settings.responsiveControlColumnKey,
      autoHiddenColumnKeys: _autoHiddenColumnKeys,
    );

    if (!debugInstrumentation) {
      return result;
    }

    stopwatch?.stop();

    _emitInstrumentation(
      'draw.rebuildRenderedRows',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
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
    _syncResponsiveViewportState(reason: reason);
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
        'performanceProfile': performanceProfile.name,
        'virtualOverscan': _effectiveVirtualOverscan,
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
          ..._collectDrawPerformanceDetails(totalStopwatch),
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
          ..._collectDrawPerformanceDetails(totalStopwatch),
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
          ..._collectDrawPerformanceDetails(totalStopwatch),
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
        ..._collectDrawPerformanceDetails(totalStopwatch),
      },
    );
  }

  void _handleViewportChange() {
    final responsiveStateChanged = _syncResponsiveViewportState(
      reason: 'viewport change',
    );

    if (isVirtualScrollActive) {
      scheduleDraw(force: true, reason: 'viewport change');
      return;
    }

    if (!_areResponsiveFeaturesActive) {
      _syncFixedColumnOffsets();
      _changeDetectorRef.markForCheck();
      return;
    }

    if (responsiveStateChanged) {
      _manualRowsRevision++;
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
      final responsiveStateChanged = _syncResponsiveViewportState(
        reason: 'postRenderSync.frame',
      );
      if (responsiveStateChanged) {
        _manualRowsRevision++;
        scheduleDraw(force: true, reason: 'responsive viewport state');
      }
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

  int get getCurrentPage => _paginationController.currentPage;

  int get numPages {
    return _paginationController.numPages(dataTableFilter, totalRecords);
  }

  bool get isEnglishLocale => locale.toLowerCase().startsWith('en');

  String get resolvedEmptyStateLabel {
    final customLabel = emptyStateLabel.trim();
    if (customLabel.isNotEmpty) {
      return customLabel;
    }

    return isEnglishLocale ? 'Empty list' : 'Lista vazia';
  }

  String get paginationSummaryText {
    if (isEnglishLocale) {
      final entryLabel = totalRecords == 1 ? 'entry' : 'entries';
      return 'Showing ${dataTableFilter.offset} to $getCurrentTotalItems '
          'of $totalRecords $entryLabel, $numPages page(s)';
    }

    return 'Mostrando de ${dataTableFilter.offset} a $getCurrentTotalItems '
        'de $totalRecords entrada(s), $numPages página(s)';
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
    _paginationController.syncCurrentPageFromOffset(dataTableFilter);
  }

  void drawPagination() {
    _syncFooterTemplateContext();
    _changeDetectorRef.markForCheck();
  }

  void prevPage() {
    if (_paginationController.previousPage()) {
      changePage(_paginationController.currentPage);
    }
  }

  void nextPage() {
    if (_paginationController.nextPage(dataTableFilter, totalRecords)) {
      changePage(_paginationController.currentPage);
    }
  }

  void changePage(int page) {
    _paginationController.setPage(page);
    _syncTemplateContexts();
    onRequestData();
    _changeDetectorRef.markForCheck();
  }

  void irParaUltimaPagina() {
    changePage(
      _paginationController.goToLastPage(dataTableFilter, totalRecords),
    );
  }

  void irParaPrimeiraPagina() {
    changePage(_paginationController.goToFirstPage());
  }

  @Output()
  Stream<Filters> get dataRequest => _paginationController.dataRequest;

  bool isLoading = true;

  void onRequestData() {
    isLoading = true;
    _syncTemplateContexts();
    _paginationController.requestData(dataTableFilter, _settings);
    _changeDetectorRef.markForCheck();
  }

  @Output()
  Stream<Filters> get limitChange => _paginationController.limitChange;

  void changeItemsPerPageHandler(SelectElement select) {
    final li = int.tryParse(select.selectedOptions.first.value);
    _changeItemsPerPage(li);
  }

  void _changeItemsPerPage(int? limit) {
    if (limit == null) {
      return;
    }

    final emittedDataRequest = _paginationController.changeItemsPerPage(
      limit,
      dataTableFilter,
      _settings,
      requestDataOnItemsPerPageChange: requestDataOnItemsPerPageChange,
    );
    if (!emittedDataRequest) {
      _syncTemplateContexts();
    }
    _changeDetectorRef.markForCheck();
  }

  @Output()
  Stream<Filters> get searchRequest => _paginationController.searchRequest;

  void onSearch() {
    _paginationController.search(dataTableFilter);
    _syncTemplateContexts();
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
      if (isSelectAll) {
        _selectionController.selectAllVirtualItems(
          _data.items,
          itemMaps: _data.itemsAsMap,
          rowKeyResolver: settings.rowKeyResolver,
        );
      } else {
        _selectionController.clearVirtualSelection();
      }
    }

    for (final row in _selectableRows) {
      row.selected = isSelectAll;
    }

    _emitSelectedRows();
    _changeDetectorRef.markForCheck();
  }

  void unSelectAll() {
    _selectionController.clearVirtualSelection();
    for (final row in _selectableRows) {
      row.selected = false;
    }
    isSelectAll = false;
    _changeDetectorRef.markForCheck();
  }

  void syncSelection(bool Function(dynamic instance) predicate) {
    final selectableRows = _selectableRows.toList(growable: false);

    if (virtualScroll) {
      _selectionController.syncVirtualSelection(
        _data.items,
        predicate,
        itemMaps: _data.itemsAsMap,
        rowKeyResolver: settings.rowKeyResolver,
      );
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
      _selectionController.unselectItemInstance(
        _data.items,
        item,
        itemMaps: _data.itemsAsMap,
        rowKeyResolver: settings.rowKeyResolver,
      );
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
          _selectionController.selectSingleVirtualRow(
            item,
            rowKeyResolver: settings.rowKeyResolver,
          );
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
          _selectionController.unselectVirtualRow(
            item,
            rowKeyResolver: settings.rowKeyResolver,
          );
        }
        item.selected = false;
      }
    } else {
      item.selected = intendedSelectionState;
      if (item.selected) {
        if (virtualScroll) {
          _selectionController.selectVirtualRow(
            item,
            rowKeyResolver: settings.rowKeyResolver,
          );
        }
        _selectStreamController.add(item.instance);
        final selectableRows = _selectableRows.toList(growable: false);
        isSelectAll = selectableRows.isNotEmpty &&
            selectableRows.every((row) => row.selected);
      } else {
        if (virtualScroll) {
          _selectionController.unselectVirtualRow(
            item,
            rowKeyResolver: settings.rowKeyResolver,
          );
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

    _sortController.applyColumnSort(
      dataTableFilter,
      column: colDefinition,
      enableMultiColumnSorting: enableMultiColumnSorting,
    );

    _syncSortingIndicators();
    onRequestData();
    _changeDetectorRef.markForCheck();
  }

  List<FilterOrderField> _resolvedOrderFields() {
    return _sortController.resolveOrderFields(
      dataTableFilter,
      enableMultiColumnSorting: enableMultiColumnSorting,
    );
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
      _responsiveController.setForcedVisible(columnKey, shouldShowColumn);
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

      _responsiveController.setForcedVisible(columnKey, newVisibility);
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
    if (!enableGridMode) {
      resolvedGridContainerClass = 'grid-container';
      resolvedGridContainerStyleCss = '';
      resolvedGridLayoutStyleCss = '';
      resolvedGridScrollContainerStyleCss = '';
      return;
    }

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

  void _clearGridRuntimeState() {
    _cachedGridRowsSignature = null;
    _cachedGridRows = null;
    _cardTemplateContextCache.clear();
    resolvedGridScrollContainerStyleCss = '';
    resolvedGridContainerStyleCss = '';
    resolvedGridLayoutStyleCss = '';
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
      ..searchInFields = searchInFields
      ..limitPerPageOptions = limitPerPageOptions
      ..exportMenuActions = exportMenuActions
      ..searchLabel = searchLabel
      ..searchPlaceholder = searchPlaceholder
      ..gridMode = gridMode
      ..enableGridMode = enableGridMode
      ..enableResponsiveFeatures = enableResponsiveFeatures
      ..showExportMenu = showExportMenu
      ..disableHeaderPadding = disableHeaderPadding
      ..totalRecords = totalRecords
      ..currentPage = getCurrentPage
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
      ..currentPage = getCurrentPage
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
    return _responsiveRenderedRowFor(row).hasResponsiveHiddenColumns;
  }

  Iterable<DatatableCol> responsiveHiddenColumns(DatatableRow row) {
    return _responsiveRenderedRowFor(row).responsiveHiddenColumns;
  }

  DatatableRenderedRow _responsiveRenderedRowFor(DatatableRow row) {
    return _rowBuilder.rebuildRenderedRows(
      rows: <DatatableRow>[row],
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      responsiveCollapseActive: _isResponsiveCollapseActive,
      responsiveControlColumnKey: settings.responsiveControlColumnKey,
      autoHiddenColumnKeys: _autoHiddenColumnKeys,
    ).first;
  }

  bool hasCellTemplateFor(DatatableCol column) {
    return _resolveCellTemplate(column) != null;
  }

  bool usePlainTextCell(DatatableCol column) {
    return _isSaliPagedPerformanceProfile &&
        column.htmlElement == null &&
        !hasCellTemplateFor(column);
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

  bool useSimpleHeaderTitle(DatatableCol column) {
    return !hasHeaderCellTemplateFor(column) &&
        !titleHelp.hasRenderedTitleHtml(column) &&
        !titleHelp.hasTitleTooltip(column) &&
        !titleHelp.hasTitlePopover(column);
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

  bool get _isResponsiveCollapseActive => _responsiveCollapseActiveCache;

  bool get hasResponsiveCollapsedColumns =>
      _areResponsiveFeaturesActive &&
      (_isResponsiveCollapseActive || _autoHiddenColumnKeys.isNotEmpty);

  bool isFixedColumn(DatatableCol column) {
    return _responsiveController.isFixedColumn(
      column: column,
      responsiveEnabled: _areResponsiveFeaturesActive,
      collapseActive: _isResponsiveCollapseActive,
    );
  }

  bool isLeftFixedColumn(DatatableCol column) {
    return _responsiveController.isLeftFixedColumn(
      column: column,
      responsiveEnabled: _areResponsiveFeaturesActive,
      collapseActive: _isResponsiveCollapseActive,
    );
  }

  bool isRightFixedColumn(DatatableCol column) {
    return _responsiveController.isRightFixedColumn(
      column: column,
      responsiveEnabled: _areResponsiveFeaturesActive,
      collapseActive: _isResponsiveCollapseActive,
    );
  }

  String resolvedHeaderStyleCss(DatatableCol column, int index) {
    return DatatableCssUtils.mergeDeclarations(
          column.headerStyleCss,
          _fixedColumnStyleCss(column, index),
        ) ??
        '';
  }

  String resolvedCellStyleCss(DatatableCol column, int index) {
    return DatatableCssUtils.mergeDeclarations(
          column.styleCss,
          _fixedColumnStyleCss(column, index),
        ) ??
        '';
  }

  bool isColumnEffectivelyVisible(DatatableCol column) {
    return _responsiveController.isColumnEffectivelyVisible(
      column: column,
      responsiveEnabled: _areResponsiveFeaturesActive,
      collapseActive: _isResponsiveCollapseActive,
    );
  }

  bool isRuntimeResponsiveHidden(DatatableCol column) {
    return _responsiveController.isRuntimeResponsiveHidden(
      column: column,
      responsiveEnabled: _areResponsiveFeaturesActive,
      collapseActive: _isResponsiveCollapseActive,
    );
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
    if (!enableGridMode) {
      _emitInstrumentation(
        'changeViewMode.disabled',
        details: <String, Object?>{
          'gridMode': gridMode,
          'rows': rows.length,
          'renderedRows': renderedRows.length,
        },
      );
      _syncHeaderTemplateContext();
      _changeDetectorRef.markForCheck();
      return;
    }

    _requestedGridMode = !gridMode;
    _setGridMode(_requestedGridMode, reason: 'changeViewMode()');
    _emitInstrumentation(
      'changeViewMode',
      details: <String, Object?>{
        'gridMode': _gridMode,
        'rows': rows.length,
        'renderedRows': renderedRows.length,
      },
    );
  }

  Future<void> exportXlsx() async {
    await _exportController.exportXlsx(
      settings: settings,
      rows: rows,
      card: card,
      onExportXlsx: onExportXlsx,
    );
  }

  Future<void> exportPdf([bool isPrint = false, bool isDownload = true]) async {
    await _exportController.exportPdf(
      settings: settings,
      rows: rows,
      card: card,
      onExportPdf: onExportPdf,
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
    if (!_areResponsiveFeaturesActive ||
        !responsiveAutoHideColumns ||
        gridMode) {
      return;
    }

    _responsiveController.syncColumnWidthCache(
      tableElement: table,
      showCheckboxToSelectRow: showCheckboxToSelectRow,
    );
  }

  void _resetResponsiveMeasurementCache() {
    _responsiveController.resetMeasurementCache();
  }

  bool _cancelResponsiveAutoHideFrame() {
    if (_responsiveAutoHideAnimationFrameId == null) {
      return false;
    }

    window.cancelAnimationFrame(_responsiveAutoHideAnimationFrameId!);
    _responsiveAutoHideAnimationFrameId = null;
    return true;
  }

  void _scheduleResponsiveAutoHideSync() {
    if (_isDestroyed ||
        !_areResponsiveFeaturesActive ||
        !responsiveAutoHideColumns) {
      _emitInstrumentation('responsiveAutoHideSync.skipped');
      return;
    }

    var canceledPreviousFrame = false;
    canceledPreviousFrame = _cancelResponsiveAutoHideFrame();

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
      _syncResponsiveViewportState(reason: 'responsiveAutoHideSync.frame');
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
    final changed = _responsiveController.syncAutoHiddenColumns(
      responsiveEnabled: _areResponsiveFeaturesActive,
      autoHideEnabled: responsiveAutoHideColumns,
      gridMode: gridMode,
      availableWidth: availableWidth,
      columns: settings.colsDefinitions,
      collapseActive: _isResponsiveCollapseActive,
      showCheckboxToSelectRow: showCheckboxToSelectRow,
    );
    if (!changed) {
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

  double _resolveResponsiveAvailableWidth() {
    return _responsiveAvailableWidthCache;
  }

  bool _syncResponsiveViewportState({required String reason}) {
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    final previousAvailableWidth = _responsiveAvailableWidthCache;
    final previousViewportActive = _responsiveCollapseViewportActiveCache;
    final previousContainerActive = _responsiveCollapseContainerActiveCache;
    final previousActive = _responsiveCollapseActiveCache;

    if (!_areResponsiveFeaturesActive) {
      _responsiveAvailableWidthCache = 0;
      _responsiveCollapseViewportActiveCache = false;
      _responsiveCollapseContainerActiveCache = false;
      _responsiveCollapseActiveCache = false;
      return _emitResponsiveViewportStateSync(
        reason: reason,
        stopwatch: stopwatch,
        previousAvailableWidth: previousAvailableWidth,
        previousViewportActive: previousViewportActive,
        previousContainerActive: previousContainerActive,
        previousActive: previousActive,
      );
    }

    if (!responsiveCollapse) {
      _responsiveAvailableWidthCache =
          responsiveAutoHideColumns ? _measureResponsiveAvailableWidth() : 0;
      _responsiveCollapseViewportActiveCache = false;
      _responsiveCollapseContainerActiveCache = false;
      _responsiveCollapseActiveCache = false;
      return _emitResponsiveViewportStateSync(
        reason: reason,
        stopwatch: stopwatch,
        previousAvailableWidth: previousAvailableWidth,
        previousViewportActive: previousViewportActive,
        previousContainerActive: previousContainerActive,
        previousActive: previousActive,
      );
    }

    final viewportActive = window.innerWidth != null &&
        window.innerWidth! <= responsiveCollapseMaxWidth;
    final shouldMeasureAvailableWidth =
        responsiveCollapseByContainer || responsiveAutoHideColumns;
    final availableWidth = shouldMeasureAvailableWidth
        ? _measureResponsiveAvailableWidth()
        : _responsiveAvailableWidthCache;
    final containerActive = responsiveCollapseByContainer &&
        availableWidth > 0 &&
        availableWidth <= responsiveCollapseContainerMaxWidth;

    _responsiveAvailableWidthCache = availableWidth;
    _responsiveCollapseViewportActiveCache = viewportActive;
    _responsiveCollapseContainerActiveCache = containerActive;
    _responsiveCollapseActiveCache = viewportActive || containerActive;

    return _emitResponsiveViewportStateSync(
      reason: reason,
      stopwatch: stopwatch,
      previousAvailableWidth: previousAvailableWidth,
      previousViewportActive: previousViewportActive,
      previousContainerActive: previousContainerActive,
      previousActive: previousActive,
    );
  }

  bool _emitResponsiveViewportStateSync({
    required String reason,
    required Stopwatch? stopwatch,
    required double previousAvailableWidth,
    required bool previousViewportActive,
    required bool previousContainerActive,
    required bool previousActive,
  }) {
    final changed = previousAvailableWidth != _responsiveAvailableWidthCache ||
        previousViewportActive != _responsiveCollapseViewportActiveCache ||
        previousContainerActive != _responsiveCollapseContainerActiveCache ||
        previousActive != _responsiveCollapseActiveCache;

    stopwatch?.stop();

    _emitInstrumentation(
      'responsiveViewportState.sync',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'reason': reason,
        'changed': changed,
        'availableWidth': _responsiveAvailableWidthCache,
        'collapseViewportActive': _responsiveCollapseViewportActiveCache,
        'collapseContainerActive': _responsiveCollapseContainerActiveCache,
        'collapseActive': _responsiveCollapseActiveCache,
      },
    );

    if (changed) {
      _emitInstrumentation('responsiveViewportState.changed');
    }

    return changed;
  }

  double _measureResponsiveAvailableWidth() {
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

  void _syncFixedColumnOffsets() {
    final stopwatch = debugInstrumentation ? (Stopwatch()..start()) : null;
    _responsiveController.syncFixedColumnOffsets(
      gridMode: gridMode,
      columns: settings.colsDefinitions,
      responsiveEnabled: _areResponsiveFeaturesActive,
      collapseActive: _isResponsiveCollapseActive,
    );

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

    stopwatch?.stop();
    _emitInstrumentation(
      'syncFixedColumnOffsets',
      elapsedMicroseconds: stopwatch?.elapsedMicroseconds,
      details: <String, Object?>{
        'leftFixed': _responsiveController.leftFixedCount,
        'rightFixed': _responsiveController.rightFixedCount,
      },
    );
  }

  String? _fixedColumnStyleCss(DatatableCol column, int index) {
    return _responsiveController.fixedColumnStyleCss(
      column: column,
      index: index,
      responsiveEnabled: _areResponsiveFeaturesActive,
      collapseActive: _isResponsiveCollapseActive,
    );
  }
}
