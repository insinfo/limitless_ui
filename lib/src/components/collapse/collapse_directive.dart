import 'dart:js_interop';
import 'dart:async';
import 'package:web/web.dart' as web;

import '../../web_support/zone_dom_callbacks.dart';

import 'package:ngx_dart/angular.dart';

import 'collapse_config.dart';

const liCollapseDirectives = <Object>[
  LiCollapseDirective,
  LiCollapseToggleDirective,
];

/// Controller that applies Bootstrap/Limitless collapse classes and transitions.
class LiCollapseController implements OnDestroy {
  LiCollapseController(this._element);

  static const Duration _transitionDuration = Duration(milliseconds: 300);

  final web.HTMLElement _element;
  final StreamController<void> _shownController =
      StreamController<void>.broadcast();
  final StreamController<void> _hiddenController =
      StreamController<void>.broadcast();

  StreamSubscription<web.Event>? _transitionSubscription;
  Timer? _transitionTimer;

  bool _animation = true;
  bool _horizontal = false;
  bool _collapsed = true;
  bool _collapsing = false;
  bool _initialized = false;

  Stream<void> get shown => _shownController.stream;
  Stream<void> get hidden => _hiddenController.stream;
  bool get collapsed => _collapsed;
  bool get isTransitioning => _collapsing;

  void initialize({
    required bool collapsed,
    required bool animation,
    required bool horizontal,
  }) {
    _collapsed = collapsed;
    _animation = animation;
    _horizontal = horizontal;
    _initialized = true;
    _applyStaticState();
  }

  void updateOptions({
    required bool animation,
    required bool horizontal,
  }) {
    _animation = animation;
    _horizontal = horizontal;
    if (!_collapsing && _initialized) {
      _applyStaticState();
    }
  }

  void setCollapsed(bool collapsed) {
    if (!_initialized) {
      initialize(
        collapsed: collapsed,
        animation: _animation,
        horizontal: _horizontal,
      );
      return;
    }

    if (_collapsed == collapsed && !_collapsing) {
      return;
    }

    if (!_animation) {
      _cancelPendingTransition();
      _collapsing = false;
      _collapsed = collapsed;
      _applyStaticState();
      _emitSettledEvent();
      return;
    }

    if (collapsed) {
      _startCollapse();
      return;
    }

    _startExpand();
  }

  @override
  void ngOnDestroy() {
    _cancelPendingTransition();
    _shownController.close();
    _hiddenController.close();
  }

  void _startExpand() {
    _cancelPendingTransition();
    _collapsed = false;
    _collapsing = true;

    _element.classList
      ..remove('collapse')
      ..remove('show')
      ..add('collapsing');
    _syncOrientationClass(collapsing: true);
    _setDimension('0px');
    _forceReflow();

    final targetSize = _expandedSize;
    requestAnimationFrameInZone((_) {
      if (!_collapsing || _collapsed) {
        return;
      }
      _setDimension('${targetSize}px');
    });

    _awaitTransition(_finalizeExpand);
  }

  void _startCollapse() {
    _cancelPendingTransition();
    final currentSize = _currentSize;
    _collapsed = true;
    _collapsing = true;

    _element.classList
      ..remove('collapse')
      ..remove('show')
      ..add('collapsing');
    _syncOrientationClass(collapsing: true);
    _setDimension('${currentSize}px');
    _forceReflow();

    requestAnimationFrameInZone((_) {
      if (!_collapsing || !_collapsed) {
        return;
      }
      _setDimension('0px');
    });

    _awaitTransition(_finalizeCollapse);
  }

  void _awaitTransition(void Function() onComplete) {
    _transitionSubscription = _element.onTransitionEnd.listen((event) {
      if (event.target != _element) {
        return;
      }
      onComplete();
    });
    _transitionTimer = Timer(_transitionDuration, onComplete);
  }

  void _finalizeExpand() {
    if (!_collapsing || _collapsed) {
      return;
    }

    _cancelPendingTransition();
    _collapsing = false;
    _element.classList
      ..remove('collapsing')
      ..add('collapse')
      ..add('show');
    _syncOrientationClass(collapsing: false);
    _clearDimension();
    _shownController.add(null);
  }

