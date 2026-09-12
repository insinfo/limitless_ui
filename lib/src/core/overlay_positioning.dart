import 'dart:html' as html;

import 'package:popper/popper.dart';

import 'overlay_layers.dart';

/// Selectors of the containers an anchored overlay has to clear.
///
/// These are the layers that *block*: while one of them is on screen, what is
/// underneath cannot be reached. An overlay opened from inside one has to draw
/// above it, or it is invisible to the person who opened it.
///
/// The loading curtain is **not** here, and that is deliberate. It outranks
/// everything on purpose — see [LiOverlayLayers] — and while it is up nothing
/// below can be clicked anyway, so there is nothing to clear.
///
/// Mutable, so an application that draws its own blocking layer can have the
/// library's overlays clear it too:
///
/// ```dart
/// LiOverlayStack.blockingSelectors.add('.minha-cortina-de-assinatura');
/// ```
class LiOverlayStack {
  LiOverlayStack._();

  /// Containers an anchored overlay must draw above.
  ///
  /// `li-modal` carries `data-status`; the dialog carries `data-li-simple-dialog`
  /// and also a `.modal` class, which is why it is matched by its own attribute
  /// instead of by the class — it has no `data-status`, so before `dev.42` the
  /// scan for open modals simply did not see it.
  ///
  /// The offcanvas is matched by its shell, `.li-offcanvas-shell`: that is the
  /// node that carries the z-index, and the one an anchored overlay inside the
  /// panel finds with `closest`. It got its `data-status` in `dev.42` for this
  /// list — the selector first written here, `.li-offcanvas[data-status]`,
  /// named a class the component never had, so a select opened inside an
  /// offcanvas stayed under it.
  static final List<String> blockingSelectors = <String>[
    '.modal[data-status="open"]',
    '[data-li-simple-dialog="true"]',
    '.swal2-container',
    '.li-offcanvas-shell[data-status="open"]',
  ];

  /// Highest z-index currently occupied by a blocking container, or `null` when
  /// none is on screen.
  static int? topmostBlockingZIndex() {
    var topmost = -1;
    for (final selector in blockingSelectors) {
      for (final element in html.document.querySelectorAll(selector)) {
        final zIndex = _parseElementZIndex(element);
        if (zIndex != null && zIndex > topmost) {
          topmost = zIndex;
        }
      }
    }
    return topmost >= 0 ? topmost : null;
  }

  /// The blocking container [element] lives inside, if any.
  static html.Element? owningBlockingContainer(html.Element element) {
    for (final selector in blockingSelectors) {
      final owner = element.closest(selector);
      if (owner != null) {
        return owner;
      }
    }
    return null;
  }

  /// A z-index for an overlay anchored at [referenceElement].
  ///
  /// Never below [baseZIndex]; above the blocking container that owns the
  /// reference, or — when the reference is not inside one — above the topmost
  /// blocking container on screen.
  static int resolve({
    required html.Element referenceElement,
    required int baseZIndex,
    int? offset,
  }) {
    final step = offset ?? LiOverlayLayers.stackOffset;

    final owner = owningBlockingContainer(referenceElement);
    final owningZIndex = _parseElementZIndex(owner);
    if (owningZIndex != null) {
      return _max(baseZIndex, owningZIndex + step);
    }

    final topmost = topmostBlockingZIndex();
    if (topmost != null) {
      return _max(baseZIndex, topmost + step);
    }

    return baseZIndex;
  }
}

/// Portal options for an overlay that has to clear whatever is blocking.
///
/// The name says "modal" for compatibility: until `1.0.0-dev.42` this only knew
/// about `li-modal`. It now clears every layer in
/// [LiOverlayStack.blockingSelectors], which is what the name always meant to
/// promise.
PopperPortalOptions resolveModalAwarePortalOptions({
  required String hostClassName,
  required html.Element referenceElement,
  required int baseHostZIndex,
  int? baseFloatingZIndex,
  int modalZIndexOffset = 1,
  bool restoreOnDispose = false,
}) {
  final effectiveFloatingZIndex = baseFloatingZIndex ?? baseHostZIndex;
  final resolvedHostZIndex = LiOverlayStack.resolve(
    referenceElement: referenceElement,
    baseZIndex: baseHostZIndex,
    offset: modalZIndexOffset,
  );

  // The floating panel keeps its distance from the host, in either direction.
  //
  // Only a positive delta used to survive here, which silently threw away a
  // `baseFloatingZIndex` lower than `baseHostZIndex` — the datatable column
  // menu asked for host 10000 and floating 1080 and got 10000 for both. Either
  // the call was wrong or this was; keeping the sign makes the call site mean
  // what it says.
  final floatingDelta = effectiveFloatingZIndex - baseHostZIndex;
  final resolvedFloatingZIndex = resolvedHostZIndex + floatingDelta;

  return PopperPortalOptions(
    hostClassName: hostClassName,
    hostZIndex: '$resolvedHostZIndex',
    floatingZIndex: '$resolvedFloatingZIndex',
    restoreOnDispose: restoreOnDispose,
  );
}

