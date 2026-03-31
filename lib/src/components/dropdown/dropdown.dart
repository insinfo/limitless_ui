import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:popper/popper.dart';

import 'dropdown_config.dart';

/// Public directives used by dropdown APIs.
const liDropdownDirectives = <Object>[
  LiDropdownDirective,
  LiDropdownAnchorDirective,
  LiDropdownToggleDirective,
  LiDropdownMenuDirective,
  LiDropdownItemDirective,
  LiDropdownButtonItemDirective,
];

String _normalizedDropdownKey(html.KeyboardEvent event) {
  final key = event.key;
  if (key != null && key.isNotEmpty) {
    return key;
  }

  switch (event.keyCode) {
    case 9:
      return 'Tab';
    case 13:
      return 'Enter';
    case 27:
      return 'Escape';
    case 32:
      return ' ';
    case 35:
      return 'End';
    case 36:
      return 'Home';
    case 38:
      return 'ArrowUp';
    case 40:
      return 'ArrowDown';
    default:
      return '';
  }
}

/// Dropdown declarativo com API próxima ao `ng-bootstrap`.
///
/// O visual do caret do gatilho depende do CSS do tema. No example usando
/// Limitless 4 + ícones Phosphor, o tema base precisa renderizar
/// `.dropdown-toggle::after` com um glyph existente da fonte Phosphor.
/// Caso o tema carregado use um codepoint diferente, faça um override global
/// para o caret, por exemplo usando `content: "\e9fe"` (`ph-caret-down`).
@Directive(
  selector: '[liDropdown]',
  exportAs: 'liDropdown',
)
class LiDropdownDirective implements OnInit, OnDestroy {
  LiDropdownDirective(
    this._hostElement,
    this._changeDetectorRef, [
    @Optional() LiDropdownConfig? config,
  ]) : _config = config ?? LiDropdownConfig();

  final html.Element _hostElement;
  final ChangeDetectorRef _changeDetectorRef;
  final LiDropdownConfig _config;
  final StreamController<bool> _openChangeController =
      StreamController<bool>.broadcast();

  final List<LiDropdownItemDirective> _items = <LiDropdownItemDirective>[];

  LiDropdownMenuDirective? _menu;
  LiDropdownAnchorDirective? _anchor;
  PopperController? _popperController;
  html.DivElement? _bodyContainer;
  StreamSubscription<html.MouseEvent>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;

  bool _open = false;
  String? _dropdownClass;
  String? _container;
  String? _display;
  dynamic _autoClose = true;
  dynamic _placement = 'bottom-start bottom-end top-start top-end';

  @Input()
  set autoClose(Object? value) {
    _autoClose = value ?? _config.autoClose;
  }

  Object? get autoClose => _autoClose;

  @Input()
  set container(String? value) {
    final normalized = value?.trim();
    _container = normalized == null || normalized.isEmpty
        ? _config.container
        : normalized;
  }

  String? get container => _container;

  @Input()
  set display(String? value) {
    final normalized = value?.trim();
    _display =
        normalized == null || normalized.isEmpty ? _config.display : normalized;
  }

  String get display => _display ?? 'dynamic';

  @Input()
  set dropdownClass(String? value) {
    _applyCustomDropdownClass(value?.trim(), _dropdownClass);
    _dropdownClass = value?.trim();
  }

  String? get dropdownClass => _dropdownClass;

  @Input('open')
  set opened(bool value) {
    if (value) {
      open();
      return;
    }
    close();
  }

  @Input()
  set placement(Object? value) {
    _placement = value ?? _config.placement;
    _applyPlacementClasses();
    _updatePositioning();
  }

  Object? get placement => _placement;

  @Output()
  Stream<bool> get openChange => _openChangeController.stream;

  @HostBinding('class.show')
  bool get hostShowClass => _open;

  @HostBinding('class.dropdown')
  bool get hostDropdownClass => !_isDropup(_firstPlacement);

  @HostBinding('class.dropup')
  bool get hostDropupClass => _isDropup(_firstPlacement);

