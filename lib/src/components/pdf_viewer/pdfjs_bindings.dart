@JS()

import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

import 'package:js/js.dart';

@JS()
@anonymous
class ViewportParams {
  external factory ViewportParams({double scale, double rotation});
}

@JS()
@anonymous
class RenderParams {
  external factory RenderParams({
    html.CanvasRenderingContext2D canvasContext,
    dynamic viewport,
  });
}

@JS()
@anonymous
class TextContentOptions {
  external factory TextContentOptions({
    bool includeMarkedContent,
    bool disableNormalization,
  });
}

@JS()
@anonymous
class RenderTask {
  external dynamic get promise;
  external void cancel();
}

extension RenderTaskExtension on RenderTask {
  Future<void> get onFinished => js_util.promiseToFuture(promise);
}

@JS()
@anonymous
class PDFPageProxy {
  external PageViewport getViewport(ViewportParams params);
  external RenderTask render(RenderParams params);
  external dynamic getTextContent([dynamic params]);
  external dynamic getAnnotations(dynamic params);
  external dynamic cleanup();
  external dynamic streamTextContent(TextContentOptions options);
}

@JS()
@anonymous
class PDFTextContent {
  external List<dynamic> get items;
  external dynamic get styles;
  external String? get lang;
}

@JS()
@anonymous
class PDFTextItem {
  external String? get str;
  external String? get dir;
  external num? get width;
  external num? get height;
  external bool? get hasEOL;
  external String? get fontName;
  external List<num>? get transform;
}

@JS()
@anonymous
class PageViewport {
  external num get height;
  external num get width;
  external num get rotation;
  external num get scale;
  external List<num> convertToViewportRectangle(List<num> rect);
}

extension PDFPageProxyExtension on PDFPageProxy {
  Future<PDFTextContent> getTextContentDart({
    bool includeMarkedContent = false,
    bool disableNormalization = false,
  }) {
    return js_util.promiseToFuture(
      getTextContent(
        js_util.jsify(<String, Object?>{
          'includeMarkedContent': includeMarkedContent,
          'disableNormalization': disableNormalization,
        }),
      ),
    );
  }

  Future<List<dynamic>> getAnnotationsDart() async {
    final result = await js_util.promiseToFuture(
      getAnnotations(js_util.jsify(<String, Object?>{'intent': 'display'})),
    );
    return (result as List).cast<dynamic>();
  }
}

Uint8List _convertToUint8List(dynamic jsObject) {
  if (jsObject == null) {
    return Uint8List(0);
  }

  final buffer = js_util.getProperty(jsObject, 'buffer');
  final byteOffset = js_util.getProperty(jsObject, 'byteOffset');
  final length = js_util.getProperty(jsObject, 'length');
  return Uint8List.view(buffer, byteOffset, length);
}

@JS()
@anonymous
class PDFDocumentProxy {
  external int get numPages;
  @JS('getPage')
  external dynamic getPage(int pageNum);
  external dynamic destroy();
  external dynamic getDestinations();
  external dynamic getPageIndex(dynamic ref);
  external dynamic getData();
}

extension PDFDocumentProxyExtension on PDFDocumentProxy {
  Future<PDFPageProxy> getPageDart(int pageNum) =>
      js_util.promiseToFuture(getPage(pageNum));

  Future<dynamic> getDestinationsDart() =>
      js_util.promiseToFuture(getDestinations());

  Future<int> getPageIndexDart(dynamic ref) =>
      js_util.promiseToFuture(getPageIndex(ref));

  Future<Uint8List> getDataDart() async {
    final jsResult = await js_util.promiseToFuture(getData());
    return _convertToUint8List(jsResult);
  }
}

@JS()
@anonymous
class PDFDocumentLoadingTask {
  external dynamic get promise;
  external void cancel();
}

extension PDFDocumentLoadingTaskExtension on PDFDocumentLoadingTask {
  Future<PDFDocumentProxy> load() => js_util.promiseToFuture(promise);
}

@JS('pdfjsLib')
external PDFLib get pdfjsLib;

@JS()
class PDFLib {
  external PDFDocumentLoadingTask getDocument(dynamic data);
}

extension PDFLibExtension on PDFLib {
  PDFDocumentLoadingTask getDocumentDart(dynamic data) {
    return getDocument(js_util.jsify(data));
  }
}

@JS('pdfjsLib.TextLayer')
class TextLayer {
  external factory TextLayer(dynamic options);

  factory TextLayer.init(Map<String, dynamic> options) {
    return TextLayer(js_util.jsify(options));
  }

  external dynamic render();
}

extension TextLayerExtension on TextLayer {
  Future<void> renderDart() async {
    final result = render();
    await js_util.promiseToFuture(result);
  }
}

@JS('pdfjsLib.GlobalWorkerOptions.workerSrc')
external set workerSrc(String src);