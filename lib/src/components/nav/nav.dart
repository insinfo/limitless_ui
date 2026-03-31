import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

import 'nav_config.dart';

/// Public directives used by nav APIs.
const liNavDirectives = <Object>[
  LiNavDirective,
  LiNavItemDirective,
  LiNavLinkDirective,
  LiNavContentDirective,
  LiNavOutletDirective,
];

bool _isValidNavId(Object? id) => id != null && id.toString().isNotEmpty;

String _normalizedKey(html.KeyboardEvent event) {
  final key = event.key;
  if (key != null && key.isNotEmpty) {
    return key;
  }

  switch (event.keyCode) {
    case 35:
      return 'End';
    case 36:
      return 'Home';
    case 37:
      return 'ArrowLeft';
    case 38:
      return 'ArrowUp';
    case 39:
      return 'ArrowRight';
    case 40:
      return 'ArrowDown';
    default:
      return '';
  }
}

class LiNavChangeEvent {
  LiNavChangeEvent({
    required this.activeId,
    required this.nextId,
  });

  final Object? activeId;
  final Object? nextId;

  bool _defaultPrevented = false;

  bool get defaultPrevented => _defaultPrevented;

  void preventDefault() {
    _defaultPrevented = true;
  }
}

@Directive(selector: 'template[liNavContent]')
class LiNavContentDirective {
  LiNavContentDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(
  selector: '[liNav]',
  exportAs: 'liNav',
)
class LiNavDirective implements AfterContentInit, OnDestroy {
  LiNavDirective(
    this._changeDetectorRef, [
    @Optional() LiNavConfig? config,
  ])  : _config = config ?? LiNavConfig(),
        animation = (config ?? LiNavConfig()).animation,
        destroyOnHide = (config ?? LiNavConfig()).destroyOnHide,
        keyboard = (config ?? LiNavConfig()).keyboard,
        orientation = (config ?? LiNavConfig()).orientation,
        roles = (config ?? LiNavConfig()).roles;

  final ChangeDetectorRef _changeDetectorRef;
  final LiNavConfig _config;

  final List<LiNavItemDirective> _items = <LiNavItemDirective>[];
  final List<LiNavLinkDirective> _links = <LiNavLinkDirective>[];
  final StreamController<Object?> _activeIdChangeController =
      StreamController<Object?>.broadcast();
  final StreamController<LiNavChangeEvent> _navChangeController =
      StreamController<LiNavChangeEvent>.broadcast(sync: true);
  final StreamController<Object?> _shownController =
      StreamController<Object?>.broadcast();
  final StreamController<Object?> _hiddenController =
      StreamController<Object?>.broadcast();
  final StreamController<LiNavItemDirective?> _itemChangeController =
      StreamController<LiNavItemDirective?>.broadcast();

  Object? _activeId;
  bool _contentInitialized = false;
  bool _navigatingWithKeyboard = false;

  @Input()
  set activeId(Object? value) {
    if (_activeId == value) {
      return;
    }
    _activeId = value;
    if (_contentInitialized) {
      _emitItemChange();
      _changeDetectorRef.markForCheck();
    }
  }

  Object? get activeId => _activeId;

  @Input()
  bool animation;

  @Input()
  bool destroyOnHide;

  @Input()
  dynamic keyboard;

  @Input()
  String orientation;

  @Input()
  bool roles;

  @Output()
  Stream<Object?> get activeIdChange => _activeIdChangeController.stream;

  @Output()
  Stream<LiNavChangeEvent> get navChange => _navChangeController.stream;

  @Output()
  Stream<Object?> get shown => _shownController.stream;

  @Output()
  Stream<Object?> get hidden => _hiddenController.stream;

  Stream<LiNavItemDirective?> get itemChange => _itemChangeController.stream;

  List<LiNavItemDirective> get items =>
      List<LiNavItemDirective>.unmodifiable(_items);

  List<LiNavLinkDirective> get links =>
      List<LiNavLinkDirective>.unmodifiable(_links);

  @HostBinding('class.nav')
  bool hostNavClass = true;

  @HostBinding('class.flex-column')
  bool get hostVerticalClass => orientation == 'vertical';

  @HostBinding('attr.role')
  String? get hostRole => roles ? 'tablist' : null;