  @override
  void ngOnInit() {
    autoClose = _autoClose;
    container = _container;
    display = _display;
    placement = _placement;

    _display ??= _hostElement.closest('.navbar') != null ? 'static' : 'dynamic';

    _applyPlacementClasses();
    if (_open) {
      open();
    }
  }

  void registerMenu(LiDropdownMenuDirective menu) {
    _menu = menu;
    _applyPlacementClasses();
  }

  void unregisterMenu(LiDropdownMenuDirective menu) {
    if (identical(_menu, menu)) {
      _menu = null;
    }
  }

  void registerAnchor(LiDropdownAnchorDirective anchor) {
    _anchor = anchor;
  }

  void unregisterAnchor(LiDropdownAnchorDirective anchor) {
    if (identical(_anchor, anchor)) {
      _anchor = null;
    }
  }

  void registerItem(LiDropdownItemDirective item) {
    if (_items.contains(item)) {
      return;
    }
    _items.add(item);
  }

  void unregisterItem(LiDropdownItemDirective item) {
    _items.remove(item);
  }

  bool isOpen() => _open;

  void open() {
    if (_open) {
      _updatePositioning();
      return;
    }

    _open = true;
    _applyContainer();
    _setCloseHandlers();
    _applyPlacementClasses();
    _updatePositioning();
    _openChangeController.add(true);
    _changeDetectorRef.markForCheck();
  }

  void close() {
    if (!_open) {
      return;
    }

    _open = false;
    _destroyDocumentHandlers();
    _destroyPopper();
    _resetContainer();
    _openChangeController.add(false);
    _changeDetectorRef.markForCheck();
  }

  void toggle() {
    if (_open) {
      close();
      return;
    }
    open();
  }

  void onKeyDown(html.KeyboardEvent event) {
    final key = _normalizedDropdownKey(event);
    final itemElements = _enabledItemElements;
    final isFromAnchor =
        _anchor?.nativeElement.contains(event.target as html.Node?) ?? false;

    var position = -1;
    html.Element? currentItem;

    for (var index = 0; index < itemElements.length; index++) {
      final item = itemElements[index];
      if (identical(item, html.document.activeElement)) {
        position = index;
      }
      if (event.target is html.Element &&
          item.contains(event.target as html.Element)) {
        currentItem = item;
      }
    }

    if (key == ' ' || key == 'Enter') {
      if (currentItem != null &&
          (_autoCloseMode == 'true' || _autoCloseMode == 'inside')) {
        Future<void>.microtask(close);
      }
      return;
    }

    if (key == 'Tab') {
      if (_open && _autoCloseMode != 'false') {
        Future<void>.microtask(close);
      }
      return;
    }

    if (isFromAnchor || currentItem != null) {
      switch (key) {
        case 'ArrowDown':
          open();
          position = itemElements.isEmpty
              ? -1
              : (position < 0
                  ? 0
                  : (position + 1).clamp(0, itemElements.length - 1));
          break;
        case 'ArrowUp':
          open();
          if (itemElements.isEmpty) {
            position = -1;
          } else if (position < 0 && _isDropup(_firstPlacement)) {
            position = itemElements.length - 1;
          } else {
            position = (position - 1).clamp(0, itemElements.length - 1);
          }
          break;
        case 'Home':
          open();
          position = itemElements.isEmpty ? -1 : 0;
          break;
        case 'End':
          open();
          position = itemElements.isEmpty ? -1 : itemElements.length - 1;
          break;
        default:
          return;
      }

      if (position >= 0 && position < itemElements.length) {
        itemElements[position].focus();
      }
      event.preventDefault();
    }
  }

  List<html.Element> get _enabledItemElements => _items
      .where((item) => !item.disabled)
      .map((item) => item.nativeElement)
      .toList(growable: false);

  String get _firstPlacement {
    final currentPlacement = _placement;
    if (currentPlacement is List && currentPlacement.isNotEmpty) {
      return currentPlacement.first.toString();
    }
    final normalized = currentPlacement?.toString().trim() ?? '';
    if (normalized.isEmpty) {
      return 'bottom-start';
    }
    return normalized.split(RegExp(r'\s+')).first;
  }

