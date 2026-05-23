import 'dart:html' as html;
import 'dart:js_util' as js_util;

abstract class LiPdfViewerBrowserBridge {
  const LiPdfViewerBrowserBridge();

  String createObjectUrlFromBlob(html.Blob blob);

  void revokeObjectUrl(String url);

  void clickAnchor(html.AnchorElement anchor);

  void printWindow(dynamic targetFrame);
}

class DefaultLiPdfViewerBrowserBridge implements LiPdfViewerBrowserBridge {
  const DefaultLiPdfViewerBrowserBridge();

  @override
  String createObjectUrlFromBlob(html.Blob blob) {
    return html.Url.createObjectUrlFromBlob(blob);
  }

  @override
  void revokeObjectUrl(String url) {
    html.Url.revokeObjectUrl(url);
  }

  @override
  void clickAnchor(html.AnchorElement anchor) {
    anchor.click();
  }

  @override
  void printWindow(dynamic targetFrame) {
    js_util.callMethod(targetFrame, 'print', const <Object?>[]);
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
