import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:math';

import 'package:ngx_dart/angular.dart';

import 'pdf_viewer_pdfjs_bridge.dart';
import 'pdfjs_bindings.dart';

const double liPdfViewerMinScale = 0.25;
const double liPdfViewerMaxScale = 10.0;
const double liPdfViewerDefaultScale = 1.0;
const String liPdfViewerDefaultScaleValue = 'auto';
const int liPdfViewerZoomUpdateDebounceMs = 100;
const double liPdfViewerMaxAutoScale = 1.25;
const int liPdfViewerDefaultCacheSize = 10;
const int liPdfViewerMaxCanvasPixels = 4096 * 4096;
const int liPdfViewerMaxCanvasDimension = 4096;
const double liPdfViewerMinCanvasPixelRatio = 0.25;

enum RenderingState { initial, rendering, paused, finished, zooming }

class PdfPageView {
  PdfPageView(
    this.pageNum,
    this._changeDetectorRef,
    this.div,
    this._onNavigateToDest,
    this._sanitizeAnnotationUrl,
    this._onLog,
  );

  final int pageNum;
  final ChangeDetectorRef _changeDetectorRef;
  final html.DivElement div;
  final Future<void> Function(dynamic dest)? _onNavigateToDest;
  final String? Function(String rawUrl)? _sanitizeAnnotationUrl;
  final void Function(String message) _onLog;

  PDFPageProxy? pdfPage;
  PageViewport? viewport;
  RenderingState renderingState = RenderingState.initial;

  html.CanvasElement? _outputCanvas;
  html.CanvasElement? get canvas => _outputCanvas;
  html.DivElement? textLayerDiv;
  html.DivElement? annotationLayerDiv;
  RenderTask? _renderTask;
  html.DivElement? canvasWrapper;

  double _renderedScale = 1.0;
  double? _baseWidth;
  double? _baseHeight;

  bool get isRendering => renderingState == RenderingState.rendering;

  void cancelRender() {
    final renderTask = _renderTask;
    if (renderTask == null) {
      return;
    }
    try {
      renderTask.cancel();
    } catch (_) {}
    _renderTask = null;
  }

  void setPdfPage(PDFPageProxy page) {
    pdfPage = page;
    final baseViewport = page.getViewport(
      ViewportParams(scale: 1.0, rotation: 0),
    );
    _baseWidth = baseViewport.width.toDouble();
    _baseHeight = baseViewport.height.toDouble();
  }

  void updateViewport(double scale, int rotation) {
    final activePage = pdfPage;
    if (activePage != null) {
      viewport = activePage.getViewport(
        ViewportParams(scale: scale, rotation: rotation.toDouble()),
      );
    } else if (_baseWidth != null && _baseHeight != null) {
      final normalizedRotation = rotation % 180;
      final width = normalizedRotation == 0 ? _baseWidth! : _baseHeight!;
      final height = normalizedRotation == 0 ? _baseHeight! : _baseWidth!;
      div.style
        ..width = '${width * scale}px'
        ..height = '${height * scale}px'
        ..setProperty('--scale-factor', scale.toString());
      return;
    } else {
      return;
    }

    div.style
      ..width = '${viewport!.width}px'
      ..height = '${viewport!.height}px'
      ..setProperty('--scale-factor', scale.toString());
  }

  void applyOrUpdateCssZoom(double currentViewerScale) {
    final outputCanvas = _outputCanvas;
    if (outputCanvas == null) {
      return;
    }

    renderingState = RenderingState.zooming;
    final cssScale = currentViewerScale / _renderedScale;
    outputCanvas.style
      ..transform = 'scale($cssScale)'
      ..transformOrigin = '0 0';

    textLayerDiv?.style.visibility = 'hidden';
    annotationLayerDiv?.style.visibility = 'hidden';
    div.style.overflow = cssScale > 1 ? 'hidden' : 'visible';
  }

  Future<void> draw() async {
    if (pdfPage == null || viewport == null || isRendering) {
      return;
    }

    cancelRender();
    renderingState = RenderingState.rendering;
    _changeDetectorRef.markForCheck();

    final oldCanvas = _outputCanvas;
    final devicePixelRatio = html.window.devicePixelRatio.toDouble();
    var canvasWidth = (viewport!.width * devicePixelRatio).ceil();
    var canvasHeight = (viewport!.height * devicePixelRatio).ceil();
    var pixelRatio = devicePixelRatio;

    while ((canvasWidth * canvasHeight > liPdfViewerMaxCanvasPixels ||
            canvasWidth > liPdfViewerMaxCanvasDimension ||
            canvasHeight > liPdfViewerMaxCanvasDimension) &&
        pixelRatio > liPdfViewerMinCanvasPixelRatio) {
      pixelRatio = max(liPdfViewerMinCanvasPixelRatio, pixelRatio * 0.8);
      canvasWidth = (viewport!.width * pixelRatio).ceil();
      canvasHeight = (viewport!.height * pixelRatio).ceil();
    }

    final newCanvas = html.CanvasElement(width: canvasWidth, height: canvasHeight)
      ..style.width = '${viewport!.width}px'
      ..style.height = '${viewport!.height}px'
      ..style.visibility = 'hidden'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0';

    canvasWrapper?.append(newCanvas);

    final context = newCanvas.context2D;
    context.scale(pixelRatio, pixelRatio);

    final renderContext = RenderParams(
      canvasContext: context,
      viewport: viewport,
    );
    _renderTask = pdfPage!.render(renderContext);

    try {
      await _renderTask!.onFinished;
      _renderTask = null;

      _outputCanvas = newCanvas;
      _renderedScale = viewport!.scale.toDouble();
      _outputCanvas!.style
        ..visibility = 'visible'
        ..transform = ''
        ..position = ''
        ..top = ''
        ..left = '';

      oldCanvas?.remove();
      div.style.overflow = '';

      await _renderTextLayer();
      textLayerDiv?.style.visibility = 'visible';
      await _renderAnnotationLayer();
      annotationLayerDiv?.style.visibility = 'visible';
      renderingState = RenderingState.finished;
    } catch (error) {
      _renderTask = null;
      newCanvas.remove();

      if (error.toString().contains('RenderingCancelledException')) {
        renderingState =
            oldCanvas == null ? RenderingState.initial : RenderingState.zooming;
      } else {
        _onLog('Error rendering PDF page $pageNum: $error');
        reset();
      }
    } finally {
      _changeDetectorRef.markForCheck();
    }
  }

