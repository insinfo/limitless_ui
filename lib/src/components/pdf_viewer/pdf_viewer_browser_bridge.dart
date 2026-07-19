import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

abstract class LiPdfViewerBrowserBridge {
  const LiPdfViewerBrowserBridge();

  String createObjectUrlFromBlob(web.Blob blob);

  void revokeObjectUrl(String url);

  void clickAnchor(web.HTMLAnchorElement anchor);

  void printWindow(dynamic targetFrame);
}

class DefaultLiPdfViewerBrowserBridge implements LiPdfViewerBrowserBridge {
  const DefaultLiPdfViewerBrowserBridge();

  @override
  String createObjectUrlFromBlob(web.Blob blob) {
    return web.URL.createObjectURL(blob);
  }

  @override
  void revokeObjectUrl(String url) {
    web.URL.revokeObjectURL(url);
  }

  @override
  void clickAnchor(web.HTMLAnchorElement anchor) {
    anchor.click();
  }

  @override
  void printWindow(dynamic targetFrame) {
    (targetFrame as JSObject).callMethod('print'.toJS);
  }
}

LiPdfViewerBrowserBridge _activeLiPdfViewerBrowserBridge =
    const DefaultLiPdfViewerBrowserBridge();

LiPdfViewerBrowserBridge get liPdfViewerBrowserBridge =>
    _activeLiPdfViewerBrowserBridge;

void setLiPdfViewerBrowserBridgeForTesting(LiPdfViewerBrowserBridge? bridge) {
  _activeLiPdfViewerBrowserBridge =
      bridge ?? const DefaultLiPdfViewerBrowserBridge();
}