int? _parseElementZIndex(html.Element? element) {
  if (element == null) {
    return null;
  }

  final inline = element.style.zIndex;
  final parsedInline = int.tryParse(inline);
  if (parsedInline != null) {
    return parsedInline;
  }

  final computed = element.getComputedStyle().zIndex;
  return int.tryParse(computed);
}

int _max(int a, int b) => a >= b ? a : b;

bool matchesResponsivePresentation({
  required String configuredPresentation,
  required String presentation,
  String widthBreakpoint = '',
  String heightBreakpoint = '',
}) {
  if (configuredPresentation.trim().toLowerCase() != presentation) {
    return false;
  }

  final normalizedWidthBreakpoint = widthBreakpoint.trim();
  final normalizedHeightBreakpoint = heightBreakpoint.trim();
  if (normalizedWidthBreakpoint.isEmpty && normalizedHeightBreakpoint.isEmpty) {
    return false;
  }

  final widthMatches = normalizedWidthBreakpoint.isNotEmpty &&
      html.window.matchMedia('(max-width: $normalizedWidthBreakpoint)').matches;
  final heightMatches = normalizedHeightBreakpoint.isNotEmpty &&
      html.window
          .matchMedia('(max-height: $normalizedHeightBreakpoint)')
          .matches;

  return widthMatches || heightMatches;
}

double resolveViewportHeight() {
  final windowHeight = html.window.innerHeight?.toDouble() ?? 0;
  final documentHeight =
      html.document.documentElement?.clientHeight.toDouble() ?? 0;
  if (windowHeight > 0 && documentHeight > 0) {
    return windowHeight <= documentHeight ? windowHeight : documentHeight;
  }
  return windowHeight >= documentHeight ? windowHeight : documentHeight;
}

void resetOverlayViewportConstraints({
  required html.Element? floatingElement,
}) {
  final floating = floatingElement;
  if (floating == null) {
    return;
  }

  floating.style.maxHeight = '';
  floating.style.overflowY = '';
  floating.style.overflowX = '';
  floating.style.removeProperty('overscroll-behavior');
}

/// The height the overlay would take with no cap applied.
///
/// Once a `max-height` is in place the layout rect reports the *clamped*
/// height, which reads as "it fits" and would make the very next layout pass
/// drop the cap — leaving the overlay overflowing the viewport again. The
/// element's own `scrollHeight` still measures the content, so the larger of
/// the two is what the cap has to be decided against.
double _resolveNaturalFloatingHeight(
  html.Element floating,
  PopperLayout layout,
) {
  final layoutHeight = layout.floatingRect.height.toDouble();
  final contentHeight = floating.scrollHeight.toDouble();
  return contentHeight > layoutHeight ? contentHeight : layoutHeight;
}

void normalizeOverlayVerticalPosition({
  required html.Element? floatingElement,
  required PopperLayout layout,
  double gap = 0.0,
}) {
  final floating = floatingElement;
  if (floating == null) {
    return;
  }

  final basePlacement = layout.placement.split('-').first;
  final x = layout.x.toDouble();
  final referenceTop = layout.referenceRect.top.toDouble();
  final referenceHeight = layout.referenceRect.height.toDouble();
  final floatingHeight = layout.floatingRect.height.toDouble();

  double? correctedY;
  if (basePlacement == 'bottom') {
    correctedY = referenceTop + referenceHeight + gap;
  } else if (basePlacement == 'top') {
    correctedY = referenceTop - floatingHeight - gap;
  }

  if (correctedY == null) {
    return;
  }

  final correctedTransform =
      'translate(${x.toStringAsFixed(2)}px, ${correctedY.toStringAsFixed(2)}px)';
  if (floating.style.transform != correctedTransform) {
    floating.style.transform = correctedTransform;
  }
}

void constrainOverlayHeightToViewport({
  required html.Element? floatingElement,
  required PopperLayout layout,
  double viewportPadding = 8.0,
  double gap = 0.0,
}) {
  final floating = floatingElement;
  if (floating == null) {
    return;
  }

  final viewportHeight = resolveViewportHeight();
  if (viewportHeight <= 0) {
    return;
  }

  final basePlacement = layout.placement.split('-').first;
  final referenceTop = layout.referenceRect.top.toDouble();
  final referenceHeight = layout.referenceRect.height.toDouble();
  final floatingHeight = _resolveNaturalFloatingHeight(floating, layout);
  final availableAbove = referenceTop - viewportPadding - gap;
  final availableBelow =
      viewportHeight - referenceTop - referenceHeight - viewportPadding - gap;

  final availableHeight = switch (basePlacement) {
    'top' => availableAbove,
    'bottom' => availableBelow,
    _ => availableAbove >= availableBelow ? availableAbove : availableBelow,
  };

  if (availableHeight <= 0) {
    return;
  }

  if (floatingHeight > availableHeight) {
    floating.style.maxHeight = '${availableHeight.floor()}px';
    floating.style.overflowY = 'auto';
    floating.style.overflowX = 'hidden';
    floating.style.setProperty('overscroll-behavior', 'contain');
    return;
  }

  floating.style.maxHeight = '';
  floating.style.overflowY = '';
  floating.style.overflowX = '';
  floating.style.removeProperty('overscroll-behavior');
}