  Future<void> _renderTextLayer() async {
    if (pdfPage == null || viewport == null) {
      return;
    }

    textLayerDiv?.remove();
    textLayerDiv = html.DivElement()..className = 'textLayer';
    div.append(textLayerDiv!);

    try {
      final textContentSource = pdfPage!.streamTextContent(
        TextContentOptions(
          includeMarkedContent: true,
          disableNormalization: true,
        ),
      );
      final textLayer = liPdfViewerPdfJsBridge.createTextLayer(<String, dynamic>{
        'textContentSource': textContentSource,
        'viewport': viewport,
        'container': textLayerDiv,
      });
      await textLayer.renderDart();
    } catch (error) {
      _onLog('Error rendering text layer for page $pageNum: $error');
      textLayerDiv?.remove();
      textLayerDiv = null;
    }
  }

  Future<void> _renderAnnotationLayer() async {
    if (pdfPage == null || viewport == null) {
      return;
    }

    annotationLayerDiv?.remove();
    annotationLayerDiv = html.DivElement()..className = 'annotationLayer';
    div.append(annotationLayerDiv!);

    List<dynamic> annotations;
    try {
      annotations = await pdfPage!.getAnnotationsDart();
    } catch (error) {
      _onLog('Error loading annotations for page $pageNum: $error');
      return;
    }

    for (final annotation in annotations) {
      final subtype = js_util.getProperty(annotation, 'subtype')?.toString();
      if (subtype != 'Link') {
        continue;
      }

      final rectRaw = js_util.getProperty(annotation, 'rect');
      if (rectRaw is! List) {
        continue;
      }
      final rect = rectRaw.map((value) => (value as num).toDouble()).toList();
      final viewportRect = viewport!.convertToViewportRectangle(rect);
      if (viewportRect.length < 4) {
        continue;
      }

      final x1 = viewportRect[0];
      final y1 = viewportRect[1];
      final x2 = viewportRect[2];
      final y2 = viewportRect[3];
      final left = min(x1, x2);
      final top = min(y1, y2);
      final width = (x1 - x2).abs();
      final height = (y1 - y2).abs();

      if (width <= 0 || height <= 0) {
        continue;
      }

      final urlProp = js_util.getProperty(annotation, 'url');
      final unsafeUrlProp = js_util.getProperty(annotation, 'unsafeUrl');
      final dest = js_util.getProperty(annotation, 'dest');
      final url = urlProp?.toString() ?? unsafeUrlProp?.toString();
      if (url == null && dest == null) {
        continue;
      }

      final link = html.AnchorElement()
        ..style.position = 'absolute'
        ..style.left = '${left}px'
        ..style.top = '${top}px'
        ..style.width = '${width}px'
        ..style.height = '${height}px'
        ..style.cursor = 'pointer'
        ..style.textDecoration = 'none';

      final safeUrl = url == null || url.isEmpty
          ? null
          : _sanitizeAnnotationUrl?.call(url);

      if (safeUrl != null && safeUrl.isNotEmpty) {
        link.href = safeUrl;
        link.target = '_blank';
        link.rel = 'noopener noreferrer';
      } else {
        if (dest == null) {
          continue;
        }
        link.href = '#';
        link.onClick.listen((event) {
          event.preventDefault();
          final navigate = _onNavigateToDest;
          if (navigate != null) {
            navigate(dest);
          }
        });
      }

      annotationLayerDiv!.append(link);
    }
  }

  void reset() {
    cancelRender();
    canvasWrapper?.children.clear();
    textLayerDiv?.remove();
    textLayerDiv = null;
    annotationLayerDiv?.remove();
    annotationLayerDiv = null;
    _outputCanvas = null;
    renderingState = RenderingState.initial;
    _renderedScale = 1.0;
  }

  void destroy() {
    reset();
    try {
      pdfPage?.cleanup();
    } catch (_) {}
    pdfPage = null;
    viewport = null;
  }
}