import 'dart:js_interop';
import 'dart:async';
import 'package:limitless_ui/web_compat.dart';

import 'package:ngx_dart/angular.dart';

/// Generic modal component for AngularDart applications.
///
/// Use the `li-modal` selector with projected content to render a reusable
/// dialog container.
@Component(
  selector: 'li-modal',
  templateUrl: 'modal_component.html',
  styleUrls: ['modal_component.css'],
  directives: [
    coreDirectives,
  ],
  encapsulation: ViewEncapsulation.none,
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiModalComponent implements OnInit, OnDestroy {
  static const int _baseZIndex = 1200;
  static const int _zIndexStep = 10;
  static int _nextTitleId = 0;
  static final List<LiModalComponent> _openModalStack = <LiModalComponent>[];

  LiModalComponent(this.rootElement, this._changeDetectorRef);

  final Element rootElement;
  final ChangeDetectorRef _changeDetectorRef;
  final String _modalTitleId = 'li-modal-title-${_nextTitleId++}';
  bool _isOpen = false;
  int _stackZIndex = _baseZIndex;
  StreamSubscription<KeyboardEvent>? _escSubscription;
  Element? _previouslyFocusedElement;

  @Input()
  bool enableHeader = true;

  /// Adds the `modal-body` class to the body container.
  @Input()
  bool enableModalBodyClass = true;

  /// Adds the internal body layout class without Bootstrap body padding.
  ///
  /// Enable this when [enableModalBodyClass] is false but projected
  /// content still needs to participate in fullscreen modal flex/scroll layout.
  @Input()
  bool enableModalBodyLayout = false;

  /// Extra classes applied to the modal body container.
  @Input()
  String bodyClass = '';

  @Input()
  bool lockBodyScroll = true;

  @Input()
  bool enableBackdrop = true;

  @Input()
  bool enableRoundedCorners = true;

  @Input()
  bool closeOnBackdropClick = true;

  @Input()
  bool enableCloseBtn = true;

  @Input()
  bool closeOnEscape = true;

  @Input()
  bool compactHeader = false;

  @Input()
  bool smallHeader = false;

  @Input()
  bool showError = false;

  @Input()
  String errorMessage = '';

  void showErrorMessage([String? errorMsg]) {
    showError = true;
    if (errorMsg != null) {
      errorMessage = errorMsg;
    }
  }

  void hideErrorMessage() {
    showError = false;
  }

  @Input()
  bool verticalCenter = false;

  @Input()

  /// When `true`, applies the scrollable dialog class
  /// (`modal-dialog-scrollable`).
  ///
  /// In dialogs that render components with their own scroll behavior such as
  /// datatables, this may interfere with the expected internal scrolling.
  bool dialogScrollable = false;

  @Input()

  /// Supported values include `default`, `modal-xs`, `modal-sm`, `large`,
  /// `xtra-large`, `xx-large`, `xxx-large`, `fluid`, and `modal-full`.
  ///
  /// The `xx-large`, `xxx-large`, and `fluid` sizes are wider intermediate
  /// steps between the classic `modal-xl` width and the fullscreen shell.
  String size = 'default';

  @Input()
  String headerColor = 'primary';

  @Input()
  String? customWidth;

  @Input()
  String? customHeight;

  @Input()
  String? ariaLabel;

  @Input()
  String? ariaLabelledBy;

  @Input('title-text')
  String titleText = '';

  @Input('start-open')
  bool startOpen = false;

  @Input()
  bool enableShadow = false;

  @Input()
  bool fullScreenOnMobile = false;

  /// When `true`, `size="modal-full"` also removes rounded modal chrome so
  /// the dialog behaves like a fullscreen shell instead of a floating card.
  @Input()
  bool fullScreenShell = false;

  /// When `true`, the projected body content is only rendered while the modal
  /// is open.
  ///
  /// Use this for heavy content that should not be created eagerly in the DOM.
  @Input()
  bool lazyContent = false;

  @Input()
  TemplateRef? contentTemplate;

  @Input()
  dynamic contentTemplateContext;

  @Input()
  String contentHostClass = '';

  @ViewChild('modalRootElement')
  DivElement? modalRootElement;

  @ViewChild('modalContent')
  DivElement? modalContent;

  @ViewChild('modalHeader')
  DivElement? modalHeader;

  @ViewChild('modalBody')
  DivElement? modalBody;

  @ViewChild('modalTitleElement')
  HtmlElement? modalTitleElement;

  @override
  void ngOnInit() {
    document.body?.append(rootElement);

    rootElement.addEventListener('mousedown', _handleRootMouseDown.toJS);

    if (startOpen) {
      Future<void>.microtask(open);
    }
  }

  void stopPropagation(Event event) {
    event.stopPropagation();
  }

  void _handleRootMouseDown(Event event) {
    if (!closeOnBackdropClick || !_isTopmostModal) {
      return;
    }

    final target = event.target;
    if (target != modalRootElement) {
      return;
    }

    if (event.isA<MouseEvent>() &&
        _isScrollbarInteraction(event as MouseEvent, target)) {
      return;
    }

    close();
  }

  bool _isScrollbarInteraction(MouseEvent event, EventTarget? target) {
    if (!(target?.isA<Element>() ?? false)) {
      return false;
    }

    final element = target as Element;
    final rect = element.getBoundingClientRect();
    final offsetX = event.client.x - rect.left;
    final offsetY = event.client.y - rect.top;
    final style = element.getComputedStyle();
    final hasVerticalScrollbar = element.scrollHeight > element.clientHeight ||
        element.offsetWidth > element.clientWidth ||
        style.overflowY == 'auto' ||
        style.overflowY == 'scroll';
    final hasHorizontalScrollbar = element.scrollWidth > element.clientWidth ||
        element.offsetHeight > element.clientHeight ||
        style.overflowX == 'auto' ||
        style.overflowX == 'scroll';

    return hasVerticalScrollbar && offsetX >= element.clientWidth ||
        hasHorizontalScrollbar && offsetY >= element.clientHeight;
  }

  DivElement backdropDiv = DivElement();

  bool get shouldRenderContent => !lazyContent || _isOpen;

  bool get hasTitleText => titleText.trim().isNotEmpty;

  String? get resolvedCustomWidth {
    final value = customWidth?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String? get resolvedCustomHeight {
    final value = customHeight?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  bool get hasCustomWidth => resolvedCustomWidth != null;

  bool get hasCustomHeight => resolvedCustomHeight != null;

  bool get usesFullScreenShell => size == 'modal-full' && fullScreenShell;

  String get modalTitleId => _modalTitleId;

  String get modalAutomationValue => _modalTitleId;

  bool get _isTopmostModal =>
      _openModalStack.isNotEmpty && identical(_openModalStack.last, this);

  String? get resolvedAriaLabelledBy {
    final customValue = ariaLabelledBy?.trim();
    if (customValue != null && customValue.isNotEmpty) {
      return customValue;
    }

    return hasTitleText ? modalTitleId : null;
  }

  String? get resolvedAriaLabel {
    final customValue = ariaLabel?.trim();
    if (customValue != null && customValue.isNotEmpty) {
      return customValue;
    }

    return resolvedAriaLabelledBy == null && hasTitleText
        ? titleText.trim()
        : null;
  }

  String get resolvedBodyClass {
    final useInternalBodyLayout =
        !enableModalBodyClass && enableModalBodyLayout;
    final hasExtraBodyClass = bodyClass.trim().isNotEmpty;
    final usePositionContext =
        enableModalBodyClass || useInternalBodyLayout || hasExtraBodyClass;

    return _joinClasses(<String>[
      enableModalBodyClass ? 'modal-body' : '',
      useInternalBodyLayout ? 'li-modal-body' : '',
      usePositionContext ? 'position-relative' : '',
      bodyClass,
    ]);
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  bool _isEscapeKey(KeyboardEvent event) {
    return event.key == 'Escape' || event.keyCode == KeyCode.ESC;
  }

  void _bindEscapeListener() {
    _escSubscription?.cancel();
    _escSubscription = document.onKeyDown.listen((KeyboardEvent event) {
      if (!_isEscapeKey(event) || !_isTopmostModal || !closeOnEscape) {
        return;
      }

      if (!closeOnBackdropClick) {
        return;
      }

      event.preventDefault();
      close();
    });
  }

  void _unbindEscapeListener() {
    _escSubscription?.cancel();
    _escSubscription = null;
  }

  void _rememberFocus() {
    _previouslyFocusedElement = document.activeElement;
  }

  void _restoreFocus() {
    final previousElement = _previouslyFocusedElement;
    if ((previousElement?.isA<HtmlElement>() ?? false) &&
        document.body?.contains(previousElement) == true) {
      previousElement!.focus();
    }
    _previouslyFocusedElement = null;
  }

  void _focusModal() {
    Future<void>.microtask(() {
      final modalElement = modalRootElement;
      if (_isOpen && modalElement != null) {
        modalElement.focus();
      }
    });
  }

  static void _syncBodyScrollLock() {
    final shouldLock = _openModalStack.any((modal) => modal.lockBodyScroll);
    if (shouldLock) {
      document.body?.classes.add('modal-open');
      return;
    }

    document.body?.classes.remove('modal-open');
  }

  void _applyStackZIndex(int zIndex) {
    _stackZIndex = zIndex;
    modalRootElement?.style.zIndex = '$zIndex';
    backdropDiv.style.zIndex = '${zIndex - 1}';
  }

  static void _reflowOpenModalStack() {
    for (var index = 0; index < _openModalStack.length; index++) {
      final modal = _openModalStack[index];
      modal._applyStackZIndex(_baseZIndex + (index * _zIndexStep));
    }
    _syncBodyScrollLock();
  }

  void _pushToModalStack() {
    _openModalStack.remove(this);
    _openModalStack.add(this);
    _reflowOpenModalStack();
  }

  void _removeFromModalStack() {
    _openModalStack.remove(this);
    _reflowOpenModalStack();
  }

  /// Opens the modal.
  void open() {
    if (isOpen) {
      return;
    }

    _rememberFocus();
    _isOpen = true;
    _pushToModalStack();
    _changeDetectorRef.markForCheck();

    backdropDiv.remove();
    backdropDiv = DivElement()
      ..classes.add('li-modal-backdrop')
      ..setAttribute('data-label', 'li_mdl_backdrop')
      ..setAttribute('data-value', modalAutomationValue)
      ..setAttribute('data-open', 'true')
      ..style.position = 'fixed'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100vw'
      ..style.height = '100vh'
      ..style.backgroundColor = '#000'
      ..style.opacity = '.5';

    _applyStackZIndex(_stackZIndex);

    if (enableBackdrop) {
      document.body?.append(backdropDiv);
    }

    modalRootElement?.style.display = 'block';
    modalRootElement?.setAttribute('data-status', 'open');
    modalRootElement?.setAttribute('data-open', 'true');
    _syncBodyScrollLock();
    _bindEscapeListener();
    _focusModal();
    _onOpenCtrl.add(null);
  }

  bool get isOpen => _isOpen;

  final _onOpenCtrl = StreamController<void>.broadcast();

  /// Emitted after the modal opens, mirroring [onClose].
  ///
  /// With [lazyContent] the projected content only exists once the modal is
  /// open, so this is the earliest point a consumer can load data for it.
  @Output('open')
  Stream<void> get onOpen => _onOpenCtrl.stream;

  final _onCloseCtrl = StreamController<void>.broadcast();

  @Output('close')
  Stream<void> get onClose => _onCloseCtrl.stream;

  /// Closes the modal.
  void close() {
    if (!isOpen) {
      return;
    }

    _isOpen = false;
    _unbindEscapeListener();
    _removeFromModalStack();
    backdropDiv.remove();
    modalRootElement?.style.display = 'none';
    modalRootElement?.setAttribute('data-status', 'close');
    modalRootElement?.setAttribute('data-open', 'false');
    showError = false;
    _changeDetectorRef.markForCheck();
    _restoreFocus();
    _onCloseCtrl.add(null);
  }

  @override
  void ngOnDestroy() {
    _unbindEscapeListener();
    _removeFromModalStack();
    rootElement.remove();
    backdropDiv.remove();
    _onOpenCtrl.close();
    _onCloseCtrl.close();
  }
}
