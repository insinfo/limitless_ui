import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

const liOffcanvasDirectives = <Object>[
  LiOffcanvasComponent,
  LiOffcanvasHeaderDirective,
  LiOffcanvasFooterDirective,
];

enum LiOffcanvasDismissReason {
  backdrop,
  escape,
  programmatic,
}

typedef LiOffcanvasBeforeDismiss = FutureOr<bool> Function(
  LiOffcanvasDismissReason reason,
);

class LiOffcanvasRef {
  LiOffcanvasRef._(this._component, this.id);

  final LiOffcanvasComponent _component;
  final String? id;

  bool get isOpen => _component.isOpen;

  Stream<void> get opened => _component.onOpen;

  Stream<void> get closed => _component.onClose;

  Stream<void> get shown => _component.onShown;

  Stream<void> get hidden => _component.onHidden;

  Stream<LiOffcanvasDismissReason> get dismissed => _component.onDismiss;

  void open() => _component.open();

  void close() => _component.close();

  Future<void> dismiss([
    LiOffcanvasDismissReason reason = LiOffcanvasDismissReason.programmatic,
  ]) {
    return _component.dismiss(reason);
  }

  void toggle() => _component.toggle();
}

@Injectable()
class LiOffcanvasService {
  static final Map<String, LiOffcanvasComponent> _componentsById =
      <String, LiOffcanvasComponent>{};
  static final Map<LiOffcanvasComponent, LiOffcanvasRef> _refsByComponent =
      <LiOffcanvasComponent, LiOffcanvasRef>{};

  LiOffcanvasRef open(Object target) {
    final offcanvasRef = ref(target);
    offcanvasRef.open();
    return offcanvasRef;
  }

  LiOffcanvasRef ref(Object target) {
    if (target is LiOffcanvasRef) {
      return target;
    }

    if (target is LiOffcanvasComponent) {
      return _refForComponent(target);
    }

    if (target is String) {
      final component = _componentsById[target];
      if (component == null) {
        throw StateError('No li-offcanvas registered with id "$target".');
      }
      return _refForComponent(component);
    }

    throw ArgumentError.value(
      target,
      'target',
      'Use a String offcanvasId, LiOffcanvasComponent, or LiOffcanvasRef.',
    );
  }

  bool has(String id) => _componentsById.containsKey(id);

  static void registerComponent(String id, LiOffcanvasComponent component) {
    _componentsById[id] = component;
  }

  static void unregisterComponent(String id, LiOffcanvasComponent component) {
    final registered = _componentsById[id];
    if (identical(registered, component)) {
      _componentsById.remove(id);
    }
  }

  static LiOffcanvasRef _refForComponent(LiOffcanvasComponent component) {
    return _refsByComponent.putIfAbsent(
      component,
      () => LiOffcanvasRef._(component, component.offcanvasId),
    );
  }

  static void unregisterRef(LiOffcanvasComponent component) {
    _refsByComponent.remove(component);
  }
}

@Directive(selector: '[liOffcanvasHeader]')
class LiOffcanvasHeaderDirective {}

@Directive(selector: '[liOffcanvasFooter]')
class LiOffcanvasFooterDirective {}

