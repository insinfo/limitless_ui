import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:popper/popper.dart';

import 'tooltip_config.dart';

/// Public directives used by tooltip APIs.
const liTooltipDirectives = <Object>[
  LiTooltipComponent,
  LiTooltipDirective,
];

class _LiTooltipFloatingOverlay {
  _LiTooltipFloatingOverlay._(
    this._controller, {
    this.portal,
    required this.floatingElement,
  });

  final PopperController _controller;
  final PopperPortal? portal;
  final html.Element floatingElement;

  factory _LiTooltipFloatingOverlay.attach({
    required html.Element referenceElement,
    required html.Element floatingElement,
    required html.Element localContainer,
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
      localContainer.append(floatingElement);
      floatingElement.style
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

  final html.Element _hostElement;
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
  html.DivElement? _tooltipElement;
  html.DivElement? _tooltipInnerElement;
  StreamSubscription<html.MouseEvent>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;
  StreamSubscription<html.MouseEvent>? _tooltipMouseEnterSubscription;
  StreamSubscription<html.MouseEvent>? _tooltipMouseLeaveSubscription;
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
  html.Element? _positionTargetElement;
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
    if (value is html.Element) {
      _positionTargetElement = value;
      _positionTargetSelector = null;
    } else if (value is String && value.trim().isNotEmpty) {
      _positionTargetSelector = value.trim();
      _positionTargetElement = null;
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

  html.Element get _referenceElement {
    if (_positionTargetElement != null) {
      return _positionTargetElement!;
    }

    final selector = _positionTargetSelector;
    if (selector != null) {
      final target = html.document.querySelector(selector);
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

  void handleFocusIn(html.Event event) {
    if (_isManual || !_triggers.contains('focus')) {
      return;
    }

    _focusActive = true;
    open(useDelay: true);
  }

  void handleFocusOut(html.FocusEvent event) {
    if (_isManual || !_triggers.contains('focus')) {
      return;
    }

    final relatedTarget = event.relatedTarget;
    if (relatedTarget is html.Element && _hostElement.contains(relatedTarget)) {
      return;
    }

    _focusActive = false;
    _hideIfInactive();
  }

  void handleClick(html.MouseEvent event) {
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
      _tooltipElement!.classes.remove('show');
      Future<void>.delayed(Duration.zero, () {
        if (_visible && _tooltipElement != null) {
          _tooltipElement!.classes.add('show');
        }
      });
      _shownTimer = Timer(_animationDuration, _emitShownIfVisible);
      return;
    }

    _tooltipElement!.classes.add('show');
    _shownController.add(null);
  }

  void _hideNow([bool? animateOverride]) {
    if (!_visible) {
      return;
    }

    _hideController.add(null);
    _visible = false;
    _hostElement.attributes.remove('aria-describedby');
    _cancelShownTimer();

    if (_tooltipElement == null) {
      _destroyTooltip();
      return;
    }

    final shouldAnimate = animateOverride ?? animation;
    if (shouldAnimate) {
      _tooltipElement!.classes.remove('show');
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

    final tooltipElement = html.DivElement()
      ..id = _tooltipId
      ..classes.add('tooltip')
      ..setAttribute('role', 'tooltip')
      ..style.pointerEvents = 'auto';

    if (animation) {
      tooltipElement.classes.add('fade');
    }

    final tooltipArrowElement = html.DivElement()..classes.add('tooltip-arrow');
    final tooltipInnerElement = html.DivElement()
      ..classes.add('tooltip-inner')
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
      portalOptions: const PopperPortalOptions(
        hostClassName: 'LiTooltipComponent',
        hostZIndex: '1080',
        floatingZIndex: '1080',
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

          arrowElement.style.position = 'absolute';

          if (placement.startsWith('top') || placement.startsWith('bottom')) {
            arrowElement.style
              ..left = '${((arrowData['x'] as num?) ?? 0).toStringAsFixed(2)}px'
              ..right = ''
              ..top = placement.startsWith('bottom') ? '-1px' : ''
              ..bottom = placement.startsWith('top') ? '-1px' : '';
            return;
          }

          arrowElement.style
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

    final showClassPresent = tooltipElement.classes.contains('show');
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
      _tooltipElement?.classes.add('show');
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
    tooltipElement.classes
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
      // ignore: unsafe_html
      tooltipInnerElement.setInnerHtml(
        _content,
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
      return;
    }

    tooltipInnerElement.text = _content;
  }

  void _syncTemplateContent(html.DivElement tooltipInnerElement) {
    _ensureTemplateView();
    final contentView = _contentView;
    if (contentView == null) {
      tooltipInnerElement.text = '';
      return;
    }

    tooltipInnerElement.nodes.clear();
    for (final node in contentView.rootNodes) {
      tooltipInnerElement.append(node);
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

  html.Element _resolveOverlayContainer() {
    return _referenceElement.parent ??
        _hostElement.parent ??
        html.document.body!;
  }

  void _syncTooltipClasses() {
    final tooltipElement = _tooltipElement;
    if (tooltipElement == null) {
      return;
    }

    if (_appliedTooltipClasses.isNotEmpty) {
      tooltipElement.classes.removeAll(_appliedTooltipClasses);
    }

    _appliedTooltipClasses = _tooltipClass
            ?.split(RegExp(r'\s+'))
            .where((className) => className.trim().isNotEmpty)
            .toSet() ??
        <String>{};

    if (_appliedTooltipClasses.isNotEmpty) {
      tooltipElement.classes.addAll(_appliedTooltipClasses);
    }
  }

  void _bindDocumentListeners() {
    if (_closeOnEscape) {
      _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
        if (event.key == 'Escape' || event.keyCode == 27) {
          _clickActive = false;
          _hoverActive = false;
          _focusActive = false;
          _tooltipHoverActive = false;
          close(false);
        }
      });
    }

    if (_closeOnInsideClick || _closeOnOutsideClick) {
      _documentClickSubscription ??= html.document.onClick.listen((event) {
        if (!_visible) {
          return;
        }

        final target = event.target;
        if (target is! html.Element) {
          return;
        }

        final tooltipElement = _tooltipElement;
        final clickedInsideTooltip =
            tooltipElement != null && tooltipElement.contains(target);
        final clickedOnReference = _referenceElement.contains(target);
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
  LiTooltipComponent(
      html.Element hostElement, ViewContainerRef viewContainerRef,
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
  void onFocusIn(html.Event event) {
    _overlay.handleFocusIn(event);
  }

  @HostListener('focusout', ['\$event'])
  void onFocusOut(html.FocusEvent event) {
    _overlay.handleFocusOut(event);
  }

  @HostListener('click', ['\$event'])
  void onClick(html.MouseEvent event) {
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
  LiTooltipDirective(
      html.Element hostElement, ViewContainerRef viewContainerRef,
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

  @HostListener('mouseenter')
  void onMouseEnter() {
    _overlay.handleMouseEnter();
  }

  @HostListener('mouseleave')
  void onMouseLeave() {
    _overlay.handleMouseLeave();
  }

  @HostListener('focusin', ['\$event'])
  void onFocusIn(html.Event event) {
    _overlay.handleFocusIn(event);
  }

  @HostListener('focusout', ['\$event'])
  void onFocusOut(html.FocusEvent event) {
    _overlay.handleFocusOut(event);
  }

  @HostListener('click', ['\$event'])
  void onClick(html.MouseEvent event) {
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
