//datatable_col.dart
import 'dart:async';
import 'dart:html';

import 'package:popper/popper.dart';

import '../../core/outside_click.dart';
import '../../core/overlay_positioning.dart';

export 'datatable_style.dart';

import 'datatable_style.dart';

typedef DatatableCellStyleResolver = String? Function(
  Map<String, dynamic> itemMap,
  dynamic itemInstance,
);

typedef DatatableTitleRenderString = String Function(DatatableCol column);
typedef DatatableTitleRenderHtml = Element Function(DatatableCol column);

enum DatatableTitleTooltipDisplayMode { icon, title }

class DatatableTitleTooltipConfig {
  const DatatableTitleTooltipConfig({
    required this.text,
    this.placement = 'top',
    this.trigger = 'hover focus',
    this.displayMode = DatatableTitleTooltipDisplayMode.icon,
    this.useNativeTitle = false,
    this.allowHtml = false,
    this.tooltipClass,
    this.iconClass = 'ph ph-info',
    this.buttonClass =
        'btn btn-link btn-icon p-0 border-0 bg-transparent datatable-title-help-button',
    this.ariaLabel,
    this.container = 'body',
    this.openDelay = 0,
    this.closeDelay = 0,
  });

  final Object text;
  final String placement;
  final String trigger;
  final DatatableTitleTooltipDisplayMode displayMode;
  final bool useNativeTitle;
  final bool allowHtml;
  final String? tooltipClass;
  final String iconClass;
  final String buttonClass;
  final String? ariaLabel;
  final String? container;
  final int openDelay;
  final int closeDelay;
}

class DatatableTitlePopoverConfig {
  const DatatableTitlePopoverConfig({
    required this.body,
    this.title,
    this.placement = 'top',
    this.trigger = 'click',
    this.allowHtml = false,
    this.popoverClass,
    this.iconClass = 'ph ph-question',
    this.buttonClass =
        'btn btn-link btn-icon p-0 border-0 bg-transparent datatable-title-help-button',
    this.ariaLabel,
    this.container = 'body',
    this.autoClose = 'outside',
    this.openDelay = 0,
    this.closeDelay = 0,
  });

  final Object body;
  final Object? title;
  final String placement;
  final String trigger;
  final bool allowHtml;
  final String? popoverClass;
  final String iconClass;
  final String buttonClass;
  final String? ariaLabel;
  final String? container;
  final Object autoClose;
  final int openDelay;
  final int closeDelay;
}

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

enum DatatableActionResponsiveMode {
  normal,
  desktopTextMobileIcon,
  desktopTextAndIconMobileIcon,
}

enum DatatableActionOverflowBehavior {
  auto,
  alwaysVisible,
  overflowMenu,
}

class DatatableAction {
  final String label;
  final String? iconClass;
  final String? title;
  final String buttonClass;
  final String size;
  final DatatableActionAppearance appearance;
  final bool iconOnly;
  final DatatableActionResponsiveMode responsiveMode;
  final DatatableActionOverflowBehavior overflowBehavior;
  final DatatableActionPredicate? visibleWhen;
  final DatatableActionPredicate? enabledWhen;
  final DatatableActionHandler onTap;

  const DatatableAction({
    required this.label,
    required this.onTap,
    this.iconClass,
    this.title,
    this.buttonClass = '',
    this.size = '',
    this.appearance = DatatableActionAppearance.button,
    this.iconOnly = false,
    this.responsiveMode = DatatableActionResponsiveMode.normal,
    this.overflowBehavior = DatatableActionOverflowBehavior.auto,
    this.visibleWhen,
    this.enabledWhen,
  });
}

class _DatatableResolvedActionLayout {
  final List<DatatableAction> inlineActions;
  final List<DatatableAction> overflowActions;

  const _DatatableResolvedActionLayout({
    required this.inlineActions,
    required this.overflowActions,
  });
}

class _DatatableActionFloatingOverlay {
  _DatatableActionFloatingOverlay._(
    this._controller, {
    required this.portal,
    required this.floatingElement,
  });

