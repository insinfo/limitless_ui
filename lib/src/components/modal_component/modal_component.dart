import 'dart:async';
import 'dart:html';

import 'package:ngdart/angular.dart';

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

  /// When `true`, `size="modal-full"` also removes rounded chrome so the
  /// modal behaves like an app shell instead of a floating card.
  @Input()
  bool fullScreenChrome = false;

  /// When `true`, the projected body content is only rendered while the modal
  /// is open.
  ///
  /// Use this for heavy content that should not be created eagerly in the DOM.
  @Input()
  bool lazyContent = false;

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

    rootElement.addEventListener('mousedown', (_) {
      if (closeOnBackdropClick && _isTopmostModal) {
        close();
      }
    });

    if (startOpen) {
      Future<void>.microtask(open);
    }
  }

  void stopPropagation(event) {
    event.stopPropagation();
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

  bool get usesFullScreenChrome => size == 'modal-full' && fullScreenChrome;

  String get modalTitleId => _modalTitleId;

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
    if (previousElement is HtmlElement &&
        document.body?.contains(previousElement) == true) {
      previousElement.focus();
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
    modalRootElement?.attributes['data-status'] = 'open';
    _syncBodyScrollLock();
    _bindEscapeListener();
    _focusModal();
  }

  bool get isOpen => _isOpen;

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
    modalRootElement?.attributes['data-status'] = 'close';
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
    _onCloseCtrl.close();
  }
}
