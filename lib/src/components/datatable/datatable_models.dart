import 'datatable_col.dart';
import 'datatable_row.dart';

/// Callback for custom PDF export. Receives the same data the built-in
/// exporter uses so callers can build their own PDF layout.
typedef DatatableExportPdfCallback = Future<void> Function(
  List<DatatableRow> rows,
  List<DatatableCol> visibleColumns,
);

/// Callback for custom XLSX export.
typedef DatatableExportXlsxCallback = void Function(
  List<DatatableRow> rows,
  List<DatatableCol> visibleColumns,
);

/// A custom action that appears in the export/actions dropdown menu.
class DatatableMenuAction {
  final String label;
  final String? iconClass;
  final void Function() action;

  DatatableMenuAction({
    required this.label,
    required this.action,
    this.iconClass,
  });
}

class DatatableSearchField {
  bool selected = false;
  final String label;
  final String field;
  final String operator;

  DatatableSearchField({
    this.selected = false,
    required this.label,
    required this.field,
    required this.operator,
  });

  void select() {
    selected = true;
  }
}

class DatatableRenderedRow {
  DatatableRenderedRow({
    required this.row,
    required this.hasResponsiveHiddenColumns,
    required this.responsiveHiddenColumns,
    required this.responsiveControlColumnKey,
  });

  final DatatableRow row;
  final bool hasResponsiveHiddenColumns;
  final List<DatatableCol> responsiveHiddenColumns;
  final String? responsiveControlColumnKey;
}
