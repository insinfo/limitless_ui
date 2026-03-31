import 'dart:async';
import 'dart:html';

import 'package:popper/popper.dart';

class SweetAlertPopover {
  static void showPopover(
    Element target,
    String message, {
    String title = 'Atenção',
    String? popoverClass,
    Duration? timeout = const Duration(seconds: 3),
  }) async {
//     var template = '''
//    <div class="popover-arrow" style="position: absolute; left: 0px; transform: translate(129px, 0px);"></div>
//    <h3 class="popover-header">${title}</h3>
//    <div class="popover-body">${message}</div>
// ''';

    final id = 'popover441630';

    final olds = document.querySelectorAll('#$id');
    if (olds.isNotEmpty) {
      for (final old in olds) {
        old.remove();
      }
    }

    final rootPopover = DivElement();
    rootPopover.attributes['id'] = id;
    rootPopover.classes.addAll(['popover', 'bs-popover-auto', 'fade', 'show']);
    final popoverClassNames = _classNames(popoverClass);
    if (popoverClassNames.isNotEmpty) {
      rootPopover.classes.addAll(popoverClassNames);
    }
    rootPopover.attributes['data-popper-placement'] = 'top';
    rootPopover.style.position = 'fixed';
    rootPopover.style.margin = '0px';
    rootPopover.style.zIndex = '10000';

    final popoverArrow = DivElement();
    popoverArrow.classes.add('popover-arrow');
    popoverArrow.classes.addAll(
      popoverClassNames.where((className) => className.startsWith('border-')),
    );
    rootPopover.append(popoverArrow);
    popoverArrow.style.position = 'absolute';
    popoverArrow.style.left = '0px';

    final popoverHeader = HeadingElement.h3();
    popoverHeader.classes.add('popover-header');
    popoverHeader.text = title;
    _applyCustomTheme(
      header: popoverHeader,
      body: null,
      popoverClassNames: popoverClassNames,
    );
    rootPopover.append(popoverHeader);

    final popoverBody = DivElement();
    popoverBody.classes.add('popover-body');
    popoverBody.innerHtml = message;
    popoverBody.style.whiteSpace = 'pre-line';
    _applyCustomTheme(
      header: null,
      body: popoverBody,
      popoverClassNames: popoverClassNames,
    );
    rootPopover.append(popoverBody);
    rootPopover.style.maxWidth = '420px';

    // ignore: unsafe_html
    // rootPopover.setInnerHtml(template,
    //     treeSanitizer: NodeTreeSanitizer.trusted);

    document.body!.classes.addAll(['swal2-toast-shown', 'swal2-shown']);
    final overlay = PopperAnchoredOverlay.attach(
      referenceElement: target,
      floatingElement: rootPopover,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'SweetAlertPopover',
        hostZIndex: '10000',
        floatingZIndex: '10001',
      ),
      popperOptions: PopperOptions(
        placement: 'top-start',
        fallbackPlacements: const <String>[
          'bottom-start',
          'top-end',
          'bottom-end',
        ],
        strategy: PopperStrategy.fixed,
        padding: const PopperInsets.all(8),
        offset: const PopperOffset(mainAxis: 10),
        arrowElement: popoverArrow,
        arrowPadding: const PopperInsets.all(10),
        onLayout: (layout) {
          rootPopover.attributes['data-popper-placement'] = layout.placement;
          rootPopover.classes
            ..remove('bs-popover-top')
            ..remove('bs-popover-bottom')
            ..remove('bs-popover-start')
            ..remove('bs-popover-end')
            ..add(_placementClassFor(layout.placement));
          _normalizeArrowOffset(popoverArrow, layout.placement);
        },
      ),
    );
    overlay.startAutoUpdate();
    overlay.update();
    Future<void>.delayed(Duration.zero, overlay.update);

    StreamSubscription? ssoc, ssokd;
    Timer? closeTimer;

    void close() {
      target.attributes.remove('data-popover');
      document.body!.classes.removeAll(['swal2-toast-shown', 'swal2-shown']);
      overlay.dispose();
      ssoc?.cancel();
      ssokd?.cancel();
      closeTimer?.cancel();
    }

    rootPopover.onClick.listen((event) {
      event.stopPropagation();
      close();
    });
    if (timeout != null) {
      closeTimer = Timer(timeout, close);
    }

