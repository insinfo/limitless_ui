import 'dart:js_util' as js_util;
import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:limitless_ui/src/components/pdf_viewer/pdf_viewer_pdfjs_bridge.dart';
import 'package:limitless_ui/src/components/pdf_viewer/pdfjs_bindings.dart';

@JS('Promise.resolve')
external Object _promiseResolve(dynamic value);

@JS('Promise.reject')
external Object _promiseReject(dynamic error);

class FakePdfDocumentState {
  int destroyCalls = 0;
  int getDataCalls = 0;
  int getDestinationsCalls = 0;
  int getPageIndexCalls = 0;
  final List<dynamic> pageIndexRefs = <dynamic>[];
}

class FakePdfJsBridge implements LiPdfViewerPdfJsBridge {
  FakePdfJsBridge({
    required this.documentFactory,
    this.loadError,
  });

  final PDFDocumentProxy Function(Map<String, dynamic> source) documentFactory;
  final Object? loadError;

  String? configuredWorkerSrc;
  final List<Map<String, dynamic>> documentRequests = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> textLayerRequests =
      <Map<String, dynamic>>[];

  @override
  void configureWorker(String src) {
    configuredWorkerSrc = src;
  }

  @override
  TextLayer createTextLayer(Map<String, dynamic> options) {
    textLayerRequests.add(Map<String, dynamic>.from(options));
    final jsTextLayer = js_util.newObject();
    js_util.setProperty(
      jsTextLayer,
      'render',
      allowInterop(() => _promiseResolve(null)),
    );
    return jsTextLayer as dynamic;
  }

  @override
  PDFDocumentLoadingTask getDocument(Map<String, dynamic> source) {
    documentRequests.add(Map<String, dynamic>.from(source));

    final jsTask = js_util.newObject();
    js_util.setProperty(jsTask, 'cancel', allowInterop(() {}));
    final error = loadError;
    js_util.setProperty(
      jsTask,
      'promise',
      error == null
          ? _promiseResolve(documentFactory(source))
          : _promiseReject(error),
    );
    return jsTask as dynamic;
  }
}

PDFDocumentProxy createFakePdfDocument({
  int numPages = 1,
  double pageWidth = 612,
  double pageHeight = 792,
  FakePdfDocumentState? state,
  Map<String, dynamic> destinations = const <String, dynamic>{},
  int Function(dynamic ref)? pageIndexResolver,
  Uint8List? data,
  List<dynamic> annotations = const <dynamic>[],
  List<dynamic> textItems = const <dynamic>[],
}) {
  final documentState = state ?? FakePdfDocumentState();
  final pages = <int, PDFPageProxy>{
    for (var pageNum = 1; pageNum <= numPages; pageNum++)
      pageNum: createFakePdfPage(
        pageNum: pageNum,
        width: pageWidth,
        height: pageHeight,
        annotations: annotations,
        textItems: textItems,
      ),
  };

  final jsDocument = js_util.newObject();
  js_util.setProperty(jsDocument, 'numPages', numPages);
  js_util.setProperty(
    jsDocument,
    'getPage',
    allowInterop((int pageNum) {
      final page = pages[pageNum];
      if (page == null) {
        return _promiseReject(StateError('Missing fake page $pageNum'));
      }
      return _promiseResolve(page);
    }),
  );
  js_util.setProperty(jsDocument, 'destroy', allowInterop(() {
    documentState.destroyCalls += 1;
    return null;
  }));
  js_util.setProperty(
    jsDocument,
    'getDestinations',
    allowInterop(() {
      documentState.getDestinationsCalls += 1;
      return _promiseResolve(destinations);
    }),
  );
  js_util.setProperty(
    jsDocument,
    'getPageIndex',
    allowInterop((dynamic ref) {
      documentState.getPageIndexCalls += 1;
      documentState.pageIndexRefs.add(ref);
      return _promiseResolve(pageIndexResolver?.call(ref) ?? 0);
    }),
  );
  js_util.setProperty(
    jsDocument,
    'getData',
    allowInterop(() {
      documentState.getDataCalls += 1;
      return _promiseResolve(
        data ?? Uint8List.fromList(<int>[37, 80, 68, 70]),
      );
    }),
  );
  return jsDocument as dynamic;
}