  String get _autoCloseMode {
    final value = _autoClose;
    if (value is bool) {
      return value ? 'true' : 'false';
    }
    final normalized = value?.toString().trim().toLowerCase() ?? 'true';
    if (normalized == 'inside' ||
        normalized == 'outside' ||
        normalized == 'false') {
      return normalized;
    }
    return 'true';
  }

  bool _isDropup(String placement) {
    final normalized = placement.trim().toLowerCase();
    return normalized.startsWith('top');
  }

  void _setCloseHandlers() {
    _destroyDocumentHandlers();

    if (_autoCloseMode != 'false') {
      _documentClickSubscription = html.document.onClick.listen((event) {
        if (!_open) {
          return;
        }

        final target = event.target;
        if (target is! html.Element) {
          return;
        }

        final clickedAnchor =
            _anchor != null && _anchor!.nativeElement.contains(target);
        final clickedMenu =
            _menu != null && _menu!.nativeElement.contains(target);

        if (clickedAnchor) {
          return;
        }

        if (clickedMenu) {
          if (_autoCloseMode == 'true' || _autoCloseMode == 'inside') {
            close();
          }
          return;
        }

        if (_autoCloseMode == 'true' || _autoCloseMode == 'outside') {
          close();
        }
      });
    }

    _documentKeySubscription = html.document.onKeyDown.listen((event) {
      if (!_open) {
        return;
      }
      if (_normalizedDropdownKey(event) == 'Escape') {
        close();
        _anchor?.nativeElement.focus();
      }
    });
  }

  void _destroyDocumentHandlers() {
    _documentClickSubscription?.cancel();
    _documentKeySubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription = null;
  }

  void _applyContainer() {
    final menu = _menu?.nativeElement;
    if (menu == null) {
      return;
    }

    _resetContainer();
    if (container == 'body') {
      final wrapper = _bodyContainer ??= html.DivElement();
      wrapper.style
        ..position = 'absolute'
        ..zIndex = '1055';
      menu.style.position = 'static';
      wrapper.append(menu);
      html.document.body?.append(wrapper);
    }

    _applyCustomDropdownClass(_dropdownClass, null);
  }

  void _resetContainer() {
    final menu = _menu?.nativeElement;
    if (menu != null && container == 'body' && _bodyContainer != null) {
      _hostElement.append(menu);
    }
    _bodyContainer?.remove();
    _bodyContainer = null;
  }

  void _destroyPopper() {
    _popperController?.dispose();
    _popperController = null;
  }

  void _updatePositioning() {
    final anchor = _anchor?.nativeElement;
    final menu = _menu?.nativeElement;
    if (!_open || anchor == null || menu == null) {
      return;
    }

    if (display == 'static') {
      _applyPlacementClasses();
      return;
    }

    _destroyPopper();
    final floatingElement = _bodyContainer ?? menu;
    _popperController = PopperController(
      referenceElement: anchor,
      floatingElement: floatingElement,
      options: PopperOptions(
        placement: _firstPlacement,
        strategy: PopperStrategy.fixed,
        offset: const PopperOffset(mainAxis: 2),
        padding: const PopperInsets.all(8),
      ),
    );
    _popperController!.startAutoUpdate();
    _popperController!.update();
    _applyPlacementClasses();
  }

  void _applyCustomDropdownClass(String? newClass, String? oldClass) {
    final target = container == 'body' ? _bodyContainer : _hostElement;
    if (target == null) {
      return;
    }

    if (oldClass != null && oldClass.isNotEmpty) {
      target.classes.remove(oldClass);
    }
    if (newClass != null && newClass.isNotEmpty) {
      target.classes.add(newClass);
    }
  }

  void _applyPlacementClasses() {
    final placement = _firstPlacement;
    final isDropup = _isDropup(placement);
    _hostElement.classes
      ..remove('dropdown')
      ..remove('dropup')
      ..add(isDropup ? 'dropup' : 'dropdown');

    if (_bodyContainer != null) {
      _bodyContainer!.classes
        ..remove('dropdown')
        ..remove('dropup')
        ..add(isDropup ? 'dropup' : 'dropdown');
    }

    if (_menu != null) {
      if (display == 'static') {
        _menu!.nativeElement.setAttribute('data-bs-popper', 'static');
      } else {
        _menu!.nativeElement.attributes.remove('data-bs-popper');
      }
    }
  }

