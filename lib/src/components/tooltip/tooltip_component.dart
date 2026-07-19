import 'dart:js_interop';
import 'dart:async';
import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';
import 'package:popper/popper.dart';

import '../../core/overlay_positioning.dart';
import '../../web_support/dom_tokens.dart';
import '../../web_support/html_sinks.dart';
import '../../web_support/js_type_guards.dart';
import 'tooltip_config.dart';

/// Public directives used by tooltip APIs.
const liTooltipDirectives = <Object>[
  LiTooltipComponent,
  LiTooltipDirective,
];

typedef LiTooltipLifecycleCallback = void Function(web.Element tooltip);

class LiTooltipController {
  LiTooltipController._(
    this._overlay,
    this._detach, {
    this.onOpen,
    this.onClose,
  }) {
    _shownSubscription = _overlay.shownEvent.listen((_) {
      _notifyOpen();
    });
    _hideSubscription = _overlay.hideEvent.listen((_) {
      _notifyClose();
    });
    _hiddenSubscription = _overlay.hiddenEvent.listen((_) {
      if (!_closedCompleter.isCompleted) {
        _closedCompleter.complete();
      }
      Future<void>.microtask(dispose);
    });
  }

  final _LiTooltipOverlay _overlay;
  final void Function(LiTooltipController controller) _detach;
  final LiTooltipLifecycleCallback? onOpen;
  final LiTooltipLifecycleCallback? onClose;
  final Completer<void> _closedCompleter = Completer<void>();
  StreamSubscription<void>? _shownSubscription;
  StreamSubscription<void>? _hideSubscription;
  StreamSubscription<void>? _hiddenSubscription;
  Timer? _closeTimer;
  bool _disposed = false;
  bool _openNotified = false;
  bool _closeNotified = false;

  Future<void> get closed => _closedCompleter.future;

  bool isOpen() => !_disposed && _overlay.isOpen();

  void close([bool? animation]) {
    if (_disposed) {
      return;
    }
    _closeTimer?.cancel();
    _notifyClose();
    _overlay.close(animation);
  }

  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    _closeTimer?.cancel();
    _shownSubscription?.cancel();
    _shownSubscription = null;
    _hideSubscription?.cancel();
    _hideSubscription = null;
    _hiddenSubscription?.cancel();
    _hiddenSubscription = null;
    _detach(this);
    if (!_closedCompleter.isCompleted) {
      _closedCompleter.complete();
    }
    _overlay.ngOnDestroy();
  }

  void scheduleClose(Duration? timer) {
    _closeTimer?.cancel();
    if (_disposed || timer == null) {
      return;
    }
    _closeTimer = Timer(timer, close);
  }

  void _notifyOpen() {
    if (_openNotified) {
      return;
    }

    final tooltipElement = _overlay._tooltipElement;
    if (tooltipElement == null) {
      return;
    }

    _openNotified = true;
    onOpen?.call(tooltipElement);
  }

  void _notifyClose() {
    if (_closeNotified) {
      return;
    }

    final tooltipElement = _overlay._tooltipElement;
    if (tooltipElement == null) {
      return;
    }

    _closeNotified = true;
    onClose?.call(tooltipElement);
  }
}

class LiTooltip {
  static final Set<LiTooltipController> _activeControllers =
      <LiTooltipController>{};

  static LiTooltipController show({
    required web.Element referenceElement,
    required Object content,
    String placement = 'top',
    Object? positionTarget,
    bool animation = true,
    int delayMs = 0,
    int? openDelay,
    int? closeDelay,
    String? tooltipClass,
    String? container,
    Object? autoClose = false,
    bool allowHtml = false,
    bool disabled = false,
    Duration? timer,
    LiTooltipConfig? config,
    Object? context,
    LiTooltipLifecycleCallback? onOpen,
    LiTooltipLifecycleCallback? onClose,
  }) {
    if (content is String && content.trim().isEmpty) {
      throw ArgumentError.value(
        content,
        'content',
        'Tooltip content must not be empty.',
      );
    }

    final overlay = _LiTooltipOverlay(referenceElement, null, config)
      ..content = content
      ..placement = placement
      ..positionTarget = positionTarget
      ..animation = animation
      ..delayMs = delayMs
      ..showDelayMs = openDelay
      ..hideDelayMs = closeDelay
      ..tooltipClass = tooltipClass
      ..container = container
      ..autoClose = autoClose
      ..allowHtml = allowHtml
      ..disabled = disabled;

    final controller = LiTooltipController._(
      overlay,
      _activeControllers.remove,
      onOpen: onOpen,
      onClose: onClose,
    );
    _activeControllers.add(controller);
    overlay.open(context: context);
    controller._notifyOpen();
    controller.scheduleClose(timer);
    return controller;
  }

