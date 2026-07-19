import 'dart:async';
import 'dart:js_interop';
import 'dart:math' as math;
import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';
import 'package:popper/popper.dart';

import '../../web_support/dom_tokens.dart';
import '../../web_support/html_sinks.dart';
import '../../web_support/js_type_guards.dart';
import 'popover_config.dart';

/// Public directives used by the popover component.
const liPopoverDirectives = <Object>[
  LiPopoverComponent,
  LiPopoverDirective,
];

class _LiPopoverFloatingOverlay {
  _LiPopoverFloatingOverlay._(
    this._controller, {
    this.portal,
    required this.floatingElement,
  });

  final PopperController _controller;
  final PopperPortal? portal;
  final web.Element floatingElement;

  factory _LiPopoverFloatingOverlay.attach({
    required web.Element referenceElement,
    required web.Element floatingElement,
    required web.Element localContainer,
    required bool appendToBody,
    PopperOptions popperOptions = const PopperOptions(),
    PopperPortalOptions portalOptions = const PopperPortalOptions(),
  }) {
    PopperPortal? portal;

    if (appendToBody) {
      portal = PopperPortal.attach(
        floatingElement: floatingElement,
        options: portalOptions,
      );
    } else {
      localContainer.appendChild(floatingElement);
      (floatingElement as web.HTMLElement).style
        ..position = 'fixed'
        ..pointerEvents = 'auto'
        ..zIndex = portalOptions.floatingZIndex;
    }

    final controller = PopperController(
      referenceElement: referenceElement,
      floatingElement: floatingElement,
      options: popperOptions,
    );

    return _LiPopoverFloatingOverlay._(
      controller,
      portal: portal,
      floatingElement: floatingElement,
    );
  }

  Future<PopperLayout?> update() => _controller.update();

  void startAutoUpdate() => _controller.startAutoUpdate();

  void stopAutoUpdate() => _controller.stopAutoUpdate();

  void dispose() {
    _controller.dispose();
    portal?.dispose();
    if (portal == null) {
      floatingElement.remove();
    }
  }
}

