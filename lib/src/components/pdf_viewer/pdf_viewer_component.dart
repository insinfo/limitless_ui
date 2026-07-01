import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:math';
import 'dart:typed_data';

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import '../dropdown_menu/dropdown_menu_component.dart';
import '../modal/modal_component.dart';
import 'pdf_viewer_browser_bridge.dart';
import 'pdf_viewer_document_controller.dart';
import 'pdf_viewer_page_view.dart';
import 'pdf_viewer_pdfjs_bridge.dart';
import 'pdf_viewer_rendering_queue.dart';
import 'pdf_viewer_visibility_controller.dart';
import 'pdfjs_bindings.dart';

typedef LiPdfViewerLinkSanitizer = String? Function(String rawUrl);

const liPdfViewerDirectives = <Object>[
  LiPdfViewerComponent,
  LiPdfViewerToolbarActionsDirective,
  LiPdfViewerSidePanelDirective,
];

typedef LiPdfViewerToolbarActionCallback = FutureOr<void> Function(
  LiPdfViewerToolbarActionEvent event,
);
typedef LiPdfViewerToolbarActionStringResolver = String Function(
  LiPdfViewerComponent viewer,
);
typedef LiPdfViewerToolbarActionBoolResolver = bool Function(
  LiPdfViewerComponent viewer,
);

enum LiPdfViewerToolbarActionPlacement {
  leading,
  trailing,
}

class LiPdfViewerToolbarAction {
  const LiPdfViewerToolbarAction({
    required this.id,
    required this.iconClass,
    this.label = '',
    this.title = '',
    this.buttonClass = '',
    this.placement = LiPdfViewerToolbarActionPlacement.trailing,
    this.showInToolbar = true,
    this.showInDesktopOverflowMenu = true,
    this.showInMobileMenu = true,
    this.disabled = false,
    this.active = false,
    this.labelBuilder,
    this.titleBuilder,
    this.iconClassBuilder,
    this.disabledBuilder,
    this.activeBuilder,
    this.onPressed,
  });

  final String id;
  final String iconClass;
  final String label;
  final String title;
  final String buttonClass;
  final LiPdfViewerToolbarActionPlacement placement;
  final bool showInToolbar;
  final bool showInDesktopOverflowMenu;
  final bool showInMobileMenu;
  final bool disabled;
  final bool active;
  final LiPdfViewerToolbarActionStringResolver? labelBuilder;
  final LiPdfViewerToolbarActionStringResolver? titleBuilder;
  final LiPdfViewerToolbarActionStringResolver? iconClassBuilder;
  final LiPdfViewerToolbarActionBoolResolver? disabledBuilder;
  final LiPdfViewerToolbarActionBoolResolver? activeBuilder;
  final LiPdfViewerToolbarActionCallback? onPressed;
}

class LiPdfViewerToolbarActionEvent {
  const LiPdfViewerToolbarActionEvent({
    required this.viewer,
    required this.action,
  });

  final LiPdfViewerComponent viewer;
  final LiPdfViewerToolbarAction action;
}

class LiPdfViewerTemplateContext {
  LiPdfViewerTemplateContext(this.viewer);

  final LiPdfViewerComponent viewer;

  int get currentPage => viewer.currentPage;

  int get totalPages => viewer.totalPages;

  double get scale => viewer.scale;

  String get zoomLabel => viewer.zoomPercentage;

  bool get sidePanelOpen => viewer.sidePanelOpen;

  bool get isPanModeEnabled => viewer.isPanModeEnabled;

  bool get isFullscreenActive => viewer.isFullscreenActive;

  PDFDocumentProxy? get pdfDocument => viewer.pdfDocument;

  void previousPage() => viewer.previousPage();

  void nextPage() => viewer.nextPage();

  void zoomIn() => viewer.zoomIn();

  void zoomOut() => viewer.zoomOut();

  void fitWidth() => viewer.fitContent();

  void rotate() => viewer.rotate();

  void openGoToPage() => viewer.openGoToPageModal();

  void togglePanMode() => viewer.togglePanMode();

  Future<void> toggleFullscreen() => viewer.toggleFullscreen();

  Future<void> download() => viewer.downloadDocument();

  Future<void> print() => viewer.printDocument();

  void openSidePanel() => viewer.openSidePanel();

  void closeSidePanel() => viewer.closeSidePanel();

  void toggleSidePanel() => viewer.toggleSidePanel();

  void scrollToPage(int pageNumber) => viewer.scrollToPage(pageNumber);

  Future<String> extractDocumentText({String pageSeparator = '\n\n'}) {
    return viewer.extractDocumentText(pageSeparator: pageSeparator);
  }

  Future<LiPdfViewerPageText> extractPageText(int pageNumber) {
    return viewer.extractPageText(pageNumber);
  }

  Future<LiPdfViewerPageInfo> getPageInfo(int pageNumber) {
    return viewer.getPageInfo(pageNumber);
  }
}

class LiPdfViewerPageTextItem {
  const LiPdfViewerPageTextItem({
    required this.text,
    this.direction = '',
    this.width = 0,
    this.height = 0,
    this.hasEndOfLine = false,
    this.fontName = '',
    this.transform = const <double>[],
  });

  final String text;
  final String direction;
  final double width;
  final double height;
  final bool hasEndOfLine;
  final String fontName;
  final List<double> transform;
}

class LiPdfViewerPageText {
  const LiPdfViewerPageText({
    required this.pageNumber,
    required this.text,
    this.language = '',
    this.items = const <LiPdfViewerPageTextItem>[],
  });

  final int pageNumber;
  final String text;
  final String language;
  final List<LiPdfViewerPageTextItem> items;
}

class LiPdfViewerPageInfo {
  const LiPdfViewerPageInfo({
    required this.pageNumber,
    required this.width,
    required this.height,
    required this.rotation,
    required this.currentScale,
    required this.isRendered,
    required this.hasTextLayer,
    required this.hasAnnotationLayer,
  });

  final int pageNumber;
  final double width;
  final double height;
  final int rotation;
  final double currentScale;
  final bool isRendered;
  final bool hasTextLayer;
  final bool hasAnnotationLayer;
}

@Directive(selector: 'template[liPdfViewerToolbarActions]')
class LiPdfViewerToolbarActionsDirective {
  LiPdfViewerToolbarActionsDirective(this.templateRef);

  final TemplateRef templateRef;
}

@Directive(selector: 'template[liPdfViewerSidePanel]')
class LiPdfViewerSidePanelDirective {
  LiPdfViewerSidePanelDirective(this.templateRef);

  final TemplateRef templateRef;
}

const defaultLiPdfViewerZoomOptions = <LiDropdownMenuOption>[
  LiDropdownMenuOption(value: 'auto', label: 'Automatic zoom'),
  LiDropdownMenuOption(value: 'page-actual', label: 'Actual size'),
  LiDropdownMenuOption(value: 'page-fit', label: 'Fit page'),
  LiDropdownMenuOption(value: 'page-width', label: 'Fit width'),
  LiDropdownMenuOption(divider: true),
  LiDropdownMenuOption(value: '0.5', label: '50%'),
  LiDropdownMenuOption(value: '0.75', label: '75%'),
  LiDropdownMenuOption(value: '1', label: '100%'),
  LiDropdownMenuOption(value: '1.25', label: '125%'),
  LiDropdownMenuOption(value: '1.5', label: '150%'),
  LiDropdownMenuOption(value: '2', label: '200%'),
  LiDropdownMenuOption(value: '3', label: '300%'),
  LiDropdownMenuOption(value: '4', label: '400%'),
];

const defaultLiPdfViewerZoomOptionsPt = <LiDropdownMenuOption>[
  LiDropdownMenuOption(value: 'auto', label: 'Zoom automático'),
  LiDropdownMenuOption(value: 'page-actual', label: 'Tamanho real'),
  LiDropdownMenuOption(value: 'page-fit', label: 'Ajustar página'),
  LiDropdownMenuOption(value: 'page-width', label: 'Largura da página'),
  LiDropdownMenuOption(divider: true),
  LiDropdownMenuOption(value: '0.5', label: '50%'),
  LiDropdownMenuOption(value: '0.75', label: '75%'),
  LiDropdownMenuOption(value: '1', label: '100%'),
  LiDropdownMenuOption(value: '1.25', label: '125%'),
  LiDropdownMenuOption(value: '1.5', label: '150%'),
  LiDropdownMenuOption(value: '2', label: '200%'),
  LiDropdownMenuOption(value: '3', label: '300%'),
  LiDropdownMenuOption(value: '4', label: '400%'),
];

class LiPdfViewerLabels {
  const LiPdfViewerLabels({
    this.loading = 'Loading PDF...',
    this.emptyState = 'Select a PDF to preview.',
    this.fitWidth = 'Fit width',
    this.rotate = 'Rotate',
    this.download = 'Download',
    this.print = 'Print',
    this.goToPage = 'Go to page',
    this.goToPageTitle = 'Go to page',
    this.moreActions = 'More PDF actions',
    this.mobileActions = 'PDF actions',
    this.fullscreen = 'Fullscreen',
    this.exitFullscreen = 'Exit fullscreen',
    this.enablePan = 'Enable pan mode',
    this.disablePan = 'Disable pan mode',
    this.previousPage = 'Previous page',
    this.nextPage = 'Next page',
    this.page = 'Page',
    this.zoomOut = 'Zoom out',
    this.zoomIn = 'Zoom in',
    this.cancel = 'Cancel',
    this.confirm = 'OK',
    this.errorPrefix = 'Unable to load PDF:',
    this.selectZoomTitle = 'Select zoom',
    this.pageRangeHintPrefix = 'Enter a page between',
    this.pageRangeHintMiddle = 'and',
  });