  @override
  void ngOnDestroy() {
    close();
    _openChangeController.close();
  }
}

@Directive(selector: '[liDropdownMenu]')
class LiDropdownMenuDirective implements OnInit, OnDestroy {
  LiDropdownMenuDirective(this.dropdown, this.nativeElement);

  final LiDropdownDirective dropdown;
  final html.Element nativeElement;

  @HostBinding('class.dropdown-menu')
  bool hostDropdownMenuClass = true;

  @HostBinding('class.show')
  bool get hostShowClass => dropdown.isOpen();

  @override
  void ngOnInit() {
    dropdown.registerMenu(this);
  }

  @HostListener('keydown', ['\$event'])
  void onKeyDown(html.KeyboardEvent event) {
    dropdown.onKeyDown(event);
  }

  @override
  void ngOnDestroy() {
    dropdown.unregisterMenu(this);
  }
}

@Directive(selector: '[liDropdownAnchor]')
class LiDropdownAnchorDirective implements OnInit, OnDestroy {
  LiDropdownAnchorDirective(this.dropdown, this.nativeElement);

  final LiDropdownDirective dropdown;
  final html.Element nativeElement;

  @HostBinding('class.dropdown-toggle')
  bool hostDropdownToggleClass = true;

  @HostBinding('class.show')
  bool get hostShowClass => dropdown.isOpen();

  @HostBinding('attr.aria-expanded')
  String get hostAriaExpanded => dropdown.isOpen().toString();

  @override
  void ngOnInit() {
    dropdown.registerAnchor(this);
  }

  @HostListener('keydown', ['\$event'])
  void onKeyDown(html.KeyboardEvent event) {
    dropdown.onKeyDown(event);
  }

  @override
  void ngOnDestroy() {
    dropdown.unregisterAnchor(this);
  }
}

@Directive(selector: '[liDropdownToggle]')
class LiDropdownToggleDirective extends LiDropdownAnchorDirective {
  LiDropdownToggleDirective(
    super.dropdown,
    super.nativeElement,
  );

  @HostListener('click', ['\$event'])
  void onClick(html.MouseEvent event) {
    event.preventDefault();
    dropdown.toggle();
  }
}

@Directive(selector: '[liDropdownItem]')
class LiDropdownItemDirective implements OnInit, OnDestroy {
  LiDropdownItemDirective(
    this.nativeElement,
    this.dropdown,
  );

  final html.Element nativeElement;
  final LiDropdownDirective dropdown;

  bool _disabled = false;
  String _tabindex = '0';

  @Input()
  set disabled(bool value) {
    _disabled = value;
  }

  bool get disabled => _disabled;

  @Input()
  set tabindex(Object? value) {
    final normalized = value?.toString().trim();
    _tabindex = normalized == null || normalized.isEmpty ? '0' : normalized;
  }

  @HostBinding('class.dropdown-item')
  bool hostDropdownItemClass = true;

  @HostBinding('class.disabled')
  bool get hostDisabledClass => disabled;

  @HostBinding('attr.tabindex')
  String get hostTabIndex => disabled ? '-1' : _tabindex;

  @HostBinding('attr.disabled')
  String? get hostDisabledAttribute =>
      nativeElement is html.ButtonElement && disabled ? '' : null;

  @override
  void ngOnInit() {
    dropdown.registerItem(this);
  }

  @override
  void ngOnDestroy() {
    dropdown.unregisterItem(this);
  }
}

@Directive(selector: 'button[liDropdownItem]')
class LiDropdownButtonItemDirective {
  LiDropdownButtonItemDirective(this.item);

  final LiDropdownItemDirective item;

  @HostBinding('attr.disabled')
  String? get hostDisabledAttribute => item.disabled ? '' : null;
}