  @HostBinding('attr.aria-orientation')
  String? get hostAriaOrientation =>
      roles && orientation == 'vertical' ? 'vertical' : null;

  @override
  void ngAfterContentInit() {
    keyboard ??= _config.keyboard;
    if (orientation.trim().isEmpty) {
      orientation = _config.orientation;
    }
    _contentInitialized = true;

    if (!_isValidNavId(_activeId)) {
      final firstItem = _items.isEmpty ? null : _items.first;
      if (firstItem != null) {
        _activeId = firstItem.id;
        _activeIdChangeController.add(_activeId);
      }
    }

    _emitItemChange();
    _changeDetectorRef.markForCheck();
  }

  void registerItem(LiNavItemDirective item) {
    if (_items.contains(item)) {
      return;
    }
    _items.add(item);
    if (_contentInitialized && !_isValidNavId(_activeId) && _items.isNotEmpty) {
      _activeId = _items.first.id;
      _activeIdChangeController.add(_activeId);
      _emitItemChange();
    } else if (_contentInitialized) {
      _emitItemChange();
    }
    _changeDetectorRef.markForCheck();
  }

  void unregisterItem(LiNavItemDirective item) {
    _items.remove(item);
    if (_contentInitialized) {
      _emitItemChange();
    }
    _changeDetectorRef.markForCheck();
  }

  void registerLink(LiNavLinkDirective link) {
    if (_links.contains(link)) {
      return;
    }
    _links.add(link);
  }

  void unregisterLink(LiNavLinkDirective link) {
    _links.remove(link);
  }

  void click(LiNavItemDirective item) {
    if (!item.disabled) {
      _updateActiveId(item.id, emitNavChange: true, emitActiveIdChange: true);
    }
  }

  void select(Object? id) {
    _updateActiveId(id, emitNavChange: false, emitActiveIdChange: true);
  }

  void onFocusout(html.FocusEvent event) {
    final relatedTarget = event.relatedTarget;
    if (relatedTarget is html.Element &&
        _links.any((link) => link.nativeElement.contains(relatedTarget))) {
      return;
    }
    _navigatingWithKeyboard = false;
    _changeDetectorRef.markForCheck();
  }

  @HostListener('focusout', ['\$event'])
  void handleFocusout(html.FocusEvent event) => onFocusout(event);

  @HostListener('keydown', ['\$event'])
  void handleKeydown(html.KeyboardEvent event) => onKeyDown(event);

  void onKeyDown(html.KeyboardEvent event) {
    if (!roles || keyboard == false) {
      return;
    }

    final enabledLinks =
        _links.where((link) => !link.item.disabled).toList(growable: false);
    if (enabledLinks.isEmpty) {
      return;
    }

    var position = enabledLinks.indexWhere(
      (link) => identical(link.nativeElement, html.document.activeElement),
    );
    if (position < 0) {
      position = enabledLinks.indexWhere((link) => link.item.active);
      if (position < 0) {
        position = 0;
      }
    }

    switch (_normalizedKey(event)) {
      case 'ArrowLeft':
      case 'ArrowUp':
        position = (position - 1 + enabledLinks.length) % enabledLinks.length;
        break;
      case 'ArrowRight':
      case 'ArrowDown':
        position = (position + 1) % enabledLinks.length;
        break;
      case 'Home':
        position = 0;
        break;
      case 'End':
        position = enabledLinks.length - 1;
        break;
      default:
        return;
    }

    final nextLink = enabledLinks[position];
    if (keyboard == 'changeWithArrows') {
      select(nextLink.item.id);
    }
    _navigatingWithKeyboard = true;
    nextLink.focus();
    _changeDetectorRef.markForCheck();
    event.preventDefault();
  }

  bool isKeyboardNavigating() => _navigatingWithKeyboard;