  void _finalizeCollapse() {
    if (!_collapsing || !_collapsed) {
      return;
    }

    _cancelPendingTransition();
    _collapsing = false;
    _applyStaticState();
    _hiddenController.add(null);
  }

  void _emitSettledEvent() {
    if (_collapsed) {
      _hiddenController.add(null);
      return;
    }
    _shownController.add(null);
  }

  void _applyStaticState() {
    _element.classList
      ..remove('collapsing')
      ..add('collapse');
    _syncOrientationClass(collapsing: false);
    if (_collapsed) {
      _element.classList.remove('show');
    } else {
      _element.classList.add('show');
    }
    _clearDimension();
  }

  void _syncOrientationClass({required bool collapsing}) {
    if (_horizontal) {
      _element.classList.add('collapse-horizontal');
      return;
    }

    _element.classList.remove('collapse-horizontal');
    if (!collapsing) {
      _element.style.width = '';
    }
  }

  void _setDimension(String value) {
    if (_horizontal) {
      _element.style.width = value;
      _element.style.height = '';
      return;
    }

    _element.style.height = value;
    _element.style.width = '';
  }

  void _clearDimension() {
    _element.style
      ..height = ''
      ..width = '';
  }

  void _forceReflow() {
    _element.getBoundingClientRect();
  }

  num get _expandedSize =>
      _horizontal ? _element.scrollWidth : _element.scrollHeight;

  num get _currentSize {
    final rect = _element.getBoundingClientRect();
    final size = _horizontal ? rect.width : rect.height;
    if (size > 0) {
      return size;
    }
    return _expandedSize;
  }

  void _cancelPendingTransition() {
    _transitionSubscription?.cancel();
    _transitionTimer?.cancel();
    _transitionSubscription = null;
    _transitionTimer = null;
  }
}

/// Bootstrap/Limitless collapse directive similar to ng-bootstrap.
@Directive(
  selector: '[liCollapse]',
  exportAs: 'liCollapse',
)
class LiCollapseDirective implements OnInit, OnDestroy {
  LiCollapseDirective(
    this._element, [
    @Optional() LiCollapseConfig? config,
  ]) : _config = config ?? LiCollapseConfig() {
    _animation = _config.animation;
    _horizontal = _config.horizontal;
  }

  final web.HTMLElement _element;
  final LiCollapseConfig _config;
  final StreamController<bool> _collapseChangeController =
      StreamController<bool>.broadcast();
  late final LiCollapseController _controller = LiCollapseController(_element);

  bool _collapsed = true;
  bool _animation = true;
  bool _horizontal = false;

  @Input('liCollapse')
  set collapsed(bool value) {
    _setCollapsed(value, emitChange: false);
  }

  bool get collapsed => _collapsed;

  @Input()
  set animation(bool value) {
    _animation = value;
    _controller.updateOptions(animation: _animation, horizontal: _horizontal);
  }

  bool get animation => _animation;

  @Input()
  set horizontal(bool value) {
    _horizontal = value;
    _controller.updateOptions(animation: _animation, horizontal: _horizontal);
  }

  bool get horizontal => _horizontal;

  @Output('liCollapseChange')
  Stream<bool> get collapseChange => _collapseChangeController.stream;

  @Output()
  Stream<void> get shown => _controller.shown;

  @Output()
  Stream<void> get hidden => _controller.hidden;

  @override
  void ngOnInit() {
    _controller.initialize(
      collapsed: _collapsed,
      animation: _animation,
      horizontal: _horizontal,
    );
  }

  void toggle([bool? open]) {
    final nextCollapsed = open == null ? !_collapsed : !open;
    _setCollapsed(nextCollapsed);
  }

  void _setCollapsed(bool value, {bool emitChange = true}) {
    _collapsed = value;
    if (emitChange) {
      _collapseChangeController.add(_collapsed);
    }
    _controller.setCollapsed(_collapsed);
  }

  @override
  void ngOnDestroy() {
    _collapseChangeController.close();
    _controller.ngOnDestroy();
  }
}

