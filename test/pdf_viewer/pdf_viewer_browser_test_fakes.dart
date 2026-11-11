import 'dart:html' as html;

import 'package:limitless_ui/src/components/pdf_viewer/pdf_viewer_browser_bridge.dart';

class FakePdfViewerBrowserBridge implements LiPdfViewerBrowserBridge {
  final List<String> createdUrls = <String>[];
  final List<String> revokedUrls = <String>[];
  final List<String> clickedDownloads = <String>[];
  int printCalls = 0;

  /// What `document.fullscreenEnabled` reports.
  bool fullscreenAllowed = true;

  /// Whether `requestFullscreen()` is refused (its promise rejects).
  bool refuseFullscreen = false;

  /// Elements `requestFullscreen()` was called on.
  final List<html.Element> fullscreenRequests = <html.Element>[];

  @override
  bool get fullscreenEnabled => fullscreenAllowed;

  @override
  Future<void> requestFullscreen(html.Element element) async {
    fullscreenRequests.add(element);
    if (refuseFullscreen) {
      throw StateError('Permissions check failed');
    }
  }

  @override
  void clickAnchor(html.AnchorElement anchor) {
    clickedDownloads.add(anchor.download ?? '');
  }

  @override
  String createObjectUrlFromBlob(html.Blob blob) {
    final url = 'blob:fake-${createdUrls.length}';
    createdUrls.add(url);
    return url;
  }

  /// What printWindow received last: has to be the JS window, with `print`.
  Object? lastPrintTarget;

  /// Makes printWindow fail, as a browser that refuses to print would.
  bool failPrint = false;

  @override
  void printWindow(dynamic targetFrame) {
    printCalls += 1;
    lastPrintTarget = targetFrame as Object?;
    if (failPrint) {
      throw StateError('print refused');
    }
  }

  @override
  void revokeObjectUrl(String url) {
    revokedUrls.add(url);
  }
}