  LiNavItemDirective? getItemById(Object? id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  void _updateActiveId(
    Object? nextId, {
    required bool emitNavChange,
    required bool emitActiveIdChange,
  }) {
    if (_activeId == nextId) {
      return;
    }

    final previousId = _activeId;
    if (emitNavChange) {
      final changeEvent = LiNavChangeEvent(
        activeId: previousId,
        nextId: nextId,
      );
      _navChangeController.add(changeEvent);
      if (changeEvent.defaultPrevented) {
        return;
      }
    }

    final previousItem = getItemById(previousId);
    final nextItem = getItemById(nextId);
    _activeId = nextId;

    if (emitActiveIdChange) {
      _activeIdChangeController.add(nextId);
    }

    if (previousItem != null) {
      previousItem.emitHidden();
      _hiddenController.add(previousItem.id);
    }
    if (nextItem != null) {
      nextItem.emitShown();
      _shownController.add(nextItem.id);
    }

    _emitItemChange();
    _changeDetectorRef.markForCheck();
  }

  void _emitItemChange() {
    if (!_itemChangeController.isClosed) {
      _itemChangeController.add(getItemById(_activeId));
    }
  }

  @override
  void ngOnDestroy() {
    _activeIdChangeController.close();
    _navChangeController.close();
    _shownController.close();
    _hiddenController.close();
    _itemChangeController.close();
  }
}

@Directive(
  selector: '[liNavItem]',
  exportAs: 'liNavItem',
)
class LiNavItemDirective implements OnInit, OnDestroy {
  LiNavItemDirective(
    this.nav,
    this._changeDetectorRef,
  ) {
    _domId = 'li-nav-${_nextId++}';
  }

  static int _nextId = 0;

  final LiNavDirective nav;
  final ChangeDetectorRef _changeDetectorRef;
  final StreamController<void> _shownController =
      StreamController<void>.broadcast();
  final StreamController<void> _hiddenController =
      StreamController<void>.broadcast();

  String _domId = '';
  Object? _itemId;
  bool? _destroyOnHide;

  @ContentChild(LiNavContentDirective)
  LiNavContentDirective? content;

  @Input('liNavItem')
  set itemId(Object? value) {
    _itemId = value;
  }

  @Input()
  bool disabled = false;

  @Input()
  set domId(String? value) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      _domId = normalized;
    }
  }

  String get domId => _domId;

  @Input()
  set destroyOnHide(bool value) {
    _destroyOnHide = value;
    _changeDetectorRef.markForCheck();
  }

  bool get resolvedDestroyOnHide => _destroyOnHide ?? nav.destroyOnHide;

  Object get id => _isValidNavId(_itemId) ? _itemId! : domId;

  bool get active => nav.activeId == id;

  String get panelDomId => '$domId-panel';

  bool get isPanelInDom => active || !resolvedDestroyOnHide;

  @Output()
  Stream<void> get shown => _shownController.stream;

  @Output()
  Stream<void> get hidden => _hiddenController.stream;

  @HostBinding('class.nav-item')
  bool hostNavItemClass = true;

  @HostBinding('attr.role')
  String? get hostRole => nav.roles ? 'presentation' : null;

  @override
  void ngOnInit() {
    nav.registerItem(this);
  }

  void emitShown() {
    if (!_shownController.isClosed) {
      _shownController.add(null);
    }
  }

  void emitHidden() {
    if (!_hiddenController.isClosed) {
      _hiddenController.add(null);
    }
  }

  @override
  void ngOnDestroy() {
    nav.unregisterItem(this);
    _shownController.close();
    _hiddenController.close();
  }
}

@Directive(selector: 'a[liNavLink],button[liNavLink]')
class LiNavLinkDirective implements OnInit, OnDestroy {
  LiNavLinkDirective(
    this.item,
    this.nav,
    this.nativeElement,
  );

  final LiNavItemDirective item;
  final LiNavDirective nav;
  final html.Element nativeElement;

  @HostBinding('class.nav-link')
  bool hostNavLinkClass = true;

  @HostBinding('class.active')
  bool get hostActiveClass => item.active;

  @HostBinding('class.disabled')
  bool get hostDisabledClass => item.disabled;

  @HostBinding('attr.id')
  String get hostId => item.domId;

  @HostBinding('attr.role')
  String? get hostRole => nav.roles ? 'tab' : null;

  @HostBinding('attr.aria-controls')
  String? get hostAriaControls => item.isPanelInDom ? item.panelDomId : null;

  @HostBinding('attr.aria-selected')
  String get hostAriaSelected => item.active.toString();

  @HostBinding('attr.aria-disabled')
  String get hostAriaDisabled => item.disabled.toString();