    Future.delayed(const Duration(milliseconds: 250), () {
      ssoc = document.onClick.listen((event) {
        final te = event.target;
        if (te is Element &&
            !rootPopover.contains(te) &&
            !target.contains(te)) {
          close();
        }
      });

      ssokd = document.onKeyDown.listen((event) {
        // print('onKeyDown ${event.key} | ${event.code} | ${event.keyCode}');
        if (event.keyCode == 27) {
          close();
        }
      });
    });

    if (target.attributes['data-popover'] == null) {
      target.attributes['data-popover'] = 'true';
    }
  }

  static void _normalizeArrowOffset(
      HtmlElement arrowElement, String placement) {
    final insetValues = _expandInsetValues(
      arrowElement.style.getPropertyValue('inset'),
    );
    final top = insetValues?[0] ?? arrowElement.style.top;
    final right = insetValues?[1] ?? arrowElement.style.right;
    final bottom = insetValues?[2] ?? arrowElement.style.bottom;
    final left = insetValues?[3] ?? arrowElement.style.left;
    final normalized = placement.trim().toLowerCase();

    arrowElement.style.removeProperty('inset');

    if (normalized.startsWith('top') || normalized.startsWith('bottom')) {
      arrowElement.style
        ..top = ''
        ..bottom = ''
        ..left = _normalizeCssValue(left)
        ..right = _normalizeCssValue(right);
      return;
    }

    arrowElement.style
      ..left = ''
      ..right = ''
      ..top = _normalizeCssValue(top)
      ..bottom = _normalizeCssValue(bottom);
  }

  static List<String>? _expandInsetValues(String inset) {
    final normalizedInset = inset.trim();
    if (normalizedInset.isEmpty) {
      return null;
    }

    final parts = normalizedInset.split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return null;
    }

    if (parts.length == 1) {
      return <String>[parts[0], parts[0], parts[0], parts[0]];
    }
    if (parts.length == 2) {
      return <String>[parts[0], parts[1], parts[0], parts[1]];
    }
    if (parts.length == 3) {
      return <String>[parts[0], parts[1], parts[2], parts[1]];
    }
    return <String>[parts[0], parts[1], parts[2], parts[3]];
  }

  static String _normalizeCssValue(String value) {
    final normalized = value.trim();
    return normalized == 'auto' ? '' : normalized;
  }

  static String _placementClassFor(String placement) {
    final normalized = placement.trim().toLowerCase();
    if (normalized.startsWith('bottom')) {
      return 'bs-popover-bottom';
    }
    if (normalized.startsWith('left') || normalized.startsWith('start')) {
      return 'bs-popover-start';
    }
    if (normalized.startsWith('right') || normalized.startsWith('end')) {
      return 'bs-popover-end';
    }
    return 'bs-popover-top';
  }

  static List<String> _classNames(String? rawClasses) {
    final normalized = rawClasses?.trim();
    if (normalized == null || normalized.isEmpty) {
      return const <String>[];
    }

    return normalized
        .split(RegExp(r'\s+'))
        .where((className) => className.trim().isNotEmpty)
        .toList(growable: false);
  }

  static void _applyCustomTheme({
    HeadingElement? header,
    DivElement? body,
    required List<String> popoverClassNames,
  }) {
    if (!popoverClassNames.contains('popover-custom')) {
      return;
    }

    final backgroundClassNames = popoverClassNames
        .where((className) => className.startsWith('bg-'))
        .toList(growable: false);
    final textClassNames = popoverClassNames
        .where((className) => className.startsWith('text-'))
        .toList(growable: false);

    if (header != null) {
      if (backgroundClassNames.isNotEmpty) {
        header.classes.addAll(backgroundClassNames);
      }
      if (textClassNames.isNotEmpty) {
        header.classes.addAll(textClassNames);
        if (textClassNames.contains('text-white')) {
          header.classes.addAll(
            const <String>['border-white', 'border-opacity-25'],
          );
        } else if (textClassNames.contains('text-black')) {
          header.classes.addAll(
            const <String>['border-black', 'border-opacity-10'],
          );
        }
      }
    }

    if (body != null && textClassNames.isNotEmpty) {
      body.classes.addAll(textClassNames);
    }
  }
}