  static const LiPdfViewerLabels english = LiPdfViewerLabels();

  static const LiPdfViewerLabels portuguese = LiPdfViewerLabels(
    loading: 'Carregando PDF...',
    emptyState: 'Selecione um PDF para visualizar.',
    fitWidth: 'Ajustar à largura',
    rotate: 'Girar',
    download: 'Baixar',
    print: 'Imprimir',
    goToPage: 'Ir para página',
    goToPageTitle: 'Ir para página',
    moreActions: 'Mais ações do PDF',
    mobileActions: 'Ações do PDF',
    fullscreen: 'Tela cheia',
    exitFullscreen: 'Sair da tela cheia',
    enablePan: 'Ativar modo pan',
    disablePan: 'Desativar modo pan',
    previousPage: 'Página anterior',
    nextPage: 'Próxima página',
    page: 'Página',
    zoomOut: 'Reduzir zoom',
    zoomIn: 'Ampliar zoom',
    cancel: 'Cancelar',
    confirm: 'OK',
    errorPrefix: 'Falha ao carregar o PDF:',
    selectZoomTitle: 'Selecionar zoom',
    pageRangeHintPrefix: 'Informe uma página entre',
    pageRangeHintMiddle: 'e',
  );

  final String loading;
  final String emptyState;
  final String fitWidth;
  final String rotate;
  final String download;
  final String print;
  final String goToPage;
  final String goToPageTitle;
  final String moreActions;
  final String mobileActions;
  final String fullscreen;
  final String exitFullscreen;
  final String enablePan;
  final String disablePan;
  final String previousPage;
  final String nextPage;
  final String page;
  final String zoomOut;
  final String zoomIn;
  final String cancel;
  final String confirm;
  final String errorPrefix;
  final String selectZoomTitle;
  final String pageRangeHintPrefix;
  final String pageRangeHintMiddle;

  String pageRangeHint(int totalPages) {
    return '$pageRangeHintPrefix 1 $pageRangeHintMiddle $totalPages.';
  }
}