  @HostBinding('attr.tabindex')
  String? get hostTabIndex {
    if (nav.keyboard == false) {
      return item.disabled ? '-1' : null;
    }
    if (nav.isKeyboardNavigating()) {
      return '-1';
    }
    return item.disabled || !item.active ? '-1' : null;
  }

  @HostBinding('attr.href')
  String? get hostHref => nativeElement is html.AnchorElement ? '' : null;

  @HostBinding('attr.type')
  String? get hostType => nativeElement is html.ButtonElement ? 'button' : null;

  @HostBinding('attr.disabled')
  String? get hostDisabledAttribute =>
      nativeElement is html.ButtonElement && item.disabled ? '' : null;

  @override
  void ngOnInit() {
    nav.registerLink(this);
  }

  @HostListener('click', ['\$event'])
  void onClick(html.MouseEvent event) {
    if (nativeElement is html.AnchorElement) {
      event.preventDefault();
    }
    nav.click(item);
  }

  void focus() {
    nativeElement.focus();
  }

  @override
  void ngOnDestroy() {
    nav.unregisterLink(this);
  }
}

class _LiNavPaneView {
  _LiNavPaneView({
    required this.item,
    required this.viewRef,
    required this.paneElement,
  });

  final LiNavItemDirective item;
  final EmbeddedViewRef? viewRef;
  final html.DivElement paneElement;
}

@Directive(selector: '[liNavOutlet]')
class LiNavOutletDirective implements OnInit, OnDestroy {
  LiNavOutletDirective(
    this._hostElement,
    this._viewContainerRef,
    this._changeDetectorRef,
  );

  final html.Element _hostElement;
  final ViewContainerRef _viewContainerRef;
  final ChangeDetectorRef _changeDetectorRef;

  final List<_LiNavPaneView> _paneViews = <_LiNavPaneView>[];
  StreamSubscription<LiNavItemDirective?>? _itemChangeSubscription;

  LiNavDirective? _nav;
  String? paneRole;

  @Input('liNavOutlet')
  set nav(LiNavDirective? value) {
    if (identical(_nav, value)) {
      return;
    }

    _itemChangeSubscription?.cancel();
    _nav = value;
    if (_nav != null) {
      _itemChangeSubscription = _nav!.itemChange.listen((_) => _render());
    }
    _render();
  }

  @Input()
  set paneRoleInput(String? value) {
    paneRole = value?.trim();
    _render();
  }

  @HostBinding('class.tab-content')
  bool hostTabContentClass = true;

  @override
  void ngOnInit() {
    _render();
  }

  void _render() {
    _disposePaneViews();
    final nav = _nav;
    if (nav == null) {
      return;
    }

    for (final item in nav.items) {
      if (!item.isPanelInDom) {
        continue;
      }

      final pane = html.DivElement()
        ..classes.add('tab-pane')
        ..id = item.panelDomId
        ..setAttribute('aria-labelledby', item.domId);
      final role = paneRole ?? (nav.roles ? 'tabpanel' : null);
      if (role != null && role.isNotEmpty) {
        pane.setAttribute('role', role);
      }
      if (item.active) {
        pane.classes.add('active');
      }

      _hostElement.append(pane);

      EmbeddedViewRef? viewRef;
      final template = item.content?.templateRef;
      if (template != null) {
        viewRef = _viewContainerRef.createEmbeddedView(template);
        if (viewRef.hasLocal(r'$implicit')) {
          viewRef.setLocal(r'$implicit', item.active);
        }
        if (viewRef.hasLocal('active')) {
          viewRef.setLocal('active', item.active);
        }
        for (final rootNode in viewRef.rootNodes) {
          pane.append(rootNode);
        }
      }

      _paneViews.add(_LiNavPaneView(
        item: item,
        viewRef: viewRef,
        paneElement: pane,
      ));
    }

    _changeDetectorRef.markForCheck();
  }

  void _disposePaneViews() {
    for (final paneView in _paneViews) {
      paneView.viewRef?.destroy();
      paneView.paneElement.remove();
    }
    _paneViews.clear();
    _viewContainerRef.clear();
  }

  @override
  void ngOnDestroy() {
    _itemChangeSubscription?.cancel();
    _disposePaneViews();
  }
}
