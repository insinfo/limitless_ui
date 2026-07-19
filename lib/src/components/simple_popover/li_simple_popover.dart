import 'dart:js_interop';
import 'dart:async';
import 'package:web/web.dart' as web;

import '../../web_support/dom_tokens.dart';

/// Lightweight DOM-based popover helper for quick warning messages.
class LiSimplePopover {
  static const _popoverId = 'simple-popover-root';

  /// Shows a warning popover anchored to [target].
  static void showWarning(
    web.Element target,
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
    web.Element target,
    String message, {
    required String title,
    required Duration timeout,
  }) {
    web.document.querySelector('#$_popoverId')?.remove();

    final body = web.document.body;
    if (body == null) {
      return;
    }

    final root = addClassTokens(
      web.HTMLDivElement()..id = _popoverId,
      const <String>['popover', 'show', 'bs-popover-top'],
    )
      ..style.position = 'fixed'
      ..style.margin = '0'
      ..style.maxWidth = '420px'
      ..style.zIndex = '10000'
      ..style.visibility = 'hidden';

    final arrow = web.HTMLDivElement()..classList.add('popover-arrow');
    final header = web.HTMLHeadingElement.h3()
      ..classList.add('popover-header')
      ..textContent = title;
    final content = web.HTMLDivElement()
      ..classList.add('popover-body')
      ..style.whiteSpace = 'pre-line'
      ..textContent = message;

    root
      ..append(arrow)
      ..append(header)
      ..append(content);
    body.append(root);

    _positionPopover(root, arrow, target);
    root.style.visibility = 'visible';

    StreamSubscription<web.MouseEvent>? clickSub;
    StreamSubscription<web.KeyboardEvent>? keySub;
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

    clickSub = web.EventStreamProvider<web.MouseEvent>('click')
        .forTarget(web.document)
        .listen((event) {
      final clickTarget = event.target;
      if ((clickTarget?.isA<web.Element>() ?? false) &&
          !root.contains(clickTarget as web.Node?) &&
          !target.contains(clickTarget)) {
        close();
      }
    });

    keySub = web.EventStreamProvider<web.KeyboardEvent>('keydown')
        .forTarget(web.document)
        .listen((event) {
      if (event.key == 'Escape') {
        close();
      }
    });

    timer = Timer(timeout, close);
  }

  static void _positionPopover(
    web.HTMLDivElement popover,
    web.HTMLDivElement arrow,
    web.Element target,
  ) {
    final targetRect = target.getBoundingClientRect();
    final popoverRect = popover.getBoundingClientRect();
    final viewportWidth = web.window.innerWidth;
    final viewportHeight = web.window.innerHeight;
    const spacing = 10.0;
    const pagePadding = 8.0;

    final showAbove =
        targetRect.top >= popoverRect.height + spacing + pagePadding;
    final placementClass = showAbove ? 'bs-popover-top' : 'bs-popover-bottom';
    popover.classList
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
