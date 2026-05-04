import 'dart:async';
import 'dart:html';

export 'datatable_style.dart';

import 'datatable_style.dart';

typedef DatatableCellStyleResolver = String? Function(
  Map<String, dynamic> itemMap,
  dynamic itemInstance,
);

enum DatatableColType { normal, groupTitle }

enum DatatableFixedColumnPosition { left, right }

class DatatableActionContext {
  final Map<String, dynamic> itemMap;
  final dynamic itemInstance;

  DatatableActionContext({
    required this.itemMap,
    required this.itemInstance,
  });
}

typedef DatatableActionHandler = FutureOr<void> Function(
  DatatableActionContext context,
);
typedef DatatableActionPredicate = bool Function(
    DatatableActionContext context);

enum DatatableActionAppearance { button, linkIcon }

class DatatableAction {
  final String label;
  final String? iconClass;
  final String? title;
  final String buttonClass;
  final DatatableActionAppearance appearance;
  final bool iconOnly;
  final DatatableActionPredicate? visibleWhen;
  final DatatableActionPredicate? enabledWhen;
  final DatatableActionHandler onTap;

  const DatatableAction({
    required this.label,
    required this.onTap,
    this.iconClass,
    this.title,
    this.buttonClass = '',
    this.appearance = DatatableActionAppearance.button,
    this.iconOnly = false,
    this.visibleWhen,
    this.enabledWhen,
  });
}

class DatatableActionController {
  List<DatatableAction> _actions;

  DatatableActionController({List<DatatableAction>? actions})
      : _actions =
            List<DatatableAction>.from(actions ?? const <DatatableAction>[]);

  List<DatatableAction> get actions =>
      List<DatatableAction>.unmodifiable(_actions);

  void setActions(Iterable<DatatableAction> nextActions) {
    _actions = List<DatatableAction>.from(nextActions);
  }

  void clear() {
    _actions = <DatatableAction>[];
  }
}

/// Helper column for row actions in table mode.
///
/// This API is independent of [customRenderHtml] and does not replace it.
/// Internally, it builds an HTML container with buttons and delegates
/// callbacks through [DatatableAction].
class DatatableActionColumn extends DatatableCol {
  final List<DatatableAction> _actions;
  final DatatableActionController? controller;
  final bool wrapActions;
  final String containerClass;

  DatatableActionColumn({
    required super.key,
    super.title = 'Ações',
    List<DatatableAction> actions = const <DatatableAction>[],
    this.controller,
    this.wrapActions = false,
    this.containerClass =
        'datatable-action-cell d-inline-flex align-items-center gap-1',
    super.width = '1%',
    super.minWidth = '1%',
    super.maxWidth,
    super.headerClass,
    super.cellClass,
    super.visibility = true,
    super.visibilityOnCard = true,
    super.showTitleOnCard = false,
    super.hideOnMobile = false,
    super.responsiveAutoHideRequired = true,
    super.responsiveAutoHidePriority,
    super.fixedPosition,
    super.showAsFooterOnCard = false,
  })  : _actions = List<DatatableAction>.from(actions),
        super(
          enableSorting: false,
          customRenderString: null,
        ) {
    nowrap = true;
    customRenderHtml = _renderActionsCell;
  }

  List<DatatableAction> get resolvedActions =>
      controller?.actions ?? List<DatatableAction>.unmodifiable(_actions);

  Element _renderActionsCell(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    final context = DatatableActionContext(
      itemMap: itemMap,
      itemInstance: itemInstance,
    );

    final actions = resolvedActions.where((action) {
      final visibleWhen = action.visibleWhen;
      if (visibleWhen == null) {
        return true;
      }
      try {
        return visibleWhen(context);
      } catch (_) {
        return false;
      }
    }).toList(growable: false);

    final classes = wrapActions ? '$containerClass flex-wrap' : containerClass;
    final container = DivElement()..className = classes;

    for (final action in actions) {
      final normalizedButtonClass = action.buttonClass.trim();
      final defaultButtonClass =
          action.appearance == DatatableActionAppearance.linkIcon
              ? (action.iconOnly ? 'btn btn-link btn-icon' : 'btn btn-link')
              : (action.iconOnly
                  ? 'btn btn-flat-primary border-transparent btn-icon'
                  : 'btn btn-flat-primary border-transparent');
      final classNames = <String>[
        normalizedButtonClass.isEmpty
            ? defaultButtonClass
            : normalizedButtonClass,
        if (action.iconOnly) 'datatable-action-button--icon-only',
      ];

      final button = ButtonElement()
        ..type = 'button'
        ..className =
            classNames.where((value) => value.trim().isNotEmpty).join(' ')
        ..title = (action.title ?? action.label)
        ..setAttribute('aria-label', action.title ?? action.label);

      var isEnabled = true;
      final enabledWhen = action.enabledWhen;
      if (enabledWhen != null) {
        try {
          isEnabled = enabledWhen(context);
        } catch (_) {
          isEnabled = false;
        }
      }
      if (!isEnabled) {
        button.disabled = true;
      }

      final iconClass = action.iconClass?.trim();
      if (iconClass != null && iconClass.isNotEmpty) {
        final resolvedIconClass =
            !action.iconOnly ? '$iconClass me-1' : iconClass;
        final icon = Element.tag('i')..className = resolvedIconClass;
        button.append(icon);
      }

      final renderLabel = !action.iconOnly || button.nodes.isEmpty;
      if (renderLabel) {
        button.appendText(action.label);
      }

      button.onClick.listen((event) {
        event.preventDefault();
        event.stopPropagation();
        Future.sync(() => action.onTap(context));
      });

      container.append(button);
    }

    return container;
  }
}

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

  /// When [LiDataTableComponent.responsiveAutoHideColumns] is enabled,
  /// columns marked as required are never auto-hidden.
  bool responsiveAutoHideRequired = false;

  /// Optional priority used by responsive auto-hide.
  ///
  /// Lower values are hidden first. Columns without a priority are not part
  /// of the automatic hiding cycle.
  int? responsiveAutoHidePriority;

  /// Keeps the column sticky on the chosen side during horizontal scrolling.
  DatatableFixedColumnPosition? fixedPosition;

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
    this.responsiveAutoHideRequired = false,
    this.responsiveAutoHidePriority,
    this.fixedPosition,
    this.showAsFooterOnCard = false,
    this.type = DatatableColType.normal,
  });
}