@Component(
  selector: 'li-pdf-viewer',
  templateUrl: 'pdf_viewer_component.html',
  styleUrls: ['pdf_viewer_component.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiDropdownMenuComponent,
    LiModalComponent,
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiPdfViewerComponent
    implements OnInit, AfterChanges, AfterViewInit, OnDestroy {
  static const String _customActionMenuValuePrefix = '__custom__:';

  LiPdfViewerComponent(
    this._changeDetectorRef,
    this._hostElement,
  ) {
    _documentController = PdfViewerDocumentController(
      changeDetectorRef: _changeDetectorRef,
      scaleProvider: () => _scale,
      rotationProvider: () => _rotation,
      scrollToPage: scrollToPage,
      onLog: _log,
    );
    _renderingQueue = PdfViewerRenderingQueue(
      renderPage: _documentController.renderPage,
      onRendered: _handlePageRendered,
      onLog: _log,
    );
    _documentController.onPageVisible = _scheduleRenderFromIntersection;
  }

  final ChangeDetectorRef _changeDetectorRef;
  final html.HtmlElement _hostElement;
  final PdfPageViewCache _pageViewCache =
      PdfPageViewCache(liPdfViewerDefaultCacheSize);
  final PdfViewerVisibilityController visibilityController =
      PdfViewerVisibilityController();
  late final LiPdfViewerTemplateContext templateContext =
      LiPdfViewerTemplateContext(this);

  late final PdfViewerDocumentController _documentController;
  late final PdfViewerRenderingQueue _renderingQueue;

  final StreamController<int> _pageChangeController =
      StreamController<int>.broadcast();
  final StreamController<double> _scaleChangeController =
      StreamController<double>.broadcast();
  final StreamController<int> _documentLoadedController =
      StreamController<int>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<LiPdfViewerToolbarActionEvent>
      _toolbarActionController =
      StreamController<LiPdfViewerToolbarActionEvent>.broadcast();
  final StreamController<bool> _sidePanelOpenChangeController =
      StreamController<bool>.broadcast();

  @Input()
  String title = 'PDF Viewer';

  @Input()
  LiPdfViewerLabels labels = const LiPdfViewerLabels();

  @Input()
  bool toolbarVisible = true;

  @Input()
  bool showTitle = true;

  @Input()
  bool enableDownloadAction = true;

  @Input()
  bool enablePrintAction = true;

  @Input()
  bool enableRotateAction = true;

  @Input()
  bool enableFitWidthAction = true;

  @Input()
  bool enablePanModeAction = true;

  @Input()
  bool enableFullscreenAction = true;

  @Input()
  bool enableGoToPageAction = true;

  @Input()
  bool allowKeyboardShortcuts = true;

  @Input()
  bool debug = false;

  @Input()
  String pdfJsBasePath = 'assets/js/pdf.js/5.4.149';

  @Input()
  String workerSource = '';

  @Input()
  String standardFontDataUrl = '';

  @Input()
  String cMapUrl = '';

  @Input()
  bool cMapPacked = true;

  @Input()
  String downloadFileName = 'document.pdf';

  @Input()
  Map<String, String> requestHeaders = const <String, String>{};

  @Input()
  List<LiDropdownMenuOption> zoomOptions = defaultLiPdfViewerZoomOptions;

  List<LiPdfViewerToolbarAction> _customToolbarActions =
      const <LiPdfViewerToolbarAction>[];

  @Input()
  set customToolbarActions(List<LiPdfViewerToolbarAction>? value) {
    _customToolbarActions = List<LiPdfViewerToolbarAction>.unmodifiable(
      value ?? const <LiPdfViewerToolbarAction>[],
    );
    _syncActionOptions();
  }

  List<LiPdfViewerToolbarAction> get customToolbarActions =>
      _customToolbarActions;

  @Input()
  TemplateRef? toolbarActionsTemplate;

  @Input()
  TemplateRef? sidePanelTemplate;

  @Input()
  String sidePanelTitle = '';

  @Input()
  String sidePanelWidth = '22rem';

  @Input()
  bool enableSidePanelCloseButton = true;

  @Input()
  bool sidePanelModalOnMobile = true;

  bool _sidePanelOpen = false;

  @Input()
  set sidePanelOpen(bool value) {
    _updateSidePanelOpen(value, emit: false);
  }

  bool get sidePanelOpen => _sidePanelOpen;

  @Input()
  LiPdfViewerLinkSanitizer? linkSanitizer;

  @Input()
  set initialScale(String value) {
    _setScale(value);
  }

  String? _url;
  @Input()
  set url(String? value) {
    final normalized = value?.trim();
    _url = normalized == null || normalized.isEmpty ? null : normalized;
    if (_url != null) {
      _pdfSource = _url;
      _scheduleLoadPdf();
    }
  }

  Uint8List? _bytes;
  @Input()
  set bytes(Uint8List? value) {
    _bytes = value == null || value.isEmpty ? null : Uint8List.fromList(value);
    if (_bytes != null) {
      _pdfSource = _bytes;
      _scheduleLoadPdf();
    }
  }

  @ViewChild('viewer')
  html.DivElement? viewer;

  @ViewChild('toolbarContainer')
  html.DivElement? toolbarContainer;

  @ViewChild('viewerContainer')
  html.DivElement? viewerContainer;

  @ViewChild('goToPageModal')
  LiModalComponent? goToPageModal;

  @ViewChild('sidePanelModal')
  LiModalComponent? sidePanelModal;

  @ContentChild(LiPdfViewerToolbarActionsDirective)
  LiPdfViewerToolbarActionsDirective? projectedToolbarActionsTemplate;

  @ContentChild(LiPdfViewerSidePanelDirective)
  LiPdfViewerSidePanelDirective? projectedSidePanelTemplate;

  @Output()
  Stream<int> get pageChange => _pageChangeController.stream;

  @Output()
  Stream<double> get scaleChange => _scaleChangeController.stream;

  @Output()
  Stream<int> get documentLoaded => _documentLoadedController.stream;

  @Output('loadError')
  Stream<String> get loadError => _errorController.stream;

  @Output()
  Stream<LiPdfViewerToolbarActionEvent> get toolbarAction =>
      _toolbarActionController.stream;

  @Output()
  Stream<bool> get sidePanelOpenChange => _sidePanelOpenChangeController.stream;

  bool isLoading = false;
  String? errorMessage;
  dynamic _pdfSource;
  int currentPage = 1;
  int _rotation = 0;
  double _scale = liPdfViewerDefaultScale;
  String _currentScaleValue = liPdfViewerDefaultScaleValue;
  bool isCustomScale = false;
  String customScaleValue = 'custom';
  bool _pendingPdfLoad = false;
  bool _isPanModeEnabled = false;
  bool _isFallbackFullscreen = false;
  int _toolbarWidth = 0;
  int? _scrollRafId;
  int _lastScrollTop = 0;
  bool _isScrollingDown = true;
  bool _zoomRafPending = false;
  double? _pendingScale;
  Point<num>? _pendingOrigin;
  Timer? _zoomDebounceTimer;
  html.ResizeObserver? _resizeObserver;
  String goToPageInputText = '';
  List<LiPdfViewerToolbarAction> leadingCustomToolbarActions =
      const <LiPdfViewerToolbarAction>[];
  List<LiPdfViewerToolbarAction> trailingCustomToolbarActions =
      const <LiPdfViewerToolbarAction>[];

  StreamSubscription<html.KeyboardEvent>? _keyDownSub;
  StreamSubscription<html.Event>? _scrollSub;
  StreamSubscription<html.WheelEvent>? _wheelSub;
  StreamSubscription<html.PointerEvent>? _pointerDownSub;
  StreamSubscription<html.PointerEvent>? _pointerMoveSub;
  StreamSubscription<html.PointerEvent>? _pointerUpSub;
  StreamSubscription<html.PointerEvent>? _pointerCancelSub;
  StreamSubscription<html.TouchEvent>? _touchStartSub;
  StreamSubscription<html.TouchEvent>? _touchMoveSub;
  StreamSubscription<html.TouchEvent>? _touchEndSub;
  StreamSubscription<html.TouchEvent>? _touchCancelSub;
  StreamSubscription<html.Event>? _fullscreenChangeSub;
  StreamSubscription<html.Event>? _webkitFullscreenChangeSub;
  StreamSubscription<html.Event>? _afterPrintSubscription;
  StreamSubscription<html.Event>? _windowResizeSub;

  final Map<int, html.PointerEvent> _activeTouchPointers =
      <int, html.PointerEvent>{};
  double? _pinchStartDistance;
  double? _pinchStartScale;
  double? _touchPinchStartDistance;
  double? _touchPinchStartScale;
  int? _mousePanPointerId;
  Point<num>? _mousePanStartPoint;
  int _mousePanStartScrollTop = 0;
  int _mousePanStartScrollLeft = 0;
  bool _mousePanCandidate = false;
  bool _isMousePanning = false;
  String? _previousBodyOverflow;
  html.IFrameElement? _printFrame;
  String? _printObjectUrl;

  final Map<double, String> _scaleToValueMap = <double, String>{
    0.5: '0.5',
    0.75: '0.75',
    1.0: '1',
    1.25: '1.25',
    1.5: '1.5',
    2.0: '2',
    3.0: '3',
    4.0: '4',
  };

  List<LiDropdownMenuOption> pdfMobileActionOptions =
      const <LiDropdownMenuOption>[];
  List<LiDropdownMenuOption> pdfDesktopOverflowActionOptions =
      const <LiDropdownMenuOption>[];

  PDFDocumentProxy? get pdfDocument => _documentController.document;
  int get totalPages => _documentController.totalPages;
  List<PdfPageView> get _pageViews => _documentController.pageViews;
  double get scale => _scale;
  bool get passwordVisible => false;

  TemplateRef? get resolvedToolbarActionsTemplate =>
      toolbarActionsTemplate ?? projectedToolbarActionsTemplate?.templateRef;

  TemplateRef? get resolvedSidePanelTemplate =>
      sidePanelTemplate ?? projectedSidePanelTemplate?.templateRef;

  bool get hasToolbarActionsTemplate => resolvedToolbarActionsTemplate != null;

  bool get hasSidePanelTemplate => resolvedSidePanelTemplate != null;

  bool get hasSidePanelHeader =>
      resolvedSidePanelTitle != null || enableSidePanelCloseButton;

  bool get isMobileViewport =>
      html.window.matchMedia('(max-width: 767.98px)').matches;

  bool get shouldShowInlineSidePanel =>
      hasSidePanelTemplate &&
      sidePanelOpen &&
      (!sidePanelModalOnMobile || !isMobileViewport);

  String? get resolvedSidePanelTitle {
    final normalized = sidePanelTitle.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
    final fallback = title.trim();
    return fallback.isEmpty ? null : fallback;
  }

  String get resolvedSidePanelWidth {
    final normalized = sidePanelWidth.trim();
    return normalized.isEmpty ? '22rem' : normalized;
  }

  bool get showEmptyState =>
      !isLoading &&
      errorMessage == null &&
      totalPages == 0 &&
      _pdfSource == null;

  bool get isFullscreenActive =>
      _isFallbackFullscreen || _nativeFullscreenElement == _hostElement;

  bool get isPanModeEnabled => _isPanModeEnabled;

  String get fullscreenIconClass =>
      isFullscreenActive ? 'ph ph-corners-in' : 'ph ph-corners-out';

  String get fullscreenButtonLabel =>
      isFullscreenActive ? labels.exitFullscreen : labels.fullscreen;

  String get panModeIconClass =>
      isPanModeEnabled ? 'ph ph-hand-grabbing' : 'ph ph-hand';

  String get panModeButtonLabel =>
      isPanModeEnabled ? labels.disablePan : labels.enablePan;

  String get zoomPercentage => '${(_scale * 100).round()}%';

  int get _pageCounterDigits => max(
        '$currentPage'.length,
        '${max(totalPages, 1)}'.length,
      );

  int get pageInputSize => _pageCounterDigits.clamp(2, 7);

  String get pageInputSizeAttr => '$pageInputSize';

  String get pageInputWidth => '${pageInputSize + 1}ch';

  String get totalPagesMinWidth =>
      '${max('${max(totalPages, 1)}'.length + 1, 3)}ch';

  String get pageCounterLabel => '$currentPage/${max(totalPages, 1)}';

  String get currentScaleValueForSelect {
    if (zoomOptions.any(
      (option) => !option.divider && option.value == _currentScaleValue,
    )) {
      return _currentScaleValue;
    }

    final roundedScale = (_scale * 100).round() / 100.0;
    return _scaleToValueMap[roundedScale] ?? customScaleValue;
  }

  String get currentScaleLabel {
    for (final option in zoomOptions) {
      if (!option.divider && option.value == currentScaleValueForSelect) {
        return option.label;
      }
    }
    return zoomPercentage;
  }

  bool get useDesktopOverflowMenu => _toolbarWidth > 0 && _toolbarWidth < 760;

  Object? get _nativeFullscreenElement {
    final document = html.document;
    if (js_util.hasProperty(document, 'fullscreenElement')) {
      return js_util.getProperty<Object?>(document, 'fullscreenElement');
    }
    if (js_util.hasProperty(document, 'webkitFullscreenElement')) {
      return js_util.getProperty<Object?>(document, 'webkitFullscreenElement');
    }
    return null;
  }

  bool get _isNativeFullscreenActive =>
      _nativeFullscreenElement == _hostElement;

  @override
  void ngOnInit() {
    _syncActionOptions();
  }

  @override
  void ngAfterChanges() {
    _syncActionOptions();
    _changeDetectorRef.markForCheck();
  }

  @override
  void ngAfterViewInit() {
    _disposeBrowserListeners();

    _keyDownSub = _hostElement.onKeyDown.listen(_handleKeyDown);
    _lastScrollTop = viewerContainer?.scrollTop ?? 0;
    _scrollSub =
        viewerContainer?.onScroll.listen((_) => _scheduleScrollUpdate());

    _resizeObserver = html.ResizeObserver((entries, observer) {
      _updateToolbarResponsiveState();
      if (viewerContainer?.clientWidth != null &&
          viewerContainer!.clientWidth > 0 &&
          <String>{'page-width', 'page-fit', 'auto'}
              .contains(_currentScaleValue)) {
        _setScale(_currentScaleValue);
      }
    });
    if (toolbarContainer != null) {
      _resizeObserver!.observe(toolbarContainer!);
    }
    if (viewerContainer != null) {
      _resizeObserver!.observe(viewerContainer!);
    }
    _updateToolbarResponsiveState();

    _wheelSub = viewerContainer?.onWheel.listen((event) {
      final container = viewerContainer;
      if (container == null) {
        return;
      }
      if (!event.ctrlKey) {
        return;
      }
      event.preventDefault();
      final delta = event.deltaY < 0 ? 1.1 : 1 / 1.1;
      final next =
          (_scale * delta).clamp(liPdfViewerMinScale, liPdfViewerMaxScale);
      _scheduleZoom(next, Point<num>(event.client.x, event.client.y));
    });

    _pointerDownSub = viewerContainer?.on['pointerdown']
        .cast<html.PointerEvent>()
        .listen(_handlePointerDown);
    _pointerMoveSub = viewerContainer?.on['pointermove']
        .cast<html.PointerEvent>()
        .listen(_handlePointerMove);
    _pointerUpSub = viewerContainer?.on['pointerup']
        .cast<html.PointerEvent>()
        .listen(_handlePointerEnd);
    _pointerCancelSub = viewerContainer?.on['pointercancel']
        .cast<html.PointerEvent>()
        .listen(_handlePointerEnd);
    _touchStartSub = viewerContainer?.onTouchStart.listen(_handleTouchStart);
    _touchMoveSub = viewerContainer?.onTouchMove.listen(_handleTouchMove);
    _touchEndSub = viewerContainer?.onTouchEnd.listen(_handleTouchEnd);
    _touchCancelSub = viewerContainer?.onTouchCancel.listen(_handleTouchEnd);
    _fullscreenChangeSub = html.document.on['fullscreenchange']
        .cast<html.Event>()
        .listen((_) => _syncFullscreenState());
    _webkitFullscreenChangeSub = html.document.on['webkitfullscreenchange']
        .cast<html.Event>()
        .listen((_) => _syncFullscreenState());
    _windowResizeSub = html.window.onResize.listen((_) {
      _syncSidePanelPresentationState();
      _changeDetectorRef.markForCheck();
    });

    _syncSidePanelPresentationState();

    if (_pendingPdfLoad && _pdfSource != null) {
      _pendingPdfLoad = false;
      scheduleMicrotask(_loadPdf);
    }
  }

  @override
  void ngOnDestroy() {
    _renderingQueue.dispose();
    _pageViewCache.clear(destroyPages: true);
    _documentController.dispose();
    _cancelScrollUpdate();
    _zoomDebounceTimer?.cancel();
    _resizeObserver?.disconnect();
    _disposeBrowserListeners();
    _disposePrintArtifacts();
    _windowResizeSub?.cancel();
    _exitFallbackFullscreen();
    _pageChangeController.close();
    _scaleChangeController.close();
    _documentLoadedController.close();
    _errorController.close();
    _toolbarActionController.close();
    _sidePanelOpenChangeController.close();
  }

  void onScaleDropdownChange(String value) {
    final parsed = double.tryParse(value);
    _setScale(parsed ?? value);
  }

  void onActionMenuSelect(String action) {
    scheduleMicrotask(() {
      final customAction = _resolveCustomAction(action);
      if (customAction != null) {
        onCustomToolbarActionClick(customAction);
        return;
      }

      switch (action) {
        case 'fit':
          fitContent();
          break;
        case 'page':
          openGoToPageModal();
          break;
        case 'rotate':
          rotate();
          break;
        case 'pan':
          togglePanMode();
          break;
        case 'fullscreen':
          toggleFullscreen();
          break;
        case 'download':
          downloadDocument();
          break;
        case 'print':
          printDocument();
          break;
      }
    });
  }

  void onCustomToolbarActionClick(LiPdfViewerToolbarAction action) {
    if (isCustomToolbarActionDisabled(action)) {
      return;
    }

    final event = LiPdfViewerToolbarActionEvent(
      viewer: this,
      action: action,
    );
    _toolbarActionController.add(event);
    final handler = action.onPressed;
    if (handler != null) {
      Future<void>.sync(() async {
        await handler(event);
      });
    }
  }

  void zoomOutBtnClick() => zoomOut();

  void zoomInBtnClick() => zoomIn();

  void zoomIn([html.MouseEvent? event]) => _scheduleZoom(
        (_scale * 1.2).clamp(liPdfViewerMinScale, liPdfViewerMaxScale),
        event == null ? null : Point<num>(event.client.x, event.client.y),
      );

  void zoomOut([html.MouseEvent? event]) => _scheduleZoom(
        (_scale / 1.2).clamp(liPdfViewerMinScale, liPdfViewerMaxScale),
        event == null ? null : Point<num>(event.client.x, event.client.y),
      );

  void fitContent() => _setScale('page-width');

  void rotate() {
    _rotation = (_rotation + 90) % 360;
    _setScale(_currentScaleValue);
  }

  void openGoToPageModal() {
    if (!enableGoToPageAction) {
      return;
    }
    goToPageInputText = currentPage > 0 ? '$currentPage' : '';
    _changeDetectorRef.markForCheck();
    Timer.run(() {
      goToPageModal?.open();
      Timer.run(() {
        final input = html.document.getElementById('pdfGoToPageInput');
        if (input is html.InputElement) {
          input.focus();
          input.select();
        }
      });
    });
  }

  void closeGoToPageModal() {
    goToPageModal?.close();
    _changeDetectorRef.markForCheck();
  }

  void openSidePanel() {
    if (!hasSidePanelTemplate) {
      return;
    }
    _updateSidePanelOpen(true);
  }

  void closeSidePanel() {
    if (!hasSidePanelTemplate) {
      return;
    }
    _updateSidePanelOpen(false);
  }

  void toggleSidePanel() {
    if (!hasSidePanelTemplate) {
      return;
    }
    _updateSidePanelOpen(!sidePanelOpen);
  }

  void onGoToPageModalClose() {
    _changeDetectorRef.markForCheck();
  }

  void onSidePanelModalClose() {
    if (!sidePanelOpen) {
      return;
    }
    _updateSidePanelOpen(false);
  }

  void confirmGoToPage() {
    final pageNum = int.tryParse(goToPageInputText.trim());
    if (pageNum == null || pageNum < 1 || pageNum > totalPages) {
      return;
    }
    closeGoToPageModal();
    scrollToPage(pageNum);
  }

  void nextPage() => scrollToPage(min(currentPage + 1, totalPages));

  void previousPage() => scrollToPage(max(currentPage - 1, 1));

  void onChangePageHandle(html.Event event) {
    final pageNum =
        int.tryParse((event.target as html.InputElement).value ?? '');
    if (pageNum != null) {
      scrollToPage(pageNum);
    }
  }

  void scrollToPage(int pageNum) {
    if (pageNum <= 0 ||
        pageNum > _pageViews.length ||
        viewerContainer == null) {
      return;
    }

    final pageDiv = _pageViews[pageNum - 1].div;
    final container = viewerContainer!;
    if (container.scrollHeight > container.clientHeight) {
      container.scrollTop = pageDiv.offsetTop;
    } else {
      pageDiv.scrollIntoView();
    }
    _setCurrentPage(pageNum);
  }

  void togglePanMode() {
    if (!enablePanModeAction) {
      return;
    }
    _isPanModeEnabled = !_isPanModeEnabled;
    if (!_isPanModeEnabled) {
      _endMousePan(null);
    }
    _syncActionOptions();
    _changeDetectorRef.markForCheck();
  }

  Future<void> toggleFullscreen() async {
    if (!enableFullscreenAction) {
      return;
    }
    if (_isNativeFullscreenActive) {
      await _exitNativeFullscreen();
      return;
    }
    if (_isFallbackFullscreen) {
      _exitFallbackFullscreen();
      _syncFullscreenState();
      return;
    }

    final enteredNative = await _requestNativeFullscreen();
    if (!enteredNative) {
      _enterFallbackFullscreen();
      _syncFullscreenState();
    }
  }

  Future<void> downloadDocument() async {
    final document = pdfDocument;
    if (!enableDownloadAction || document == null) {
      return;
    }

    try {
      final data = await document.getDataDart();
      final blob = html.Blob(<Object>[data], 'application/pdf');
      final blobUrl = liPdfViewerBrowserBridge.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: blobUrl)
        ..style.display = 'none'
        ..download = downloadFileName.trim().isEmpty
            ? 'document.pdf'
            : downloadFileName.trim();

      html.document.body?.append(anchor);
      liPdfViewerBrowserBridge.clickAnchor(anchor);
      anchor.remove();

      Future<void>.delayed(const Duration(seconds: 1), () {
        liPdfViewerBrowserBridge.revokeObjectUrl(blobUrl);
      });
    } catch (error) {
      _setError('Failed to download PDF: $error');
    }
  }

  Future<void> printDocument() async {
    final document = pdfDocument;
    if (!enablePrintAction || document == null) {
      return;
    }

    try {
      final data = await document.getDataDart();
      final blob = html.Blob(<Object>[data], 'application/pdf');

      if (_printObjectUrl != null) {
        liPdfViewerBrowserBridge.revokeObjectUrl(_printObjectUrl!);
      }
      _printFrame?.remove();

      _printObjectUrl = liPdfViewerBrowserBridge.createObjectUrlFromBlob(blob);
      _printFrame = html.IFrameElement()
        ..id = 'liPdfViewerPrintFrame'
        ..name = 'liPdfViewerPrintFrame'
        ..src = _printObjectUrl
        ..style.display = 'none';

      html.document.body?.append(_printFrame!);
      _afterPrintSubscription?.cancel();
      _afterPrintSubscription = html.window.on['afterprint'].listen((_) {
        _disposePrintArtifacts();
      });

      await _printFrame!.onLoad.first;
      try {
        dynamic targetFrame = _printFrame?.contentWindow;
        if (targetFrame == null) {
          final frames = js_util.getProperty(html.window, 'frames');
          targetFrame = js_util.getProperty(frames, 'liPdfViewerPrintFrame');
        }
        if (targetFrame == null) {
          throw StateError('Print frame is not available.');
        }
        liPdfViewerBrowserBridge.printWindow(targetFrame);
      } catch (error) {
        _setError('Failed to print PDF: $error');
      }
    } catch (error) {
      _setError('Failed to prepare PDF printing: $error');
    }
  }

  Future<LiPdfViewerPageText> extractPageText(
    int pageNum, {
    bool includeMarkedContent = false,
    bool disableNormalization = false,
    bool trim = true,
  }) async {
    final document = pdfDocument;
    if (document == null) {
      throw StateError('No PDF document is loaded.');
    }
    if (pageNum < 1 || pageNum > totalPages) {
      throw RangeError.range(pageNum, 1, totalPages, 'pageNum');
    }

    final page = await document.getPageDart(pageNum);
    final textContent = await page.getTextContentDart(
      includeMarkedContent: includeMarkedContent,
      disableNormalization: disableNormalization,
    );
    final items = _mapPageTextItems(textContent.items);
    final text = _joinPageTextItems(items, trim: trim);

    return LiPdfViewerPageText(
      pageNumber: pageNum,
      text: text,
      language: textContent.lang ?? '',
      items: items,
    );
  }

  Future<List<LiPdfViewerPageText>> extractAllPagesText({
    bool includeMarkedContent = false,
    bool disableNormalization = false,
    bool trim = true,
  }) async {
    final document = pdfDocument;
    if (document == null) {
      throw StateError('No PDF document is loaded.');
    }

    final results = <LiPdfViewerPageText>[];
    for (var pageNum = 1; pageNum <= totalPages; pageNum++) {
      results.add(
        await extractPageText(
          pageNum,
          includeMarkedContent: includeMarkedContent,
          disableNormalization: disableNormalization,
          trim: trim,
        ),
      );
    }
    return List<LiPdfViewerPageText>.unmodifiable(results);
  }

  Future<String> extractDocumentText({
    String pageSeparator = '\n\n',
    bool includeMarkedContent = false,
    bool disableNormalization = false,
    bool trimPages = true,
  }) async {
    final pages = await extractAllPagesText(
      includeMarkedContent: includeMarkedContent,
      disableNormalization: disableNormalization,
      trim: trimPages,
    );
    return pages.map((page) => page.text).join(pageSeparator);
  }

  Future<LiPdfViewerPageInfo> getPageInfo(int pageNum) async {
    final document = pdfDocument;
    if (document == null) {
      throw StateError('No PDF document is loaded.');
    }
    if (pageNum < 1 || pageNum > totalPages) {
      throw RangeError.range(pageNum, 1, totalPages, 'pageNum');
    }

    final page = await document.getPageDart(pageNum);
    final viewport = page.getViewport(
      ViewportParams(scale: 1.0, rotation: 0),
    );
    final pageView =
        pageNum <= _pageViews.length ? _pageViews[pageNum - 1] : null;

    return LiPdfViewerPageInfo(
      pageNumber: pageNum,
      width: viewport.width.toDouble(),
      height: viewport.height.toDouble(),
      rotation: viewport.rotation.toInt(),
      currentScale: pageView?.viewport?.scale.toDouble() ?? _scale,
      isRendered: pageView?.canvas != null,
      hasTextLayer: pageView?.textLayerDiv != null,
      hasAnnotationLayer: pageView?.annotationLayerDiv != null,
    );
  }

  Future<List<LiPdfViewerPageInfo>> getAllPageInfo() async {
    final infos = <LiPdfViewerPageInfo>[];
    for (var pageNum = 1; pageNum <= totalPages; pageNum++) {
      infos.add(await getPageInfo(pageNum));
    }
    return List<LiPdfViewerPageInfo>.unmodifiable(infos);
  }

  void _syncActionOptions() {
    final leadingActions = <LiPdfViewerToolbarAction>[];
    final trailingActions = <LiPdfViewerToolbarAction>[];
    for (final action in customToolbarActions) {
      if (!action.showInToolbar || useDesktopOverflowMenu) {
        continue;
      }

      switch (action.placement) {
        case LiPdfViewerToolbarActionPlacement.leading:
          leadingActions.add(action);
          break;
        case LiPdfViewerToolbarActionPlacement.trailing:
          trailingActions.add(action);
          break;
      }
    }
    leadingCustomToolbarActions =
        List<LiPdfViewerToolbarAction>.unmodifiable(leadingActions);
    trailingCustomToolbarActions =
        List<LiPdfViewerToolbarAction>.unmodifiable(trailingActions);

    final mobileOptions = <LiDropdownMenuOption>[];
    if (enableFitWidthAction) {
      mobileOptions.add(
        LiDropdownMenuOption(
          value: 'fit',
          label: labels.fitWidth,
          iconClass: 'ph ph-frame-corners',
        ),
      );
    }
    if (enableGoToPageAction) {
      mobileOptions.add(
        LiDropdownMenuOption(
          value: 'page',
          label: labels.goToPage,
          iconClass: 'ph ph-file-text',
        ),
      );
    }
    if (enableRotateAction) {
      mobileOptions.add(
        LiDropdownMenuOption(
          value: 'rotate',
          label: labels.rotate,
          iconClass: 'ph ph-arrow-counter-clockwise',
        ),
      );
    }
    if (enablePanModeAction) {
      mobileOptions.add(
        LiDropdownMenuOption(
          value: 'pan',
          label: panModeButtonLabel,
          iconClass: panModeIconClass,
        ),
      );
    }
    if (enableFullscreenAction) {
      mobileOptions.add(
        LiDropdownMenuOption(
          value: 'fullscreen',
          label: fullscreenButtonLabel,
          iconClass: fullscreenIconClass,
        ),
      );
    }
    if (enableDownloadAction) {
      mobileOptions.add(
        LiDropdownMenuOption(
          value: 'download',
          label: labels.download,
          iconClass: 'ph ph-download',
        ),
      );
    }
    if (enablePrintAction) {
      mobileOptions.add(
        LiDropdownMenuOption(
          value: 'print',
          label: labels.print,
          iconClass: 'ph ph-printer',
        ),
      );
    }
    for (final action in customToolbarActions) {
      if (!action.showInMobileMenu) {
        continue;
      }
      mobileOptions.add(
        LiDropdownMenuOption(
          value: _customActionMenuValue(action),
          label: resolveCustomToolbarActionLabel(action),
          iconClass: resolveCustomToolbarActionIconClass(action),
          disabled: isCustomToolbarActionDisabled(action),
        ),
      );
    }
    pdfMobileActionOptions = mobileOptions;

    final desktopOptions = <LiDropdownMenuOption>[];
    if (enableFitWidthAction) {
      desktopOptions.add(
        LiDropdownMenuOption(
          value: 'fit',
          label: labels.fitWidth,
          iconClass: 'ph ph-frame-corners',
        ),
      );
    }
    if (enableGoToPageAction) {
      desktopOptions.add(
        LiDropdownMenuOption(
          value: 'page',
          label: labels.goToPage,
          iconClass: 'ph ph-file-text',
        ),
      );
    }
    if (enableRotateAction) {
      desktopOptions.add(
        LiDropdownMenuOption(
          value: 'rotate',
          label: labels.rotate,
          iconClass: 'ph ph-arrow-counter-clockwise',
        ),
      );
    }
    if (enablePanModeAction) {
      desktopOptions.add(
        LiDropdownMenuOption(
          value: 'pan',
          label: panModeButtonLabel,
          iconClass: panModeIconClass,
        ),
      );
    }
    if (enableFullscreenAction) {
      desktopOptions.add(
        LiDropdownMenuOption(
          value: 'fullscreen',
          label: fullscreenButtonLabel,
          iconClass: fullscreenIconClass,
        ),
      );
    }
    if (enableDownloadAction) {
      desktopOptions.add(
        LiDropdownMenuOption(
          value: 'download',
          label: labels.download,
          iconClass: 'ph ph-download',
        ),
      );
    }
    if (enablePrintAction) {
      desktopOptions.add(
        LiDropdownMenuOption(
          value: 'print',
          label: labels.print,
          iconClass: 'ph ph-printer',
        ),
      );
    }
    for (final action in customToolbarActions) {
      if (!action.showInDesktopOverflowMenu) {
        continue;
      }
      desktopOptions.add(
        LiDropdownMenuOption(
          value: _customActionMenuValue(action),
          label: resolveCustomToolbarActionLabel(action),
          iconClass: resolveCustomToolbarActionIconClass(action),
          disabled: isCustomToolbarActionDisabled(action),
        ),
      );
    }
    pdfDesktopOverflowActionOptions = desktopOptions;
  }

  void _setScale(dynamic value, {Point<num>? origin}) {
    double? newScale;
    var newScaleValue = _currentScaleValue;
    isCustomScale = false;

    if (value is double) {
      newScale = value;
      final roundedScale = (newScale * 100).round() / 100.0;
      if (_scaleToValueMap.containsKey(roundedScale)) {
        newScaleValue = _scaleToValueMap[roundedScale]!;
      } else {
        isCustomScale = true;
        customScaleValue = newScale.toString();
        newScaleValue = customScaleValue;
      }
    } else if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return;
      }
      newScaleValue = trimmed;
      final parsedPercent = double.tryParse(trimmed.replaceAll('%', ''));
      if (!<String>{'page-actual', 'page-width', 'page-fit', 'auto'}
          .contains(trimmed)) {
        final parsedScale =
            parsedPercent != null ? parsedPercent / 100.0 : null;
        newScale = parsedScale ?? double.tryParse(trimmed);
      }

      final firstPage = _pageViews.isNotEmpty ? _pageViews.first : null;
      if (newScale == null && firstPage?.pdfPage == null) {
        _currentScaleValue = newScaleValue;
        _changeDetectorRef.markForCheck();
        return;
      }

      if (newScale == null) {
        final container = viewerContainer;
        if (container == null) {
          _currentScaleValue = newScaleValue;
          return;
        }

        final containerWidth = container.clientWidth - 20;
        final containerHeight = container.clientHeight - 20;
        final baseViewport = firstPage!.pdfPage!.getViewport(
          ViewportParams(scale: 1.0, rotation: _rotation.toDouble()),
        );

        switch (trimmed) {
          case 'page-actual':
            newScale = 1.0;
            break;
          case 'page-width':
            newScale = containerWidth / baseViewport.width;
            break;
          case 'page-fit':
            newScale = min(
              containerWidth / baseViewport.width,
              containerHeight / baseViewport.height,
            );
            break;
          case 'auto':
            final widthScale = containerWidth / baseViewport.width;
            final heightScale = containerHeight / baseViewport.height;
            final isPortrait = baseViewport.width <= baseViewport.height;
            final horizontalScale =
                isPortrait ? widthScale : min(widthScale, heightScale);
            newScale = min(liPdfViewerMaxAutoScale, horizontalScale);
            break;
        }
      }

      if (newScale != null &&
          !<String>{'page-actual', 'page-width', 'page-fit', 'auto'}
              .contains(trimmed)) {
        final roundedScale = (newScale * 100).round() / 100.0;
        if (!_scaleToValueMap.containsKey(roundedScale)) {
          isCustomScale = true;
          customScaleValue = newScale.toString();
          newScaleValue = customScaleValue;
        }
      }
    }

    if (newScale != null) {
      _currentScaleValue = newScaleValue;
      _updateScale(newScale, origin: origin, forceRedraw: value is String);
    }
  }

  void _updateScale(
    double newScale, {
    Point<num>? origin,
    bool forceRedraw = false,
  }) {
    final clamped = newScale.clamp(liPdfViewerMinScale, liPdfViewerMaxScale);
    if ((_scale - clamped).abs() < 1e-5 && !forceRedraw) {
      return;
    }

    final container = viewerContainer;
    if (container == null) {
      _scale = clamped;
      _scaleChangeController.add(_scale);
      _changeDetectorRef.markForCheck();
      return;
    }

    final oldScale = _scale;
    _scale = clamped;

    double relativePageOffsetRatio = 0.0;
    double relativeHorizontalRatio = 0.0;

    if (origin == null &&
        _pageViews.isNotEmpty &&
        currentPage > 0 &&
        currentPage <= _pageViews.length) {
      final currentPageDiv = _pageViews[currentPage - 1].div;
      if (currentPageDiv.clientHeight > 0) {
        relativePageOffsetRatio =
            (container.scrollTop - currentPageDiv.offsetTop) /
                currentPageDiv.clientHeight;
      }
      if (container.scrollWidth > 0) {
        relativeHorizontalRatio =
            (container.scrollLeft + container.clientWidth / 2) /
                container.scrollWidth;
      }
    }

    final oldScrollTop = container.scrollTop;
    final oldScrollLeft = container.scrollLeft;
    final containerRect = container.getBoundingClientRect();
    final zoomOrigin = origin == null
        ? null
        : Point<num>(
            origin.x - containerRect.left,
            origin.y - containerRect.top,
          );

    for (final pageView in _pageViews) {
      pageView.updateViewport(_scale, _rotation);
      if (pageView.canvas != null) {
        pageView.applyOrUpdateCssZoom(_scale);
      }
    }

    if (origin != null && zoomOrigin != null) {
      final scaleRatio = clamped / oldScale;
      container.scrollTop =
          ((zoomOrigin.y + oldScrollTop) * scaleRatio - zoomOrigin.y).round();
      container.scrollLeft =
          ((zoomOrigin.x + oldScrollLeft) * scaleRatio - zoomOrigin.x).round();
    } else if (_pageViews.isNotEmpty &&
        currentPage > 0 &&
        currentPage <= _pageViews.length) {
      final newPageDiv = _pageViews[currentPage - 1].div;
      final newScrollTop = newPageDiv.offsetTop +
          (relativePageOffsetRatio * newPageDiv.clientHeight);
      container.scrollTop = newScrollTop.round();

      if (container.scrollWidth > container.clientWidth) {
        final newScrollLeft =
            (relativeHorizontalRatio * container.scrollWidth) -
                (container.clientWidth / 2);
        container.scrollLeft = newScrollLeft.round();
      }
    }

    _zoomDebounceTimer?.cancel();
    _zoomDebounceTimer = Timer(
      const Duration(milliseconds: liPdfViewerZoomUpdateDebounceMs),
      _redrawVisibleAndNearPages,
    );

    _scaleChangeController.add(_scale);
    _changeDetectorRef.markForCheck();
  }

  void _scheduleZoom(double scale, Point<num>? origin) {
    _pendingScale = scale;
    _pendingOrigin = origin;
    if (_zoomRafPending) {
      return;
    }
    _zoomRafPending = true;
    html.window.requestAnimationFrame((_) {
      _zoomRafPending = false;
      final nextScale = _pendingScale;
      if (nextScale == null) {
        return;
      }
      _setScale(nextScale, origin: _pendingOrigin);
    });
  }

  void _scheduleLoadPdf() {
    if (viewer == null || viewerContainer == null) {
      _pendingPdfLoad = true;
      return;
    }
    _pendingPdfLoad = false;
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final source = _pdfSource;
    if (source == null) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    _renderingQueue.clear(cancelActive: true);
    _pageViewCache.clear(destroyPages: true);
    await _documentController.dispose();
    viewer?.children.clear();
    currentPage = 1;
    _lastScrollTop = 0;
    _isScrollingDown = true;
    _rotation = 0;
    _scale = liPdfViewerDefaultScale;
    if (_currentScaleValue.trim().isEmpty) {
      _currentScaleValue = liPdfViewerDefaultScaleValue;
    }
    _changeDetectorRef.markForCheck();

    try {
      _configurePdfJsWorker();
      await _documentController.loadDocument(
        source: source,
        viewerElement: viewer,
        requestHeaders: requestHeaders,
        standardFontDataUrl: _resolvedStandardFontDataUrl,
        cMapUrl: _resolvedCMapUrl,
        cMapPacked: cMapPacked,
        sanitizeAnnotationUrl: _sanitizeLinkUrl,
      );
      _documentController.setupIntersectionObserver(
        viewerContainer: viewerContainer,
      );
      _setScale(_currentScaleValue);
      _setCurrentPage(1);
      _documentLoadedController.add(totalPages);
    } catch (error) {
      _setError('$error');
    } finally {
      isLoading = false;
      _changeDetectorRef.markForCheck();
    }
  }

  void _configurePdfJsWorker() {
    try {
      liPdfViewerPdfJsBridge.configureWorker(_resolvedWorkerSource);
    } catch (error) {
      _setError('PDF.js worker configuration failed: $error');
    }
  }

  String get _resolvedWorkerSource {
    final explicit = workerSource.trim();
    if (explicit.isNotEmpty) {
      return explicit;
    }
    return '${pdfJsBasePath.trim()}/build/pdf.worker.mjs';
  }

  String get _resolvedStandardFontDataUrl {
    final explicit = standardFontDataUrl.trim();
    if (explicit.isNotEmpty) {
      return explicit;
    }
    return '${pdfJsBasePath.trim()}/web/standard_fonts/';
  }

  String get _resolvedCMapUrl {
    final explicit = cMapUrl.trim();
    if (explicit.isNotEmpty) {
      return explicit;
    }
    return '${pdfJsBasePath.trim()}/web/cmaps/';
  }

  String? _sanitizeLinkUrl(String rawUrl) {
    final custom = linkSanitizer;
    if (custom != null) {
      return custom(rawUrl);
    }

    final normalized = rawUrl.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(normalized);
    if (parsed == null) {
      return null;
    }
    if (!parsed.hasScheme) {
      return normalized;
    }

    switch (parsed.scheme.toLowerCase()) {
      case 'http':
      case 'https':
      case 'mailto':
      case 'tel':
        return parsed.toString();
      default:
        return null;
    }
  }

  void _setError(String message) {
    errorMessage = message;
    _errorController.add(message);
    _changeDetectorRef.markForCheck();
  }

  void _setCurrentPage(int pageNum) {
    if (currentPage == pageNum) {
      return;
    }
    currentPage = pageNum;
    _pageChangeController.add(pageNum);
    _changeDetectorRef.markForCheck();
  }

  void _scheduleRenderFromIntersection(PdfPageView pageView) {
    if (viewerContainer == null) {
      _renderingQueue.schedule(<PdfPageView>[pageView]);
      return;
    }
    _redrawVisibleAndNearPages();
  }

  void _handlePageRendered(PdfPageView pageView) {
    _pageViewCache.push(pageView);
  }

  void _scheduleScrollUpdate() {
    if (_scrollRafId != null) {
      return;
    }
    _scrollRafId = html.window.requestAnimationFrame((_) {
      _scrollRafId = null;
      _onScroll();
    });
  }

  void _cancelScrollUpdate() {
    final scrollRafId = _scrollRafId;
    if (scrollRafId == null) {
      return;
    }
    html.window.cancelAnimationFrame(scrollRafId);
    _scrollRafId = null;
  }

  void _onScroll() {
    final container = viewerContainer;
    if (container == null || _pageViews.isEmpty) {
      return;
    }

    final currentScrollTop = container.scrollTop;
    _isScrollingDown = currentScrollTop >= _lastScrollTop;
    _lastScrollTop = currentScrollTop;

    final visibleElements =
        visibilityController.getVisibleElements(container, _pageViews);
    if (visibleElements.isEmpty) {
      return;
    }

    _updateCurrentPageFromVisibleElements(visibleElements);
    _updateRenderedPageCache(visibleElements);
    _redrawVisibleAndNearPages(visibleElements: visibleElements);
  }

  void _updateCurrentPageFromVisibleElements(
    List<Map<String, dynamic>> visibleElements,
  ) {
    _setCurrentPage(visibleElements.first['id'] as int);
  }

  void _updateRenderedPageCache(List<Map<String, dynamic>> visibleElements) {
    final visibleIds =
        visibleElements.map((entry) => entry['id'] as int).toSet();
    final cacheSize =
        max(liPdfViewerDefaultCacheSize, (visibleElements.length * 2) + 1);
    _pageViewCache.resize(cacheSize, idsToKeep: visibleIds);

    for (final element in visibleElements) {
      final view = element['view'] as PdfPageView;
      if (view.renderingState == RenderingState.finished) {
        _pageViewCache.push(view);
      }
    }
  }

  void _redrawVisibleAndNearPages({
    List<Map<String, dynamic>>? visibleElements,
  }) {
    final container = viewerContainer;
    if (container == null) {
      return;
    }

    visibleElements ??=
        visibilityController.getVisibleElements(container, _pageViews);

    final margin = (container.clientHeight * 1.5).round();
    final top = container.scrollTop - margin;
    final bottom = container.scrollTop + container.clientHeight + margin;

    final priorityViews = <PdfPageView>[];
    final priorityIds = <int>{};

    void addPriorityView(PdfPageView view) {
      if (!priorityIds.add(view.pageNum)) {
        return;
      }
      priorityViews.add(view);
    }

    for (final element in visibleElements) {
      addPriorityView(element['view'] as PdfPageView);
    }

    final previousViews = <PdfPageView>[];
    final nextViews = <PdfPageView>[];
    for (final view in _pageViews) {
      final element = view.div;
      final elementTop = element.offsetTop;
      final elementBottom = elementTop + element.clientHeight;

      if (elementBottom <= top ||
          elementTop >= bottom ||
          priorityIds.contains(view.pageNum)) {
        continue;
      }

      if (view.pageNum >= currentPage) {
        nextViews.add(view);
      } else {
        previousViews.add(view);
      }
    }

    if (_isScrollingDown) {
      priorityViews
        ..addAll(nextViews)
        ..addAll(previousViews.reversed);
    } else {
      priorityViews
        ..addAll(previousViews.reversed)
        ..addAll(nextViews);
    }

    final allowedIds = priorityViews.map((view) => view.pageNum).toSet();
    _renderingQueue.schedule(
      priorityViews,
      cancelActiveOutsidePageIds: allowedIds,
    );
  }

  void _updateToolbarResponsiveState() {
    final nextWidth = toolbarContainer?.clientWidth ?? 0;
    if (_toolbarWidth == nextWidth) {
      return;
    }
    _toolbarWidth = nextWidth;
    _syncActionOptions();
    _changeDetectorRef.markForCheck();
  }

  Future<bool> _requestNativeFullscreen() async {
    try {
      if (js_util.hasProperty(_hostElement, 'requestFullscreen')) {
        final result = js_util.callMethod<Object?>(
          _hostElement,
          'requestFullscreen',
          const <Object?>[],
        );
        if (result != null) {
          await js_util.promiseToFuture<Object?>(result);
        }
      } else if (js_util.hasProperty(_hostElement, 'webkitRequestFullscreen')) {
        js_util.callMethod<Object?>(
          _hostElement,
          'webkitRequestFullscreen',
          const <Object?>[],
        );
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }

    _syncFullscreenState();
    return _isNativeFullscreenActive;
  }

  Future<void> _exitNativeFullscreen() async {
    final document = html.document;
    try {
      if (js_util.hasProperty(document, 'exitFullscreen')) {
        final result = js_util.callMethod<Object?>(
          document,
          'exitFullscreen',
          const <Object?>[],
        );
        if (result != null) {
          await js_util.promiseToFuture<Object?>(result);
        }
      } else if (js_util.hasProperty(document, 'webkitExitFullscreen')) {
        js_util.callMethod<Object?>(
          document,
          'webkitExitFullscreen',
          const <Object?>[],
        );
      }
    } catch (_) {
      _exitFallbackFullscreen();
    }
    _syncFullscreenState();
  }

  void _enterFallbackFullscreen() {
    if (_isFallbackFullscreen) {
      return;
    }
    final body = html.document.body;
    _previousBodyOverflow = body?.style.overflow;
    body?.style.overflow = 'hidden';
    _hostElement.classes.add('pdf-viewer-viewport-fullscreen');
    _isFallbackFullscreen = true;
  }

  void _exitFallbackFullscreen() {
    if (!_isFallbackFullscreen) {
      return;
    }
    _hostElement.classes.remove('pdf-viewer-viewport-fullscreen');
    final body = html.document.body;
    body?.style.overflow = _previousBodyOverflow ?? '';
    _previousBodyOverflow = null;
    _isFallbackFullscreen = false;
  }

  void _syncFullscreenState() {
    if (_isNativeFullscreenActive && _isFallbackFullscreen) {
      _exitFallbackFullscreen();
    }
    if (!_isNativeFullscreenActive && !_isFallbackFullscreen) {
      _hostElement.classes.remove('pdf-viewer-viewport-fullscreen');
    }
    _syncActionOptions();
    _changeDetectorRef.markForCheck();
  }

  String resolveCustomToolbarActionLabel(LiPdfViewerToolbarAction action) {
    final resolved = action.labelBuilder?.call(this) ?? action.label;
    return resolved.trim();
  }

  String resolveCustomToolbarActionTitle(LiPdfViewerToolbarAction action) {
    final resolved = action.titleBuilder?.call(this) ?? action.title;
    final normalized = resolved.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }

    final label = resolveCustomToolbarActionLabel(action);
    return label.isNotEmpty ? label : action.id;
  }

  String resolveCustomToolbarActionIconClass(LiPdfViewerToolbarAction action) {
    final resolved = action.iconClassBuilder?.call(this) ?? action.iconClass;
    final normalized = resolved.trim();
    return normalized.isEmpty ? action.iconClass : normalized;
  }

  String resolveCustomToolbarActionButtonClass(
    LiPdfViewerToolbarAction action,
  ) {
    final customClass = action.buttonClass.trim();
    return <String>[
      'btn',
      'btn-light',
      'btn-icon',
      'btn-sm',
      'rounded-pill',
      'border-transparent',
      'li-pdf-viewer__toolbar-button',
      'li-pdf-viewer__custom-toolbar-button',
      if (customClass.isNotEmpty) customClass,
      if (isCustomToolbarActionActive(action)) 'is-active',
    ].join(' ');
  }

  bool isCustomToolbarActionDisabled(LiPdfViewerToolbarAction action) {
    return action.disabledBuilder?.call(this) ?? action.disabled;
  }

  bool isCustomToolbarActionActive(LiPdfViewerToolbarAction action) {
    return action.activeBuilder?.call(this) ?? action.active;
  }

  LiPdfViewerToolbarAction? _resolveCustomAction(String actionValue) {
    if (!actionValue.startsWith(_customActionMenuValuePrefix)) {
      return null;
    }

    final actionId = actionValue.substring(_customActionMenuValuePrefix.length);
    for (final action in customToolbarActions) {
      if (action.id == actionId) {
        return action;
      }
    }
    return null;
  }

  String _customActionMenuValue(LiPdfViewerToolbarAction action) {
    return '$_customActionMenuValuePrefix${action.id}';
  }

  void _updateSidePanelOpen(bool value, {bool emit = true}) {
    final nextValue = value && hasSidePanelTemplate;
    if (_sidePanelOpen == nextValue) {
      _syncSidePanelPresentationState();
      return;
    }

    _sidePanelOpen = nextValue;
    _syncActionOptions();
    _syncSidePanelPresentationState();
    if (emit) {
      _sidePanelOpenChangeController.add(_sidePanelOpen);
    }
    _changeDetectorRef.markForCheck();
  }

  void _syncSidePanelPresentationState() {
    if (sidePanelModal == null ||
        !hasSidePanelTemplate ||
        !sidePanelModalOnMobile) {
      return;
    }

    if (isMobileViewport) {
      if (sidePanelOpen) {
        scheduleMicrotask(() {
          if (sidePanelOpen && isMobileViewport) {
            sidePanelModal?.open();
          }
        });
      } else {
        sidePanelModal?.close();
      }
      return;
    }

    sidePanelModal?.close();
  }

  void _handleKeyDown(html.KeyboardEvent event) {
    if (!allowKeyboardShortcuts) {
      return;
    }
    if (event.target is html.InputElement ||
        event.target is html.TextAreaElement) {
      return;
    }

    final isCtrl = event.ctrlKey || event.metaKey;
    if (isCtrl) {
      switch (event.key) {
        case '+':
        case '=':
          zoomIn();
          event.preventDefault();
          break;
        case '-':
          zoomOut();
          event.preventDefault();
          break;
        case '0':
          _setScale('page-actual');
          event.preventDefault();
          break;
      }
      return;
    }

    switch (event.key) {
      case 'PageDown':
      case 'ArrowDown':
        nextPage();
        event.preventDefault();
        break;
      case 'PageUp':
      case 'ArrowUp':
        previousPage();
        event.preventDefault();
        break;
    }
  }

  void _handlePointerDown(html.PointerEvent event) {
    if (event.pointerType == 'mouse') {
      if (!_canStartMousePan(event)) {
        return;
      }
      event.preventDefault();
      viewerContainer?.focus();
      _mousePanPointerId = event.pointerId;
      _capturePointer(event.pointerId);
      _mousePanStartPoint = Point<num>(event.client.x, event.client.y);
      _mousePanStartScrollTop = viewerContainer?.scrollTop ?? 0;
      _mousePanStartScrollLeft = viewerContainer?.scrollLeft ?? 0;
      _mousePanCandidate = true;
      _isMousePanning = false;
      return;
    }

    if (event.pointerType != 'touch') {
      return;
    }

    final int? pointerId = event.pointerId;
    if (pointerId == null) {
      return;
    }
    _activeTouchPointers[pointerId] = event;
    if (_activeTouchPointers.length == 1) {
      _mousePanPointerId = pointerId;
      _capturePointer(pointerId);
      _mousePanStartPoint = Point<num>(event.client.x, event.client.y);
      _mousePanStartScrollTop = viewerContainer?.scrollTop ?? 0;
      _mousePanStartScrollLeft = viewerContainer?.scrollLeft ?? 0;
      _mousePanCandidate = true;
      _isMousePanning = false;
      return;
    }

    if (_activeTouchPointers.length == 2) {
      _endMousePan(null);
      _pinchStartDistance = _currentPinchDistance;
      _pinchStartScale = _scale;
    }
  }

  void _handlePointerMove(html.PointerEvent event) {
    if (event.pointerType == 'mouse') {
      _handleMousePanMove(event);
      return;
    }

    final int? pointerId = event.pointerId;
    if (event.pointerType != 'touch' ||
        pointerId == null ||
        !_activeTouchPointers.containsKey(pointerId)) {
      return;
    }

    _activeTouchPointers[pointerId] = event;
    if (_activeTouchPointers.length == 1) {
      _handleMousePanMove(event);
      return;
    }
    if (_activeTouchPointers.length != 2) {
      return;
    }

    final startDistance = _pinchStartDistance;
    final startScale = _pinchStartScale;
    final currentDistance = _currentPinchDistance;
    final currentCenter = _currentPinchCenter;
    if (startDistance == null ||
        startScale == null ||
        currentDistance == null ||
        currentCenter == null ||
        startDistance <= 0) {
      return;
    }

    event.preventDefault();
    final nextScale = startScale * (currentDistance / startDistance);
    _scheduleZoom(nextScale, currentCenter);
  }

  void _handlePointerEnd(html.PointerEvent event) {
    if (event.pointerType == 'mouse') {
      _endMousePan(event.pointerId);
      return;
    }

    if (event.pointerType != 'touch') {
      return;
    }

    _activeTouchPointers.remove(event.pointerId);
    if (_mousePanPointerId == event.pointerId) {
      _endMousePan(event.pointerId);
    }
    if (_activeTouchPointers.length < 2) {
      _pinchStartDistance = null;
      _pinchStartScale = null;
      if (_activeTouchPointers.length == 1) {
        final remainingPointer = _activeTouchPointers.values.first;
        _mousePanPointerId = remainingPointer.pointerId;
        _capturePointer(remainingPointer.pointerId);
        _mousePanStartPoint = Point<num>(
          remainingPointer.client.x,
          remainingPointer.client.y,
        );
        _mousePanStartScrollTop = viewerContainer?.scrollTop ?? 0;
        _mousePanStartScrollLeft = viewerContainer?.scrollLeft ?? 0;
        _mousePanCandidate = true;
        _isMousePanning = false;
      }
    } else {
      _pinchStartDistance = _currentPinchDistance;
      _pinchStartScale = _scale;
    }
  }

  void _handleTouchStart(html.TouchEvent event) {
    if (_activeTouchPointers.length >= 2) {
      return;
    }
    final touches = event.touches;
    if (touches == null || touches.length < 2) {
      _touchPinchStartDistance = null;
      _touchPinchStartScale = null;
      return;
    }
    _touchPinchStartDistance = _distanceBetweenTouches(touches[0], touches[1]);
    _touchPinchStartScale = _scale;
  }

  void _handleTouchMove(html.TouchEvent event) {
    if (_activeTouchPointers.length >= 2) {
      return;
    }
    final touches = event.touches;
    if (touches == null || touches.length < 2) {
      return;
    }

    final startDistance = _touchPinchStartDistance;
    final startScale = _touchPinchStartScale;
    if (startDistance == null || startScale == null || startDistance <= 0) {
      _handleTouchStart(event);
      return;
    }

    event.preventDefault();
    final currentDistance = _distanceBetweenTouches(touches[0], touches[1]);
    final currentCenter = _centerBetweenTouches(touches[0], touches[1]);
    final nextScale = startScale * (currentDistance / startDistance);
    _scheduleZoom(nextScale, currentCenter);
  }

  void _handleTouchEnd(html.TouchEvent event) {
    if (_activeTouchPointers.length >= 2) {
      return;
    }
    final touches = event.touches;
    if (touches == null || touches.length < 2) {
      _touchPinchStartDistance = null;
      _touchPinchStartScale = null;
      return;
    }
    _touchPinchStartDistance = _distanceBetweenTouches(touches[0], touches[1]);
    _touchPinchStartScale = _scale;
  }

  bool _canStartMousePan(html.PointerEvent event) {
    if (event.button == 1) {
      return true;
    }
    if (event.button != 0 || event.altKey) {
      return false;
    }
    return event.ctrlKey || event.metaKey || _isPanModeEnabled;
  }

  void _handleMousePanMove(html.PointerEvent event) {
    final startPoint = _mousePanStartPoint;
    final container = viewerContainer;
    if (container == null ||
        event.pointerId != _mousePanPointerId ||
        startPoint == null ||
        !_mousePanCandidate) {
      return;
    }

    final deltaX = event.client.x - startPoint.x;
    final deltaY = event.client.y - startPoint.y;
    if (!_isMousePanning) {
      if (deltaX.abs() < 3 && deltaY.abs() < 3) {
        return;
      }
      _isMousePanning = true;
      container.classes.add('mouse-panning');
    }

    event.preventDefault();
    container.scrollLeft = _mousePanStartScrollLeft - deltaX.round();
    container.scrollTop = _mousePanStartScrollTop - deltaY.round();
  }

  void _endMousePan(int? pointerId) {
    if (pointerId != null &&
        _mousePanPointerId != null &&
        pointerId != _mousePanPointerId) {
      return;
    }
    _releasePointer(_mousePanPointerId);
    viewerContainer?.classes.remove('mouse-panning');
    _mousePanPointerId = null;
    _mousePanStartPoint = null;
    _mousePanStartScrollTop = 0;
    _mousePanStartScrollLeft = 0;
    _mousePanCandidate = false;
    _isMousePanning = false;
  }

  void _capturePointer(int? pointerId) {
    final container = viewerContainer;
    if (container == null || pointerId == null) {
      return;
    }
    try {
      if (js_util.hasProperty(container, 'setPointerCapture')) {
        js_util.callMethod<void>(container, 'setPointerCapture', <Object?>[
          pointerId,
        ]);
      }
    } catch (_) {}
  }

  void _releasePointer(int? pointerId) {
    final container = viewerContainer;
    if (container == null || pointerId == null) {
      return;
    }
    try {
      if (js_util.hasProperty(container, 'releasePointerCapture')) {
        js_util.callMethod<void>(container, 'releasePointerCapture', <Object?>[
          pointerId,
        ]);
      }
    } catch (_) {}
  }

  double _distanceBetweenTouches(html.Touch first, html.Touch second) {
    return sqrt(
      pow(first.client.x - second.client.x, 2) +
          pow(first.client.y - second.client.y, 2),
    ).toDouble();
  }

  Point<num> _centerBetweenTouches(html.Touch first, html.Touch second) {
    return Point<num>(
      (first.client.x + second.client.x) / 2,
      (first.client.y + second.client.y) / 2,
    );
  }

  double? get _currentPinchDistance {
    if (_activeTouchPointers.length < 2) {
      return null;
    }
    final pointers =
        _activeTouchPointers.values.take(2).toList(growable: false);
    return sqrt(
      pow(pointers[0].client.x - pointers[1].client.x, 2) +
          pow(pointers[0].client.y - pointers[1].client.y, 2),
    ).toDouble();
  }

  Point<num>? get _currentPinchCenter {
    if (_activeTouchPointers.length < 2) {
      return null;
    }
    final pointers =
        _activeTouchPointers.values.take(2).toList(growable: false);
    return Point<num>(
      (pointers[0].client.x + pointers[1].client.x) / 2,
      (pointers[0].client.y + pointers[1].client.y) / 2,
    );
  }

  void _disposeBrowserListeners() {
    _keyDownSub?.cancel();
    _scrollSub?.cancel();
    _wheelSub?.cancel();
    _pointerDownSub?.cancel();
    _pointerMoveSub?.cancel();
    _pointerUpSub?.cancel();
    _pointerCancelSub?.cancel();
    _touchStartSub?.cancel();
    _touchMoveSub?.cancel();
    _touchEndSub?.cancel();
    _touchCancelSub?.cancel();
    _fullscreenChangeSub?.cancel();
    _webkitFullscreenChangeSub?.cancel();
  }

  void _disposePrintArtifacts() {
    _printFrame?.remove();
    if (_printObjectUrl != null) {
      liPdfViewerBrowserBridge.revokeObjectUrl(_printObjectUrl!);
      _printObjectUrl = null;
    }
    _afterPrintSubscription?.cancel();
    _afterPrintSubscription = null;
  }

  void _log(String message) {
    if (!debug) {
      return;
    }
  }

  List<LiPdfViewerPageTextItem> _mapPageTextItems(List<dynamic> rawItems) {
    final items = <LiPdfViewerPageTextItem>[];
    for (final rawItem in rawItems) {
      if (rawItem is! PDFTextItem) {
        continue;
      }
      final text = rawItem.str ?? '';
      if (text.isEmpty && rawItem.hasEOL != true) {
        continue;
      }
      items.add(
        LiPdfViewerPageTextItem(
          text: text,
          direction: rawItem.dir ?? '',
          width: rawItem.width?.toDouble() ?? 0,
          height: rawItem.height?.toDouble() ?? 0,
          hasEndOfLine: rawItem.hasEOL ?? false,
          fontName: rawItem.fontName ?? '',
          transform: (rawItem.transform ?? const <num>[])
              .map((value) => value.toDouble())
              .toList(growable: false),
        ),
      );
    }
    return List<LiPdfViewerPageTextItem>.unmodifiable(items);
  }

  String _joinPageTextItems(
    List<LiPdfViewerPageTextItem> items, {
    required bool trim,
  }) {
    final buffer = StringBuffer();
    for (final item in items) {
      buffer.write(item.text);
      if (item.hasEndOfLine) {
        buffer.write('\n');
      }
    }
    final text = buffer.toString();
    return trim ? text.trim() : text;
  }
}