  final PopperController _controller;
  final PopperPortal portal;
  final Element floatingElement;

  factory _DatatableActionFloatingOverlay.attach({
    required Element referenceElement,
    required Element floatingElement,
  }) {
    final portal = PopperPortal.attach(
      floatingElement: floatingElement,
      options: resolveModalAwarePortalOptions(
        hostClassName: 'DatatableActionOverflowPortal',
        referenceElement: referenceElement,
        baseHostZIndex: 10000,
        baseFloatingZIndex: 1080,
      ),
    );

    final controller = PopperController(
      referenceElement: referenceElement,
      floatingElement: floatingElement,
      options: PopperOptions(
        placement: 'bottom-end',
        fallbackPlacements: const <String>[
          'top-end',
          'bottom-start',
          'top-start',
        ],
        strategy: PopperStrategy.fixed,
        offset: const PopperOffset(mainAxis: 4),
        padding: const PopperInsets.all(8),
        onLayout: (layout) => _handleLayout(floatingElement, layout),
      ),
    );

    return _DatatableActionFloatingOverlay._(
      controller,
      portal: portal,
      floatingElement: floatingElement,
    );
  }

  /// Keeps the menu anchored to the toggle and scrollable when the viewport
  /// is too short to show every action.
  static void _handleLayout(Element floatingElement, PopperLayout layout) {
    normalizeOverlayVerticalPosition(
      floatingElement: floatingElement,
      layout: layout,
      gap: 4,
    );
    constrainOverlayHeightToViewport(
      floatingElement: floatingElement,
      layout: layout,
      gap: 4,
    );
  }

  Future<PopperLayout?> update() => _controller.update();

  void startAutoUpdate() => _controller.startAutoUpdate();

  void dispose() {
    resetOverlayViewportConstraints(floatingElement: floatingElement);
    _controller.dispose();
    portal.dispose();
  }
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
  final int? maxVisibleActions;
  final String overflowButtonClass;
  final String overflowButtonIconClass;
  final String overflowButtonLabel;
  final bool overflowButtonIconOnly;
  final String overflowMenuClass;
  final String overflowButtonAriaLabel;
  final String? overflowButtonTitle;

