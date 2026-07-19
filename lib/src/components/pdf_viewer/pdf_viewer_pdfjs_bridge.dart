import 'pdfjs_bindings.dart';

abstract class LiPdfViewerPdfJsBridge {
  const LiPdfViewerPdfJsBridge();

  PDFDocumentLoadingTask getDocument(Map<String, dynamic> source);

  TextLayer createTextLayer(Map<String, dynamic> options);

  void configureWorker(String src);
}

class DefaultLiPdfViewerPdfJsBridge implements LiPdfViewerPdfJsBridge {
  const DefaultLiPdfViewerPdfJsBridge();

  @override
  PDFDocumentLoadingTask getDocument(Map<String, dynamic> source) {
    return pdfjsLib.getDocumentDart(source);
  }

  @override
  TextLayer createTextLayer(Map<String, dynamic> options) {
    return TextLayer.init(options);
  }

  @override
  void configureWorker(String src) {
    workerSrc = src;
  }
}

LiPdfViewerPdfJsBridge _activeLiPdfViewerPdfJsBridge =
    const DefaultLiPdfViewerPdfJsBridge();

LiPdfViewerPdfJsBridge get liPdfViewerPdfJsBridge =>
    _activeLiPdfViewerPdfJsBridge;

void setLiPdfViewerPdfJsBridgeForTesting(LiPdfViewerPdfJsBridge? bridge) {
  _activeLiPdfViewerPdfJsBridge =
      bridge ?? const DefaultLiPdfViewerPdfJsBridge();
}
