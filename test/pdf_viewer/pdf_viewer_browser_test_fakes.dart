import 'package:web/web.dart' as web;

import 'package:limitless_ui/src/components/pdf_viewer/pdf_viewer_browser_bridge.dart';

class FakePdfViewerBrowserBridge implements LiPdfViewerBrowserBridge {
  final List<String> createdUrls = <String>[];
  final List<String> revokedUrls = <String>[];
  final List<String> clickedDownloads = <String>[];
  int printCalls = 0;

  @override
  void clickAnchor(web.HTMLAnchorElement anchor) {
    clickedDownloads.add(anchor.download);
  }

  @override
  String createObjectUrlFromBlob(web.Blob blob) {
    final url = 'blob:fake-${createdUrls.length}';
    createdUrls.add(url);
    return url;
  }

  @override
  void printWindow(dynamic targetFrame) {
    printCalls += 1;
  }

  @override
  void revokeObjectUrl(String url) {
    revokedUrls.add(url);
  }
}