/// Limitless/Bootstrap popover component with declarative AngularDart API.
@Component(
  selector: 'li-popover',
  templateUrl: 'popover_component.html',
  styleUrls: ['popover_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiPopoverComponent implements OnDestroy {
  static const int _defaultOverlayZIndex = 1080;
  static const int _modalOverlayZIndexOffset = 1;

  LiPopoverComponent(this._hostElement, this._viewContainerRef,
      [@Optional() LiPopoverConfig? config])
      : _config = config ?? LiPopoverConfig() {
    animation = _config.animation;
    _trigger = _config.triggers;
    _placement = _config.placement;
    openDelay = _config.openDelay;
    closeDelay = _config.closeDelay;
    _popoverClass = _config.popoverClass;
    _container = _config.container;
    _autoClose = _config.autoClose;
    _enabled = !_config.disablePopover;
    _defaultTemplateContext = _config.popoverContext;
    _popperOptions = _config.popperOptions;
  }

  static int _nextId = 0;
  static const Duration _animationDuration = Duration(milliseconds: 150);
  static const Set<String> _supportedTriggers = <String>{
    'hover',
    'focus',
    'click',
    'manual',
  };

  final web.Element _hostElement;
  final ViewContainerRef _viewContainerRef;
  final LiPopoverConfig _config;
  final StreamController<void> _shownController =
      StreamController<void>.broadcast();
  final StreamController<void> _hiddenController =
      StreamController<void>.broadcast();

  _LiPopoverFloatingOverlay? _overlay;
  web.HTMLDivElement? _popoverElement;
  web.HTMLHeadingElement? _popoverHeaderElement;
  web.HTMLDivElement? _popoverBodyElement;
  StreamSubscription<web.MouseEvent>? _documentClickSubscription;
  StreamSubscription<web.KeyboardEvent>? _documentKeySubscription;
  StreamSubscription<web.MouseEvent>? _popoverMouseEnterSubscription;
  StreamSubscription<web.MouseEvent>? _popoverMouseLeaveSubscription;
  Timer? _showTimer;
  Timer? _hideTimer;
  Timer? _shownTimer;

  bool _enabled = true;
  bool _visible = false;
  bool _hoverActive = false;
  bool _focusActive = false;
  bool _clickActive = false;
  bool _popoverHoverActive = false;
  bool _allowHtml = false;

  @Input()
  bool animation = true;

  @Input()
  int openDelay = 0;

  @Input()
  int closeDelay = 0;
  String _body = '';
  TemplateRef? _bodyTemplate;
  EmbeddedViewRef? _bodyView;
  String _title = '';
  TemplateRef? _titleTemplate;
  EmbeddedViewRef? _titleView;
  String _placement = 'auto';
  String _trigger = 'click';
  String? _popoverClass;
  String? _container;
  Object _autoClose = true;
  Object? _defaultTemplateContext;
  Object? _templateContext;
  bool _usesExplicitOpenContext = false;
  LiPopoverPopperOptions _popperOptions = defaultLiPopoverPopperOptions;
  web.Element? _positionTargetElement;
  String? _positionTargetSelector;
  math.Rectangle<num>? _stableAnchorRect;
  late final String _popoverId = 'li-popover-${_nextId++}';

  @Input()
  set popover(Object? value) {
    _applyBodyValue(value);
  }

  String get popover => _body;

  @Input()
  set body(Object? value) {
    popover = value;
  }

  String get body => _body;

  @Input()
  set popoverTitle(Object? value) {
    _applyTitleValue(value);
  }

  String get popoverTitle => _title;

  @Input()
  set title(Object? value) {
    popoverTitle = value;
  }

  String get title => _title;

  @Input()
  set placement(String value) {
    _placement = value;
    if (_visible) {
      _rebuildVisiblePopover();
    }
  }

  String get placement => _placement;

  @Input()
  set trigger(String value) {
    _trigger = value;
  }

  String get trigger => _trigger;

  @Input()
  set triggers(String value) {
    _trigger = value;
  }

  @Input('html')
  set allowHtml(bool value) {
    _allowHtml = value;
    _syncContent();
  }

  bool get allowHtml => _allowHtml;

  @Input()
  set autoClose(Object? value) {
    _autoClose = value ?? true;
  }

  String get autoClose => _autoCloseMode;

  @Input()
  set popoverClass(String? value) {
    final normalized = value?.trim();
    _popoverClass =
        normalized == null || normalized.isEmpty ? null : normalized;
    if (_visible) {
      _rebuildVisiblePopover();
    }
  }

  String? get popoverClass => _popoverClass;

  @Input()
  set container(String? value) {
    final normalized = value?.trim();
    _container = normalized == null || normalized.isEmpty ? null : normalized;
    if (_visible) {
      _rebuildVisiblePopover();
    }
  }

  String? get container => _container;

  @Input()
  set positionTarget(Object? value) {
    if (value is String) {
      final selector = value.trim();
      _positionTargetSelector = selector.isEmpty ? null : selector;
      _positionTargetElement = null;
    } else if (elementOrNull(value) case final element?) {
      _positionTargetElement = element;
      _positionTargetSelector = null;
    } else {
      _positionTargetElement = null;
      _positionTargetSelector = null;
    }

    _stableAnchorRect = null;

    if (_visible) {
      _rebuildVisiblePopover();
    }
  }

  @Input()
  set popoverContext(Object? value) {
    _defaultTemplateContext = value;
    if (_visible && !_usesExplicitOpenContext) {
      _templateContext = value;
      _applyTemplateContext();
    }
  }

  Object? get popoverContext => _defaultTemplateContext;

  @Input()
  set popperOptions(LiPopoverPopperOptions? value) {
    _popperOptions = value ?? defaultLiPopoverPopperOptions;
    if (_visible) {
      _rebuildVisiblePopover();
    }
  }

  LiPopoverPopperOptions get popperOptions => _popperOptions;

  @Input()
  set disablePopover(bool value) {
    _enabled = !value;
    if (!_enabled) {
      close(false);
    }
  }

  bool get disablePopover => !_enabled;

  @Output()
  Stream<void> get shown => _shownController.stream;

  @Output()
  Stream<void> get hidden => _hiddenController.stream;

  @HostBinding('class.li-popover-host')
  bool hostPopoverClass = true;

  @HostBinding('attr.data-label')
  String get hostDataLabel => 'li_popover_trigger';

  @HostBinding('attr.data-open')
  String get hostDataOpen => isOpen() ? 'true' : 'false';

  bool isOpen() => _visible;

  bool get _hasRenderableContent =>
      _bodyTemplate != null ||
      _titleTemplate != null ||
      _body.trim().isNotEmpty ||
      _title.trim().isNotEmpty;

  bool get _hasTemplateContent =>
      _bodyTemplate != null || _titleTemplate != null;

  bool get _appendToBody => _container?.toLowerCase() == 'body';

  Set<String> get _triggers {
    final parsed = _trigger
        .split(RegExp(r'[\s,]+'))
        .map((value) => value.trim().toLowerCase())
        .where(
            (value) => value.isNotEmpty && _supportedTriggers.contains(value))
        .toSet();
    return parsed.isEmpty ? <String>{'click'} : parsed;
  }

  bool get _supportsHover => _triggers.contains('hover');

  bool get _supportsFocus => _triggers.contains('focus');

  bool get _supportsClick => _triggers.contains('click');

  bool get _isManual => _triggers.contains('manual');

  String get _autoCloseMode {
    final value = _autoClose;
    if (value is bool) {
      return value ? 'true' : 'false';
    }

    final normalized = value.toString().trim().toLowerCase();
    switch (normalized) {
      case 'false':
      case 'inside':
      case 'outside':
      case 'true':
        return normalized;
      default:
        return 'true';
    }
  }

  bool get _closeOnEscape => _autoCloseMode != 'false';

  bool get _closeOnInsideClick =>
      _autoCloseMode == 'true' || _autoCloseMode == 'inside';

  bool get _closeOnOutsideClick =>
      _autoCloseMode == 'true' || _autoCloseMode == 'outside';

  web.Element? get _defaultReferenceElement {
    final children = _hostElement.children;
    if (children.length != 0) {
      return children.item(0);
    }

    return null;
  }

  web.Element get _referenceElement {
    if (_positionTargetElement != null) {
      return _positionTargetElement!;
    }

    final selector = _positionTargetSelector;
    if (selector != null) {
      final target = web.document.querySelector(selector);
      if (target != null) {
        _positionTargetElement = target;
        return target;
      }
    }

    final defaultReference = _defaultReferenceElement;
    if (defaultReference != null) {
      return defaultReference;
    }

    return _hostElement;
  }

  List<String> get _popoverClassNames {
    final rawClasses = _popoverClass?.trim();
    if (rawClasses == null || rawClasses.isEmpty) {
      return const <String>[];
    }

    return rawClasses
        .split(RegExp(r'\s+'))
        .where((className) => className.trim().isNotEmpty)
        .toList(growable: false);
  }

  List<String> get _popoverBackgroundClassNames => _popoverClassNames
      .where((className) => className.startsWith('bg-'))
      .toList(growable: false);

  List<String> get _popoverTextClassNames => _popoverClassNames
      .where((className) => className.startsWith('text-'))
      .toList(growable: false);

  @HostListener('mouseenter')
  void onMouseEnter() {
    if (_isManual || !_supportsHover) {
      return;
    }

    _hoverActive = true;
    if (_visible) {
      return;
    }

    open();
  }

  @HostListener('mouseleave')
  void onMouseLeave() {
    if (_isManual || !_supportsHover) {
      return;
    }

    _hoverActive = false;
    _hideIfInactive();
  }

  @HostListener('focusin', ['\$event'])
  void onFocusIn(web.Event event) {
    if (_isManual || !_supportsFocus) {
      return;
    }

    _focusActive = true;
    if (_visible) {
      return;
    }

    open();
  }

  @HostListener('focusout', ['\$event'])
  void onFocusOut(web.FocusEvent event) {
    if (_isManual || !_supportsFocus) {
      return;
    }

    final relatedTarget = event.relatedTarget;
    if ((relatedTarget?.isA<web.Element>() ?? false) &&
        _hostElement.contains(relatedTarget as web.Node?)) {
      return;
    }

    _focusActive = false;
    _hideIfInactive();
  }

  @HostListener('click', ['\$event'])
  void onClick(web.MouseEvent event) {
    if (_isManual || !_supportsClick) {
      return;
    }

    event.preventDefault();
    event.stopPropagation();

    _clickActive = !_clickActive;
    if (_clickActive) {
      open();
      return;
    }

    _hideIfInactive(force: true);
  }

  void open([dynamic context]) {
    _usesExplicitOpenContext = context != null;
    _templateContext = context ?? _defaultTemplateContext;
    if (_hasTemplateContent) {
      _applyTemplateContext();
    }

    if (!_enabled || !_hasRenderableContent) {
      return;
    }

    _cancelHideTimer();

    if (_visible) {
      _overlay?.update();
      return;
    }

    _cancelShowTimer();
    if (!_isManual && openDelay > 0) {
      _showTimer = Timer(Duration(milliseconds: openDelay), _openNow);
      return;
    }

    _openNow();
  }

  void close([bool withAnimation = true]) {
    _clickActive = false;
    _hoverActive = false;
    _focusActive = false;
    _popoverHoverActive = false;
    _usesExplicitOpenContext = false;
    _cancelShowTimer();

    if (!_visible) {
      return;
    }

    _cancelHideTimer();
    if (!_isManual && closeDelay > 0) {
      _hideTimer = Timer(
        Duration(milliseconds: closeDelay),
        () => _closeNow(withAnimation),
      );
      return;
    }

    _closeNow(withAnimation);
  }

  void toggle([dynamic context]) {
    if (_visible) {
      close();
      return;
    }

    open(context);
  }

  void _applyBodyValue(Object? value) {
    if (value == null) {
      _destroyBodyView();
      _bodyTemplate = null;
      _body = '';
      _syncContent();
      return;
    }

    if (value is TemplateRef) {
      if (!identical(_bodyTemplate, value)) {
        _destroyBodyView();
      }
      _bodyTemplate = value;
      _body = '';
      _syncContent();
      return;
    }

    _destroyBodyView();
    _bodyTemplate = null;
    _body = value.toString();
    _syncContent();
  }

  void _applyTitleValue(Object? value) {
    if (value == null) {
      _destroyTitleView();
      _titleTemplate = null;
      _title = '';
      _syncContent();
      return;
    }

    if (value is TemplateRef) {
      if (!identical(_titleTemplate, value)) {
        _destroyTitleView();
      }
      _titleTemplate = value;
      _title = '';
      _syncContent();
      return;
    }

    _destroyTitleView();
    _titleTemplate = null;
    _title = value.toString();
    _syncContent();
  }

  void _openNow() {
    if (_visible || !_enabled || !_hasRenderableContent) {
      return;
    }

    _stableAnchorRect = null;
    _ensurePopover();
    _visible = true;
    _referenceElement.setAttribute('aria-describedby', _popoverId);
    _overlay?.startAutoUpdate();
    _overlay?.update();

    final popoverElement = _popoverElement;
    if (popoverElement == null) {
      return;
    }

    _bindDocumentListeners();

    if (animation) {
      popoverElement.classList.remove('show');
      Future<void>.delayed(Duration.zero, () {
        if (_visible && _popoverElement != null) {
          _popoverElement!.classList.add('show');
        }
      });
      _shownTimer = Timer(_animationDuration, _emitShownIfVisible);
      return;
    }

    popoverElement.classList.add('show');
    _shownController.add(null);
  }

  void _closeNow(bool withAnimation) {
    if (!_visible) {
      return;
    }

    _visible = false;
    _stableAnchorRect = null;
    _referenceElement.removeAttribute('aria-describedby');
    _cancelShownTimer();

    final popoverElement = _popoverElement;
    if (popoverElement == null) {
      _destroyPopover();
      return;
    }

    if (animation && withAnimation) {
      popoverElement.classList.remove('show');
      _shownTimer = Timer(_animationDuration, _destroyPopover);
      return;
    }

    _destroyPopover();
  }

  void _emitShownIfVisible() {
    if (_visible) {
      _shownController.add(null);
    }
  }

  void _ensurePopover() {
    if (_overlay != null && _popoverElement != null) {
      _syncContent();
      return;
    }

    final popoverElement = addClassTokens(
      web.HTMLDivElement()..id = _popoverId,
      const <String>['popover', 'bs-popover-auto'],
    )
      ..setAttribute('role', 'tooltip')
      ..setAttribute('data-label', 'li_popover_panel')
      ..setAttribute('data-open', 'true')
      ..style.pointerEvents = 'auto';

    if (animation) {
      popoverElement.classList.add('fade');
    }

    final popoverClassNames = _popoverClassNames;
    if (popoverClassNames.isNotEmpty) {
      addClassTokens(popoverElement, popoverClassNames);
    }

    final popoverArrowElement = web.HTMLDivElement()
      ..classList.add('popover-arrow')
      ..setAttribute('data-label', 'li_popover_arrow');
    if (popoverClassNames.isNotEmpty) {
      addClassTokens(
        popoverArrowElement,
        popoverClassNames.where((className) => className.startsWith('border-')),
      );
    }

    final popoverHeaderElement = web.HTMLHeadingElement.h3()
      ..classList.add('popover-header')
      ..setAttribute('data-label', 'li_popover_header');
    final popoverBodyElement = web.HTMLDivElement()
      ..classList.add('popover-body')
      ..setAttribute('data-label', 'li_popover_body')
      ..style.whiteSpace = 'pre-line';

    popoverElement
      ..appendChild(popoverArrowElement)
      ..appendChild(popoverHeaderElement)
      ..appendChild(popoverBodyElement);

    _popoverElement = popoverElement;
    _popoverHeaderElement = popoverHeaderElement;
    _popoverBodyElement = popoverBodyElement;
    _syncContent();
    _bindPopoverHoverListeners();

    final localContainer = _resolveOverlayContainer();
    final overlayZIndex = _resolveOverlayZIndex().toString();

    _overlay = _LiPopoverFloatingOverlay.attach(
      referenceElement: _referenceElement,
      floatingElement: popoverElement,
      localContainer: localContainer,
      appendToBody: _appendToBody,
      portalOptions: PopperPortalOptions(
        hostClassName: 'LiPopoverComponent',
        hostZIndex: overlayZIndex,
        floatingZIndex: overlayZIndex,
      ),
      popperOptions: _buildPopperOptions(popoverArrowElement),
    );
  }

  PopperOptions _buildPopperOptions(web.Element arrowElement) {
    final baseOptions = PopperOptions(
      placement: _resolvedPlacement,
      fallbackPlacements: _fallbackPlacements,
      allowedAutoPlacements: const <String>['top', 'right', 'bottom', 'left'],
      strategy: PopperStrategy.fixed,
      padding: const PopperInsets.all(8),
      offset: const PopperOffset(mainAxis: 8),
      arrowElement: arrowElement,
      arrowPadding: const PopperInsets.all(10),
      arrowWriteMode: PopperArrowWriteMode.crossAxisOnly,
      arrowLayoutWriter: (layout, arrowElement) {
        final arrowData =
            layout.middlewareData['arrow'] ?? const <String, dynamic>{};
        final placement = layout.placement.toLowerCase();

        final arrowStyle = (arrowElement as web.HTMLElement).style;
        arrowStyle.position = 'absolute';

        if (placement.startsWith('top') || placement.startsWith('bottom')) {
          arrowStyle
            ..left = '${((arrowData['x'] as num?) ?? 0).toStringAsFixed(2)}px'
            ..right = ''
            ..top = ''
            ..bottom = '';
          return;
        }

        arrowStyle
          ..top = '${((arrowData['y'] as num?) ?? 0).toStringAsFixed(2)}px'
          ..bottom = ''
          ..left = ''
          ..right = '';
      },
      anchorRectBuilder: (reference, floating) {
        final cached = _stableAnchorRect;
        if (cached != null) {
          return cached;
        }
        final r = reference.getBoundingClientRect();
        return _stableAnchorRect =
            math.Rectangle<num>(r.left, r.top, r.width, r.height);
      },
      onLayout: _handleLayout,
    );

    final transformedOptions = _popperOptions(baseOptions);
    return transformedOptions.copyWith(
      arrowElement: transformedOptions.arrowElement ?? arrowElement,
      arrowWriteMode: transformedOptions.arrowWriteMode,
      onLayout: (layout) {
        transformedOptions.onLayout?.call(layout);
        _handleLayout(layout);
      },
    );
  }

  void _rebuildVisiblePopover() {
    final wasVisible = _visible;
    final popoverElement = _popoverElement;
    if (!wasVisible || popoverElement == null) {
      return;
    }

    final showClassPresent = popoverElement.classList.contains('show');
    _overlay?.stopAutoUpdate();
    _overlay?.dispose();
    _overlay = null;
    _popoverMouseEnterSubscription?.cancel();
    _popoverMouseLeaveSubscription?.cancel();
    _popoverMouseEnterSubscription = null;
    _popoverMouseLeaveSubscription = null;
    popoverElement.remove();
    _popoverElement = null;
    _popoverHeaderElement = null;
    _popoverBodyElement = null;
    _ensurePopover();
    if (showClassPresent) {
      _popoverElement?.classList.add('show');
    }
    _overlay?.startAutoUpdate();
    _overlay?.update();
  }

  String get _resolvedPlacement {
    final normalized = _placement.trim().toLowerCase();
    switch (normalized) {
      case 'top':
      case 'top-start':
      case 'top-end':
      case 'bottom':
      case 'bottom-start':
      case 'bottom-end':
      case 'left':
      case 'left-start':
      case 'left-end':
      case 'right':
      case 'right-start':
      case 'right-end':
      case 'start':
      case 'start-top':
      case 'start-bottom':
      case 'end':
      case 'end-top':
      case 'end-bottom':
      case 'auto':
      case 'auto-start':
      case 'auto-end':
        return normalized;
      default:
        return 'auto';
    }
  }

  List<String> get _fallbackPlacements {
    switch (_resolvedPlacement) {
      case 'top':
      case 'top-start':
      case 'top-end':
        return const <String>['bottom', 'right', 'left'];
      case 'bottom':
      case 'bottom-start':
      case 'bottom-end':
        return const <String>['top', 'right', 'left'];
      case 'left':
      case 'left-start':
      case 'left-end':
      case 'start':
      case 'start-top':
      case 'start-bottom':
        return const <String>['right', 'top', 'bottom'];
      case 'right':
      case 'right-start':
      case 'right-end':
      case 'end':
      case 'end-top':
      case 'end-bottom':
        return const <String>['left', 'top', 'bottom'];
      default:
        return const <String>['top', 'right', 'bottom', 'left'];
    }
  }

  void _handleLayout(PopperLayout layout) {
    final popoverElement = _popoverElement;
    if (popoverElement == null) {
      return;
    }

    popoverElement.setAttribute('data-popper-placement', layout.placement);
    popoverElement.classList
      ..remove('bs-popover-top')
      ..remove('bs-popover-bottom')
      ..remove('bs-popover-start')
      ..remove('bs-popover-end')
      ..add(_placementClassFor(layout.placement));
  }

  String _placementClassFor(String placement) {
    final normalized = placement.trim().toLowerCase();
    if (normalized.startsWith('bottom')) {
      return 'bs-popover-bottom';
    }
    if (normalized.startsWith('left') || normalized.startsWith('start')) {
      return 'bs-popover-start';
    }
    if (normalized.startsWith('right') || normalized.startsWith('end')) {
      return 'bs-popover-end';
    }
    return 'bs-popover-top';
  }

  void _syncContent() {
    final popoverElement = _popoverElement;
    final popoverHeaderElement = _popoverHeaderElement;
    final popoverBodyElement = _popoverBodyElement;
    if (popoverElement == null ||
        popoverHeaderElement == null ||
        popoverBodyElement == null) {
      return;
    }

    final backgroundClassNames = _popoverBackgroundClassNames;
    final textClassNames = _popoverTextClassNames;
    final hasCustomTheme = _popoverClassNames.contains('popover-custom');
    final hasTitle = _titleTemplate != null || _title.trim().isNotEmpty;

    popoverHeaderElement.className = 'popover-header';
    if (hasCustomTheme) {
      if (backgroundClassNames.isNotEmpty) {
        addClassTokens(popoverHeaderElement, backgroundClassNames);
      }
      if (textClassNames.isNotEmpty) {
        addClassTokens(popoverHeaderElement, textClassNames);
        if (textClassNames.contains('text-white')) {
          addClassTokens(
            popoverHeaderElement,
            const <String>['border-white', 'border-opacity-25'],
          );
        } else if (textClassNames.contains('text-black')) {
          addClassTokens(
            popoverHeaderElement,
            const <String>['border-black', 'border-opacity-10'],
          );
        }
      }
    }

    if (hasTitle) {
      if (popoverHeaderElement.parentElement == null) {
        popoverElement.insertBefore(popoverHeaderElement, popoverBodyElement);
      }

      if (_titleTemplate != null) {
        _syncTemplateContent(
          popoverHeaderElement,
          template: _titleTemplate,
          currentView: _titleView,
          assignView: (view) => _titleView = view,
        );
      } else if (_allowHtml) {
        setTrustedHtml(popoverHeaderElement, _title);
      } else {
        popoverHeaderElement.textContent = _title;
      }
    } else {
      popoverHeaderElement.textContent = '';
      popoverHeaderElement.remove();
    }

    popoverBodyElement.className = 'popover-body';
    if (hasCustomTheme && textClassNames.isNotEmpty) {
      addClassTokens(popoverBodyElement, textClassNames);
    }

    if (_bodyTemplate != null) {
      _syncTemplateContent(
        popoverBodyElement,
        template: _bodyTemplate,
        currentView: _bodyView,
        assignView: (view) => _bodyView = view,
      );
      return;
    }

    if (_allowHtml) {
      setTrustedHtml(popoverBodyElement, _body);
      return;
    }

    popoverBodyElement.textContent = _body;
  }

  void _syncTemplateContent(
    web.Element container, {
    required TemplateRef? template,
    required EmbeddedViewRef? currentView,
    required void Function(EmbeddedViewRef? view) assignView,
  }) {
    final contentView = _ensureTemplateView(
      template: template,
      currentView: currentView,
      assignView: assignView,
    );
    if (contentView == null) {
      container.textContent = '';
      return;
    }

    container.textContent = '';
    for (final node in contentView.rootNodes) {
      container.appendChild(node);
    }
    contentView.markForCheck();
  }

  EmbeddedViewRef? _ensureTemplateView({
    required TemplateRef? template,
    required EmbeddedViewRef? currentView,
    required void Function(EmbeddedViewRef? view) assignView,
  }) {
    if (currentView != null || template == null) {
      return currentView;
    }

    final view = _viewContainerRef.createEmbeddedView(template);
    assignView(view);
    _applyTemplateContextToView(view);
    return view;
  }

  void _applyTemplateContext() {
    _applyTemplateContextToView(_titleView);
    _applyTemplateContextToView(_bodyView);
  }

  void _applyTemplateContextToView(EmbeddedViewRef? contentView) {
    if (contentView == null) {
      return;
    }

    final context = _templateContext;
    if (context is Map) {
      context.forEach((key, value) {
        if (key is String) {
          contentView.setLocal(key, value);
        }
      });
    }

    contentView.setLocal(r'$implicit', context);
    contentView.setLocal('popover', context);
    contentView.setLocal('context', context);
    contentView.setLocal('title', context);
    contentView.setLocal('body', context);

    contentView.markForCheck();
  }

  web.Element _resolveOverlayContainer() {
    return _referenceElement.parentElement ??
        _hostElement.parentElement ??
        web.document.body!;
  }

  int _resolveOverlayZIndex() {
    final owningModal = _resolveOwningModalElement();
    final owningModalZIndex = _parseElementZIndex(owningModal);
    if (owningModalZIndex != null) {
      return owningModalZIndex + _modalOverlayZIndexOffset;
    }

    final topModalZIndex = _highestOpenModalZIndex();
    if (topModalZIndex != null) {
      return topModalZIndex + _modalOverlayZIndexOffset;
    }

    return _defaultOverlayZIndex;
  }

  web.Element? _resolveOwningModalElement() {
    return _referenceElement.closest('.modal') ??
        _hostElement.closest('.modal');
  }

  int? _highestOpenModalZIndex() {
    int? highestZIndex;

    final openModals =
        web.document.querySelectorAll('.modal[data-status="open"]');
    for (var index = 0; index < openModals.length; index++) {
      final modal = openModals.item(index);
      final zIndex = _parseElementZIndex(elementOrNull(modal));
      if (zIndex == null) {
        continue;
      }
      if (highestZIndex == null || zIndex > highestZIndex) {
        highestZIndex = zIndex;
      }
    }

    return highestZIndex;
  }

  int? _parseElementZIndex(web.Element? element) {
    if (element == null) {
      return null;
    }

    final inlineZIndex =
        int.tryParse((element as web.HTMLElement).style.zIndex.trim());
    if (inlineZIndex != null) {
      return inlineZIndex;
    }

    final computedZIndex = int.tryParse(
      web.window.getComputedStyle(element).zIndex.trim(),
    );
    return computedZIndex;
  }

  void _bindDocumentListeners() {
    if (_closeOnEscape) {
      _documentKeySubscription ??=
          web.EventStreamProvider<web.KeyboardEvent>('keydown')
              .forTarget(web.document)
              .listen((event) {
        if (event.key == 'Escape') {
          close(false);
        }
      });
    }

    if (_closeOnInsideClick || _closeOnOutsideClick) {
      _documentClickSubscription ??=
          web.EventStreamProvider<web.MouseEvent>('click')
              .forTarget(web.document)
              .listen((event) {
        if (!_visible) {
          return;
        }

        final target = event.target;
        if (!(target?.isA<web.Element>() ?? false)) {
          return;
        }

        final popoverElement = _popoverElement;
        final clickedInsidePopover = popoverElement != null &&
            popoverElement.contains(target as web.Node?);
        final clickedOnReference =
            _referenceElement.contains(target as web.Node?);
        final clickedOnHost = _hostElement.contains(target);

        if (clickedInsidePopover) {
          if (_closeOnInsideClick) {
            close(false);
          }
          return;
        }

        if (clickedOnReference || clickedOnHost) {
          return;
        }

        if (_closeOnOutsideClick) {
          close(false);
        }
      });
    }
  }

  void _bindPopoverHoverListeners() {
    final popoverElement = _popoverElement;
    if (popoverElement == null || !_supportsHover || _isManual) {
      return;
    }

    _popoverMouseEnterSubscription ??= popoverElement.onMouseEnter.listen((_) {
      _popoverHoverActive = true;
      _cancelHideTimer();
    });
    _popoverMouseLeaveSubscription ??= popoverElement.onMouseLeave.listen((_) {
      _popoverHoverActive = false;
      _hideIfInactive();
    });
  }

  void _hideIfInactive({bool force = false}) {
    if (!force &&
        (_clickActive || _hoverActive || _focusActive || _popoverHoverActive)) {
      return;
    }

    close();
  }

  void _destroyPopover() {
    final hadPopover = _popoverElement != null || _overlay != null;
    _stableAnchorRect = null;
    _overlay?.stopAutoUpdate();
    _overlay?.dispose();
    _overlay = null;
    _popoverElement = null;
    _popoverHeaderElement = null;
    _popoverBodyElement = null;
    _unbindPopoverHoverListeners();
    _unbindDocumentListeners();
    if (hadPopover) {
      _hiddenController.add(null);
    }
  }

  void _destroyBodyView() {
    _destroyTemplateView(_bodyView);
    _bodyView = null;
  }

  void _destroyTitleView() {
    _destroyTemplateView(_titleView);
    _titleView = null;
  }

  void _destroyTemplateView(EmbeddedViewRef? contentView) {
    if (contentView == null) {
      return;
    }

    final viewIndex = _viewContainerRef.indexOf(contentView);
    if (viewIndex != -1) {
      _viewContainerRef.remove(viewIndex);
    } else {
      contentView.destroy();
    }
  }

  void _cancelShowTimer() {
    _showTimer?.cancel();
    _showTimer = null;
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _cancelShownTimer() {
    _shownTimer?.cancel();
    _shownTimer = null;
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentKeySubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription = null;
  }

  void _unbindPopoverHoverListeners() {
    _popoverMouseEnterSubscription?.cancel();
    _popoverMouseLeaveSubscription?.cancel();
    _popoverMouseEnterSubscription = null;
    _popoverMouseLeaveSubscription = null;
  }

  @override
  void ngOnDestroy() {
    _cancelShowTimer();
    _cancelHideTimer();
    _cancelShownTimer();
    _destroyPopover();
    _destroyBodyView();
    _destroyTitleView();
    _shownController.close();
    _hiddenController.close();
  }
}

/// Directive-based popover API parallel to [LiTooltipDirective].
@Directive(
  selector: '[liPopover]',
  exportAs: 'liPopover',
)
class LiPopoverDirective implements OnDestroy {
  LiPopoverDirective(web.Element hostElement, ViewContainerRef viewContainerRef,
      [@Optional() LiPopoverConfig? config])
      : _popover = LiPopoverComponent(hostElement, viewContainerRef, config);

  final LiPopoverComponent _popover;

  @Input('liPopover')
  set popover(Object? value) => _popover.popover = value;

  @Input()
  set body(Object? value) => _popover.body = value;

  @Input()
  set popoverTitle(Object? value) => _popover.popoverTitle = value;

  @Input()
  set title(Object? value) => _popover.title = value;

  @Input()
  set placement(String value) => _popover.placement = value;

  String get placement => _popover.placement;

  @Input()
  set trigger(String value) => _popover.trigger = value;

  String get trigger => _popover.trigger;

  @Input()
  set triggers(String value) => _popover.triggers = value;

  @Input('html')
  set allowHtml(bool value) => _popover.allowHtml = value;

  bool get allowHtml => _popover.allowHtml;

  @Input()
  set animation(bool value) => _popover.animation = value;

  bool get animation => _popover.animation;

  @Input()
  set openDelay(int value) => _popover.openDelay = value;

  int get openDelay => _popover.openDelay;

  @Input()
  set closeDelay(int value) => _popover.closeDelay = value;

  int get closeDelay => _popover.closeDelay;

  @Input()
  set autoClose(Object? value) => _popover.autoClose = value;

  @Input()
  set popoverClass(String? value) => _popover.popoverClass = value;

  String? get popoverClass => _popover.popoverClass;

  @Input()
  set container(String? value) => _popover.container = value;

  String? get container => _popover.container;

  @Input()
  set positionTarget(Object? value) => _popover.positionTarget = value;

  @Input()
  set popoverContext(Object? value) => _popover.popoverContext = value;

  Object? get popoverContext => _popover.popoverContext;

  @Input()
  set popperOptions(LiPopoverPopperOptions? value) =>
      _popover.popperOptions = value;

  LiPopoverPopperOptions get popperOptions => _popover.popperOptions;

  @Input()
  set disablePopover(bool value) => _popover.disablePopover = value;

  bool get disablePopover => _popover.disablePopover;

  @Output()
  Stream<void> get shown => _popover.shown;

  @Output()
  Stream<void> get hidden => _popover.hidden;

  @HostBinding('class.li-popover-host')
  bool hostPopoverClass = true;

  @HostBinding('attr.data-label')
  String get hostDataLabel => 'li_popover_trigger';

  @HostBinding('attr.data-open')
  String get hostDataOpen => isOpen() ? 'true' : 'false';

  bool isOpen() => _popover.isOpen();

  @HostListener('mouseenter')
  void onMouseEnter() {
    _popover.onMouseEnter();
  }

  @HostListener('mouseleave')
  void onMouseLeave() {
    _popover.onMouseLeave();
  }

  @HostListener('focusin', ['\$event'])
  void onFocusIn(web.Event event) {
    _popover.onFocusIn(event);
  }

  @HostListener('focusout', ['\$event'])
  void onFocusOut(web.FocusEvent event) {
    _popover.onFocusOut(event);
  }

  @HostListener('click', ['\$event'])
  void onClick(web.MouseEvent event) {
    _popover.onClick(event);
  }

  void open([dynamic context]) {
    _popover.open(context);
  }

  void close([bool withAnimation = true]) {
    _popover.close(withAnimation);
  }

  void toggle([dynamic context]) {
    _popover.toggle(context);
  }

  @override
  void ngOnDestroy() {
    _popover.ngOnDestroy();
  }
}
