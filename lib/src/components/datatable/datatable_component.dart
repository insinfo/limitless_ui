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

  @ViewChild('card')
  DivElement? card;

  @ViewChild('table')
  HtmlElement? table;

  final SimpleLoading _loading = SimpleLoading();
  StreamSubscription<void>? _resizeSubscription;
  Timer? _resizeDebounce;
  int? _drawAnimationFrameId;
  int? _postRenderAnimationFrameId;
  bool _isDestroyed = false;
  bool _drawScheduled = false;
  bool _viewInitialized = false;
  int _manualRowsRevision = 0;
  int? _lastRowsSignature;
  bool _visible = true;

  @Input()
  Filters dataTableFilter = Filters();

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
    if (fields.isEmpty) {
      _searchInFields = <DatatableSearchField>[];
      dataTableFilter.searchInFields = <FilterSearchField>[];
      return;
    }

    if (!fields.any((field) => field.selected)) {
      fields.first.select();
    }

    final selectedSearchField = fields.firstWhere((field) => field.selected);
    dataTableFilter.searchInFields = <FilterSearchField>[
      FilterSearchField(
        active: true,
        field: selectedSearchField.field,
        operator: selectedSearchField.operator,
        label: selectedSearchField.label,
      ),
    ];

    _searchInFields = fields;
  }

  List<DatatableSearchField> get searchInFields => _searchInFields;

  DatatableSettings _settings = DatatableSettings(colsDefinitions: <DatatableCol>[]);

  @Input('settings')
  set settings(DatatableSettings value) {
    _settings = value;
    _rowBuilder.applyComputedColumnMetadataToSettings(_settings);
    _manualRowsRevision++;
    scheduleDraw(force: true);
  }

  DatatableSettings get settings => _settings;

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
    _schedulePostRenderSync();
    scheduleDraw();
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngAfterChanges() {
    _syncCurrentPageFromOffset();
    drawPagination();
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
      );
      drawPagination();
      _schedulePostRenderSync();
      _changeDetectorRef.markForCheck();
      return;
    }

    rows = <DatatableRow>[];
    renderedRows = <DatatableRenderedRow>[];

    if (settings.colsDefinitions.isEmpty) {
      _lastRowsSignature = signature;
      drawPagination();
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
    );
    rows = buildResult.rows;
    renderedRows = buildResult.renderedRows;

    _lastRowsSignature = signature;
    drawPagination();
    _schedulePostRenderSync();

    _changeDetectorRef.markForCheck();
  }

  void _handleViewportChange() {
    if (!_isResponsiveViewportActive) {
      for (final row in rows) {
        row.isExpanded = false;
      }
    }

    renderedRows = _rowBuilder.rebuildRenderedRows(
      rows: rows,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
    );
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

  final int paginationButtonQuantity = 5;
  
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
    _dataRequest.add(dataTableFilter);
    _changeDetectorRef.markForCheck();
  }

  final _limitChangeRequest = StreamController<Filters>();

  @Output()
  Stream<Filters> get limitChange => _limitChangeRequest.stream;

  void changeItemsPerPageHandler(SelectElement select) {
    final li = int.tryParse(select.selectedOptions.first.value);
    _currentPage = 1;
    dataTableFilter.limit = li;
    _limitChangeRequest.add(dataTableFilter);
    _changeDetectorRef.markForCheck();
  }

  final _searchRequest = StreamController<Filters>();

  @Output()
  Stream<Filters> get searchRequest => _searchRequest.stream;

  void onSearch() {
    _currentPage = 1;
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

    final selectedSearchField = _searchInFields[int.parse(index)];
    dataTableFilter.searchInFields = <FilterSearchField>[
      FilterSearchField(
        active: true,
        field: selectedSearchField.field,
        operator: selectedSearchField.operator,
        label: selectedSearchField.label,
      ),
    ];
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

  List<T> getAllSelected<T>() => rows
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

    for (final row in rows) {
      row.selected = isSelectAll;
    }

    _emitSelectedRows();
    _changeDetectorRef.markForCheck();
  }

  void unSelectAll() {
    for (final row in rows) {
      row.selected = false;
    }
    isSelectAll = false;
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
    final intendedSelectionState = !item.selected;

    if (allowSingleSelectionOnly) {
      if (intendedSelectionState) {
        for (final row in rows) {
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
        isSelectAll = rows.isNotEmpty && rows.every((row) => row.selected);
      } else {
        isSelectAll = false;
      }
    }

    _emitSelectedRows();
    _changeDetectorRef.markForCheck();
  }

  void _emitSelectedRows() {
    _selectAllStreamController.add(
      rows.where((row) => row.selected).map((row) => row.instance).toList(),
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
      final existingIndex = orderFields.indexWhere((field) => field.field == sortingBy);
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
      dataTableFilter.setOrderFields(orderFields);
    } else {
      dataTableFilter.setSingleOrder(sortingBy, direction: nextDirection);
    }

    _syncSortingIndicators();
    onRequestData();
    _changeDetectorRef.markForCheck();
  }

  List<FilterOrderField> _resolvedOrderFields() {
    if (dataTableFilter.orderFields.isNotEmpty) {
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
    col.visibility = !col.visibility;
    col.visibilityOnCard = col.visibility;

    for (final row in rows) {
      for (final column in row.columns) {
        if (column.key == col.key) {
          column.visibility = col.visibility;
          column.visibilityOnCard = col.visibilityOnCard;
        }
      }
    }

    renderedRows = _rowBuilder.rebuildRenderedRows(
      rows: rows,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
    );
    _changeDetectorRef.markForCheck();
  }

  bool get allColumnsVisible =>
      settings.colsDefinitions.every((col) => col.visibility);

  void toggleAllColumnsVisibility() {
    final newVisibility = !allColumnsVisible;
    for (final col in settings.colsDefinitions) {
      col.visibility = newVisibility;
      col.visibilityOnCard = newVisibility;
    }

    for (final row in rows) {
      for (final column in row.columns) {
        column.visibility = newVisibility;
        column.visibilityOnCard = newVisibility;
      }
    }

    renderedRows = _rowBuilder.rebuildRenderedRows(
      rows: rows,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
    );
    _changeDetectorRef.markForCheck();
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
        )
        .first
        .responsiveHiddenColumns;
  }

  bool get _isResponsiveViewportActive =>
      window.innerWidth != null && window.innerWidth! <= responsiveCollapseMaxWidth && responsiveCollapse;

  bool isResponsiveControlColumn(DatatableRenderedRow view, DatatableCol column) {
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
      view = _rowBuilder
          .rebuildRenderedRows(
            rows: <DatatableRow>[viewOrRow],
            responsiveCollapse: responsiveCollapse,
            responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
          )
          .first;
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
    );
    _changeDetectorRef.markForCheck();
    return idx;
  }
}
