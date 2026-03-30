import 'dart:html';

export 'datatable_style.dart';

import 'datatable_style.dart';

typedef DatatableCellStyleResolver = String? Function(
  Map<String, dynamic> itemMap,
  dynamic itemInstance,
);

enum DatatableColType { normal, groupTitle }

/// Column definition and rendered value container used by the datatable.
class DatatableCol {
  /// Source key used to read the value from an item map.
  String key;
  String? sortingBy;
  String defaultSortDirection;
  dynamic id;
  String value;

  /// HTML element appended to the table cell when using [customRenderHtml].
  Element? htmlElement;
  dynamic instance;
  String title;
  DatatableFormat? format;
  String? styleCss;
  String? headerStyleCss;
  String? headerClass;
  String? cellClass;
  String? width;
  String? minWidth;
  String? maxWidth;
  String? textAlign;
  bool nowrap = false;
  DatatableCellStyleResolver? cellStyleResolver;

  /// Whether the column is visible in table mode.
  bool visibility = true;

  /// Whether the column is visible in grid mode.
  bool visibilityOnCard = true;

  /// Whether the title should be shown in grid mode.
  bool showTitleOnCard = true;

  /// Whether the column should collapse into the mobile details row.
  bool hideOnMobile = false;

  bool showAsFooterOnCard = false;
  bool enableSorting = false;

  /// Custom renderer for the string content shown in the cell.
  String Function(Map<String, dynamic> itemMap, dynamic itemInstance)?
      customRenderString;

  Element Function(Map<String, dynamic> itemMap, dynamic itemInstance)?
      customRenderHtml;

  /// Separator used when multiple values are rendered in the same column.
  String multiValSeparator = ' - ';

  bool enableGrouping = false;

  /// Key used to build grouping sections.
  String? groupByKey;

  /// Optional colspan used by group rows and custom cells.
  int? colspan;

  DatatableColType type = DatatableColType.normal;

  DatatableCol({
    this.id,
    required this.key,
    this.value = '',
    this.instance,
    required this.title,
    this.format,
    this.styleCss,
    this.headerStyleCss,
    this.headerClass,
    this.cellClass,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.textAlign,
    this.nowrap = false,
    this.cellStyleResolver,
    this.visibility = true,
    this.enableSorting = false,
    this.customRenderString,
    this.customRenderHtml,
    this.multiValSeparator = ' - ',
    this.sortingBy,
    this.defaultSortDirection = 'asc',
    this.htmlElement,
    this.enableGrouping = false,
    this.groupByKey,
    this.colspan,
    this.visibilityOnCard = true,
    this.showTitleOnCard = true,
    this.hideOnMobile = false,
    this.showAsFooterOnCard = false,
    this.type = DatatableColType.normal,
  });
}
