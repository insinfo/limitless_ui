import 'package:ngx_dart/angular.dart';

/// Marks projected content as the custom datatable header template.
///
/// The template receives a `LiDatatableHeaderContext` through `let-ctx`.
@Directive(selector: 'template[li-datatable-header]')
class LiDatatableHeaderDirective {
  LiDatatableHeaderDirective(this.templateRef);

  /// Angular template rendered in the datatable header area.
  final TemplateRef templateRef;
}

/// Marks projected content as the custom datatable footer template.
///
/// The template receives a `LiDatatableFooterContext` through `let-ctx`.
@Directive(selector: 'template[li-datatable-footer]')
class LiDatatableFooterDirective {
  LiDatatableFooterDirective(this.templateRef);

  /// Angular template rendered in the datatable footer area.
  final TemplateRef templateRef;
}

/// Marks projected content as a custom body cell template for one column.
///
/// The directive value must match the target `DatatableCol.key`.
@Directive(selector: 'template[li-datatable-cell]')
class LiDatatableCellDirective {
  LiDatatableCellDirective(this.templateRef);

  /// Angular template rendered for matching body cells.
  final TemplateRef templateRef;

  /// Column key that receives this template.
  @Input('li-datatable-cell')
  String columnKey = '';
}

/// Marks projected content as a custom header-cell template for one column.
///
/// The directive value must match the target `DatatableCol.key`.
@Directive(selector: 'template[li-datatable-header-cell]')
class LiDatatableHeaderCellDirective {
  LiDatatableHeaderCellDirective(this.templateRef);

  /// Angular template rendered for the matching header cell.
  final TemplateRef templateRef;

  /// Column key that receives this template.
  @Input('li-datatable-header-cell')
  String columnKey = '';
}

/// Marks projected content as the custom card template used in grid mode.
///
/// The template receives a `LiDatatableCardContext` through `let-ctx`.
@Directive(selector: 'template[li-datatable-card]')
class LiDatatableCardDirective {
  LiDatatableCardDirective(this.templateRef);

  /// Angular template rendered for each grid item.
  final TemplateRef templateRef;
}
