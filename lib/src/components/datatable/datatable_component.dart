//datatable_component.dart
// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:html';

import 'package:essential_core/essential_core.dart';
import 'package:ngdart/angular.dart';

import '../../directives/dropdown_menu_directive.dart';
import '../../directives/form_directives.dart';
import '../../directives/css_style_directive.dart';
import '../../directives/safe_html_directive.dart';
import '../pagination/pagination_component.dart';
import '../loading/loading.dart';
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
  final void Function() exportXlsx;
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
      exportXlsx: exportXlsx,
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

  @Input()
  TemplateRef? headerTemplate;

  @Input()
  TemplateRef? footerTemplate;

  @ViewChild('card')
  DivElement? card;

  @ViewChild('table')
  HtmlElement? table;

  @ViewChild('scrollContainer')
  HtmlElement? scrollContainer;

  final SimpleLoading _loading = SimpleLoading();
  StreamSubscription<void>? _resizeSubscription;
  Timer? _resizeDebounce;
  int? _drawAnimationFrameId;
  int? _postRenderAnimationFrameId;
  int? _responsiveAutoHideAnimationFrameId;
  bool _isDestroyed = false;
  bool _drawScheduled = false;
  bool _viewInitialized = false;
  int _manualRowsRevision = 0;
  int? _lastRowsSignature;
  bool _visible = true;
  final Map<String, double> _responsiveColumnWidthCache = <String, double>{};
  final Map<int, double> _fixedLeftOffsets = <int, double>{};
  final Map<int, double> _fixedRightOffsets = <int, double>{};
  final Set<String> _autoHiddenColumnKeys = <String>{};
  final Set<String> _forcedVisibleColumnKeys = <String>{};
  double _responsiveCheckboxWidthCache = 44;

  Filters _dataTableFilter = Filters();

  @Input()
  set dataTableFilter(Filters filter) {
    _dataTableFilter = filter;
    _applySelectedSearchFieldToFilter();
  }

  Filters get dataTableFilter => _dataTableFilter;

  @Input()
  bool nullIsEmpty = true;

  bool _gridMode = false;

  @Input('gridMode')
  set gridMode(bool value) {
    if (_gridMode == value) {
      return;
    }

    _gridMode = value;
    _manualRowsRevision++;
    if (_canDrawNow) {
      draw();
    }
  }

  bool get gridMode => _gridMode;

  @Input()
  bool responsiveCollapse = false;

  @Input()
  int responsiveCollapseMaxWidth = 767;

  @Input()
  bool responsiveAutoHideColumns = false;

  @Input()
  bool deferInitialDrawUntilVisible = false;

  @Input()
  set visible(bool value) {
    if (_visible == value) {
      return;
    }

    _visible = value;
    if (_visible) {
      scheduleDraw(force: true);
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

  @Input('settings')
  set settings(DatatableSettings value) {
    _settings = value;
    final validKeys = _settings.colsDefinitions
        .map((column) => column.key)
        .where((key) => key.trim().isNotEmpty)
        .toSet();
    _forcedVisibleColumnKeys.removeWhere((key) => !validKeys.contains(key));
    _rowBuilder.applyComputedColumnMetadataToSettings(_settings);
    _manualRowsRevision++;
    scheduleDraw(force: true);
  }

  DatatableSettings get settings => _settings;

  String get gridContainerClass {
    final customClass = _settings.gridContainerClass?.trim();
    if (customClass == null || customClass.isEmpty) {
      return 'grid-container';
    }

    return 'grid-container $customClass';
  }

  DataFrame _data = DataFrame(items: <dynamic>[], totalRecords: 0);

  @Input('data')
  set data(DataFrame value) {
    _data = value;
    totalRecords = _data.totalRecords;
    isLoading = false;
    _syncCurrentPageFromOffset();
    _manualRowsRevision++;
    scheduleDraw(force: true);
  }

  DataFrame get data => _data;

  List<DatatableRow> rows = <DatatableRow>[];
  List<DatatableRenderedRow> renderedRows = <DatatableRenderedRow>[];

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
    _schedulePostRenderSync();
    scheduleDraw();
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngAfterChanges() {
    _syncCurrentPageFromOffset();
    drawPagination();
    _syncTemplateContexts();
    _schedulePostRenderSync();
    scheduleDraw();
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
    _dataRequest.close();
    _limitChangeRequest.close();
    _searchRequest.close();
    _onRowClickStreamController.close();
    _selectAllStreamController.close();
    _selectStreamController.close();
  }

  void update() {
    _manualRowsRevision++;
    scheduleDraw(force: true);
  }

  bool get _canDrawNow {
    if (_isDestroyed) {
      return false;
    }
    if (deferInitialDrawUntilVisible && !_visible) {
      return false;
    }
    return true;
  }

  void scheduleDraw({bool force = false}) {
    if (!_canDrawNow) {
      return;
    }

    if (_drawScheduled && !force) {
      return;
    }

    if (_drawAnimationFrameId != null) {
      window.cancelAnimationFrame(_drawAnimationFrameId!);
      _drawAnimationFrameId = null;
    }

    _drawScheduled = true;
    _drawAnimationFrameId = window.requestAnimationFrame((_) {
      _drawAnimationFrameId = null;
      _drawScheduled = false;
      if (_isDestroyed || !_canDrawNow) {
        return;
      }
      draw();
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
      responsiveAutoHideColumns,
      _manualRowsRevision,
    );
  }

  void draw() {
    final signature = _computeRowsSignature();

    if (_lastRowsSignature == signature) {
      renderedRows = _rowBuilder.rebuildRenderedRows(
        rows: rows,
        responsiveCollapse: responsiveCollapse,
        responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
        autoHiddenColumnKeys: _autoHiddenColumnKeys,
      );
      drawPagination();
      _syncTemplateContexts();
      _syncFixedColumnOffsets();
      _schedulePostRenderSync();
      _changeDetectorRef.markForCheck();
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
      return;
    }

    final buildResult = _rowBuilder.build(
      data: _data,
      settings: settings,
      nullIsEmpty: nullIsEmpty,
      gridMode: gridMode,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      autoHiddenColumnKeys: _autoHiddenColumnKeys,
    );
    rows = buildResult.rows;
    renderedRows = buildResult.renderedRows;

    _lastRowsSignature = signature;
    drawPagination();
    _syncTemplateContexts();
    _syncFixedColumnOffsets();
    _schedulePostRenderSync();

    _changeDetectorRef.markForCheck();
  }

  void _handleViewportChange() {
    _syncResponsiveColumnWidthCache();

    final autoHideChanged = _syncResponsiveAutoHideNow();

    if (!_isResponsiveCollapseViewportActive && _autoHiddenColumnKeys.isEmpty) {
      for (final row in rows) {
        row.isExpanded = false;
      }
    }

    if (autoHideChanged) {
      return;
    }

    renderedRows = _rowBuilder.rebuildRenderedRows(
      rows: rows,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      autoHiddenColumnKeys: _autoHiddenColumnKeys,
    );
    _syncTemplateContexts();
    _syncFixedColumnOffsets();
    _schedulePostRenderSync();
    _changeDetectorRef.markForCheck();
  }

  void _schedulePostRenderSync() {
    if (!_viewInitialized || _isDestroyed) {
      return;
    }

    if (_postRenderAnimationFrameId != null) {
      window.cancelAnimationFrame(_postRenderAnimationFrameId!);
      _postRenderAnimationFrameId = null;
    }

    _postRenderAnimationFrameId = window.requestAnimationFrame((_) {
      _postRenderAnimationFrameId = null;
      if (_isDestroyed) {
        return;
      }
      _syncSortingIndicators();
      _syncResponsiveColumnWidthCache();
      _syncFixedColumnOffsets();
      _scheduleResponsiveAutoHideSync();
      _changeDetectorRef.markForCheck();
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

  List<T> getAllSelected<T>() => _selectableRows
      .where((row) => row.selected)
      .map<T>((row) => row.instance as T)
      .toList();

  void onSelectAll(Event event) {
    if (allowSingleSelectionOnly) {
      event.preventDefault();
      return;
    }

    final checkbox = event.target as InputElement;
    isSelectAll = checkbox.checked ?? false;

    for (final row in _selectableRows) {
      row.selected = isSelectAll;
    }

    _emitSelectedRows();
    _changeDetectorRef.markForCheck();
  }

  void unSelectAll() {
    for (final row in _selectableRows) {
      row.selected = false;
    }
    isSelectAll = false;
    _changeDetectorRef.markForCheck();
  }

  void syncSelection(bool Function(dynamic instance) predicate) {
    final selectableRows = _selectableRows.toList(growable: false);

    for (final row in selectableRows) {
      row.selected = predicate(row.instance);
    }

    isSelectAll = selectableRows.isNotEmpty &&
        selectableRows.every((row) => row.selected);
    _changeDetectorRef.markForCheck();
  }

  void unSelectItemInstance(dynamic item) {
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
        for (final row in _selectableRows) {
          if (!identical(row, item)) {
            row.selected = false;
          }
        }
        item.selected = true;
        isSelectAll = false;
        _selectStreamController.add(item.instance);
      } else {
        item.selected = false;
      }
    } else {
      item.selected = intendedSelectionState;
      if (item.selected) {
        _selectStreamController.add(item.instance);
        final selectableRows = _selectableRows.toList(growable: false);
        isSelectAll = selectableRows.isNotEmpty &&
            selectableRows.every((row) => row.selected);
      } else {
        isSelectAll = false;
      }
    }

    _emitSelectedRows();
    _changeDetectorRef.markForCheck();
  }

  void _emitSelectedRows() {
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

    renderedRows = _rowBuilder.rebuildRenderedRows(
      rows: rows,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      autoHiddenColumnKeys: _autoHiddenColumnKeys,
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

    renderedRows = _rowBuilder.rebuildRenderedRows(
      rows: rows,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      autoHiddenColumnKeys: _autoHiddenColumnKeys,
    );
    _syncTemplateContexts();
    _syncFixedColumnOffsets();
    _schedulePostRenderSync();
    _changeDetectorRef.markForCheck();
  }

  void _syncTemplateContexts() {
    _syncHeaderTemplateContext();
    _syncFooterTemplateContext();
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
          autoHiddenColumnKeys: _autoHiddenColumnKeys,
        )
        .first
        .responsiveHiddenColumns;
  }

  bool get _isResponsiveCollapseViewportActive =>
      window.innerWidth != null &&
      window.innerWidth! <= responsiveCollapseMaxWidth &&
      responsiveCollapse;

  bool get hasResponsiveCollapsedColumns =>
      _isResponsiveCollapseViewportActive || _autoHiddenColumnKeys.isNotEmpty;

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

    final hiddenOnMobile =
        _isResponsiveCollapseViewportActive && column.hideOnMobile;
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
    _manualRowsRevision++;
    _syncHeaderTemplateContext();
    if (_canDrawNow) {
      draw();
    }
    _changeDetectorRef.markForCheck();
  }

  void exportXlsx() {
    if (onExportXlsx != null) {
      onExportXlsx!(rows, settings.visibleColumns);
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
      await onExportPdf!(rows, settings.visibleColumns);
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
    renderedRows = _rowBuilder.rebuildRenderedRows(
      rows: rows,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      autoHiddenColumnKeys: _autoHiddenColumnKeys,
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
        _responsiveColumnWidthCache[key] = measuredWidth;
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
      _responsiveCheckboxWidthCache = measuredWidth;
    }
  }

  void _scheduleResponsiveAutoHideSync() {
    if (_isDestroyed) {
      return;
    }

    if (_responsiveAutoHideAnimationFrameId != null) {
      window.cancelAnimationFrame(_responsiveAutoHideAnimationFrameId!);
      _responsiveAutoHideAnimationFrameId = null;
    }

    _responsiveAutoHideAnimationFrameId = window.requestAnimationFrame((_) {
      _responsiveAutoHideAnimationFrameId = null;
      if (_isDestroyed) {
        return;
      }

      _syncResponsiveColumnWidthCache();
      _syncResponsiveAutoHideNow();
    });
  }

  bool _syncResponsiveAutoHideNow() {
    final nextKeys = _computeResponsiveAutoHiddenColumnKeys();
    if (_setEquals(nextKeys, _autoHiddenColumnKeys)) {
      return false;
    }

    _autoHiddenColumnKeys
      ..clear()
      ..addAll(nextKeys);
    _manualRowsRevision++;
    scheduleDraw(force: true);
    return true;
  }

  Set<String> _computeResponsiveAutoHiddenColumnKeys() {
    if (!responsiveAutoHideColumns || gridMode) {
      return const <String>{};
    }

    final availableWidth = _resolveResponsiveAvailableWidth();
    if (availableWidth <= 0) {
      return const <String>{};
    }

    final baseVisibleColumns = settings.colsDefinitions.where((column) {
      final hiddenOnMobile = _isResponsiveCollapseViewportActive &&
          column.hideOnMobile &&
          !_isColumnForcedVisible(column);
      return column.visibility && !hiddenOnMobile;
    }).toList(growable: false);

    if (baseVisibleColumns.isEmpty) {
      return const <String>{};
    }

    final totalWidth = baseVisibleColumns.fold<double>(
      showCheckboxToSelectRow ? _responsiveCheckboxWidthCache : 0,
      (sum, column) => sum + _resolveResponsiveColumnWidth(column),
    );

    if (totalWidth <= availableWidth) {
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

      final widthCompare = _resolveResponsiveColumnWidth(right)
          .compareTo(_resolveResponsiveColumnWidth(left));
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
      if (remainingWidth <= availableWidth) {
        break;
      }

      hiddenKeys.add(candidate.key);
      remainingWidth -= _resolveResponsiveColumnWidth(candidate);
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

  double _resolveResponsiveColumnWidth(DatatableCol column) {
    final configuredWidth = _parseCssLength(column.width) ??
        _parseCssLength(column.minWidth) ??
        _parseCssLength(column.maxWidth);
    if (configuredWidth != null && configuredWidth > 0) {
      return configuredWidth;
    }

    final fallbackWidth = column.nowrap ? 140.0 : 120.0;
    final cachedWidth = _responsiveColumnWidthCache[column.key];
    if (cachedWidth != null && cachedWidth > 0) {
      return cachedWidth < fallbackWidth ? cachedWidth : fallbackWidth;
    }

    return fallbackWidth;
  }

  void _syncFixedColumnOffsets() {
    _fixedLeftOffsets.clear();
    _fixedRightOffsets.clear();

    if (gridMode || settings.colsDefinitions.isEmpty) {
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
