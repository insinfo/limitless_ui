import 'dart:html' as html;
import 'dart:typed_data';

import 'package:ngx_dart/angular.dart';

import 'pdf_viewer_page_view.dart';
import 'pdf_viewer_pdfjs_bridge.dart';
import 'pdfjs_bindings.dart';

class PdfViewerDocumentController {
  PdfViewerDocumentController({
    required ChangeDetectorRef changeDetectorRef,
    required double Function() scaleProvider,
    required int Function() rotationProvider,
    required void Function(int pageNumber) scrollToPage,
    required void Function(String message) onLog,
  })  : _changeDetectorRef = changeDetectorRef,
        _scaleProvider = scaleProvider,
        _rotationProvider = rotationProvider,
        _scrollToPage = scrollToPage,
        _onLog = onLog;

  final ChangeDetectorRef _changeDetectorRef;
  final double Function() _scaleProvider;
  final int Function() _rotationProvider;
  final void Function(int pageNumber) _scrollToPage;
  final void Function(String message) _onLog;

  PDFDocumentProxy? document;
  final List<PdfPageView> pageViews = <PdfPageView>[];
  html.IntersectionObserver? intersectionObserver;
  void Function(PdfPageView pageView)? onPageVisible;
  int totalPages = 0;

  Future<void> dispose() async {
    intersectionObserver?.disconnect();
    for (final pageView in pageViews) {
      pageView.reset();
    }
    pageViews.clear();
    totalPages = 0;

    final activeDocument = document;
    if (activeDocument != null) {
      try {
        activeDocument.destroy();
      } catch (_) {}
      document = null;
    }
  }

  Future<void> loadDocument({
    required dynamic source,
    required html.DivElement? viewerElement,
    required Map<String, String> requestHeaders,
    required String standardFontDataUrl,
    required String cMapUrl,
    required bool cMapPacked,
    required String? Function(String rawUrl)? sanitizeAnnotationUrl,
  }) async {
    await dispose();
    viewerElement?.children.clear();

    final Map<String, dynamic> documentSource;
    if (source is String) {
      final trimmed = source.trim();
      if (trimmed.isEmpty) {
        throw StateError('Invalid PDF URL source.');
      }
      documentSource = <String, dynamic>{
        'url': trimmed,
        if (requestHeaders.isNotEmpty) 'httpHeaders': requestHeaders,
        'withCredentials': false,
        'disableRange': false,
        'disableStream': false,
        'disableAutoFetch': false,
        'rangeChunkSize': 65536,
      };
    } else if (source is Uint8List) {
      documentSource = <String, dynamic>{
        'data': Uint8List.fromList(source),
      };
    } else {
      throw StateError('Invalid PDF source.');
    }

    final loadingTask = liPdfViewerPdfJsBridge.getDocument(<String, dynamic>{
      ...documentSource,
      'standardFontDataUrl': standardFontDataUrl,
      'cMapUrl': cMapUrl,
      'cMapPacked': cMapPacked,
    });

    document = await loadingTask.load();
    totalPages = document!.numPages;
    _changeDetectorRef.markForCheck();

    await _setupPages(
      viewerElement,
      sanitizeAnnotationUrl: sanitizeAnnotationUrl,
    );
  }

  Future<void> _setupPages(
    html.DivElement? viewerElement, {
    required String? Function(String rawUrl)? sanitizeAnnotationUrl,
  }) async {
    final activeDocument = document;
    if (activeDocument == null || viewerElement == null) {
      return;
    }

    final firstPdfPage = await activeDocument.getPageDart(1);

    for (var pageNum = 1; pageNum <= totalPages; pageNum++) {
      final pageDiv = html.DivElement()
        ..className = 'page'
        ..attributes['data-page-number'] = '$pageNum';

      final wrapper = html.DivElement()..className = 'canvasWrapper';
      pageDiv.append(wrapper);
      viewerElement.append(pageDiv);

      final pageView = PdfPageView(
        pageNum,
        _changeDetectorRef,
        pageDiv,
        _navigateToDest,
        sanitizeAnnotationUrl,
        _onLog,
      )..canvasWrapper = wrapper;
      pageViews.add(pageView);
    }

    final firstPageView = pageViews.first;
    firstPageView.setPdfPage(firstPdfPage);
    firstPageView.updateViewport(_scaleProvider(), _rotationProvider());
    _changeDetectorRef.markForCheck();
  }

  void setupIntersectionObserver({html.DivElement? viewerContainer}) {
    if (viewerContainer == null) {
      return;
    }

    final options = <String, Object?>{
      'root': viewerContainer,
      'rootMargin': '1000px 0px 1000px 0px',
    };

    intersectionObserver = html.IntersectionObserver((entries, observer) {
      for (final entry in entries) {
        if (!entry.isIntersecting) {
          continue;
        }
        final pageNum =
            int.tryParse(entry.target.attributes['data-page-number'] ?? '');
        if (pageNum == null) {
          continue;
        }
        final pageView = pageViews[pageNum - 1];
        if (pageView.renderingState != RenderingState.initial) {
          continue;
        }
        final callback = onPageVisible;
        if (callback != null) {
          callback(pageView);
        } else {
          renderPage(pageView);
        }
      }
    }, options);

    for (final pageView in pageViews) {
      intersectionObserver!.observe(pageView.div);
    }
  }

  Future<void> renderPage(PdfPageView pageView) async {
    final activeDocument = document;
    if (activeDocument == null) {
      return;
    }

    if (pageView.pdfPage == null) {
      try {
        pageView.setPdfPage(await activeDocument.getPageDart(pageView.pageNum));
      } catch (error) {
        _onLog('Error loading PDF page ${pageView.pageNum}: $error');
        return;
      }
    }

    pageView.updateViewport(_scaleProvider(), _rotationProvider());
    await pageView.draw();
  }

  Future<void> _navigateToDest(dynamic dest) async {
    final activeDocument = document;
    if (activeDocument == null || dest == null) {
      return;
    }

    dynamic destinationArray = dest;
    if (dest is String) {
      try {
        final destinations = await activeDocument.getDestinationsDart();
        if (destinations is Map && destinations.containsKey(dest)) {
          destinationArray = destinations[dest];
        } else {
          return;
        }
      } catch (error) {
        _onLog('Error resolving destination $dest: $error');
        return;
      }
    }

    if (destinationArray is List && destinationArray.isNotEmpty) {
      final pageRef = destinationArray.first;
      int? pageIndex;
      if (pageRef is int) {
        pageIndex = pageRef;
        if (pageIndex > 0) {
          pageIndex -= 1;
        }
      } else {
        try {
          pageIndex = await activeDocument.getPageIndexDart(pageRef);
        } catch (error) {
          _onLog('Error resolving destination page index: $error');
        }
      }

      if (pageIndex != null) {
        _scrollToPage(pageIndex + 1);
      }
    }
  }
}