/// Trigger directive for selector-based collapse toggles.
///
/// This covers the common Bootstrap pattern:
/// `<a href="#filters" data-bs-toggle="collapse">`.
/// Use `[liCollapseToggle]="'#filters'"` or omit the value when the host
/// already has an `href="#filters"` attribute.
@Directive(
  selector: '[liCollapseToggle]',
  exportAs: 'liCollapseToggle',
)
class LiCollapseToggleDirective implements OnInit, OnDestroy {
  LiCollapseToggleDirective(this._host);

  final web.HTMLElement _host;
  final StreamController<bool> _collapseChangeController =
      StreamController<bool>.broadcast();

  StreamSubscription<web.MouseEvent>? _clickSubscription;
  LiCollapseController? _controller;
  web.HTMLElement? _targetElement;
  bool _collapsed = true;
  bool _animation = true;
  bool _horizontal = false;

  @Input('liCollapseToggle')
  String? target;

  @Input('liCollapseToggleCollapsed')
  set collapsed(bool value) {
    _setCollapsed(value, emitChange: false);
  }

  bool get collapsed => _collapsed;

  @Input('liCollapseToggleAnimation')
  set animation(bool value) {
    _animation = value;
    _controller?.updateOptions(
      animation: _animation,
      horizontal: _horizontal,
    );
  }

  bool get animation => _animation;

  @Input('liCollapseToggleHorizontal')
  set horizontal(bool value) {
    _horizontal = value;
    _controller?.updateOptions(
      animation: _animation,
      horizontal: _horizontal,
    );
  }

  bool get horizontal => _horizontal;

  @Output('liCollapseToggleChange')
  Stream<bool> get collapseChange => _collapseChangeController.stream;

  @override
  void ngOnInit() {
    _clickSubscription = _host.onClick.listen(_handleClick);
    Timer.run(_connectToTarget);
    _syncHostState();
  }

  void toggle([bool? open]) {
    final nextCollapsed = open == null ? !_collapsed : !open;
    _setCollapsed(nextCollapsed);
  }

  void _handleClick(web.MouseEvent event) {
    event.preventDefault();
    toggle();
  }

  void _connectToTarget() {
    final resolvedTarget = _resolveTargetElement();
    if (resolvedTarget == null) {
      return;
    }

    _targetElement = resolvedTarget;
    _controller = LiCollapseController(resolvedTarget)
      ..initialize(
        collapsed: _collapsed,
        animation: _animation,
        horizontal: _horizontal,
      );
    _syncHostState();
  }

  web.HTMLElement? _resolveTargetElement() {
    final selector = _resolveTargetSelector();
    if (selector == null || selector.isEmpty) {
      return null;
    }

    if (selector.startsWith('#')) {
      final byId = web.document.getElementById(selector.substring(1));
      if ((byId?.isA<web.HTMLElement>() ?? false)) {
        return byId as web.HTMLElement;
      }
    }

    try {
      final bySelector = web.document.querySelector(selector);
      if ((bySelector?.isA<web.HTMLElement>() ?? false)) {
        return bySelector as web.HTMLElement;
      }
    } catch (_) {
      final byId = web.document.getElementById(selector);
      if ((byId?.isA<web.HTMLElement>() ?? false)) {
        return byId as web.HTMLElement;
      }
    }

    return null;
  }

  String? _resolveTargetSelector() {
    final configuredTarget = target?.trim();
    if (configuredTarget != null && configuredTarget.isNotEmpty) {
      return configuredTarget;
    }

    final hrefTarget = _host.getAttribute('href')?.trim();
    if (hrefTarget != null && hrefTarget.startsWith('#')) {
      return hrefTarget;
    }

    return null;
  }

  void _setCollapsed(bool value, {bool emitChange = true}) {
    _collapsed = value;
    _controller?.setCollapsed(_collapsed);
    _syncHostState();

    if (emitChange) {
      _collapseChangeController.add(_collapsed);
    }
  }

  void _syncHostState() {
    _host.setAttribute('aria-expanded', (!_collapsed).toString());

    final targetId = _targetElement?.id;
    if (targetId != null && targetId.isNotEmpty) {
      _host.setAttribute('aria-controls', targetId);
    }

    if (_collapsed) {
      _host.classList.add('collapsed');
      return;
    }

    _host.classList.remove('collapsed');
  }

  @override
  void ngOnDestroy() {
    _clickSubscription?.cancel();
    _controller?.ngOnDestroy();
    _collapseChangeController.close();
  }
}
