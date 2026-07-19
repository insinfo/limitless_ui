import 'dart:js_interop';
import 'dart:async';
import 'package:limitless_ui/web_compat.dart' as html;
import 'dart:math' as math;

import 'package:ngx_dart/angular.dart';
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
  LiDropdownSubmenuDirective,
  LiDropdownSubmenuToggleDirective,
  LiDropdownSubmenuMenuDirective,
];

String _normalizedDropdownKey(html.KeyboardEvent event) {
  final key = event.key;
  if (key.isNotEmpty) {
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

bool _normalizedDropdownBoolInput(Object? value, bool fallback) {
  if (value == null) {
    return fallback;
  }

  if (value is bool) {
    return value;
  }

  final normalized = value.toString().trim().toLowerCase();
  if (normalized.isEmpty) {
    return true;
  }
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return fallback;
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
  bool _positioningRefreshPending = false;
  bool _viewportAdaptationPending = false;
  bool _adaptToViewport = true;
  bool _menuViewportBaselineCaptured = false;
  bool _viewportWidthClamped = false;
  bool _viewportHeightClamped = false;
  String? _dropdownClass;
  String? _container;
  String? _display;
  String? _menuMaxWidth;
  String? _menuMaxHeight;
  String? _lastPopperLayoutSignature;
  String? _lastAppliedFloatingStyleSignature;
  String? _lastViewportAdaptationSignature;
  String _menuInlineWidth = '';
  String _menuInlineHeight = '';
  String _menuInlineMaxWidth = '';
  String _menuInlineMaxHeight = '';
  String _menuInlineOverflowX = '';
  String _menuInlineOverflowY = '';
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
  set adaptToViewport(Object? value) {
    _adaptToViewport =
        _normalizedDropdownBoolInput(value, _config.adaptToViewport);
    if (_open) {
      _scheduleViewportAdaptation();
    }
  }

  bool get adaptToViewport => _adaptToViewport;

  @Input()
  set dropdownClass(String? value) {
    _applyCustomDropdownClass(value?.trim(), _dropdownClass);
    _dropdownClass = value?.trim();
  }

  String? get dropdownClass => _dropdownClass;

  @Input()
  set menuMaxWidth(String? value) {
    final normalized = value?.trim();
    _menuMaxWidth =
        normalized == null || normalized.isEmpty ? null : normalized;
    if (_open) {
      _scheduleViewportAdaptation();
    }
  }

  String? get menuMaxWidth => _menuMaxWidth;

  @Input()
  set menuMaxHeight(String? value) {
    final normalized = value?.trim();
    _menuMaxHeight =
        normalized == null || normalized.isEmpty ? null : normalized;
    if (_open) {
      _scheduleViewportAdaptation();
    }
  }

  String? get menuMaxHeight => _menuMaxHeight;

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
    adaptToViewport = _adaptToViewport;
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
    _schedulePostOpenPositioningRefresh();
  }

  void close() {
    if (!_open) {
      return;
    }

    _open = false;
    _destroyDocumentHandlers();
    _destroyPopper();
    _restoreViewportAdaptationStyles();
    _resetContainer();
    _positioningRefreshPending = false;
    _viewportAdaptationPending = false;
    _lastPopperLayoutSignature = null;
    _lastAppliedFloatingStyleSignature = null;
    _lastViewportAdaptationSignature = null;
    _viewportWidthClamped = false;
    _viewportHeightClamped = false;
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
      if (item == html.document.activeElement) {
        position = index;
      }
      if ((event.target?.isA<html.Element>() ?? false) &&
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
      .where((item) => !item.disabled && item.isNavigable)
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

  List<String> get _fallbackPlacements {
    final currentPlacement = _placement;
    if (currentPlacement is List && currentPlacement.length > 1) {
      return currentPlacement
          .skip(1)
          .map((placement) => placement.toString().trim())
          .where((placement) => placement.isNotEmpty)
          .toList(growable: false);
    }

    final normalized = currentPlacement?.toString().trim() ?? '';
    if (normalized.contains(RegExp(r'\s+'))) {
      final placements = normalized
          .split(RegExp(r'\s+'))
          .map((placement) => placement.trim())
          .where((placement) => placement.isNotEmpty)
          .toList(growable: false);
      return placements.length <= 1
          ? _defaultFallbackPlacementsFor(_firstPlacement)
          : placements.skip(1).toList(growable: false);
    }

    return _defaultFallbackPlacementsFor(_firstPlacement);
  }

  List<String> _defaultFallbackPlacementsFor(String placement) {
    switch (placement.trim().toLowerCase()) {
      case 'top-end':
        return const <String>['bottom-end', 'top-start', 'bottom-start'];
      case 'top-start':
        return const <String>['bottom-start', 'top-end', 'bottom-end'];
      case 'bottom-end':
        return const <String>['top-end', 'bottom-start', 'top-start'];
      case 'bottom-start':
        return const <String>['top-start', 'bottom-end', 'top-end'];
      case 'left-start':
        return const <String>['right-start', 'bottom-start', 'top-start'];
      case 'left-end':
        return const <String>['right-end', 'bottom-end', 'top-end'];
      case 'right-start':
        return const <String>['left-start', 'bottom-end', 'top-end'];
      case 'right-end':
        return const <String>['left-end', 'bottom-start', 'top-start'];
      default:
        return const <String>['bottom-end', 'top-start', 'top-end'];
    }
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
        if (!(target?.isA<html.Element>() ?? false)) {
          return;
        }

        final clickedAnchor = _anchor != null &&
            _anchor!.nativeElement.contains(target as html.Node?);
        final clickedMenu = _menu != null &&
            _menu!.nativeElement.contains(target as html.Node?);
        final clickedSubmenuToggle =
            (target as html.Element).closest('.li-dropdown-submenu__toggle') !=
                null;

        if (clickedAnchor) {
          return;
        }

        if (clickedMenu) {
          if (clickedSubmenuToggle) {
            return;
          }

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
      final wrapper = _bodyContainer ??= html.createDivElement();
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

  void _refreshExistingPositioning() {
    if (!_open) {
      return;
    }

    if (display == 'static') {
      _applyPlacementClasses();
      return;
    }

    if (_popperController == null) {
      _updatePositioning();
      return;
    }

    _popperController!.update();
    _applyPlacementClasses();
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
        fallbackPlacements: _fallbackPlacements,
        strategy: PopperStrategy.fixed,
        offset: const PopperOffset(mainAxis: 2),
        padding: const PopperInsets.all(8),
        observeMutations: false,
        layoutWriter: _writeStablePopperLayout,
        onLayout: (layout) {
          if (_adaptToViewport && _markPopperLayoutChanged(layout)) {
            _scheduleViewportAdaptation();
          }
        },
      ),
    );
    _popperController!.startAutoUpdate();
    _popperController!.update();
    _applyPlacementClasses();
  }

  bool _markPopperLayoutChanged(PopperLayout layout) {
    final signature = <Object?>[
      layout.placement,
      layout.strategy.name,
      layout.x.toStringAsFixed(2),
      layout.y.toStringAsFixed(2),
      layout.availableWidth.toStringAsFixed(2),
      layout.availableHeight.toStringAsFixed(2),
      layout.referenceRect.left.toStringAsFixed(2),
      layout.referenceRect.top.toStringAsFixed(2),
      layout.referenceRect.width.toStringAsFixed(2),
      layout.referenceRect.height.toStringAsFixed(2),
      layout.floatingRect.width.toStringAsFixed(2),
      layout.floatingRect.height.toStringAsFixed(2),
    ].join('|');

    if (_lastPopperLayoutSignature == signature) {
      return false;
    }

    _lastPopperLayoutSignature = signature;
    return true;
  }

  void _writeStablePopperLayout(
    PopperLayout layout,
    html.Element floatingElement,
    html.Element? arrowElement,
  ) {
    final styleSignature = <Object?>[
      layout.strategy == PopperStrategy.fixed ? 'fixed' : 'absolute',
      layout.x.round(),
      layout.y.round(),
      layout.placement,
      'visible',
    ].join('|');

    if (_lastAppliedFloatingStyleSignature == styleSignature) {
      return;
    }

    _lastAppliedFloatingStyleSignature = styleSignature;

    final style = floatingElement.style;

    _writeStyleValue(
      style.position,
      layout.strategy == PopperStrategy.fixed ? 'fixed' : 'absolute',
      (value) => style.position = value,
    );
    _writeStyleValue(style.left, '0px', (value) => style.left = value);
    _writeStyleValue(style.top, '0px', (value) => style.top = value);
    _writeStyleValue(style.right, 'auto', (value) => style.right = value);
    _writeStyleValue(style.bottom, 'auto', (value) => style.bottom = value);
    _writeStyleValue(style.margin, '0px', (value) => style.margin = value);
    _writeStyleValue(
      style.transform,
      'translate(${layout.x.toStringAsFixed(2)}px, ${layout.y.toStringAsFixed(2)}px)',
      (value) => style.transform = value,
    );
    _writeStyleValue(style.width, '', (value) => style.width = value);
    _writeStyleValue(style.minWidth, '', (value) => style.minWidth = value);
    _writeAttributeValue(
      floatingElement,
      'data-popper-placement',
      layout.placement,
    );
    _toggleAttribute(
      floatingElement,
      'data-popper-reference-hidden',
      layout.referenceHidden,
    );
    _toggleAttribute(
      floatingElement,
      'data-popper-escaped',
      layout.escaped,
    );
    _writeStyleValue(style.visibility, 'visible', (value) {
      style.visibility = value;
    });
    if (style.pointerEvents == 'none') {
      style.pointerEvents = '';
    }
  }

  void _writeStyleValue(
    String currentValue,
    String nextValue,
    void Function(String value) writer,
  ) {
    if (currentValue == nextValue) {
      return;
    }
    writer(nextValue);
  }

  void _writeAttributeValue(
    html.Element element,
    String attributeName,
    String nextValue,
  ) {
    if (element.getAttribute(attributeName) == nextValue) {
      return;
    }
    element.setAttribute(attributeName, nextValue);
  }

  void _toggleAttribute(
    html.Element element,
    String attributeName,
    bool enabled,
  ) {
    if (enabled) {
      if (element.getAttribute(attributeName) != 'true') {
        element.setAttribute(attributeName, 'true');
      }
      return;
    }

    if (element.hasAttribute(attributeName)) {
      element.removeAttribute(attributeName);
    }
  }

  void _schedulePostOpenPositioningRefresh() {
    if (_positioningRefreshPending) {
      return;
    }

    _positioningRefreshPending = true;
    html.window.liRequestAnimationFrame((_) {
      _positioningRefreshPending = false;
      if (!_open) {
        return;
      }
      _applyPlacementClasses();
      _updatePositioning();
      _scheduleViewportAdaptation();
    });
  }

  void _scheduleViewportAdaptation() {
    if (!_adaptToViewport ||
        !_open ||
        display == 'static' ||
        _viewportAdaptationPending) {
      return;
    }

    final menu = _menu?.nativeElement;
    if (menu == null) {
      return;
    }

    _viewportAdaptationPending = true;
    html.window.liRequestAnimationFrame((_) {
      _viewportAdaptationPending = false;
      if (!_open) {
        return;
      }

      final menuRect = menu.getBoundingClientRect();
      final menuIsVisible = menu.classes.contains('show') &&
          (menuRect.width > 0 || menuRect.height > 0);
      if (!menuIsVisible) {
        _scheduleViewportAdaptation();
        return;
      }

      final changedStyles = _applyViewportAdaptationStyles(menu);
      if (changedStyles) {
        _refreshExistingPositioning();
      }
    });
  }

  bool _applyViewportAdaptationStyles(html.Element menu) {
    _captureViewportAdaptationBaseline(menu);

    final viewportWidth = html.window.innerWidth.toDouble();
    final viewportHeight = html.window.innerHeight.toDouble();
    if (viewportWidth <= 0 || viewportHeight <= 0) {
      return false;
    }

    const viewportInset = 8.0;
    final maxViewportWidth =
        math.max(160.0, viewportWidth - (viewportInset * 2));
    final maxViewportHeight =
        math.max(120.0, viewportHeight - (viewportInset * 2));
    final menuRect = menu.getBoundingClientRect();

    final shouldClampWidth =
        _viewportWidthClamped || menuRect.width > maxViewportWidth + 0.5;
    final shouldClampHeight =
        _viewportHeightClamped || menuRect.height > maxViewportHeight + 0.5;

    final configuredMaxWidth = _menuMaxWidth;
    final configuredMaxHeight = _menuMaxHeight;
    final nextMaxWidth = shouldClampWidth
        ? configuredMaxWidth != null
            ? 'min($configuredMaxWidth, ${maxViewportWidth.floor()}px)'
            : '${maxViewportWidth.floor()}px'
        : (configuredMaxWidth ?? _menuInlineMaxWidth);
    final nextOverflowX = shouldClampWidth ? 'auto' : _menuInlineOverflowX;
    // Não sobrescreve `width` inline ao adaptar: o `max-width` aplicado acima já
    // limita o tamanho visual do menu, e preservar o `width` definido pelo
    // autor (por exemplo `width: max-content`) é o que evita o loop de
    // recalculo de estilo quando o app controla largura/overflow via CSS.
    final nextWidth = _menuInlineWidth;
    final nextMaxHeight = shouldClampHeight
        ? configuredMaxHeight != null
            ? 'min($configuredMaxHeight, ${maxViewportHeight.floor()}px)'
            : '${maxViewportHeight.floor()}px'
        : (configuredMaxHeight ?? _menuInlineMaxHeight);
    final nextOverflowY = shouldClampHeight ? 'auto' : _menuInlineOverflowY;
    // Mesmo motivo de `nextWidth`: o `max-height` já contém o overflow vertical
    // sem precisar fixar a altura inline, então preservamos o valor original
    // do autor (frequentemente vazio).
    final nextHeight = _menuInlineHeight;

    final nextSignature = <Object?>[
      nextWidth,
      nextMaxWidth,
      nextOverflowX,
      nextHeight,
      nextMaxHeight,
      nextOverflowY,
    ].join('|');

    if (_lastViewportAdaptationSignature == nextSignature) {
      return false;
    }

    var changed = false;
    changed = _applyInlineStyleValue(menu.style.width, nextWidth, (value) {
          menu.style.width = value;
        }) ||
        changed;
    changed =
        _applyInlineStyleValue(menu.style.maxWidth, nextMaxWidth, (value) {
              menu.style.maxWidth = value;
            }) ||
            changed;
    changed =
        _applyInlineStyleValue(menu.style.overflowX, nextOverflowX, (value) {
              menu.style.overflowX = value;
            }) ||
            changed;
    changed = _applyInlineStyleValue(menu.style.height, nextHeight, (value) {
          menu.style.height = value;
        }) ||
        changed;
    changed =
        _applyInlineStyleValue(menu.style.maxHeight, nextMaxHeight, (value) {
              menu.style.maxHeight = value;
            }) ||
            changed;
    changed =
        _applyInlineStyleValue(menu.style.overflowY, nextOverflowY, (value) {
              menu.style.overflowY = value;
            }) ||
            changed;

    if (changed) {
      _lastViewportAdaptationSignature = nextSignature;
    }

    _viewportWidthClamped = shouldClampWidth;
    _viewportHeightClamped = shouldClampHeight;

    return changed;
  }

  bool _applyInlineStyleValue(
    String currentValue,
    String nextValue,
    void Function(String value) writer,
  ) {
    if (currentValue == nextValue) {
      return false;
    }

    writer(nextValue);
    return true;
  }

  void _captureViewportAdaptationBaseline(html.Element menu) {
    if (_menuViewportBaselineCaptured) {
      return;
    }

    _menuViewportBaselineCaptured = true;
    _menuInlineWidth = menu.style.width;
    _menuInlineHeight = menu.style.height;
    _menuInlineMaxWidth = menu.style.maxWidth;
    _menuInlineMaxHeight = menu.style.maxHeight;
    _menuInlineOverflowX = menu.style.overflowX;
    _menuInlineOverflowY = menu.style.overflowY;
  }

  void _restoreViewportAdaptationStyles() {
    if (!_menuViewportBaselineCaptured) {
      return;
    }

    final menu = _menu?.nativeElement;
    if (menu != null) {
      menu.style.width = _menuInlineWidth;
      menu.style.height = _menuInlineHeight;
      menu.style.maxWidth = _menuInlineMaxWidth;
      menu.style.maxHeight = _menuInlineMaxHeight;
      menu.style.overflowX = _menuInlineOverflowX;
      menu.style.overflowY = _menuInlineOverflowY;
    }

    _menuViewportBaselineCaptured = false;
    _menuInlineWidth = '';
    _menuInlineHeight = '';
    _menuInlineMaxWidth = '';
    _menuInlineMaxHeight = '';
    _menuInlineOverflowX = '';
    _menuInlineOverflowY = '';
    _lastViewportAdaptationSignature = null;
    _viewportWidthClamped = false;
    _viewportHeightClamped = false;
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
        _menu!.nativeElement.removeAttribute('data-bs-popper');
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

@Directive(
  selector: '[liDropdownSubmenu]',
  exportAs: 'liDropdownSubmenu',
)
class LiDropdownSubmenuDirective implements OnInit, OnDestroy {
  LiDropdownSubmenuDirective(
    this.hostElement,
    this._changeDetectorRef, [
    @Optional() this.dropdown,
  ]);

  static final List<LiDropdownSubmenuDirective> _openSubmenus =
      <LiDropdownSubmenuDirective>[];

  final html.Element hostElement;
  final ChangeDetectorRef _changeDetectorRef;
  final LiDropdownDirective? dropdown;
  final StreamController<bool> _openChangeController =
      StreamController<bool>.broadcast();

  LiDropdownSubmenuToggleDirective? _toggle;
  LiDropdownSubmenuMenuDirective? _menu;
  StreamSubscription<bool>? _dropdownOpenChangeSubscription;
  StreamSubscription<html.MouseEvent>? _documentClickSubscription;

  bool _open = false;
  bool _openedByHover = false;

  @Input()
  String placement = 'end';

  @Input()
  bool openOnHover = true;

  @Input()
  bool closeOnItemClick = true;

  @Input('open')
  set opened(bool value) {
    if (value) {
      openSubmenu();
      return;
    }
    closeSubmenu();
  }

  @Output()
  Stream<bool> get openChange => _openChangeController.stream;

  bool get isOpen => _open;

  bool get opensTowardStart => placement.trim().toLowerCase() == 'start';

  String get openKeyboardKey => opensTowardStart ? 'ArrowLeft' : 'ArrowRight';

  String get closeKeyboardKey => opensTowardStart ? 'ArrowRight' : 'ArrowLeft';

  @HostBinding('class.dropdown-submenu')
  bool hostDropdownSubmenuClass = true;

  @HostBinding('class.li-dropdown-submenu')
  bool hostLiDropdownSubmenuClass = true;

  @HostBinding('class.dropdown-submenu-start')
  bool get hostDropdownSubmenuStartClass =>
      placement.trim().toLowerCase() == 'start';

  @HostBinding('class.show')
  bool get hostShowClass => _open;

  @override
  void ngOnInit() {
    _dropdownOpenChangeSubscription = dropdown?.openChange.listen((open) {
      if (!open) {
        closeSubmenu();
      }
    });
  }

  void registerToggle(LiDropdownSubmenuToggleDirective toggle) {
    _toggle = toggle;
  }

  void unregisterToggle(LiDropdownSubmenuToggleDirective toggle) {
    if (identical(_toggle, toggle)) {
      _toggle = null;
    }
  }

  void registerMenu(LiDropdownSubmenuMenuDirective menu) {
    _menu = menu;
  }

  void unregisterMenu(LiDropdownSubmenuMenuDirective menu) {
    if (identical(_menu, menu)) {
      _menu = null;
    }
  }

  void toggleSubmenu({bool focusFirstItem = false}) {
    if (_open) {
      if (_openedByHover) {
        _openedByHover = false;
        return;
      }

      closeSubmenu();
      return;
    }

    openSubmenu(focusFirstItem: focusFirstItem);
  }

  void openSubmenu({bool focusFirstItem = false, bool openedByHover = false}) {
    if (_open) {
      if (openedByHover) {
        _openedByHover = true;
      }
      if (focusFirstItem) {
        focusFirstItemInMenu();
      }
      return;
    }

    _closeSiblingSubmenus();
    _open = true;
    _openedByHover = openedByHover;
    _registerAsOpenSubmenu();
    _bindDocumentClick();
    _openChangeController.add(true);
    _changeDetectorRef.markForCheck();

    if (focusFirstItem) {
      focusFirstItemInMenu();
    }
  }

  void closeSubmenu({bool focusToggle = false}) {
    if (!_open) {
      return;
    }

    _open = false;
    _openedByHover = false;
    _unregisterAsOpenSubmenu();
    _closeDescendantSubmenus();
    _unbindDocumentClick();
    _openChangeController.add(false);
    _changeDetectorRef.markForCheck();

    if (focusToggle) {
      _toggle?.nativeElement.focus();
    }
  }

  void focusFirstItemInMenu() {
    _enabledMenuItems.firstOrNull?.focus();
  }

  void focusLastItemInMenu() {
    _enabledMenuItems.lastOrNull?.focus();
  }

  List<html.Element> get _enabledMenuItems {
    final menuElement = _menu?.nativeElement;
    if (menuElement == null) {
      return const <html.Element>[];
    }

    return menuElement.queryAll('.dropdown-item:not(.disabled)');
  }

  void _bindDocumentClick() {
    _documentClickSubscription ??= html.document.onClick.listen((event) {
      if (!_open) {
        return;
      }

      final target = event.target;
      if (!(target?.isA<html.Element>() ?? false)) {
        closeSubmenu();
        return;
      }

      if (!hostElement.contains(target as html.Node?)) {
        closeSubmenu();
        return;
      }

      final clickedToggle =
          (target as html.Element).closest('.li-dropdown-submenu__toggle') !=
              null;
      final clickedMenuItem = target.closest('.dropdown-item') != null;
      if (closeOnItemClick && !clickedToggle && clickedMenuItem) {
        closeSubmenu();
      }
    });
  }

  void _unbindDocumentClick() {
    _documentClickSubscription?.cancel();
    _documentClickSubscription = null;
  }

  void _closeSiblingSubmenus() {
    for (final submenu
        in List<LiDropdownSubmenuDirective>.from(_openSubmenus)) {
      if (identical(submenu, this) || !identical(submenu.dropdown, dropdown)) {
        continue;
      }

      final sharesBranch = hostElement.contains(submenu.hostElement) ||
          submenu.hostElement.contains(hostElement);
      if (!sharesBranch) {
        submenu.closeSubmenu();
      }
    }
  }

  void _closeDescendantSubmenus() {
    for (final submenu
        in List<LiDropdownSubmenuDirective>.from(_openSubmenus)) {
      if (!identical(submenu, this) &&
          hostElement.contains(submenu.hostElement)) {
        submenu.closeSubmenu();
      }
    }
  }

  void _registerAsOpenSubmenu() {
    _openSubmenus.remove(this);
    _openSubmenus.add(this);
  }

  void _unregisterAsOpenSubmenu() {
    _openSubmenus.remove(this);
  }

  @HostListener('mouseenter')
  void onMouseEnter() {
    if (openOnHover && _canUseHoverInteraction) {
      openSubmenu(openedByHover: true);
    }
  }

  @HostListener('mouseleave')
  void onMouseLeave() {
    if (openOnHover && _canUseHoverInteraction) {
      closeSubmenu();
    }
  }

  bool get _canUseHoverInteraction {
    try {
      final supportsFineHover =
          html.window.matchMedia('(hover: hover) and (pointer: fine)').matches;
      if (supportsFineHover) {
        return true;
      }

      final maxTouchPoints = html.window.navigator.maxTouchPoints;
      return maxTouchPoints <= 0;
    } catch (_) {
      return true;
    }
  }

  @override
  void ngOnDestroy() {
    closeSubmenu();
    _dropdownOpenChangeSubscription?.cancel();
    _openChangeController.close();
  }
}

@Directive(selector: '[liDropdownSubmenuToggle]')
class LiDropdownSubmenuToggleDirective implements OnInit, OnDestroy {
  LiDropdownSubmenuToggleDirective(this.submenu, this.nativeElement);

  final LiDropdownSubmenuDirective submenu;
  final html.Element nativeElement;

  @HostBinding('class.li-dropdown-submenu__toggle')
  bool hostSubmenuToggleClass = true;

  @HostBinding('class.dropdown-toggle')
  bool hostDropdownToggleClass = true;

  @HostBinding('class.show')
  bool get hostShowClass => submenu.isOpen;

  @HostBinding('attr.aria-expanded')
  String get hostAriaExpanded => submenu.isOpen.toString();

  @override
  void ngOnInit() {
    submenu.registerToggle(this);
  }

  @HostListener('click', ['\$event'])
  void onClick(html.MouseEvent event) {
    event.preventDefault();
    event.stopPropagation();
    submenu.toggleSubmenu();
  }

  @HostListener('keydown', ['\$event'])
  void onKeyDown(html.KeyboardEvent event) {
    switch (_normalizedDropdownKey(event)) {
      case ' ':
      case 'Enter':
        submenu.openSubmenu(focusFirstItem: true);
        event.preventDefault();
        event.stopPropagation();
        return;
      case 'ArrowRight':
      case 'ArrowLeft':
        if (_normalizedDropdownKey(event) == submenu.openKeyboardKey) {
          submenu.openSubmenu(focusFirstItem: true);
        } else {
          submenu.closeSubmenu(focusToggle: true);
        }
        event.preventDefault();
        event.stopPropagation();
        return;
      case 'Escape':
        submenu.closeSubmenu(focusToggle: true);
        event.preventDefault();
        event.stopPropagation();
        return;
      default:
        return;
    }
  }

  @override
  void ngOnDestroy() {
    submenu.unregisterToggle(this);
  }
}

@Directive(selector: '[liDropdownSubmenuMenu]')
class LiDropdownSubmenuMenuDirective implements OnInit, OnDestroy {
  LiDropdownSubmenuMenuDirective(
    this.submenu,
    this.dropdown,
    this.nativeElement,
  );

  final LiDropdownSubmenuDirective submenu;
  final LiDropdownDirective dropdown;
  final html.Element nativeElement;

  @HostBinding('class.dropdown-menu')
  bool hostDropdownMenuClass = true;

  @HostBinding('class.li-dropdown-submenu__menu')
  bool hostSubmenuMenuClass = true;

  @HostBinding('class.show')
  bool get hostShowClass => submenu.isOpen;

  @override
  void ngOnInit() {
    submenu.registerMenu(this);
  }

  @HostListener('keydown', ['\$event'])
  void onKeyDown(html.KeyboardEvent event) {
    switch (_normalizedDropdownKey(event)) {
      case 'Escape':
        submenu.closeSubmenu(focusToggle: true);
        event.preventDefault();
        event.stopPropagation();
        return;
      case 'ArrowRight':
      case 'ArrowLeft':
        if (_normalizedDropdownKey(event) == submenu.closeKeyboardKey) {
          submenu.closeSubmenu(focusToggle: true);
          event.preventDefault();
          event.stopPropagation();
          return;
        }
        dropdown.onKeyDown(event);
        return;
      default:
        dropdown.onKeyDown(event);
    }
  }

  @override
  void ngOnDestroy() {
    submenu.unregisterMenu(this);
  }
}

@Directive(selector: '[liDropdownAnchor]')
class LiDropdownAnchorDirective implements OnInit, OnDestroy {
  LiDropdownAnchorDirective(this.dropdown, this.nativeElement);

  final LiDropdownDirective dropdown;
  final html.Element nativeElement;

  bool _showCaret = true;

  @Input('liDropdownShowCaret')
  set showCaretInput(Object? value) {
    _showCaret = _coerceDropdownBoolean(value, defaultValue: true);
  }

  bool get showCaret => _showCaret;

  @HostBinding('class.dropdown-toggle')
  bool get hostDropdownToggleClass => _showCaret;

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
    this.dropdown, [
    @Optional() this.submenuMenu,
  ]);

  final html.Element nativeElement;
  final LiDropdownDirective dropdown;
  final LiDropdownSubmenuMenuDirective? submenuMenu;

  bool _disabled = false;
  String _tabindex = '0';

  @Input()
  set disabled(bool value) {
    _disabled = value;
  }

  bool get disabled => _disabled;

  bool get isNavigable => submenuMenu == null || submenuMenu!.submenu.isOpen;

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
      nativeElement.isA<html.ButtonElement>() && disabled ? '' : null;

  @override
  void ngOnInit() {
    dropdown.registerItem(this);
  }

  @override
  void ngOnDestroy() {
    dropdown.unregisterItem(this);
  }
}

bool _coerceDropdownBoolean(Object? value, {required bool defaultValue}) {
  if (value == null) {
    return defaultValue;
  }

  if (value is bool) {
    return value;
  }

  final normalized = value.toString().trim().toLowerCase();
  if (normalized.isEmpty) {
    return defaultValue;
  }

  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }

  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }

  return defaultValue;
}

@Directive(selector: 'button[liDropdownItem]')
class LiDropdownButtonItemDirective {
  LiDropdownButtonItemDirective(this.item);

  final LiDropdownItemDirective item;

  @HostBinding('attr.disabled')
  String? get hostDisabledAttribute => item.disabled ? '' : null;
}