  DatatableActionColumn({
    required super.key,
    super.title = 'Ações',
    super.titleTextAlign = 'center',
    super.exportable = false,
    List<DatatableAction> actions = const <DatatableAction>[],
    this.controller,
    this.wrapActions = false,
    this.containerClass =
        'datatable-action-cell d-inline-flex align-items-center gap-1',
    this.maxVisibleActions,
    this.overflowButtonClass =
        'btn btn-flat-primary border-transparent btn-icon datatable-action-overflow-toggle',
    this.overflowButtonIconClass = 'ph ph-list',
    this.overflowButtonLabel = '',
    this.overflowButtonIconOnly = true,
    this.overflowMenuClass =
        'dropdown-menu dropdown-menu-end datatable-action-overflow-menu',
    this.overflowButtonAriaLabel = 'Mais ações',
    this.overflowButtonTitle,
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
    super.responsiveControlEligible = false,
    super.fixedPosition,
    super.showAsFooterOnCard = false,
    super.customRenderTitleString,
    super.customRenderTitleHtml,
    super.titleTooltip,
    super.titlePopover,
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

    final resolvedLayout = _resolveActionLayout(actions);

    final classes = wrapActions ? '$containerClass flex-wrap' : containerClass;
    final container = DivElement()
      ..className = classes
      ..setAttribute('data-li-datatable-action-cell', 'true');

    for (final action in resolvedLayout.inlineActions) {
      final iconClass = action.iconClass?.trim();
      final useDesktopTextMobileIcon = !action.iconOnly &&
          action.responsiveMode ==
              DatatableActionResponsiveMode.desktopTextMobileIcon &&
          iconClass != null &&
          iconClass.isNotEmpty;
      final useDesktopTextAndIconMobileIcon = !action.iconOnly &&
          action.responsiveMode ==
              DatatableActionResponsiveMode.desktopTextAndIconMobileIcon &&
          iconClass != null &&
          iconClass.isNotEmpty;
      final baseButtonClass = _resolveActionBaseButtonClass(action);

      if (useDesktopTextMobileIcon || useDesktopTextAndIconMobileIcon) {
        container.append(
          _buildActionButton(
            action: action,
            context: context,
            baseButtonClass: baseButtonClass,
            renderIcon: useDesktopTextAndIconMobileIcon,
            renderLabel: true,
            extraButtonClasses: const <String>['d-none', 'd-md-inline-flex'],
          ),
        );

        container.append(
          _buildActionButton(
            action: action,
            context: context,
            baseButtonClass: baseButtonClass,
            renderIcon: true,
            renderLabel: false,
            extraButtonClasses: const <String>[
              'btn-icon',
              'd-inline-flex',
              'd-md-none',
            ],
          ),
        );
        continue;
      }

      container.append(
        _buildActionButton(
          action: action,
          context: context,
          baseButtonClass: baseButtonClass,
          renderIcon: iconClass != null && iconClass.isNotEmpty,
          renderLabel:
              !action.iconOnly || iconClass == null || iconClass.isEmpty,
          forceIconOnlyClass: action.iconOnly,
        ),
      );
    }

    if (resolvedLayout.overflowActions.isNotEmpty) {
      container.append(
        _buildOverflowDropdown(
          actions: resolvedLayout.overflowActions,
          context: context,
        ),
      );
    }

    return container;
  }

  _DatatableResolvedActionLayout _resolveActionLayout(
    List<DatatableAction> actions,
  ) {
    if (actions.isEmpty) {
      return const _DatatableResolvedActionLayout(
        inlineActions: <DatatableAction>[],
        overflowActions: <DatatableAction>[],
      );
    }

    final inlineActions = <DatatableAction>[];
    final overflowActions = <DatatableAction>[];
    final visibleLimit = maxVisibleActions;

    for (final action in actions) {
      if (action.overflowBehavior ==
          DatatableActionOverflowBehavior.alwaysVisible) {
        inlineActions.add(action);
      }
    }

    for (final action in actions) {
      if (action.overflowBehavior ==
              DatatableActionOverflowBehavior.alwaysVisible ||
          action.overflowBehavior ==
              DatatableActionOverflowBehavior.overflowMenu) {
        continue;
      }

      final canAddInline =
          visibleLimit == null || inlineActions.length < visibleLimit;
      if (canAddInline) {
        inlineActions.add(action);
      } else {
        overflowActions.add(action);
      }
    }

    for (final action in actions) {
      if (action.overflowBehavior ==
          DatatableActionOverflowBehavior.overflowMenu) {
        overflowActions.add(action);
      }
    }

    return _DatatableResolvedActionLayout(
      inlineActions: inlineActions,
      overflowActions: overflowActions,
    );
  }

  Element _buildOverflowDropdown({
    required List<DatatableAction> actions,
    required DatatableActionContext context,
  }) {
    final wrapper = DivElement()
      ..className = 'dropdown datatable-action-overflow'
      ..setAttribute('data-li-datatable-action-overflow', 'true');

    final toggleButton = ButtonElement()
      ..type = 'button'
      ..className = overflowButtonClass
      ..title = overflowButtonTitle ?? overflowButtonAriaLabel
      ..setAttribute('aria-label', overflowButtonAriaLabel)
      ..setAttribute('aria-expanded', 'false')
      ..setAttribute('data-li-datatable-action-overflow-toggle', 'true');

    final normalizedOverflowIconClass = overflowButtonIconClass.trim();
    if (normalizedOverflowIconClass.isNotEmpty) {
      toggleButton.append(
        Element.tag('i')..className = normalizedOverflowIconClass,
      );
    }

    if (!overflowButtonIconOnly && overflowButtonLabel.trim().isNotEmpty) {
      if (normalizedOverflowIconClass.isNotEmpty) {
        final iconElement = toggleButton.querySelector('i');
        iconElement?.classes.add('me-2');
      }
      toggleButton.appendText(overflowButtonLabel);
    }

    final menu = DivElement()
      ..className = overflowMenuClass
      ..setAttribute('data-li-datatable-action-overflow-menu', 'true');

    for (final action in actions) {
      menu.append(
        _buildOverflowMenuItem(action: action, context: context, menu: menu),
      );
    }

    StreamSubscription<Event>? outsideClickSubscription;
    StreamSubscription<KeyboardEvent>? escapeSubscription;
    StreamSubscription<FocusEvent>? focusInSubscription;
    _DatatableActionFloatingOverlay? overlay;

    bool targetIsInsideOverflow(Node target) {
      return wrapper.contains(target) || menu.contains(target);
    }

    void disposeOverlay() {
      overlay?.dispose();
      overlay = null;
    }

    void closeMenu() {
      menu.classes.remove('show');
      wrapper.classes.remove('show');
      toggleButton.setAttribute('aria-expanded', 'false');
      outsideClickSubscription?.cancel();
      outsideClickSubscription = null;
      escapeSubscription?.cancel();
      escapeSubscription = null;
      focusInSubscription?.cancel();
      focusInSubscription = null;
      disposeOverlay();
    }

    Future<void> openMenu() async {
      overlay ??= _DatatableActionFloatingOverlay.attach(
        referenceElement: toggleButton,
        floatingElement: menu,
      );
      overlay!.startAutoUpdate();
      menu.classes.add('show');
      wrapper.classes.add('show');
      toggleButton.setAttribute('aria-expanded', 'true');
      await overlay!.update();
      outsideClickSubscription ??= listenOutsideClick((event) {
        final target = event.target;
        if (target is Node && !targetIsInsideOverflow(target)) {
          closeMenu();
        }
      });
      escapeSubscription ??= document.onKeyDown.listen((event) {
        if (event.key == 'Escape') {
          closeMenu();
          toggleButton.focus();
        }
      });
      focusInSubscription ??=
          const EventStreamProvider<FocusEvent>('focusin')
              .forTarget(document)
              .listen((event) {
        final target = event.target;
        if (target is Node && !targetIsInsideOverflow(target)) {
          closeMenu();
        }
      });
    }

    toggleButton.onClick.listen((event) {
      event.preventDefault();
      event.stopPropagation();
      if (menu.classes.contains('show')) {
        closeMenu();
      } else {
        unawaited(openMenu());
      }
    });

    wrapper.append(toggleButton);

    return wrapper;
  }

  Element _buildOverflowMenuItem({
    required DatatableAction action,
    required DatatableActionContext context,
    required DivElement menu,
  }) {
    final button = ButtonElement()
      ..type = 'button'
      ..className =
          'dropdown-item cursor-pointer datatable-action-overflow-item'
      ..title = action.title ?? action.label
      ..setAttribute('aria-label', action.title ?? action.label)
      ..setAttribute('data-li-datatable-action', 'true');

    final iconClass = action.iconClass?.trim();
    if (iconClass != null && iconClass.isNotEmpty) {
      button.append(
        Element.tag('i')..className = '$iconClass me-2',
      );
    }
    button.appendText(action.label);

    if (!_isActionEnabled(action, context)) {
      button.disabled = true;
    }

    button.onClick.listen((event) {
      event.preventDefault();
      event.stopPropagation();
      menu.classes.remove('show');
      final wrapper = menu.parent;
      if (wrapper is Element) {
        wrapper.classes.remove('show');
        final toggle = wrapper.querySelector(
          '[data-li-datatable-action-overflow-toggle="true"]',
        );
        if (toggle is Element) {
          toggle.setAttribute('aria-expanded', 'false');
        }
      }
      Future.sync(() => action.onTap(context));
    });

    return button;
  }

  String _resolveActionBaseButtonClass(DatatableAction action) {
    final normalizedButtonClass = action.buttonClass.trim();
    if (normalizedButtonClass.isNotEmpty) {
      return normalizedButtonClass;
    }

    return action.appearance == DatatableActionAppearance.linkIcon
        ? (action.iconOnly ? 'btn btn-link btn-icon' : 'btn btn-link')
        : (action.iconOnly
            ? 'btn btn-flat-primary border-transparent btn-icon'
            : 'btn btn-flat-primary border-transparent');
  }

  String _resolveActionSizeClass(DatatableAction action) {
    switch (action.size.trim().toLowerCase()) {
      case 'sm':
        return 'btn-sm';
      case 'lg':
        return 'btn-lg';
      default:
        return '';
    }
  }

  ButtonElement _buildActionButton({
    required DatatableAction action,
    required DatatableActionContext context,
    required String baseButtonClass,
    required bool renderIcon,
    required bool renderLabel,
    bool forceIconOnlyClass = false,
    List<String> extraButtonClasses = const <String>[],
    List<String> extraIconClasses = const <String>[],
  }) {
    final sizeClass = _resolveActionSizeClass(action);
    final classNames = <String>[
      baseButtonClass,
      sizeClass,
      if (forceIconOnlyClass) 'datatable-action-button--icon-only',
      ...extraButtonClasses,
    ];

    final button = ButtonElement()
      ..type = 'button'
      ..className =
          classNames.where((value) => value.trim().isNotEmpty).join(' ')
      ..title = (action.title ?? action.label)
      ..setAttribute('aria-label', action.title ?? action.label)
      ..setAttribute('data-li-datatable-action', 'true');

    if (!_isActionEnabled(action, context)) {
      button.disabled = true;
    }

    final iconClass = action.iconClass?.trim();
    if (renderIcon && iconClass != null && iconClass.isNotEmpty) {
      final iconClasses = <String>[
        iconClass,
        if (renderLabel) 'me-2',
        ...extraIconClasses,
      ];
      final icon = Element.tag('i')
        ..className =
            iconClasses.where((value) => value.trim().isNotEmpty).join(' ');
      button.append(icon);
    }

    if (renderLabel) {
      button.appendText(action.label);
    }

    button.onClick.listen((event) {
      event.preventDefault();
      event.stopPropagation();
      Future.sync(() => action.onTap(context));
    });

    return button;
  }

  bool _isActionEnabled(
    DatatableAction action,
    DatatableActionContext context,
  ) {
    final enabledWhen = action.enabledWhen;
    if (enabledWhen == null) {
      return true;
    }

    try {
      return enabledWhen(context);
    } catch (_) {
      return false;
    }
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
  String renderedTitle = '';
  Element? titleHtmlElement;
  DatatableFormat? format;
  String? styleCss;
  String? headerStyleCss;
  String? headerClass;
  String? cellClass;
  String? width;
  String? minWidth;
  String? maxWidth;
  String? textAlign;
  String? titleTextAlign;
  bool exportable;
  bool nowrap = false;
  DatatableCellStyleResolver? cellStyleResolver;
  DatatableTitleRenderString? customRenderTitleString;
  DatatableTitleRenderHtml? customRenderTitleHtml;
  DatatableTitleTooltipConfig? titleTooltip;
  DatatableTitlePopoverConfig? titlePopover;

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

  /// Whether the column can host the inline expand/collapse control used by
  /// the responsive collapse mode.
  ///
  /// Columns packed with interactive content — action buttons above all — opt
  /// out so the control never has to share its hit area with a button.
  bool responsiveControlEligible = true;

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
    this.titleTextAlign,
    this.exportable = true,
    this.nowrap = false,
    this.cellStyleResolver,
    this.visibility = true,
    this.enableSorting = false,
    this.customRenderTitleString,
    this.customRenderTitleHtml,
    this.titleTooltip,
    this.titlePopover,
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
    this.responsiveControlEligible = true,
    this.fixedPosition,
    this.showAsFooterOnCard = false,
    this.type = DatatableColType.normal,
  }) {
    renderedTitle = title;
  }
}
