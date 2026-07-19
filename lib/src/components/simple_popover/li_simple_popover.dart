import 'dart:js_interop';
import 'dart:async';
import 'package:limitless_ui/web_compat.dart' as html;

/// Lightweight DOM-based popover helper for quick warning messages.
class LiSimplePopover {
  static const _popoverId = 'simple-popover-root';

  /// Shows a warning popover anchored to [target].
  static void showWarning(
    html.Element target,
    String message, {
    String title = 'Warning',
    Duration timeout = const Duration(seconds: 3),
  }) {
    _showPopover(
      target,
      message,
      title: title,
      timeout: timeout,
    );
  }

  static void _showPopover(
    html.Element target,
    String message, {
    required String title,
    required Duration timeout,
  }) {
    html.document.querySelector('#$_popoverId')?.remove();

    final body = html.document.body;
    if (body == null) {
      return;
    }

    final root = html.createDivElement()
      ..id = _popoverId
      ..classes.addAll(['popover', 'show', 'bs-popover-top'])
      ..style.position = 'fixed'
      ..style.margin = '0'
      ..style.maxWidth = '420px'
      ..style.zIndex = '10000'
      ..style.visibility = 'hidden';

    final arrow = html.createDivElement()..classes.add('popover-arrow');
    final header = html.createHeadingElement(3)
      ..classes.add('popover-header')
      ..text = title;
    final content = html.createDivElement()
      ..classes.add('popover-body')
      ..style.whiteSpace = 'pre-line'
      ..text = message;

    root
      ..append(arrow)
      ..append(header)
      ..append(content);
    body.append(root);

    _positionPopover(root, arrow, target);
    root.style.visibility = 'visible';

    StreamSubscription<html.MouseEvent>? clickSub;
    StreamSubscription<html.KeyboardEvent>? keySub;
    Timer? timer;

    void close() {
      clickSub?.cancel();
      keySub?.cancel();
      timer?.cancel();
      root.remove();
    }

    root.onClick.listen((event) {
      event.stopPropagation();
      close();
    });

    clickSub = html.document.onClick.listen((event) {
      final clickTarget = event.target;
      if ((clickTarget?.isA<html.Element>() ?? false) &&
          !root.contains(clickTarget as html.Node?) &&
          !target.contains(clickTarget)) {
        close();
      }
    });

    keySub = html.document.onKeyDown.listen((event) {
      if (event.keyCode == 27) {
        close();
      }
    });

    timer = Timer(timeout, close);
  }

  static void _positionPopover(
    html.DivElement popover,
    html.DivElement arrow,
    html.Element target,
  ) {
    final targetRect = target.getBoundingClientRect();
    final popoverRect = popover.getBoundingClientRect();
    final viewportWidth = html.window.innerWidth;
    final viewportHeight = html.window.innerHeight;
    const spacing = 10.0;
    const pagePadding = 8.0;

    final showAbove =
        targetRect.top >= popoverRect.height + spacing + pagePadding;
    final placementClass = showAbove ? 'bs-popover-top' : 'bs-popover-bottom';
    popover.classes
      ..remove('bs-popover-top')
      ..remove('bs-popover-bottom')
      ..add(placementClass);

    var left =
        targetRect.left + (targetRect.width / 2) - (popoverRect.width / 2);
    left = left.clamp(
        pagePadding, viewportWidth - popoverRect.width - pagePadding);

    final top = showAbove
        ? targetRect.top - popoverRect.height - spacing
        : (targetRect.bottom + spacing).clamp(
            pagePadding, viewportHeight - popoverRect.height - pagePadding);

    popover.style
      ..left = '${left}px'
      ..top = '${top}px';

    final arrowLeft = (targetRect.left + (targetRect.width / 2) - left)
        .clamp(16, popoverRect.width - 16);
    arrow.style.left = '${arrowLeft}px';
  }
}
