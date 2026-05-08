import 'package:essential_core/essential_core.dart';

import 'datatable_col.dart';
import 'datatable_models.dart';
import 'datatable_row.dart';
import 'datatable_settings.dart';

/// Context object exposed to a custom `li-datatable-header` template.
///
/// The component keeps this object synchronized with the current table state so
/// projected headers can read data, pagination, search, export, and view-mode
/// information without knowing the internal implementation of
/// `LiDataTableComponent`.
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

  /// Last data frame received by the table.
  DataFrame data = DataFrame(items: <dynamic>[], totalRecords: 0);

  /// Rows built from [data] and the current [settings].
  List<DatatableRow> rows = <DatatableRow>[];

  /// Render-ready row views after responsive and grouping rules are applied.
  List<DatatableRenderedRow> renderedRows = <DatatableRenderedRow>[];

  /// Active filter used for search, pagination, and ordering requests.
  Filters dataTableFilter = Filters();

  /// Current datatable settings.
  DatatableSettings settings =
      DatatableSettings(colsDefinitions: <DatatableCol>[]);

  /// Searchable fields shown by the header search selector.
  List<DatatableSearchField> searchInFields = <DatatableSearchField>[];

  /// Page-size options shown by the header selector.
  List<int> limitPerPageOptions = <int>[];

  /// Extra or custom export actions displayed by the export menu.
  List<DatatableMenuAction> exportMenuActions = <DatatableMenuAction>[];

  /// Label rendered near the search input.
  String searchLabel = '';

  /// Placeholder rendered in the search input.
  String searchPlaceholder = '';

  /// Whether the datatable is currently rendering cards instead of rows.
  bool gridMode = false;

  /// Whether grid/card mode is available for this datatable instance.
  bool enableGridMode = true;

  /// Whether responsive collapse and auto-hide are available.
  bool enableResponsiveFeatures = true;

  /// Whether the export menu should be visible.
  bool showExportMenu = false;

  /// Whether the default header padding should be suppressed.
  bool disableHeaderPadding = false;

  /// Total number of records reported by the data source.
  int totalRecords = 0;

  /// Current one-based page number.
  int currentPage = 1;

  /// Total number of pages resolved from [totalRecords] and the page size.
  int numPages = 1;

  /// Index of the selected search field, or `null` when search fields are empty.
  int? selectedSearchFieldIndex;

  /// Current page size from [dataTableFilter].
  int? limitPerPage;

  /// Whether every configured column is effectively visible.
  bool allColumnsVisible = true;

  /// Runs the table search flow.
  final void Function() search;

  /// Requests data using the current filter.
  final void Function() requestData;

  /// Selects a search field by index.
  final void Function(int index) selectSearchField;

  /// Updates the page size.
  final void Function(int value) changeItemsPerPage;

  /// Toggles between table and grid view.
  final void Function() toggleViewMode;

  /// Shows or hides every column.
  final void Function() toggleAllColumnsVisibility;

  /// Exports the current rows to PDF.
  final Future<void> Function() exportPdf;

  /// Exports the current rows to XLSX.
  final Future<void> Function() exportXlsx;
}

/// Context object exposed to a custom `li-datatable-footer` template.
///
/// It contains pagination state and callbacks while still exposing the current
/// data and rendered row lists for custom footers that need totals or summaries.
class LiDatatableFooterContext {
  LiDatatableFooterContext({
    required this.requestData,
    required this.changePage,
    required this.nextPage,
    required this.prevPage,
    required this.goToFirstPage,
    required this.goToLastPage,
  });

  /// Last data frame received by the table.
  DataFrame data = DataFrame(items: <dynamic>[], totalRecords: 0);

  /// Rows built from [data] and the current settings.
  List<DatatableRow> rows = <DatatableRow>[];

  /// Render-ready row views after responsive and grouping rules are applied.
  List<DatatableRenderedRow> renderedRows = <DatatableRenderedRow>[];

  /// Active filter used for search, pagination, and ordering requests.
  Filters dataTableFilter = Filters();

  /// Current datatable settings.
  DatatableSettings settings =
      DatatableSettings(colsDefinitions: <DatatableCol>[]);

  /// Total number of records reported by the data source.
  int totalRecords = 0;

  /// Current one-based page number.
  int currentPage = 1;

  /// Total number of pages resolved from [totalRecords] and the page size.
  int numPages = 1;

  /// Total number of currently reachable items in the active page.
  int currentTotalItems = 0;

  /// Current page size.
  int pageSize = 0;

  /// Number of pagination buttons after compact viewport rules are applied.
  int resolvedPaginationButtonQuantity = 0;

  /// Requests data using the current filter.
  final void Function() requestData;

  /// Changes to a specific one-based page.
  final void Function(int page) changePage;

  /// Moves to the next page when possible.
  final void Function() nextPage;

  /// Moves to the previous page when possible.
  final void Function() prevPage;

  /// Moves to the first page.
  final void Function() goToFirstPage;

  /// Moves to the last page.
  final void Function() goToLastPage;
}

/// Context passed to a custom cell template for a single row and column.
class LiDatatableCellContext {
  LiDatatableCellContext({
    required this.row,
    required this.column,
    required this.itemMap,
    required this.itemInstance,
    required this.rowIndex,
    required this.columnIndex,
  });

  /// Rendered row that owns the cell.
  final DatatableRow row;

  /// Column represented by the cell.
  final DatatableCol column;

  /// Map representation of the item when available.
  final Map<String, dynamic> itemMap;

  /// Original item instance used to build the row.
  final dynamic itemInstance;

  /// Zero-based rendered row index.
  final int rowIndex;

  /// Zero-based column index inside the row.
  final int columnIndex;
}

/// Context passed to a custom header-cell template.
class LiDatatableHeaderCellContext {
  LiDatatableHeaderCellContext({
    required this.column,
    required this.columnIndex,
    required this.enableSorting,
    required this.toggleSort,
  });

  /// Column represented by the header cell.
  final DatatableCol column;

  /// Zero-based visible column index.
  final int columnIndex;

  /// Whether this header cell can trigger sorting.
  final bool enableSorting;

  /// Toggles sorting for [column].
  final void Function() toggleSort;
}

/// Context passed to a custom grid/card template.
class LiDatatableCardContext {
  LiDatatableCardContext({
    required this.row,
    required this.itemMap,
    required this.itemInstance,
    required this.rowIndex,
    required this.bodyColumns,
    required this.footerColumns,
  });

  /// Row represented by the card.
  final DatatableRow row;

  /// Map representation of the item when available.
  final Map<String, dynamic> itemMap;

  /// Original item instance used to build the row.
  final dynamic itemInstance;

  /// Zero-based rendered row index.
  final int rowIndex;

  /// Columns intended for the card body.
  final List<DatatableCol> bodyColumns;

  /// Columns intended for the card footer.
  final List<DatatableCol> footerColumns;
}
