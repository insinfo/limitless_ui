import 'package:limitless_ui/web_compat.dart' as html;
import 'dart:math';

import 'pdf_viewer_page_view.dart';

class PdfViewerVisibilityController {
  int binarySearchFirstPage(
    List<PdfPageView> views,
    bool Function(PdfPageView view) condition,
  ) {
    var minIndex = 0;
    var maxIndex = views.length - 1;

    if (maxIndex < 0 || !condition(views[maxIndex])) {
      return views.length;
    }
    if (condition(views[minIndex])) {
      return minIndex;
    }

    while (minIndex < maxIndex) {
      final currentIndex = (minIndex + maxIndex) >> 1;
      final currentItem = views[currentIndex];

      if (condition(currentItem)) {
        maxIndex = currentIndex;
      } else {
        minIndex = currentIndex + 1;
      }
    }
    return minIndex;
  }

  List<Map<String, dynamic>> getVisibleElements(
    html.DivElement scrollElement,
    List<PdfPageView> views, {
    bool sortByVisibility = true,
  }) {
    final top = scrollElement.scrollTop;
    final bottom = top + scrollElement.clientHeight;

    bool isElementBottomAfterViewTop(PdfPageView view) {
      final element = view.div;
      final elementBottom = element.offsetTop + element.clientHeight;
      return elementBottom > top;
    }

    var firstVisibleElementIndex =
        binarySearchFirstPage(views, isElementBottomAfterViewTop);

    if (firstVisibleElementIndex > 0) {
      firstVisibleElementIndex -= 1;
    }

    final visible = <Map<String, dynamic>>[];
    for (var index = firstVisibleElementIndex; index < views.length; index++) {
      final view = views[index];
      final element = view.div;
      final elementTop = element.offsetTop;
      final elementBottom = elementTop + element.clientHeight;

      if (elementTop > bottom) {
        break;
      }

      if (elementBottom > top && elementTop < bottom) {
        final hiddenHeight =
            max(0, top - elementTop) + max(0, elementBottom - bottom);
        final percent =
            ((element.clientHeight - hiddenHeight) * 100 / element.clientHeight)
                .floor();
        visible.add(<String, dynamic>{
          'id': view.pageNum,
          'view': view,
          'percent': percent,
        });
      }
    }

    if (sortByVisibility) {
      visible.sort(
        (left, right) =>
            (right['percent'] as int).compareTo(left['percent'] as int),
      );
    }

    return visible;
  }
}