  static void dismissAll([bool? animation]) {
    for (final controller in _activeControllers.toList()) {
      controller.close(animation);
    }
  }
}

class _LiTooltipFloatingOverlay {
  _LiTooltipFloatingOverlay._(
    this._controller, {
    this.portal,
    required this.floatingElement,
  });

  final PopperController _controller;
  final PopperPortal? portal;
  final web.Element floatingElement;

  factory _LiTooltipFloatingOverlay.attach({
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

    return _LiTooltipFloatingOverlay._(
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

class _LiTooltipOverlay implements OnDestroy {
  _LiTooltipOverlay(
    this._hostElement, [
    this._viewContainerRef,
    LiTooltipConfig? config,
  ]) : _config = config ?? LiTooltipConfig() {
    animation = _config.animation;
    trigger = _config.triggers;
    _placement = _config.placement;
    showDelayMs = _config.openDelay;
    hideDelayMs = _config.closeDelay;
    _tooltipClass = _config.tooltipClass;
    _container = _config.container;
    _autoClose = _config.autoClose;
    _enabled = !_config.disableTooltip;
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
  final ViewContainerRef? _viewContainerRef;
  final LiTooltipConfig _config;
  final StreamController<void> _showController =
      StreamController<void>.broadcast();
  final StreamController<void> _shownController =
      StreamController<void>.broadcast();
  final StreamController<void> _hideController =
      StreamController<void>.broadcast();
  final StreamController<void> _hiddenController =
      StreamController<void>.broadcast();

  _LiTooltipFloatingOverlay? _overlay;
  web.HTMLDivElement? _tooltipElement;
  web.HTMLDivElement? _tooltipInnerElement;
  StreamSubscription<web.MouseEvent>? _documentClickSubscription;
  StreamSubscription<web.KeyboardEvent>? _documentKeySubscription;
  StreamSubscription<web.MouseEvent>? _tooltipMouseEnterSubscription;
  StreamSubscription<web.MouseEvent>? _tooltipMouseLeaveSubscription;
  Timer? _showTimer;
  Timer? _hideTimer;
  Timer? _shownTimer;

  bool _enabled = true;
  bool _visible = false;
  bool _hoverActive = false;
  bool _focusActive = false;
  bool _clickActive = false;
  bool _tooltipHoverActive = false;
  bool _allowHtml = false;
  bool animation = true;
  int delayMs = 0;
  int? showDelayMs;
  int? hideDelayMs;
  String _content = '';
  TemplateRef? _contentTemplate;
  EmbeddedViewRef? _contentView;
  String _placement = 'top';
  String trigger = 'hover focus';
  String? _tooltipClass;
  String? _container;
  Object _autoClose = true;
  Object? _templateContext;
  web.Element? _positionTargetElement;
  String? _positionTargetSelector;
  Set<String> _appliedTooltipClasses = <String>{};
  late final String _tooltipId = 'li-tooltip-${_nextId++}';

  Stream<void> get showEvent => _showController.stream;

  Stream<void> get shownEvent => _shownController.stream;

  Stream<void> get hideEvent => _hideController.stream;

  Stream<void> get hiddenEvent => _hiddenController.stream;

  String get text => _content;

  set text(String? value) {
    _destroyTemplateView();
    _contentTemplate = null;
    _content = value ?? '';
    _syncContent();
  }

  set content(Object? value) {
    if (value == null) {
      _destroyTemplateView();
      _contentTemplate = null;
      text = '';
      return;
    }
    if (value is TemplateRef) {
      if (!identical(_contentTemplate, value)) {
        _destroyTemplateView();
      }
      _contentTemplate = value;
      _content = '';
      _syncContent();
      return;
    }
    _destroyTemplateView();
    _contentTemplate = null;
    text = value.toString();
  }

  set title(String? value) {
    text = value;
  }

  String get placement => _placement;

  set placement(String value) {
    _placement = value;
    if (_visible) {
      _rebuildVisibleTooltip();
    }
  }

  set triggers(String value) {
    trigger = value;
  }

  bool get allowHtml => _allowHtml;

  set allowHtml(bool value) {
    _allowHtml = value;
    _syncContent();
  }

  String? get tooltipClass => _tooltipClass;

  set tooltipClass(String? value) {
    _tooltipClass = value;
    _syncTooltipClasses();
  }

  set container(String? value) {
    final normalized = value?.trim();
    _container = normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? get container => _container;

  set autoClose(Object? value) {
    _autoClose = value ?? true;
  }

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

    if (_visible) {
      _rebuildVisibleTooltip();
    }
  }

  bool get disabled => !_enabled;

  set disabled(bool value) {
    _enabled = !value;
    if (!_enabled) {
      hide(useDelay: false);
    }
  }

  set disableTooltip(bool value) {
    disabled = value;
  }

  bool isOpen() => _visible;

  bool get _hasContent =>
      _contentTemplate != null || _content.trim().isNotEmpty;

  bool get _appendToBody => _container?.toLowerCase() == 'body';

  Set<String> get _triggers {
    final parsed = trigger
        .split(RegExp(r'[\s,]+'))
        .map((value) => value.trim().toLowerCase())
        .where(
            (value) => value.isNotEmpty && _supportedTriggers.contains(value))
        .toSet();
    return parsed.isEmpty ? <String>{'hover', 'focus'} : parsed;
  }

  bool get _isManual => _triggers.contains('manual');

  int get _resolvedShowDelayMs => showDelayMs ?? delayMs;

  int get _resolvedHideDelayMs => hideDelayMs ?? delayMs;

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

    return _hostElement;
  }

  void handleMouseEnter() {
    if (_isManual || !_triggers.contains('hover')) {
      return;
    }

    _hoverActive = true;
    open(useDelay: true);
  }

  void handleMouseLeave() {
    if (_isManual || !_triggers.contains('hover')) {
      return;
    }

    _hoverActive = false;
    _hideIfInactive();
  }

  void handleFocusIn(web.Event event) {
    if (_isManual || !_triggers.contains('focus')) {
      return;
    }

    _focusActive = true;
    open(useDelay: true);
  }

  void handleFocusOut(web.FocusEvent event) {
    if (_isManual || !_triggers.contains('focus')) {
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

  void handleClick(web.MouseEvent event) {
    if (_isManual || !_triggers.contains('click')) {
      return;
    }

    event.preventDefault();
    event.stopPropagation();
    _clickActive = !_clickActive;
    if (_clickActive) {
      open(useDelay: true);
      return;
    }

    _hideIfInactive(force: true);
  }

  void open({bool useDelay = false, Object? context}) {
    if (context != null) {
      if (_contentTemplate != null) {
        _templateContext = context;
        _applyTemplateContext();
      } else {
        content = context;
      }
    }

    if (!_enabled || !_hasContent) {
      return;
    }

    _cancelHideTimer();

    if (_visible) {
      _overlay?.update();
      return;
    }

    _cancelShowTimer();
    final delay = useDelay ? _resolvedShowDelayMs : 0;
    if (delay > 0) {
      _showTimer = Timer(Duration(milliseconds: delay), _showNow);
      return;
    }

    _showNow();
  }

  void hide({bool useDelay = false, bool? animateOverride}) {
    _cancelShowTimer();

    if (!_visible) {
      return;
    }

    _cancelHideTimer();
    final delay = useDelay ? _resolvedHideDelayMs : 0;
    if (delay > 0) {
      _hideTimer =
          Timer(Duration(milliseconds: delay), () => _hideNow(animateOverride));
      return;
    }

    _hideNow(animateOverride);
  }

  void toggle() {
    if (_visible) {
      close();
      return;
    }

    open();
  }

  void close([bool? animateOverride]) {
    _clickActive = false;
    _hoverActive = false;
    _focusActive = false;
    _tooltipHoverActive = false;
    hide(useDelay: false, animateOverride: animateOverride);
  }

  void enable() {
    _enabled = true;
  }

  void disable() {
    disabled = true;
  }

  void toggleEnabled() {
    if (_enabled) {
      disable();
      return;
    }

    enable();
  }

  void dispose() {
    _resetInteractionState();
    _cancelTimers();
    _destroyTooltip();
    _destroyTemplateView();
  }

  void _showNow() {
    if (_visible || !_enabled || !_hasContent) {
      return;
    }

    _showController.add(null);
    _ensureTooltip();
    _visible = true;
    _hostElement.setAttribute('aria-describedby', _tooltipId);
    _overlay?.startAutoUpdate();
    _overlay?.update();

    if (_tooltipElement == null) {
      return;
    }

    _bindDocumentListeners();

    if (animation) {
      _tooltipElement!.classList.remove('show');
      Future<void>.delayed(Duration.zero, () {
        if (_visible && _tooltipElement != null) {
          _tooltipElement!.classList.add('show');
        }
      });
      _shownTimer = Timer(_animationDuration, _emitShownIfVisible);
      return;
    }

    _tooltipElement!.classList.add('show');
    _shownController.add(null);
  }

  void _hideNow([bool? animateOverride]) {
    if (!_visible) {
      return;
    }

    _hideController.add(null);
    _visible = false;
    _hostElement.removeAttribute('aria-describedby');
    _cancelShownTimer();

    if (_tooltipElement == null) {
      _destroyTooltip();
      return;
    }

    final shouldAnimate = animateOverride ?? animation;
    if (shouldAnimate) {
      _tooltipElement!.classList.remove('show');
      _shownTimer = Timer(_animationDuration, _destroyTooltip);
      return;
    }

    _destroyTooltip();
  }

  void _emitShownIfVisible() {
    if (_visible) {
      _shownController.add(null);
    }
  }

  void _ensureTooltip() {
    if (_overlay != null && _tooltipElement != null) {
      _syncContent();
      _syncTooltipClasses();
      return;
    }

    final tooltipElement = web.HTMLDivElement()
      ..id = _tooltipId
      ..classList.add('tooltip')
      ..setAttribute('role', 'tooltip')
      ..setAttribute('data-label', 'li_tooltip_panel')
      ..setAttribute('data-open', 'true')
      ..style.pointerEvents = 'auto';

    if (animation) {
      tooltipElement.classList.add('fade');
    }

    final tooltipArrowElement = web.HTMLDivElement()
      ..classList.add('tooltip-arrow')
      ..setAttribute('data-label', 'li_tooltip_arrow');
    final tooltipInnerElement = web.HTMLDivElement()
      ..classList.add('tooltip-inner')
      ..setAttribute('data-label', 'li_tooltip_body')
      ..style.whiteSpace = 'pre-line';

    tooltipElement
      ..append(tooltipArrowElement)
      ..append(tooltipInnerElement);

    _tooltipElement = tooltipElement;
    _tooltipInnerElement = tooltipInnerElement;
    _syncTooltipClasses();
    _syncContent();
    _bindTooltipHoverListeners();

    final localContainer = _resolveOverlayContainer();

    _overlay = _LiTooltipFloatingOverlay.attach(
      referenceElement: _referenceElement,
      floatingElement: tooltipElement,
      localContainer: localContainer,
      appendToBody: _appendToBody,
      portalOptions: resolveModalAwarePortalOptions(
        hostClassName: 'LiTooltipComponent',
        referenceElement: _referenceElement,
        baseHostZIndex: 1080,
        baseFloatingZIndex: 1080,
      ),
      popperOptions: PopperOptions(
        placement: _resolvedPlacement,
        fallbackPlacements: _fallbackPlacements,
        allowedAutoPlacements: const <String>[
          'top',
          'right',
          'bottom',
          'left',
        ],
        strategy: PopperStrategy.fixed,
        padding: const PopperInsets.all(8),
        offset: const PopperOffset(mainAxis: 6),
        arrowElement: tooltipArrowElement,
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
              ..top = placement.startsWith('bottom') ? '-1px' : ''
              ..bottom = placement.startsWith('top') ? '-1px' : '';
            return;
          }

          arrowStyle
            ..top = '${((arrowData['y'] as num?) ?? 0).toStringAsFixed(2)}px'
            ..bottom = ''
            ..right = placement.startsWith('left') ? '-1px' : ''
            ..left = placement.startsWith('right') ? '-1px' : '';
        },
        onLayout: _handleLayout,
      ),
    );
  }

  void _rebuildVisibleTooltip() {
    final wasVisible = _visible;
    final tooltipElement = _tooltipElement;
    if (!wasVisible || tooltipElement == null) {
      return;
    }

    final showClassPresent = tooltipElement.classList.contains('show');
    _overlay?.stopAutoUpdate();
    _overlay?.dispose();
    _overlay = null;
    _tooltipMouseEnterSubscription?.cancel();
    _tooltipMouseLeaveSubscription?.cancel();
    _tooltipMouseEnterSubscription = null;
    _tooltipMouseLeaveSubscription = null;
    tooltipElement.remove();
    _tooltipElement = null;
    _tooltipInnerElement = null;
    _appliedTooltipClasses = <String>{};
    _ensureTooltip();
    if (showClassPresent) {
      _tooltipElement?.classList.add('show');
    }
    _overlay?.startAutoUpdate();
    _overlay?.update();
  }

  String get _resolvedPlacement {
    final normalized = _placement.trim().toLowerCase();
    switch (normalized) {
      case 'top':
      case 'bottom':
      case 'left':
      case 'right':
      case 'auto':
      case 'auto-start':
      case 'auto-end':
        return normalized;
      default:
        return 'top';
    }
  }

  List<String> get _fallbackPlacements {
    switch (_resolvedPlacement) {
      case 'top':
        return const <String>['bottom', 'right', 'left'];
      case 'bottom':
        return const <String>['top', 'right', 'left'];
      case 'left':
        return const <String>['right', 'top', 'bottom'];
      case 'right':
        return const <String>['left', 'top', 'bottom'];
      default:
        return const <String>['top', 'right', 'bottom', 'left'];
    }
  }

  void _handleLayout(PopperLayout layout) {
    final tooltipElement = _tooltipElement;
    if (tooltipElement == null) {
      return;
    }

    tooltipElement.setAttribute('data-popper-placement', layout.placement);
    tooltipElement.classList
      ..remove('bs-tooltip-top')
      ..remove('bs-tooltip-bottom')
      ..remove('bs-tooltip-start')
      ..remove('bs-tooltip-end')
      ..add(_placementClassFor(layout.placement));
  }

  String _placementClassFor(String placement) {
    final normalized = placement.trim().toLowerCase();
    if (normalized.startsWith('bottom')) {
      return 'bs-tooltip-bottom';
    }
    if (normalized.startsWith('left')) {
      return 'bs-tooltip-start';
    }
    if (normalized.startsWith('right')) {
      return 'bs-tooltip-end';
    }
    return 'bs-tooltip-top';
  }

  void _syncContent() {
    final tooltipInnerElement = _tooltipInnerElement;
    if (tooltipInnerElement == null) {
      return;
    }

    if (_contentTemplate != null) {
      _syncTemplateContent(tooltipInnerElement);
      return;
    }

    if (_allowHtml) {
      setTrustedHtml(tooltipInnerElement, _content);
      return;
    }

    tooltipInnerElement.textContent = _content;
  }

  void _syncTemplateContent(web.HTMLDivElement tooltipInnerElement) {
    _ensureTemplateView();
    final contentView = _contentView;
    if (contentView == null) {
      tooltipInnerElement.textContent = '';
      return;
    }

    tooltipInnerElement.textContent = '';
    for (final node in contentView.rootNodes) {
      tooltipInnerElement.appendChild(node);
    }
    contentView.markForCheck();
  }

  void _ensureTemplateView() {
    if (_contentView != null || _contentTemplate == null) {
      return;
    }

    final contentTemplate = _contentTemplate!;

    final view = _viewContainerRef != null
        ? _viewContainerRef.createEmbeddedView(contentTemplate)
        : contentTemplate.createEmbeddedView();
    _contentView = view;
    _applyTemplateContext();
  }

  void _applyTemplateContext() {
    final contentView = _contentView;
    if (contentView == null) {
      return;
    }

    final context = _templateContext;
    if (context is Map) {
      context.forEach((key, value) {
        if (key is String && contentView.hasLocal(key)) {
          contentView.setLocal(key, value);
        }
      });
    }

    if (contentView.hasLocal(r'$implicit')) {
      contentView.setLocal(r'$implicit', context);
    }
    if (contentView.hasLocal('tooltip')) {
      contentView.setLocal('tooltip', context);
    }
    if (contentView.hasLocal('context')) {
      contentView.setLocal('context', context);
    }

    contentView.markForCheck();
  }

  web.Element _resolveOverlayContainer() {
    return _referenceElement.parentElement ??
        _hostElement.parentElement ??
        web.document.body!;
  }

  void _syncTooltipClasses() {
    final tooltipElement = _tooltipElement;
    if (tooltipElement == null) {
      return;
    }

    if (_appliedTooltipClasses.isNotEmpty) {
      removeClassTokens(tooltipElement, _appliedTooltipClasses);
    }

    _appliedTooltipClasses = _tooltipClass
            ?.split(RegExp(r'\s+'))
            .where((className) => className.trim().isNotEmpty)
            .toSet() ??
        <String>{};

    if (_appliedTooltipClasses.isNotEmpty) {
      addClassTokens(tooltipElement, _appliedTooltipClasses);
    }
  }

  void _bindDocumentListeners() {
    if (_closeOnEscape) {
      _documentKeySubscription ??= web.EventStreamProviders.keyDownEvent
          .forTarget(web.document)
          .listen((event) {
        if (event.key == 'Escape') {
          _clickActive = false;
          _hoverActive = false;
          _focusActive = false;
          _tooltipHoverActive = false;
          close(false);
        }
      });
    }

    if (_closeOnInsideClick || _closeOnOutsideClick) {
      _documentClickSubscription ??= web.EventStreamProviders.clickEvent
          .forTarget(web.document)
          .listen((event) {
        if (!_visible) {
          return;
        }

        final target = event.target;
        if (!(target?.isA<web.Element>() ?? false)) {
          return;
        }

        final tooltipElement = _tooltipElement;
        final clickedInsideTooltip = tooltipElement != null &&
            tooltipElement.contains(target as web.Node?);
        final clickedOnReference =
            _referenceElement.contains(target as web.Node?);
        final clickedOnHost = _hostElement.contains(target);

        if (clickedInsideTooltip) {
          if (_closeOnInsideClick) {
            _clickActive = false;
            close(false);
          }
          return;
        }

        if (clickedOnReference || clickedOnHost) {
          return;
        }

        if (_closeOnOutsideClick) {
          _clickActive = false;
          close(false);
        }
      });
    }
  }

  void _bindTooltipHoverListeners() {
    final tooltipElement = _tooltipElement;
    if (tooltipElement == null) {
      return;
    }

    _tooltipMouseEnterSubscription ??= tooltipElement.onMouseEnter.listen((_) {
      if (!_triggers.contains('hover')) {
        return;
      }

      _tooltipHoverActive = true;
      _cancelHideTimer();
    });

    _tooltipMouseLeaveSubscription ??= tooltipElement.onMouseLeave.listen((_) {
      if (!_triggers.contains('hover')) {
        return;
      }

      _tooltipHoverActive = false;
      _hideIfInactive();
    });
  }

  void _hideIfInactive({bool force = false}) {
    if (!force &&
        (_hoverActive || _focusActive || _clickActive || _tooltipHoverActive)) {
      return;
    }

    hide(useDelay: !_isManual);
  }

  void _destroyTooltip() {
    final hadTooltip = _tooltipElement != null || _overlay != null;
    _overlay?.stopAutoUpdate();
    _overlay?.dispose();
    _overlay = null;
    _tooltipMouseEnterSubscription?.cancel();
    _tooltipMouseLeaveSubscription?.cancel();
    _tooltipMouseEnterSubscription = null;
    _tooltipMouseLeaveSubscription = null;
    _tooltipElement = null;
    _tooltipInnerElement = null;
    _appliedTooltipClasses = <String>{};
    _unbindDocumentListeners();
    if (hadTooltip) {
      _hiddenController.add(null);
    }
  }

  void _destroyTemplateView() {
    final contentView = _contentView;
    if (contentView == null) {
      return;
    }

    final viewContainerRef = _viewContainerRef;
    if (viewContainerRef != null) {
      final viewIndex = viewContainerRef.indexOf(contentView);
      if (viewIndex != -1) {
        viewContainerRef.remove(viewIndex);
      } else {
        contentView.destroy();
      }
    } else {
      contentView.destroy();
    }
    _contentView = null;
    _templateContext = null;
  }

  void _resetInteractionState() {
    _hoverActive = false;
    _focusActive = false;
    _clickActive = false;
    _tooltipHoverActive = false;
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

  void _cancelTimers() {
    _cancelShowTimer();
    _cancelHideTimer();
    _cancelShownTimer();
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentKeySubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription = null;
  }

  @override
  void ngOnDestroy() {
    dispose();
    _showController.close();
    _shownController.close();
    _hideController.close();
    _hiddenController.close();
  }
}

/// Limitless/Bootstrap tooltip component with DOM-based overlay rendering.
@Component(
  selector: 'li-tooltip',
  templateUrl: 'tooltip_component.html',
  styleUrls: ['tooltip_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTooltipComponent implements OnDestroy {
  LiTooltipComponent(web.Element hostElement, ViewContainerRef viewContainerRef,
      [@Optional() LiTooltipConfig? config])
      : _overlay = _LiTooltipOverlay(hostElement, viewContainerRef, config);

  final _LiTooltipOverlay _overlay;

  @Input()
  set text(String? value) => _overlay.text = value;

  String get text => _overlay.text;

  @Input()
  set title(String? value) => _overlay.title = value;

  @Input()
  set placement(String value) => _overlay.placement = value;

  String get placement => _overlay.placement;

  @Input()
  set trigger(String value) => _overlay.trigger = value;

  String get trigger => _overlay.trigger;

  @Input()
  set triggers(String value) => _overlay.triggers = value;

  @Input('html')
  set allowHtml(bool value) => _overlay.allowHtml = value;

  bool get allowHtml => _overlay.allowHtml;

  @Input()
  set animation(bool value) => _overlay.animation = value;

  bool get animation => _overlay.animation;

  @Input()
  set delayMs(int value) => _overlay.delayMs = value;

  int get delayMs => _overlay.delayMs;

  @Input()
  set showDelayMs(int? value) => _overlay.showDelayMs = value;

  int? get showDelayMs => _overlay.showDelayMs;

  @Input()
  set hideDelayMs(int? value) => _overlay.hideDelayMs = value;

  int? get hideDelayMs => _overlay.hideDelayMs;

  @Input()
  set openDelay(int value) => _overlay.showDelayMs = value;

  @Input()
  set closeDelay(int value) => _overlay.hideDelayMs = value;

  @Input()
  set tooltipClass(String? value) => _overlay.tooltipClass = value;

  String? get tooltipClass => _overlay.tooltipClass;

  @Input()
  set disabled(bool value) => _overlay.disabled = value;

  bool get disabled => _overlay.disabled;

  @Input()
  set disableTooltip(bool value) => _overlay.disableTooltip = value;

  @Input()
  set autoClose(Object? value) => _overlay.autoClose = value;

  @Input()
  set positionTarget(Object? value) => _overlay.positionTarget = value;

  @Input()
  set container(String? value) => _overlay.container = value;

  @Output('show')
  Stream<void> get showEvent => _overlay.showEvent;

  @Output('shown')
  Stream<void> get shownEvent => _overlay.shownEvent;

  @Output('hide')
  Stream<void> get hideEvent => _overlay.hideEvent;

  @Output('hidden')
  Stream<void> get hiddenEvent => _overlay.hiddenEvent;

  @HostBinding('class.li-tooltip-host')
  bool hostTooltipClass = true;

  @HostBinding('attr.data-label')
  String get hostDataLabel => 'li_tooltip_trigger';

  @HostBinding('attr.data-open')
  String get hostDataOpen => isVisible ? 'true' : 'false';

  bool get isVisible => _overlay.isOpen();

  @HostListener('mouseenter')
  void onMouseEnter() {
    _overlay.handleMouseEnter();
  }

  @HostListener('mouseleave')
  void onMouseLeave() {
    _overlay.handleMouseLeave();
  }

  @HostListener('focusin', ['\$event'])
  void onFocusIn(web.Event event) {
    _overlay.handleFocusIn(event);
  }

  @HostListener('focusout', ['\$event'])
  void onFocusOut(web.FocusEvent event) {
    _overlay.handleFocusOut(event);
  }

  @HostListener('click', ['\$event'])
  void onClick(web.MouseEvent event) {
    _overlay.handleClick(event);
  }

  void show() {
    _overlay.open(useDelay: true);
  }

  void hide() {
    _overlay.hide(useDelay: true);
  }

  void toggle() {
    _overlay.toggle();
  }

  void enable() {
    _overlay.enable();
  }

  void disable() {
    _overlay.disable();
  }

  void toggleEnabled() {
    _overlay.toggleEnabled();
  }

  void dispose() {
    _overlay.dispose();
  }

  @override
  void ngOnDestroy() {
    _overlay.ngOnDestroy();
  }
}

/// Directive-based tooltip API similar to ng-bootstrap.
@Directive(
  selector: '[liTooltip]',
  exportAs: 'liTooltip',
)
class LiTooltipDirective implements OnDestroy {
  LiTooltipDirective(web.Element hostElement, ViewContainerRef viewContainerRef,
      [@Optional() LiTooltipConfig? config])
      : _overlay = _LiTooltipOverlay(hostElement, viewContainerRef, config);

  final _LiTooltipOverlay _overlay;

  @Input('liTooltip')
  set tooltip(Object? value) => _overlay.content = value;

  @Input()
  set animation(bool value) => _overlay.animation = value;

  bool get animation => _overlay.animation;

  @Input()
  set autoClose(Object? value) => _overlay.autoClose = value;

  @Input()
  set closeDelay(int value) => _overlay.hideDelayMs = value;

  @Input()
  set container(String? value) => _overlay.container = value;

  @Input()
  set disableTooltip(bool value) => _overlay.disableTooltip = value;

  @Input()
  set openDelay(int value) => _overlay.showDelayMs = value;

  @Input()
  set placement(String value) => _overlay.placement = value;

  @Input()
  set positionTarget(Object? value) => _overlay.positionTarget = value;

  @Input()
  set tooltipClass(String? value) => _overlay.tooltipClass = value;

  @Input()
  set triggers(String value) => _overlay.triggers = value;

  @Input('html')
  set allowHtml(bool value) => _overlay.allowHtml = value;

  @Output('show')
  Stream<void> get showEvent => _overlay.showEvent;

  @Output('shown')
  Stream<void> get shown => _overlay.shownEvent;

  @Output('hide')
  Stream<void> get hideEvent => _overlay.hideEvent;

  @Output('hidden')
  Stream<void> get hidden => _overlay.hiddenEvent;

  @HostBinding('attr.data-label')
  String get hostDataLabel => 'li_tooltip_trigger';

  @HostBinding('attr.data-open')
  String get hostDataOpen => isOpen() ? 'true' : 'false';

  @HostListener('mouseenter')
  void onMouseEnter() {
    _overlay.handleMouseEnter();
  }

  @HostListener('mouseleave')
  void onMouseLeave() {
    _overlay.handleMouseLeave();
  }

  @HostListener('focusin', ['\$event'])
  void onFocusIn(web.Event event) {
    _overlay.handleFocusIn(event);
  }

  @HostListener('focusout', ['\$event'])
  void onFocusOut(web.FocusEvent event) {
    _overlay.handleFocusOut(event);
  }

  @HostListener('click', ['\$event'])
  void onClick(web.MouseEvent event) {
    _overlay.handleClick(event);
  }

  void open([Object? context]) {
    _overlay.open(context: context);
  }

  void close([bool? animation]) {
    _overlay.close(animation);
  }

  void toggle() {
    _overlay.toggle();
  }

  bool isOpen() => _overlay.isOpen();

  @override
  void ngOnDestroy() {
    _overlay.ngOnDestroy();
  }
}
