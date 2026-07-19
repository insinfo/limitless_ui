/// pdf.js interop bindings, written with `dart:js_interop` extension types
/// (previously `package:js` classes + `dart:js_util`).
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as html show CanvasRenderingContext2D;

extension type ViewportParams._(JSObject _) implements JSObject {
  external factory ViewportParams({double scale, double rotation});
}

extension type RenderParams._(JSObject _) implements JSObject {
  external factory RenderParams({
    html.CanvasRenderingContext2D canvasContext,
    PageViewport? viewport,
  });
}

extension type TextContentOptions._(JSObject _) implements JSObject {
  external factory TextContentOptions({
    bool includeMarkedContent,
    bool disableNormalization,
  });
}

extension type RenderTask._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> get promise;
  external void cancel();
}

extension RenderTaskExtension on RenderTask {
  Future<void> get onFinished => promise.toDart;
}

extension type PDFPageProxy._(JSObject _) implements JSObject {
  external PageViewport getViewport(ViewportParams params);
  external RenderTask render(RenderParams params);
  external JSPromise<PDFTextContent> getTextContent([JSAny? params]);
  external JSPromise<JSArray<JSObject>> getAnnotations(JSAny? params);
  external JSAny? cleanup();
  external JSObject streamTextContent(TextContentOptions options);
}

extension type PDFTextContent._(JSObject _) implements JSObject {
  external JSArray<PDFTextItem> get items;
  external JSAny? get styles;
  external String? get lang;
}

extension type PDFTextItem._(JSObject _) implements JSObject {
  external String? get str;
  external String? get dir;
  external num? get width;
  external num? get height;
  external bool? get hasEOL;
  external String? get fontName;
  @JS('transform')
  external JSArray<JSNumber>? get _transform;
}

extension PDFTextItemExtension on PDFTextItem {
  List<num>? get transform =>
      _transform?.toDart.map((value) => value.toDartDouble).toList();
}

extension type PageViewport._(JSObject _) implements JSObject {
  external num get height;
  external num get width;
  external num get rotation;
  external num get scale;
  @JS('convertToViewportRectangle')
  external JSArray<JSNumber> _convertToViewportRectangle(
      JSArray<JSNumber> rect);
}

extension PageViewportExtension on PageViewport {
  List<num> convertToViewportRectangle(List<num> rect) =>
      _convertToViewportRectangle(
        [for (final value in rect) value.toJS].toJS,
      ).toDart.map((value) => value.toDartDouble).toList();
}

extension PDFPageProxyExtension on PDFPageProxy {
  Future<PDFTextContent> getTextContentDart({
    bool includeMarkedContent = false,
    bool disableNormalization = false,
  }) =>
      getTextContent(TextContentOptions(
        includeMarkedContent: includeMarkedContent,
        disableNormalization: disableNormalization,
      )).toDart;

  Future<List<JSObject>> getAnnotationsDart() async {
    final result = await getAnnotations({'intent': 'display'}.jsify()).toDart;
    return result.toDart;
  }
}

extension type PDFDocumentProxy._(JSObject _) implements JSObject {
  external int get numPages;
  external JSPromise<PDFPageProxy> getPage(int pageNum);
  external JSAny? destroy();
  external JSPromise<JSAny?> getDestinations();
  external JSPromise<JSNumber> getPageIndex(JSAny? ref);
  external JSPromise<JSUint8Array> getData();
}

extension PDFDocumentProxyExtension on PDFDocumentProxy {
  Future<PDFPageProxy> getPageDart(int pageNum) => getPage(pageNum).toDart;

  /// Resolves to plain Dart structures (`Map`/`List`), matching how the
  /// callers inspect the destination dictionary.
  Future<Object?> getDestinationsDart() async =>
      (await getDestinations().toDart).dartify();

  Future<int> getPageIndexDart(Object? ref) async =>
      (await getPageIndex(ref.jsify()).toDart).toDartInt;

  Future<Uint8List> getDataDart() async => (await getData().toDart).toDart;
}

extension type PDFDocumentLoadingTask._(JSObject _) implements JSObject {
  external JSPromise<PDFDocumentProxy> get promise;
  external void cancel();
}

extension PDFDocumentLoadingTaskExtension on PDFDocumentLoadingTask {
  Future<PDFDocumentProxy> load() => promise.toDart;
}

@JS('pdfjsLib')
external PDFLib get pdfjsLib;

extension type PDFLib._(JSObject _) implements JSObject {
  external PDFDocumentLoadingTask getDocument(JSAny? data);
}

extension PDFLibExtension on PDFLib {
  PDFDocumentLoadingTask getDocumentDart(Object? data) =>
      getDocument(data.jsify());
}

@JS('pdfjsLib.TextLayer')
extension type TextLayer._(JSObject _) implements JSObject {
  external factory TextLayer(JSAny? options);

  factory TextLayer.init(Map<String, dynamic> options) =>
      TextLayer(options.jsify());

  external JSPromise<JSAny?> render();
}

extension TextLayerExtension on TextLayer {
  Future<void> renderDart() async {
    await render().toDart;
  }
}

@JS('pdfjsLib.GlobalWorkerOptions.workerSrc')
external set workerSrc(String src);
