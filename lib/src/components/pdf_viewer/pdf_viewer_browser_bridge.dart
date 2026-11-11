import 'dart:html' as html;
import 'dart:js_util' as js_util;

abstract class LiPdfViewerBrowserBridge {
  const LiPdfViewerBrowserBridge();

  String createObjectUrlFromBlob(html.Blob blob);

  void revokeObjectUrl(String url);

  void clickAnchor(html.AnchorElement anchor);

  void printWindow(dynamic targetFrame);

  /// Whether the document may use the Fullscreen API at all:
  /// `document.fullscreenEnabled`, `false` in an iframe without
  /// `allow="fullscreen"`. Asking anyway logs a permissions policy violation.
  bool get fullscreenEnabled;

  /// Calls `requestFullscreen()` (or the WebKit prefix) on [element]. The
  /// future fails when the browser refuses.
  Future<void> requestFullscreen(html.Element element);
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

  @override
  bool get fullscreenEnabled {
    final document = html.document;
    if (js_util.hasProperty(document, 'fullscreenEnabled')) {
      return js_util.getProperty<Object?>(document, 'fullscreenEnabled') ==
          true;
    }
    if (js_util.hasProperty(document, 'webkitFullscreenEnabled')) {
      return js_util.getProperty<Object?>(
              document, 'webkitFullscreenEnabled') ==
          true;
    }
    return false;
  }

  @override
  Future<void> requestFullscreen(html.Element element) async {
    if (js_util.hasProperty(element, 'requestFullscreen')) {
      final result = js_util.callMethod<Object?>(
        element,
        'requestFullscreen',
        const <Object?>[],
      );
      if (result != null) {
        await js_util.promiseToFuture<Object?>(result);
      }
      return;
    }
    if (js_util.hasProperty(element, 'webkitRequestFullscreen')) {
      js_util.callMethod<Object?>(
        element,
        'webkitRequestFullscreen',
        const <Object?>[],
      );
      return;
    }
    throw UnsupportedError('Fullscreen API not available');
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
