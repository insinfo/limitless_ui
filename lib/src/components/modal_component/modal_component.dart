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
)
class LiModalComponent implements OnInit, OnDestroy {
  LiModalComponent(this.rootElement, this._changeDetectorRef);

  final Element rootElement;
  final ChangeDetectorRef _changeDetectorRef;
  bool _isOpen = false;

  @Input()
  bool enableHeader = true;

  /// Adds the `modal-body` class to the body container.
  @Input()
  bool enableModalBodyClass = true;

  @Input()
  bool enableBackdrop = true;

  @Input()
  bool enableRoundedCorners = true;

  @Input()
  bool closeOnBackdropClick = true;

  @Input()
  bool enableCloseBtn = true;

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
  String size = 'default';

  @Input()
  String headerColor = 'primary';

  @Input('title-text')
  String titleText = '';

  @Input('start-open')
  bool startOpen = false;

  @Input()
  bool enableShadow = false;

  @Input()
  bool fullScreenOnMobile = false;

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

  @override
  void ngOnInit() {
    document.body?.append(rootElement);

    rootElement.addEventListener('mousedown', (_) {
      if (closeOnBackdropClick) {
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

  /// Opens the modal.
  void open() {
    if (isOpen) {
      return;
    }

    _isOpen = true;
    _changeDetectorRef.markForCheck();

    backdropDiv.remove();
    backdropDiv = DivElement()
      ..style.position = 'fixed'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100vw'
      ..style.height = '100vh'
      ..style.backgroundColor = '#000'
      ..style.zIndex = '1199'
      ..style.opacity = '.5';

    if (enableBackdrop) {
      document.body?.append(backdropDiv);
    }

    modalRootElement?.style.display = 'block';
    modalRootElement?.attributes['data-status'] = 'open';
    if (enableModalBodyClass) {
      document.body?.classes.add('modal-open');
    }
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
    backdropDiv.remove();
    modalRootElement?.style.display = 'none';
    modalRootElement?.attributes['data-status'] = 'close';
    if (enableModalBodyClass) {
      document.body?.classes.remove('modal-open');
    }
    showError = false;
    _changeDetectorRef.markForCheck();
    _onCloseCtrl.add(null);
  }

  @override
  void ngOnDestroy() {
    rootElement.remove();
    backdropDiv.remove();
    _onCloseCtrl.close();
  }
}