dynamic createFakeLinkAnnotation({
  List<num> rect = const <num>[0, 0, 120, 20],
  String? url,
  String? unsafeUrl,
  dynamic dest,
}) {
  final annotation = js_util.newObject();
  js_util.setProperty(annotation, 'subtype', 'Link');
  js_util.setProperty(annotation, 'rect', rect);
  if (url != null) {
    js_util.setProperty(annotation, 'url', url);
  }
  if (unsafeUrl != null) {
    js_util.setProperty(annotation, 'unsafeUrl', unsafeUrl);
  }
  if (dest != null) {
    js_util.setProperty(annotation, 'dest', dest);
  }
  return annotation;
}

PDFPageProxy createFakePdfPage({
  required int pageNum,
  required double width,
  required double height,
  List<dynamic> annotations = const <dynamic>[],
  List<dynamic> textItems = const <dynamic>[],
}) {
  final jsPage = js_util.newObject();
  js_util.setProperty(
    jsPage,
    'getViewport',
    allowInterop((dynamic params) {
      final scale = js_util.getProperty<num>(params, 'scale').toDouble();
      final rotation = js_util.getProperty<num>(params, 'rotation').toDouble();
      return _createViewport(
        width: width * scale,
        height: height * scale,
        rotation: rotation,
        scale: scale,
      );
    }),
  );
  js_util.setProperty(
    jsPage,
    'render',
    allowInterop((dynamic _) {
      final jsTask = js_util.newObject();
      js_util.setProperty(jsTask, 'cancel', allowInterop(() {}));
      js_util.setProperty(
        jsTask,
        'promise',
        _promiseResolve(null),
      );
      return jsTask;
    }),
  );
  js_util.setProperty(
    jsPage,
    'getTextContent',
    allowInterop(
      ([dynamic _]) => _promiseResolve(
        js_util.jsify(<String, dynamic>{
          'items': textItems,
          'styles': const <String, dynamic>{},
          'lang': 'pt-BR',
        }),
      ),
    ),
  );
  js_util.setProperty(
    jsPage,
    'getAnnotations',
    allowInterop((dynamic _) => _promiseResolve(annotations)),
  );
  js_util.setProperty(jsPage, 'cleanup', allowInterop(() => null));
  js_util.setProperty(
    jsPage,
    'streamTextContent',
    allowInterop(
      (dynamic _) => <String, dynamic>{
        'items': const <dynamic>[],
        'styles': const <String, dynamic>{},
        'lang': 'pt-BR',
      },
    ),
  );
  js_util.setProperty(jsPage, 'pageNumber', pageNum);
  return jsPage as dynamic;
}

PageViewport _createViewport({
  required double width,
  required double height,
  required double rotation,
  required double scale,
}) {
  final jsViewport = js_util.newObject();
  js_util.setProperty(jsViewport, 'width', width);
  js_util.setProperty(jsViewport, 'height', height);
  js_util.setProperty(jsViewport, 'rotation', rotation);
  js_util.setProperty(jsViewport, 'scale', scale);
  js_util.setProperty(
    jsViewport,
    'rawDims',
    js_util.jsify(<String, num>{
      'pageWidth': width,
      'pageHeight': height,
      'pageX': 0,
      'pageY': 0,
    }),
  );
  js_util.setProperty(
    jsViewport,
    'convertToViewportRectangle',
    allowInterop((List<num> rect) => rect),
  );
  return jsViewport as dynamic;
}

dynamic createFakeTextItem({
  required String text,
  bool hasEndOfLine = false,
  String direction = 'ltr',
  double width = 0,
  double height = 0,
  String fontName = 'f1',
  List<num> transform = const <num>[1, 0, 0, 1, 0, 0],
}) {
  return js_util.jsify(<String, Object?>{
    'str': text,
    'dir': direction,
    'width': width,
    'height': height,
    'hasEOL': hasEndOfLine,
    'fontName': fontName,
    'transform': transform,
  });
}
