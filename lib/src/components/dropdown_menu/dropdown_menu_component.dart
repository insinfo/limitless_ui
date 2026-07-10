import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'package:ngdart/angular.dart';
import 'package:popper/popper.dart';

/// Public directives used by the dropdown menu component.
const liDropdownMenuDirectives = <Object>[
  LiDropdownMenuComponent,
];

class LiDropdownMenuOption {
  const LiDropdownMenuOption({
    this.value = '',
    this.label = '',
    this.iconClass = '',
    this.description = '',
    this.disabled = false,
    this.divider = false,
  });

  final String value;
  final String label;
  final String iconClass;
  final String description;
  final bool disabled;
  final bool divider;
}

@Component(
  selector: 'li-dropdown-menu',
  templateUrl: 'dropdown_menu_component.html',
  styleUrls: ['dropdown_menu_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiDropdownMenuComponent implements OnDestroy {
  static final List<LiDropdownMenuComponent> _openDropdownMenus =
      <LiDropdownMenuComponent>[];

  LiDropdownMenuComponent(this._changeDetectorRef);

  final ChangeDetectorRef _changeDetectorRef;

  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;
  PopperAnchoredOverlay? _overlay;
  bool _overlayRelayoutPending = false;
  bool _inlineViewportRelayoutPending = false;
  bool _openUpwardForViewport = false;
  bool _menuContentOverflows = false;
  String _viewportMaxHeight = '';
  String _menuMaxHeight = '';

  @Input()
  List<LiDropdownMenuOption> options = const <LiDropdownMenuOption>[];

  @Input()
  String value = '';

  @Input()
  String ariaLabel = '';

  @Input()
  String triggerLabel = '';

  @Input()
  String triggerIconClass = '';

  @Input()
  String triggerClass = 'btn btn-outline-primary btn-sm';

  @Input()
  String menuClass = 'dropdown-menu-end';

  /// Optional CSS max-height for long option lists.
  ///
  /// When set, the menu scrolls vertically instead of growing past the
  /// viewport or covering too much surrounding UI.
  @Input()
  set menuMaxHeight(String value) {
    _menuMaxHeight = value;
    _syncMenuStyleState();
  }

  String get menuMaxHeight => _menuMaxHeight;

  /// Mobile presentation for small viewports.
  ///
  /// `dropdown` keeps the normal anchored menu. `modal` shows the menu as a
  /// centered fixed dialog with a backdrop, and `sheet` shows it as a bottom
  /// sheet, when the viewport matches [mobileBreakpoint].
  @Input()
  String mobilePresentation = 'dropdown';

  /// CSS media-query width used by [mobilePresentation].
  @Input()
  String mobileBreakpoint = '575.98px';

  /// Optional title shown at the top of the mobile modal menu.
  @Input()
  String mobileMenuTitle = '';

  @Input()
  String mobileCloseButtonAriaLabel = 'Fechar';

  @Input()
  TemplateRef? mobileFooterTemplate;

  @Input()
  dynamic mobileFooterContext;

  String _container = 'body';

  /// Rendering container: `inline` keeps the menu in normal DOM flow,
  /// `body` renders it in a portal anchored with Popper.
  @Input()
  set container(String value) {
    final next = value.trim().isEmpty ? 'body' : value.trim();
    if (_container == next) {
      return;
    }

    final hadBodyOverlay = usesBodyOverlay;
    final wasOpen = isOpen;
    if (isOpen) {
      closeDropdown();
    }
    if (hadBodyOverlay) {
      _disposeOverlay();
    }
    _container = next;
    _changeDetectorRef.markForCheck();
    if (wasOpen) {
      Timer.run(() {
        if (!isOpen) {
          openDropdown();
        }
      });
    }
  }

  String get container => _container;

  /// Dropdown direction: dropdown, dropup, dropstart, or dropend.
  @Input()
  String placement = 'dropdown';

  /// When `true`, inline dropdowns flip upward if the menu would overflow the
  /// viewport bottom. Body overlays already use Popper fallback placements.
  @Input()
  bool adaptToViewport = true;

  @Input()
  bool showCaret = true;

  @Input()
  bool rounded = false;

  @Input()
  bool closeOnSelect = true;

  /// When `true`, opening this dropdown closes other open `li-dropdown-menu`
  /// instances first.
  ///
  /// Set it to `false` for special compositions such as submenu-like layouts
  /// or coordinated toolbars where multiple menus may stay open at once.
  @Input()
  bool closeOtherMenusOnOpen = true;

  @ViewChild('triggerButton')
  html.ButtonElement? triggerButtonElement;

  @ViewChild('menuElement')
  html.Element? menuElement;

  @Output()
  Stream<String> get valueChange => _valueChange.stream;

  final _valueChange = StreamController<String>.broadcast();

  bool isOpen = false;
  String? resolvedMenuMaxHeight;
  String? resolvedItemsMaxHeight;
  String? resolvedItemsOverflowY;

  String get resolvedHostClasses {
    final normalizedPlacement = placement.trim().toLowerCase();
    final placementClass = _openUpwardForViewport
        ? 'dropup'
        : switch (normalizedPlacement) {
            'dropup' => 'dropup',
            'dropstart' => 'dropstart',
            'dropend' => 'dropend',
            _ => 'dropdown',
          };

    return _joinClasses(<String>[
      placementClass,
      usesMobilePresentation ? 'li-dropdown-menu--mobile-open' : '',
      isOpen ? 'show' : '',
    ]);
  }

  String get resolvedTriggerClasses {
    return _joinClasses(<String>[
      'li-dropdown-menu__trigger',
      triggerClass,
      usesNavbarTrigger ? 'li-dropdown-trigger-reset' : '',
      showCaret ? 'dropdown-toggle' : '',
      rounded ? 'rounded-pill' : '',
      triggerIconClass.trim().isNotEmpty
          ? 'd-inline-flex align-items-center'
          : '',
    ]);
  }

  String get resolvedTriggerIconClasses {
    return _joinClasses(<String>[
      triggerIconClass.trim(),
      triggerLabel.trim().isNotEmpty ? 'me-2' : '',
    ]);
  }

  String get resolvedMenuClasses {
    return _joinClasses(<String>[
      'dropdown-menu',
      'li-dropdown-menu__menu',
      usesMobileModal ? 'li-dropdown-menu__menu--mobile-modal' : '',
      usesMobileSheet ? 'li-dropdown-menu__menu--mobile-sheet' : '',
      menuClass,
      isOpen ? 'show' : '',
    ]);
  }

  String? _resolveMenuMaxHeight() {
    if (!usesMobilePresentation) {
      return null;
    }

    final viewportHeight = _viewportHeight;
    final inset = usesMobileSheet ? 24 : 32;
    final maxHeight = max(120, viewportHeight - inset).floor();
    return '${maxHeight}px';
  }

  String? _resolveItemsMaxHeight() {
    if (usesMobilePresentation) {
      return null;
    }

    final normalizedMaxHeight = _menuMaxHeight.trim();
    final resolvedMaxHeight = _viewportMaxHeight.isNotEmpty
        ? _viewportMaxHeight
        : normalizedMaxHeight;
    if (resolvedMaxHeight.isEmpty) {
      return null;
    }

    return resolvedMaxHeight;
  }

  String? _resolveItemsOverflowY(String? maxHeight) {
    if (usesMobilePresentation || maxHeight == null) {
      return null;
    }

    return _viewportMaxHeight.isNotEmpty || _menuContentOverflows
        ? 'auto'
        : 'hidden';
  }

  void _syncMenuStyleState() {
    final nextMenuMaxHeight = _resolveMenuMaxHeight();
    final nextItemsMaxHeight = _resolveItemsMaxHeight();
    final nextItemsOverflowY = _resolveItemsOverflowY(nextItemsMaxHeight);
    resolvedMenuMaxHeight = nextMenuMaxHeight;
    resolvedItemsMaxHeight = nextItemsMaxHeight;
    resolvedItemsOverflowY = nextItemsOverflowY;
  }

  bool get usesMobileModal {
    return isOpen && _shouldUseMobilePresentation('modal');
  }

  bool get usesMobileSheet {
    return isOpen && _shouldUseMobilePresentation('sheet');
  }

  bool get usesMobilePresentation => usesMobileModal || usesMobileSheet;

  bool _shouldUseMobilePresentation(String presentation) {
    if (mobilePresentation.trim().toLowerCase() != presentation) {
      return false;
    }

    final breakpoint = mobileBreakpoint.trim();
    if (breakpoint.isEmpty) {
      return false;
    }

    return html.window.matchMedia('(max-width: $breakpoint)').matches;
  }

  bool get showsMobileModalHeader =>
      usesMobilePresentation && mobileMenuTitle.trim().isNotEmpty;

  double get _viewportHeight {
    final windowHeight = html.window.innerHeight?.toDouble() ?? 0;
    final documentHeight =
        html.document.documentElement?.clientHeight.toDouble() ?? 0;
    if (windowHeight > 0 && documentHeight > 0) {
      return min(windowHeight, documentHeight);
    }
    return max(windowHeight, documentHeight);
  }

  bool get usesNavbarTrigger => triggerClass.contains('navbar-nav-link');

  bool get usesBodyOverlay => container.trim().toLowerCase() == 'body';

  bool get usesBodyDropdownOverlay => usesBodyOverlay;

  bool get _alignEnd =>
      RegExp(r'(^|\s)dropdown-menu-end(\s|$)').hasMatch(menuClass);

  String get _normalizedPlacement => placement.trim().toLowerCase();

  String get _resolvedOverlayPlacement {
    switch (_normalizedPlacement) {
      case 'dropup':
        return _alignEnd ? 'top-end' : 'top-start';
      case 'dropstart':
        return 'left-start';
      case 'dropend':
        return 'right-start';
      default:
        return _alignEnd ? 'bottom-end' : 'bottom-start';
    }
  }

  List<String> get _resolvedFallbackPlacements {
    switch (_normalizedPlacement) {
      case 'dropup':
        return _alignEnd
            ? const <String>['bottom-end', 'top-start', 'bottom-start']
            : const <String>['bottom-start', 'top-end', 'bottom-end'];
      case 'dropstart':
        return const <String>['right-start', 'bottom-start', 'top-start'];
      case 'dropend':
        return const <String>['left-start', 'bottom-end', 'top-end'];
      default:
        return _alignEnd
            ? const <String>['top-end', 'bottom-start', 'top-start']
            : const <String>['top-start', 'bottom-end', 'top-end'];
    }
  }

  bool isSelected(LiDropdownMenuOption option) => option.value == value;

  String resolvedItemClasses(LiDropdownMenuOption option) {
    return _joinClasses(<String>[
      'dropdown-item',
      option.description.isNotEmpty || option.iconClass.trim().isNotEmpty
          ? 'd-flex align-items-start'
          : '',
      isSelected(option) ? 'active' : '',
    ]);
  }

  String resolvedItemIconClasses(LiDropdownMenuOption option) {
    return _joinClasses(<String>[option.iconClass.trim(), 'me-2 mt-1']);
  }

  void toggleDropdown(html.MouseEvent event) {
    event.preventDefault();
    event.stopPropagation();

    if (isOpen) {
      closeDropdown(restoreFocus: true);
      return;
    }

    openDropdown();
  }

  void openDropdown() {
    if (isOpen) {
      return;
    }

    if (closeOtherMenusOnOpen) {
      _closeOtherOpenMenus();
    }

    if (usesBodyDropdownOverlay) {
      _ensureOverlay();
    }
    _bindDocumentListeners();
    isOpen = true;
    _registerAsOpenMenu();
    _syncMenuStyleState();
    if (usesBodyDropdownOverlay && !usesMobilePresentation) {
      _overlay?.startAutoUpdate();
      _scheduleOverlayUpdate();
    }
    _scheduleViewportAdaptation();
    _changeDetectorRef.markForCheck();
  }

  void closeDropdown({bool restoreFocus = false}) {
    if (!isOpen) {
      return;
    }

    isOpen = false;
    _overlayRelayoutPending = false;
    _inlineViewportRelayoutPending = false;
    _openUpwardForViewport = false;
    _menuContentOverflows = false;
    _viewportMaxHeight = '';
    _syncMenuStyleState();
    _unregisterAsOpenMenu();
    if (usesBodyDropdownOverlay) {
      _overlay?.stopAutoUpdate();
    }
    _unbindDocumentListeners();

    if (restoreFocus) {
      triggerButtonElement?.focus();
    }

    _changeDetectorRef.markForCheck();
  }

  void selectOption(LiDropdownMenuOption option, html.MouseEvent event) {
    event.preventDefault();
    event.stopPropagation();

    if (option.disabled || option.divider) {
      return;
    }

    _valueChange.add(option.value);

    if (closeOnSelect) {
      closeDropdown();
    }
  }

  void closeFromMobilePresentation() {
    closeDropdown(restoreFocus: true);
  }

  void _ensureOverlay() {
    if (!usesBodyOverlay) {
      return;
    }

    final reference = triggerButtonElement;
    final floating = menuElement;
    if (_overlay != null || reference == null || floating == null) {
      return;
    }

    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: reference,
      floatingElement: floating,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'LiDropdownMenuComponent',
        hostZIndex: '10000',
        floatingZIndex: '1056',
        // Restore the menu element to its inline parent when the portal is
        // disposed (e.g. when `container` flips to `inline` as the PDF viewer
        // enters fullscreen). Without this the element is removed from the DOM
        // and the reopened inline menu renders nothing.
        restoreOnDispose: true,
      ),
      popperOptions: PopperOptions(
        placement: _resolvedOverlayPlacement,
        fallbackPlacements: _resolvedFallbackPlacements,
        strategy: PopperStrategy.fixed,
        padding: const PopperInsets.all(8),
        offset: const PopperOffset(mainAxis: 4),
      ),
    );
  }

  void _bindDocumentListeners() {
    _documentClickSubscription ??= html.document.onClick.listen((event) {
      if (!isOpen) {
        return;
      }

      final target = event.target;
      if (target is! html.Node) {
        closeDropdown();
        return;
      }

      final clickedTrigger = triggerButtonElement?.contains(target) ?? false;
      final clickedMenu = menuElement?.contains(target) ?? false;
      if (!clickedTrigger && !clickedMenu) {
        closeDropdown();
      }
    });

    _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
      if (!isOpen) {
        return;
      }

      if (event.key == 'Escape') {
        event.preventDefault();
        closeDropdown(restoreFocus: true);
      }
    });
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription?.cancel();
    _documentKeySubscription = null;
  }

  void _scheduleOverlayUpdate() {
    if (!usesBodyDropdownOverlay ||
        usesMobilePresentation ||
        _overlayRelayoutPending ||
        !isOpen) {
      return;
    }

    _overlayRelayoutPending = true;
    html.window.requestAnimationFrame((_) {
      _overlayRelayoutPending = false;
      if (!isOpen) {
        return;
      }

      _overlay?.update();
    });
  }

  void _scheduleViewportAdaptation() {
    if (!adaptToViewport ||
        usesMobilePresentation ||
        _inlineViewportRelayoutPending ||
        !isOpen) {
      return;
    }

    final normalizedPlacement = _normalizedPlacement;
    if (!usesBodyDropdownOverlay &&
        normalizedPlacement != 'dropdown' &&
        normalizedPlacement.isNotEmpty) {
      return;
    }

    _inlineViewportRelayoutPending = true;
    html.window.requestAnimationFrame((_) {
      _inlineViewportRelayoutPending = false;
      if (!isOpen || usesMobilePresentation) {
        return;
      }

      final trigger = triggerButtonElement;
      final menu = menuElement;
      if (trigger == null || menu == null) {
        return;
      }

      final triggerRect = trigger.getBoundingClientRect();
      final menuRect = menu.getBoundingClientRect();
      final viewportHeight = _viewportHeight;
      if (viewportHeight <= 0 || menuRect.height <= 0) {
        return;
      }

      final spaceBelow = viewportHeight - triggerRect.bottom;
      final spaceAbove = triggerRect.top;
      final shouldOpenUpward = !usesBodyDropdownOverlay &&
          menuRect.bottom > viewportHeight - 8 &&
          spaceAbove > spaceBelow;
      final availableSpace = usesBodyDropdownOverlay
          ? viewportHeight - menuRect.top
          : (shouldOpenUpward ? spaceAbove : spaceBelow);
      final availableHeight = max(80, availableSpace - 8).floor();
      final nextMaxHeight =
          menuRect.height > availableHeight ? '${availableHeight}px' : '';
      final menuItems = menu.querySelector('.li-dropdown-menu__items');
      final itemContentHeight = menu
          .querySelectorAll('.li-dropdown-menu__items > *')
          .fold<double>(0, (height, element) {
        return height + element.getBoundingClientRect().height;
      });
      final contentHeight = itemContentHeight > 0
          ? itemContentHeight.ceil()
          : menuItems is html.Element
              ? menuItems.scrollHeight
              : menu.scrollHeight;
      final contentOverflows = contentHeight > menu.clientHeight + 4;

      if (_openUpwardForViewport != shouldOpenUpward ||
          _viewportMaxHeight != nextMaxHeight ||
          _menuContentOverflows != contentOverflows) {
        _openUpwardForViewport = shouldOpenUpward;
        _viewportMaxHeight = nextMaxHeight;
        _menuContentOverflows = contentOverflows;
        _syncMenuStyleState();
        _changeDetectorRef.markForCheck();
      }
    });
  }

  void _closeOtherOpenMenus() {
    for (final dropdown
        in List<LiDropdownMenuComponent>.from(_openDropdownMenus)) {
      if (!identical(dropdown, this)) {
        dropdown.closeDropdown();
      }
    }
  }

  void _registerAsOpenMenu() {
    _openDropdownMenus.remove(this);
    _openDropdownMenus.add(this);
  }

  void _unregisterAsOpenMenu() {
    _openDropdownMenus.remove(this);
  }

  void _disposeOverlay() {
    _overlayRelayoutPending = false;
    _overlay?.stopAutoUpdate();
    _overlay?.dispose();
    _overlay = null;
  }

  String _joinClasses(List<String> classNames) {
    return classNames
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  @override
  void ngOnDestroy() {
    _unregisterAsOpenMenu();
    _unbindDocumentListeners();
    _disposeOverlay();
    _valueChange.close();
  }
}
