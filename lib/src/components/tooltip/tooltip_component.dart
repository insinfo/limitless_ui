import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:popper/popper.dart';

/// Public directives used by the tooltip component.
const liTooltipDirectives = <Object>[
  LiTooltipComponent,
];

/// Limitless/Bootstrap tooltip component with DOM-based overlay rendering.
@Component(
  selector: 'li-tooltip',
  templateUrl: 'tooltip_component.html',
  styleUrls: ['tooltip_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiTooltipComponent implements OnDestroy {
  LiTooltipComponent(this._hostElement);

  static int _nextId = 0;
  static const Duration _animationDuration = Duration(milliseconds: 150);
  static const Set<String> _supportedTriggers = <String>{
    'hover',
    'focus',
    'click',
    'manual',
  };

  final html.Element _hostElement;
  final StreamController<void> _showController =
      StreamController<void>.broadcast();
  final StreamController<void> _shownController =
      StreamController<void>.broadcast();
  final StreamController<void> _hideController =
      StreamController<void>.broadcast();
  final StreamController<void> _hiddenController =
      StreamController<void>.broadcast();

  PopperAnchoredOverlay? _overlay;
  html.DivElement? _tooltipElement;
  html.DivElement? _tooltipInnerElement;
  StreamSubscription<html.MouseEvent>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;
  Timer? _showTimer;
  Timer? _hideTimer;
  Timer? _shownTimer;

  bool _enabled = true;
  bool _visible = false;
  bool _hoverActive = false;
  bool _focusActive = false;
  bool _clickActive = false;
  String _content = '';
  late final String _tooltipId = 'li-tooltip-${_nextId++}';

  /// Tooltip text content.
  @Input()
  set text(String? value) {
    _content = value ?? '';
    _syncContent();
  }

  String get text => _content;

  /// Alias for Bootstrap-like title configuration.
  @Input()
  set title(String? value) {
    text = value;
  }

  /// Tooltip placement: top, right, bottom, left, or auto.
  @Input()
  String placement = 'top';

  /// Trigger list separated by spaces. Example: hover focus, click, manual.
  @Input()
  String trigger = 'hover focus';

  /// Allows HTML content inside the tooltip body.
  @Input('html')
  bool allowHtml = false;

  /// Enables Bootstrap fade transition styles.
  @Input()
  bool animation = true;

  /// Delay applied to both show and hide when specific delays are not set.
  @Input()
  int delayMs = 0;

  /// Delay before showing the tooltip.
  @Input()
  int? showDelayMs;

  /// Delay before hiding the tooltip.
  @Input()
  int? hideDelayMs;

  /// Extra classes applied to the floating tooltip element.
  @Input()
  String? tooltipClass;

  @Input()
  set disabled(bool value) {
    _enabled = !value;
    if (!_enabled) {
      hide();
    }
  }

  bool get disabled => !_enabled;

  @Output('show')
  Stream<void> get showEvent => _showController.stream;

  @Output('shown')
  Stream<void> get shownEvent => _shownController.stream;

  @Output('hide')
  Stream<void> get hideEvent => _hideController.stream;

  @Output('hidden')
  Stream<void> get hiddenEvent => _hiddenController.stream;

  @HostBinding('class.li-tooltip-host')
  bool hostTooltipClass = true;

  bool get isVisible => _visible;

  bool get _hasContent => _content.trim().isNotEmpty;

  Set<String> get _triggers {
    final parsed = trigger
        .split(RegExp(r'[\s,]+'))
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty && _supportedTriggers.contains(value))
        .toSet();
    return parsed.isEmpty ? <String>{'hover', 'focus'} : parsed;
  }

  bool get _isManual => _triggers.contains('manual');

  int get _resolvedShowDelayMs => showDelayMs ?? delayMs;

  int get _resolvedHideDelayMs => hideDelayMs ?? delayMs;

  @HostListener('mouseenter')
  void onMouseEnter() {
    if (_isManual || !_triggers.contains('hover')) {
      return;
    }

    _hoverActive = true;
    show();
  }

  @HostListener('mouseleave')
  void onMouseLeave() {
    if (_isManual || !_triggers.contains('hover')) {
      return;
    }

    _hoverActive = false;
    _hideIfInactive();
  }

  @HostListener('focusin', ['\$event'])
  void onFocusIn(html.Event event) {
    if (_isManual || !_triggers.contains('focus')) {
      return;
    }

    _focusActive = true;
    show();
  }

  @HostListener('focusout', ['\$event'])
  void onFocusOut(html.FocusEvent event) {
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

  @HostListener('click', ['\$event'])
  void onClick(html.MouseEvent event) {
    if (_isManual || !_triggers.contains('click')) {
      return;
    }

    event.preventDefault();
    _clickActive = !_clickActive;
    if (_clickActive) {
      show();
      return;
    }

    _hideIfInactive(force: true);
  }

  void show() {
    if (!_enabled || !_hasContent) {
      return;
    }

    _cancelHideTimer();

    if (_visible) {
      _overlay?.update();
      return;
    }

    _cancelShowTimer();
    final delay = _resolvedShowDelayMs;
    if (delay > 0) {
      _showTimer = Timer(Duration(milliseconds: delay), _showNow);
      return;
    }

    _showNow();
  }

  void hide() {
    _cancelShowTimer();

    if (!_visible) {
      return;
    }

    _cancelHideTimer();
    final delay = _resolvedHideDelayMs;
    if (delay > 0) {
      _hideTimer = Timer(Duration(milliseconds: delay), _hideNow);
      return;
    }

    _hideNow();
  }

  void toggle() {
    if (_visible) {
      hide();
      return;
    }

    show();
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

  void _hideNow() {
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

    if (animation) {
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
      return;
    }

    final tooltipElement = html.DivElement()
      ..id = _tooltipId
      ..classes.add('tooltip')
      ..setAttribute('role', 'tooltip')
      ..style.pointerEvents = 'none';

    if (animation) {
      tooltipElement.classes.add('fade');
    }

    final extraClasses = tooltipClass?.trim();
    if (extraClasses != null && extraClasses.isNotEmpty) {
      tooltipElement.classes.addAll(
        extraClasses
            .split(RegExp(r'\s+'))
            .where((className) => className.trim().isNotEmpty),
      );
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
    _syncContent();

    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: _hostElement,
      floatingElement: tooltipElement,
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
        offset: const PopperOffset(mainAxis: 8),
        arrowElement: tooltipArrowElement,
        arrowPadding: const PopperInsets.all(10),
        onLayout: _handleLayout,
      ),
    );
  }

  String get _resolvedPlacement {
    final normalized = placement.trim().toLowerCase();
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

    if (allowHtml) {
      // ignore: unsafe_html
      tooltipInnerElement.setInnerHtml(
        _content,
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
      return;
    }

    tooltipInnerElement.text = _content;
  }

  void _bindDocumentListeners() {
    _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
      if (event.key == 'Escape' || event.keyCode == 27) {
        _clickActive = false;
        _hoverActive = false;
        _focusActive = false;
        hide();
      }
    });

    if (_triggers.contains('click')) {
      _documentClickSubscription ??= html.document.onClick.listen((event) {
        final target = event.target;
        if (target is html.Element && !_hostElement.contains(target)) {
          _clickActive = false;
          _hideIfInactive(force: true);
        }
      });
    }
  }

  void _hideIfInactive({bool force = false}) {
    if (!force && (_hoverActive || _focusActive || _clickActive)) {
      return;
    }

    hide();
  }

  void _destroyTooltip() {
    final hadTooltip = _tooltipElement != null || _overlay != null;
    _overlay?.stopAutoUpdate();
    _overlay?.dispose();
    _overlay = null;
    _tooltipElement = null;
    _tooltipInnerElement = null;
    _unbindDocumentListeners();
    if (hadTooltip) {
      _hiddenController.add(null);
    }
  }

  void _resetInteractionState() {
    _hoverActive = false;
    _focusActive = false;
    _clickActive = false;
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