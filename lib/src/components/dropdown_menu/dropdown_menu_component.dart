import 'dart:async';
import 'dart:html' as html;

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

  /// Rendering container: `inline` keeps the menu in normal DOM flow,
  /// `body` renders it in a portal anchored with Popper.
  @Input()
  String container = 'body';

  /// Dropdown direction: dropdown, dropup, dropstart, or dropend.
  @Input()
  String placement = 'dropdown';

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

  String get resolvedHostClasses {
    final normalizedPlacement = placement.trim().toLowerCase();
    final placementClass = switch (normalizedPlacement) {
      'dropup' => 'dropup',
      'dropstart' => 'dropstart',
      'dropend' => 'dropend',
      _ => 'dropdown',
    };

    return _joinClasses(<String>[
      placementClass,
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
      menuClass,
      isOpen ? 'show' : '',
    ]);
  }

  bool get usesNavbarTrigger => triggerClass.contains('navbar-nav-link');

  bool get usesBodyOverlay => container.trim().toLowerCase() == 'body';

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

    if (usesBodyOverlay) {
      _ensureOverlay();
    }
    _bindDocumentListeners();
    isOpen = true;
    _registerAsOpenMenu();
    if (usesBodyOverlay) {
      _overlay?.startAutoUpdate();
      _scheduleOverlayUpdate();
    }
    _changeDetectorRef.markForCheck();
  }

  void closeDropdown({bool restoreFocus = false}) {
    if (!isOpen) {
      return;
    }

    isOpen = false;
    _overlayRelayoutPending = false;
    _unregisterAsOpenMenu();
    if (usesBodyOverlay) {
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
    if (!usesBodyOverlay || _overlayRelayoutPending || !isOpen) {
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

  void _closeOtherOpenMenus() {
    for (final dropdown in List<LiDropdownMenuComponent>.from(_openDropdownMenus)) {
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
    _overlay?.stopAutoUpdate();
    _overlay?.dispose();
    _valueChange.close();
  }
}
