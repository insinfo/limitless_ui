import 'package:limitless_ui/web_compat.dart' as html;

import 'package:limitless_ui/src/components/pdf_viewer/pdf_viewer_browser_bridge.dart';

class FakePdfViewerBrowserBridge implements LiPdfViewerBrowserBridge {
  final List<String> createdUrls = <String>[];
  final List<String> revokedUrls = <String>[];
  final List<String> clickedDownloads = <String>[];
  int printCalls = 0;

  @override
  void clickAnchor(html.AnchorElement anchor) {
    clickedDownloads.add(anchor.download);
  }

  @override
  String createObjectUrlFromBlob(html.Blob blob) {
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
