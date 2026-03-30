//datatable_row.dart
import 'dart:html';

import 'datatable_col.dart';

enum DatatableRowType { normal, groupTitle }

class DatatableRow {
  dynamic instance;
  dynamic id;
  int index;
  List<DatatableCol> columns = [];
  List<DatatableCol> columnsCardBody = [];
  List<DatatableCol> columnsCardFooter = [];
  bool selected = false;
  bool isExpanded = false;
  String? styleCss;
  Element? customCardElement;

  DatatableRowType type = DatatableRowType.normal;

  DatatableRow(
      {required this.columns,
      this.instance,
      this.id,
      this.index = -1,
      this.styleCss,
      this.customCardElement,
      this.type = DatatableRowType.normal});

  void addColumn(DatatableCol column) {
    columns.add(column);
    if (column.type != DatatableColType.normal) {
      return;
    }

    if (column.showAsFooterOnCard) {
      columnsCardFooter.add(column);
      return;
    }

    columnsCardBody.add(column);
  }

  void toggleExpanded() {
    isExpanded = !isExpanded;
  }
}