@Component(
  selector: 'li-offcanvas',
  templateUrl: 'offcanvas_component.html',
  styleUrls: ['offcanvas_component.css'],
  directives: [coreDirectives],
  encapsulation: ViewEncapsulation.none,
)
class LiOffcanvasComponent
  implements OnInit, AfterChanges, AfterViewChecked, OnDestroy {
  LiOffcanvasComponent(this.rootElement, this._changeDetectorRef);

  static const Duration _transitionDuration = Duration(milliseconds: 300);

  static int _bodyScrollLockCount = 0;
  static String? _previousBodyOverflow;

  final html.Element rootElement;
  final ChangeDetectorRef _changeDetectorRef;

  final _onOpenCtrl = StreamController<void>.broadcast();
  final _onCloseCtrl = StreamController<void>.broadcast();
  final _onShownCtrl = StreamController<void>.broadcast();
  final _onHiddenCtrl = StreamController<void>.broadcast();
  final _onDismissCtrl = StreamController<LiOffcanvasDismissReason>.broadcast();

  StreamSubscription<html.KeyboardEvent>? _keydownSubscription;
  Timer? _shownTimer;
  Timer? _hiddenTimer;
  html.Element? _previouslyFocusedElement;
  bool _lockedBodyScroll = false;
  bool _pendingFocus = false;
  String? _registeredOffcanvasId;

  @Input()
  bool enableHeader = true;

  @Input()
  bool enableBackdrop = true;

  @Input()
  bool closeOnBackdropClick = true;

  @Input()
  bool enableCloseBtn = true;

  @Input()
  bool keyboard = true;

  @Input()
  bool scroll = false;

  @Input()
  bool animation = true;

  @Input()
  bool lazyContent = false;

  @Input('start-open')
  bool startOpen = false;

  @Input('title-text')
  String titleText = '';

  @Input()
  String? offcanvasId;

  @Input()
  String position = 'end';

  @Input()
  String size = '';

  @Input()
  String? panelClass;

  @Input()
  String? backdropClass;

  @Input()
  String? headerClass;

  @Input()
  String? bodyClass;

  @Input()
  String? ariaLabelledBy;

  @Input()
  String? ariaDescribedBy;

  @Input()
  LiOffcanvasBeforeDismiss? beforeDismiss;

  bool isOpen = false;
  bool isRendered = false;

  @ContentChild(LiOffcanvasHeaderDirective)
  LiOffcanvasHeaderDirective? customHeader;

  @ViewChild('panel')
  html.DivElement? panelElement;

  bool get hasCustomHeader => customHeader != null;

  bool get shouldRenderContent => !lazyContent || isRendered;

  String get panelClasses {
    final classes = <String>['offcanvas', _positionClass];
    final sizeClass = _sizeClass;
    if (sizeClass != null) {
      classes.add(sizeClass);
    }
    if (isOpen) {
      classes.add('show');
    }
    if (!animation) {
      classes.add('li-offcanvas-no-animation');
    }
    final extraClasses = panelClass?.trim();
    if (extraClasses != null && extraClasses.isNotEmpty) {
      classes.addAll(extraClasses.split(RegExp(r'\s+')));
    }
    return classes.join(' ');
  }

  String get backdropClasses {
    final classes = <String>['li-offcanvas-backdrop'];
    if (animation) {
      classes.add('fade');
    }
    if (isOpen) {
      classes.add('show');
    }
    final extraClasses = backdropClass?.trim();
    if (extraClasses != null && extraClasses.isNotEmpty) {
      classes.addAll(extraClasses.split(RegExp(r'\s+')));
    }
    return classes.join(' ');
  }

  String get defaultHeaderClasses {
    final classes = <String>['offcanvas-header'];
    final extraClasses = headerClass?.trim();
    if (extraClasses != null && extraClasses.isNotEmpty) {
      classes.addAll(extraClasses.split(RegExp(r'\s+')));
    }
    return classes.join(' ');
  }

  String get defaultBodyClasses {
    final classes = <String>['offcanvas-body'];
    final extraClasses = bodyClass?.trim();
    if (extraClasses != null && extraClasses.isNotEmpty) {
      classes.addAll(extraClasses.split(RegExp(r'\s+')));
    }
    return classes.join(' ');
  }

  Duration get _effectiveTransitionDuration =>
      animation ? _transitionDuration : Duration.zero;

  String get _positionClass {
    switch (position) {
      case 'start':
        return 'offcanvas-start';
      case 'top':
        return 'offcanvas-top';
      case 'bottom':
        return 'offcanvas-bottom';
      case 'end':
      default:
        return 'offcanvas-end';
    }
  }

  String? get _sizeClass {
    final normalizedSize = size.trim();
    if (normalizedSize.isEmpty) {
      return null;
    }
    return 'li-offcanvas-size-$normalizedSize';
  }

  @Output('open')
  Stream<void> get onOpen => _onOpenCtrl.stream;

  @Output('close')
  Stream<void> get onClose => _onCloseCtrl.stream;

  @Output('shown')
  Stream<void> get onShown => _onShownCtrl.stream;

  @Output('hidden')
  Stream<void> get onHidden => _onHiddenCtrl.stream;

  @Output('dismiss')
  Stream<LiOffcanvasDismissReason> get onDismiss => _onDismissCtrl.stream;

  @override
  void ngOnInit() {
    html.document.body?.append(rootElement);
    _syncServiceRegistration();

    if (startOpen) {
      Future<void>.microtask(open);
    }
  }

  @override
  void ngAfterChanges() {
    _syncServiceRegistration();
  }

  @override
  void ngAfterViewChecked() {
    if (!_pendingFocus || !isOpen) {
      return;
    }

    _pendingFocus = false;
    Future<void>.microtask(_focusPanel);
  }

  void open() {
    if (isOpen) {
      return;
    }

    _hiddenTimer?.cancel();
    _previouslyFocusedElement = html.document.activeElement;
    isRendered = true;
    isOpen = true;
    _pendingFocus = true;
    _lockBodyScrollIfNeeded();
    _bindKeyboardListener();
    _changeDetectorRef.markForCheck();
    _onOpenCtrl.add(null);
    _shownTimer?.cancel();
    _shownTimer = Timer(_effectiveTransitionDuration, () {
      if (isOpen) {
        _onShownCtrl.add(null);
      }
    });
  }

  void toggle() {
    if (isOpen) {
      close();
      return;
    }
    open();
  }

  void close() {
    _hide();
    _onCloseCtrl.add(null);
  }

  Future<void> dismiss([
    LiOffcanvasDismissReason reason = LiOffcanvasDismissReason.programmatic,
  ]) async {
    if (!await _canDismiss(reason)) {
      return;
    }
    _hide();
    _onDismissCtrl.add(reason);
  }

  void stopPropagation(html.Event event) {
    event.stopPropagation();
  }

  void onBackdropMouseDown(html.MouseEvent event) {
    if (!enableBackdrop || !closeOnBackdropClick) {
      return;
    }
    event.stopPropagation();
    dismiss(LiOffcanvasDismissReason.backdrop);
  }

  Future<bool> _canDismiss(LiOffcanvasDismissReason reason) async {
    final dismissGuard = beforeDismiss;
    if (dismissGuard == null) {
      return true;
    }

    final result = dismissGuard(reason);
    if (result is Future<bool>) {
      return await result;
    }

    return result;
  }

  void _hide() {
    if (!isRendered || !isOpen) {
      return;
    }

    _shownTimer?.cancel();
    _pendingFocus = false;
    isOpen = false;
    _unbindKeyboardListener();
    _changeDetectorRef.markForCheck();

    _hiddenTimer?.cancel();
    _hiddenTimer = Timer(_effectiveTransitionDuration, () {
      isRendered = false;
      _unlockBodyScrollIfNeeded();
      _restoreFocus();
      _changeDetectorRef.markForCheck();
      _onHiddenCtrl.add(null);
    });
  }

  void _bindKeyboardListener() {
    _keydownSubscription?.cancel();
    _keydownSubscription = html.document.onKeyDown.listen((event) {
      if (!isOpen || !keyboard || event.key != 'Escape') {
        return;
      }
      event.preventDefault();
      dismiss(LiOffcanvasDismissReason.escape);
    });
  }

  void _unbindKeyboardListener() {
    _keydownSubscription?.cancel();
    _keydownSubscription = null;
  }

  void _focusPanel() {
    final panel = panelElement;
    if (panel == null || !isOpen) {
      return;
    }

    final focusTarget = panel.querySelector(
            '[liOffcanvasAutofocus], [ngbAutofocus], [autofocus]') ??
        _firstFocusable(panel) ??
        panel;

    if (focusTarget is html.HtmlElement) {
      focusTarget.focus();
    }
  }

  html.HtmlElement? _firstFocusable(html.Element root) {
    const selector =
        'a[href], button:not([disabled]), textarea:not([disabled]), '
        'input:not([disabled]), select:not([disabled]), '
        '[tabindex]:not([tabindex="-1"])';

    for (final candidate in root.querySelectorAll(selector)) {
      if (candidate is! html.HtmlElement) {
        continue;
      }
      if (candidate.hidden || candidate.tabIndex == -1) {
        continue;
      }
      return candidate;
    }

    return null;
  }

  void _restoreFocus() {
    final previous = _previouslyFocusedElement;
    _previouslyFocusedElement = null;
    if (previous is html.HtmlElement && previous.isConnected == true) {
      previous.focus();
    }
  }

  void _lockBodyScrollIfNeeded() {
    if (scroll || _lockedBodyScroll) {
      return;
    }

    final body = html.document.body;
    if (body == null) {
      return;
    }

    if (_bodyScrollLockCount == 0) {
      _previousBodyOverflow = body.style.overflow;
      body.classes.add('offcanvas-open');
      body.style.overflow = 'hidden';
    }

    _bodyScrollLockCount++;
    _lockedBodyScroll = true;
  }

  void _unlockBodyScrollIfNeeded() {
    if (!_lockedBodyScroll) {
      return;
    }

    final body = html.document.body;
    _bodyScrollLockCount = (_bodyScrollLockCount - 1).clamp(0, 1 << 20);

    if (body != null && _bodyScrollLockCount == 0) {
      body.classes.remove('offcanvas-open');
      body.style.overflow = _previousBodyOverflow ?? '';
      _previousBodyOverflow = null;
    }

    _lockedBodyScroll = false;
  }

  @override
  void ngOnDestroy() {
    _shownTimer?.cancel();
    _hiddenTimer?.cancel();
    _unbindKeyboardListener();
    _unlockBodyScrollIfNeeded();
    final registeredId = _registeredOffcanvasId;
    if (registeredId != null) {
      LiOffcanvasService.unregisterComponent(registeredId, this);
      _registeredOffcanvasId = null;
    }
    LiOffcanvasService.unregisterRef(this);
    rootElement.remove();
    _onOpenCtrl.close();
    _onCloseCtrl.close();
    _onShownCtrl.close();
    _onHiddenCtrl.close();
    _onDismissCtrl.close();
  }

  void _syncServiceRegistration() {
    final normalizedId = offcanvasId?.trim();
    final nextId =
        (normalizedId == null || normalizedId.isEmpty) ? null : normalizedId;
    if (_registeredOffcanvasId == nextId) {
      return;
    }

    final previousId = _registeredOffcanvasId;
    if (previousId != null) {
      LiOffcanvasService.unregisterComponent(previousId, this);
    }

    if (nextId != null) {
      LiOffcanvasService.registerComponent(nextId, this);
    }

    _registeredOffcanvasId = nextId;
  }
}
