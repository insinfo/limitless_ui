import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:limitless_ui/src/components/pdf_viewer/pdf_viewer_pdfjs_bridge.dart';
import 'package:limitless_ui/src/components/pdf_viewer/pdfjs_bindings.dart';

@JS('Promise.resolve')
external JSPromise<JSAny?> _promiseResolve(JSAny? value);

@JS('Promise.reject')
external JSPromise<JSAny?> _promiseReject(JSAny? error);

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
  final List<Map<String, dynamic>> textLayerRequests = <Map<String, dynamic>>[];

  @override
  void configureWorker(String src) {
    configuredWorkerSrc = src;
  }

  @override
  TextLayer createTextLayer(Map<String, dynamic> options) {
    textLayerRequests.add(Map<String, dynamic>.from(options));
    final jsTextLayer = JSObject();
    jsTextLayer.setProperty(
      'render'.toJS,
      (() => _promiseResolve(null)).toJS,
    );
    return jsTextLayer as TextLayer;
  }

  @override
  PDFDocumentLoadingTask getDocument(Map<String, dynamic> source) {
    documentRequests.add(Map<String, dynamic>.from(source));

    final jsTask = JSObject();
    jsTask.setProperty('cancel'.toJS, (() {}).toJS);
    final error = loadError;
    jsTask.setProperty(
      'promise'.toJS,
      error == null
          ? _promiseResolve(documentFactory(source))
          : _promiseReject(error.toString().toJS),
    );
    return jsTask as PDFDocumentLoadingTask;
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

  final jsDocument = JSObject();
  jsDocument.setProperty('numPages'.toJS, numPages.toJS);
  jsDocument.setProperty(
    'getPage'.toJS,
    ((int pageNum) {
      final page = pages[pageNum];
      if (page == null) {
        return _promiseReject('Missing fake page $pageNum'.toJS);
      }
      return _promiseResolve(page);
    }).toJS,
  );
  jsDocument.setProperty(
    'destroy'.toJS,
    (() {
      documentState.destroyCalls += 1;
    }).toJS,
  );
  jsDocument.setProperty(
    'getDestinations'.toJS,
    (() {
      documentState.getDestinationsCalls += 1;
      return _promiseResolve(destinations.jsify());
    }).toJS,
  );
  jsDocument.setProperty(
    'getPageIndex'.toJS,
    ((JSAny? ref) {
      documentState.getPageIndexCalls += 1;
      documentState.pageIndexRefs.add(ref.dartify());
      return _promiseResolve(
        (pageIndexResolver?.call(ref.dartify()) ?? 0).toJS,
      );
    }).toJS,
  );
  jsDocument.setProperty(
    'getData'.toJS,
    (() {
      documentState.getDataCalls += 1;
      return _promiseResolve(
        (data ?? Uint8List.fromList(<int>[37, 80, 68, 70])).toJS,
      );
    }).toJS,
  );
  return jsDocument as PDFDocumentProxy;
}

JSObject createFakeLinkAnnotation({
  List<num> rect = const <num>[0, 0, 120, 20],
  String? url,
  String? unsafeUrl,
  dynamic dest,
}) {
  final annotation = JSObject();
  annotation.setProperty('subtype'.toJS, 'Link'.toJS);
  annotation.setProperty('rect'.toJS, rect.jsify());
  if (url != null) {
    annotation.setProperty('url'.toJS, url.toJS);
  }
  if (unsafeUrl != null) {
    annotation.setProperty('unsafeUrl'.toJS, unsafeUrl.toJS);
  }
  if (dest != null) {
    annotation.setProperty('dest'.toJS, (dest as Object).jsify());
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
  final jsPage = JSObject();
  jsPage.setProperty(
    'getViewport'.toJS,
    ((JSObject params) {
      final scale =
          (params.getProperty('scale'.toJS) as JSNumber?)?.toDartDouble ?? 1;
      final rotation =
          (params.getProperty('rotation'.toJS) as JSNumber?)?.toDartDouble ?? 0;
      return _createViewport(
        width: width * scale,
        height: height * scale,
        rotation: rotation,
        scale: scale,
      );
    }).toJS,
  );
  jsPage.setProperty(
    'render'.toJS,
    ((JSAny? _) {
      final jsTask = JSObject();
      jsTask.setProperty('cancel'.toJS, (() {}).toJS);
      jsTask.setProperty('promise'.toJS, _promiseResolve(null));
      return jsTask;
    }).toJS,
  );
  jsPage.setProperty(
    'getTextContent'.toJS,
    (([JSAny? _]) {
      final content = JSObject();
      content.setProperty(
        'items'.toJS,
        [for (final item in textItems) item as JSAny?].toJS,
      );
      content.setProperty('styles'.toJS, JSObject());
      content.setProperty('lang'.toJS, 'pt-BR'.toJS);
      return _promiseResolve(content);
    }).toJS,
  );
  jsPage.setProperty(
    'getAnnotations'.toJS,
    ((JSAny? _) => _promiseResolve(
          [for (final annotation in annotations) annotation as JSAny?].toJS,
        )).toJS,
  );
  jsPage.setProperty('cleanup'.toJS, (() {}).toJS);
  jsPage.setProperty(
    'streamTextContent'.toJS,
    ((JSAny? _) {
      final stream = JSObject();
      stream.setProperty('items'.toJS, JSArray<JSAny?>());
      stream.setProperty('styles'.toJS, JSObject());
      stream.setProperty('lang'.toJS, 'pt-BR'.toJS);
      return stream;
    }).toJS,
  );
  jsPage.setProperty('pageNumber'.toJS, pageNum.toJS);
  return jsPage as PDFPageProxy;
}

PageViewport _createViewport({
  required double width,
  required double height,
  required double rotation,
  required double scale,
}) {
  final jsViewport = JSObject();
  jsViewport.setProperty('width'.toJS, width.toJS);
  jsViewport.setProperty('height'.toJS, height.toJS);
  jsViewport.setProperty('rotation'.toJS, rotation.toJS);
  jsViewport.setProperty('scale'.toJS, scale.toJS);
  jsViewport.setProperty(
    'rawDims'.toJS,
    <String, num>{
      'pageWidth': width,
      'pageHeight': height,
      'pageX': 0,
      'pageY': 0,
    }.jsify(),
  );
  jsViewport.setProperty(
    'convertToViewportRectangle'.toJS,
    ((JSArray<JSNumber> rect) => rect).toJS,
  );
  return jsViewport as PageViewport;
}

JSObject createFakeTextItem({
  required String text,
  bool hasEndOfLine = false,
  String direction = 'ltr',
  double width = 0,
  double height = 0,
  String fontName = 'f1',
  List<num> transform = const <num>[1, 0, 0, 1, 0, 0],
}) {
  return <String, Object?>{
    'str': text,
    'dir': direction,
    'width': width,
    'height': height,
    'hasEOL': hasEndOfLine,
    'fontName': fontName,
    'transform': transform,
  }.jsify()! as JSObject;
}
