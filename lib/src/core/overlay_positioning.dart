import 'dart:async';
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

/// The z-index of [element], inline first, then computed; `null` when it has
/// none (`auto`) or there is no element.
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

/// The larger of two integers.
int _max(int a, int b) => a >= b ? a : b;

/// Whether [configuredPresentation] is [presentation] and the viewport is at
/// or below [widthBreakpoint] or [heightBreakpoint] (CSS lengths; an empty
/// one is ignored, and both empty never match).
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

/// Height of the layout viewport: the smaller of `window.innerHeight` and the
/// root element's `clientHeight` (which leaves out a horizontal scrollbar),
/// or whichever of the two is known.
double resolveViewportHeight() {
  final windowHeight = html.window.innerHeight?.toDouble() ?? 0;
  final documentHeight =
      html.document.documentElement?.clientHeight.toDouble() ?? 0;
  if (windowHeight > 0 && documentHeight > 0) {
    return windowHeight <= documentHeight ? windowHeight : documentHeight;
  }
  return windowHeight >= documentHeight ? windowHeight : documentHeight;
}


/// Clears the height cap [placeAnchoredOverlay] (or the deprecated
/// `constrainOverlayHeightToViewport`) wrote on [floatingElement].
///
/// Called when an overlay opens, so the first measurement of the new open sees
/// the panel at its natural height and not at the cap of the previous one.
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

/// Glues the overlay to the edge of the reference that popper chose.
///
/// Deprecated: it trusts the height popper measured, so an overlay capped
/// afterwards by [constrainOverlayHeightToViewport] ended up away from the
/// field. Use [placeAnchoredOverlay], which decides the side, the cap and the
/// position in one pass.
@Deprecated('Use placeAnchoredOverlay, which also decides the side and the '
    'height cap. Will be removed in 2.0.0.')
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

/// Caps the overlay to the room on the side popper chose.
///
/// Deprecated: use [placeAnchoredOverlay]. Kept for code outside the library
/// that pairs it with [normalizeOverlayVerticalPosition]; since `dev.50` an
/// overlay above the reference is moved down after the cap, so it stays glued
/// to the reference instead of keeping the top it had at its natural height.
@Deprecated('Use placeAnchoredOverlay, which also decides the side and the '
    'position. Will be removed in 2.0.0.')
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
    if (basePlacement == 'top') {
      final cappedHeight = floating.getBoundingClientRect().height.toDouble();
      final y = referenceTop - gap - cappedHeight + _cssOffsetY(layout);
      floating.style.transform = 'translate(${layout.x.toStringAsFixed(2)}px, '
          '${y.toStringAsFixed(2)}px)';
    }
    return;
  }

  floating.style.maxHeight = '';
  floating.style.overflowY = '';
  floating.style.overflowX = '';
  floating.style.removeProperty('overscroll-behavior');
}

/// Side of the reference an anchored overlay was placed on, and how.
///
/// Returned by [placeAnchoredOverlay], for components that size something
/// else from the same decision (the minimum height of a list, for instance).
class LiOverlayPlacement {
  /// Creates the result of one [placeAnchoredOverlay] pass.
  const LiOverlayPlacement({
    required this.side,
    required this.availableHeight,
    required this.naturalHeight,
    required this.capped,
  });

  /// `'bottom'` or `'top'`; `'left'`/`'right'` for a horizontal placement,
  /// which is only capped, never moved.
  final String side;

  /// Room on [side], between the reference (plus the gap) and the edge of the
  /// clipping area (minus the padding).
  final double availableHeight;

  /// Height the overlay takes with no cap.
  final double naturalHeight;

  /// Whether the overlay, or its scroll element, got a `max-height`.
  final bool capped;

  /// Whether the overlay opens upwards.
  bool get isAbove => side == 'top';
}

/// Places an overlay anchored to a field: below if it fits, above if it fits
/// there, otherwise on the side with more room, capped to that room and
/// scrolling inside — always glued to the reference.
///
/// Meant to run from popper's `onLayout`, after popper wrote its own layout.
/// Popper keeps deciding the horizontal side (start/end alignment and the
/// shift into the viewport); this decides everything vertical, because
/// popper's `flip` and `shift` get it wrong for a field: they pick the side
/// with the smaller overflow and then *clamp* the panel into the viewport,
/// which moves it away from the field or over it.
///
/// The steps, in one synchronous pass, so the decision never depends on what a
/// previous pass left on the element:
///
/// 1. Measure the natural height: the panel with the cap of the previous pass
///    lifted (the stylesheet's own limits still apply). A panel still `display: none`
///    (opened in the same turn that will show it) is measured with
///    `display: block; visibility: hidden`, as popper does.
/// 2. Pick the side: [preferredSide] if the natural height fits there, the
///    other side if it fits there, otherwise the side with more room.
/// 3. Cap: with no [scrollElement], the overlay itself gets `max-height` and
///    `overflow-y: auto`; with one, that element gets the `max-height` (never
///    less than [minScrollHeight]) and the overlay keeps its own chrome.
/// 4. Measure the overlay again, now capped, and write `transform` so its edge
///    touches the reference: the top at `reference.bottom + gap`, or the
///    bottom at `reference.top - gap`.
/// 5. Keep the overlay horizontally over the reference (Floating UI's
///    `limitShift`): popper's shift keeps it in the viewport, this stops it
///    from sliding off a reference that is partly scrolled away.
///
/// `data-popper-placement` is rewritten when the side differs from popper's.
/// The clipping area is popper's clipping rect cut to the viewport, so a
/// `boundary` set on the popper options is honoured.
///
/// Returns `null` when [floatingElement] is `null`.
LiOverlayPlacement? placeAnchoredOverlay({
  required html.Element? floatingElement,
  required PopperLayout layout,
  String preferredSide = 'bottom',
  double gap = 0.0,
  double viewportPadding = 8.0,
  bool constrainHeight = true,
  html.Element? scrollElement,
  double minScrollHeight = 0.0,
}) {
  final floating = floatingElement;
  if (floating == null) {
    return null;
  }

  return _whileMeasurable(floating, () {
    final clip = _clippingBand(layout);
    final clipTop = clip.top + viewportPadding;
    final clipBottom = clip.bottom - viewportPadding;
    final reference = layout.referenceRect;
    final referenceTop = reference.top.toDouble();
    final referenceBottom = referenceTop + reference.height.toDouble();

    final naturalHeight = _naturalHeight(floating, scrollElement);
    final popperSide = layout.placement.split('-').first;

    if (popperSide == 'left' || popperSide == 'right') {
      final available = clipBottom - clipTop;
      final capped = constrainHeight &&
          _applyHeightCap(
            floating: floating,
            scrollElement: scrollElement,
            naturalHeight: naturalHeight,
            availableHeight: available,
            minScrollHeight: minScrollHeight,
          );
      return LiOverlayPlacement(
        side: popperSide,
        availableHeight: available,
        naturalHeight: naturalHeight,
        capped: capped,
      );
    }

    final spaceBelow = clipBottom - referenceBottom - gap;
    final spaceAbove = referenceTop - gap - clipTop;
    final preferred = preferredSide == 'top' ? 'top' : 'bottom';
    final other = preferred == 'top' ? 'bottom' : 'top';
    double spaceOn(String side) => side == 'top' ? spaceAbove : spaceBelow;

    final String side;
    if (naturalHeight <= spaceOn(preferred)) {
      side = preferred;
    } else if (naturalHeight <= spaceOn(other)) {
      side = other;
    } else {
      side = spaceAbove > spaceBelow ? 'top' : 'bottom';
    }
    final available = spaceOn(side) > 0 ? spaceOn(side) : 0.0;

    final capped = constrainHeight &&
        _applyHeightCap(
          floating: floating,
          scrollElement: scrollElement,
          naturalHeight: naturalHeight,
          availableHeight: available,
          minScrollHeight: minScrollHeight,
        );

    // Measured after the cap: this is the height the panel really has now.
    final rect = floating.getBoundingClientRect();
    final height = rect.height.toDouble();
    final viewportY =
        side == 'bottom' ? referenceBottom + gap : referenceTop - gap - height;

    final referenceLeft = reference.left.toDouble();
    final referenceWidth = reference.width.toDouble();
    final width = rect.width.toDouble();
    final overlap = _min3(16.0, referenceWidth, width);
    final viewportX = _clampDouble(
      layout.viewportX,
      referenceLeft - width + overlap,
      referenceLeft + referenceWidth - overlap,
    );

    final x = layout.x + (viewportX - layout.viewportX);
    final y = viewportY + _cssOffsetY(layout);
    final transform =
        'translate(${x.toStringAsFixed(2)}px, ${y.toStringAsFixed(2)}px)';
    if (floating.style.transform != transform) {
      floating.style.transform = transform;
    }

    final placement = _withSide(layout.placement, side);
    if (floating.getAttribute('data-popper-placement') != placement) {
      floating.setAttribute('data-popper-placement', placement);
    }

    return LiOverlayPlacement(
      side: side,
      availableHeight: available,
      naturalHeight: naturalHeight,
      capped: capped,
    );
  });
}

/// Re-runs an overlay's layout when the panel or the field changes size.
///
/// Popper's auto update listens to scroll, resize and DOM mutations, but not
/// to a size change: a panel that grows when its content switches (days to
/// months), when a class shows it, or when a web font arrives kept the
/// position computed for the old size. A `ResizeObserver` on both elements
/// closes that gap. Deliveries are collapsed into one [onResize] per frame,
/// on the next animation frame, so the layout written there never resizes an
/// element inside the observer's own delivery (which the browser reports as
/// "ResizeObserver loop completed with undelivered notifications").
///
/// ```dart
/// _resizeWatch ??= LiOverlayResizeWatch(() => _overlay?.update());
/// _resizeWatch!.observe(<html.Element?>[trigger, panel]);
/// // on close / destroy:
/// _resizeWatch?.disconnect();
/// ```
class LiOverlayResizeWatch {
  /// Creates a watch that calls [onResize] at most once per frame.
  LiOverlayResizeWatch(this.onResize);

  /// Called on the frame after a watched element changed size.
  final void Function() onResize;

  html.ResizeObserver? _observer;
  bool _framePending = false;

  /// Starts watching [elements] (the `null` ones are skipped), replacing what
  /// was watched before. The observer reports every element once right after
  /// it starts, which also covers a panel shown after the first layout.
  void observe(Iterable<html.Element?> elements) {
    disconnect();
    // `dart:html` delivers ResizeObserver callbacks in the root zone (see the
    // datatable's container observer); captured here so the layout runs in
    // the zone of whoever opened the overlay.
    final zone = Zone.current;
    final observer = html.ResizeObserver(
      (List<dynamic> entries, html.ResizeObserver observer) {
        zone.run(_scheduleFrame);
      },
    );
    for (final element in elements) {
      if (element != null) {
        observer.observe(element);
      }
    }
    _observer = observer;
  }

  /// Stops watching. Safe to call when nothing is watched.
  void disconnect() {
    _observer?.disconnect();
    _observer = null;
    _framePending = false;
  }

  /// Whether elements are being watched.
  bool get isObserving => _observer != null;

  /// Collapses the deliveries of one frame into a single [onResize].
  void _scheduleFrame() {
    if (_framePending) {
      return;
    }
    _framePending = true;
    html.window.requestAnimationFrame((_) {
      if (!_framePending || _observer == null) {
        return;
      }
      _framePending = false;
      onResize();
    });
  }
}

/// Runs [measure] with [floating] laid out, even when it is `display: none`.
///
/// Components show the panel through a class bound in the template, which
/// lands on the next change detection; the layout requested in the same turn
/// as the open sees the panel hidden. Like popper's own measurement, the panel
/// is shown invisibly for the length of the call and handed back as it was.
T _whileMeasurable<T>(html.Element floating, T Function() measure) {
  if (floating.getComputedStyle().display != 'none') {
    return measure();
  }

  final style = floating.style;
  final display = style.display;
  final visibility = style.visibility;
  style.display = 'block';
  style.visibility = 'hidden';
  try {
    return measure();
  } finally {
    style.display = display;
    style.visibility = visibility;
  }
}

/// Height of [floating] without the inline `max-height` this file writes on it
/// or on [scrollElement].
///
/// The inline cap is lifted for one measurement and put back, so a limit that
/// comes from the stylesheet (`.li-tag-filter__list { max-height: 15rem }`)
/// still counts: the panel is never taller than its own CSS allows, and the
/// cap written here is only ever tighter than that. Lifting the cap lets the
/// browser clamp the scroll position, so it is restored afterwards — an
/// update while the person is halfway down a list must not jump it to the top.
double _naturalHeight(html.Element floating, html.Element? scrollElement) {
  final scroller = scrollElement ?? floating;
  final inlineMaxHeight = scroller.style.maxHeight;
  if (inlineMaxHeight.isEmpty) {
    return floating.getBoundingClientRect().height.toDouble();
  }

  final scrollTop = scroller.scrollTop;
  scroller.style.maxHeight = '';
  final height = floating.getBoundingClientRect().height.toDouble();
  scroller.style.maxHeight = inlineMaxHeight;
  if (scroller.scrollTop != scrollTop) {
    scroller.scrollTop = scrollTop;
  }
  return height;
}

/// Writes or clears the `max-height` that fits the overlay in
/// [availableHeight]. Returns whether a cap is in place.
bool _applyHeightCap({
  required html.Element floating,
  required html.Element? scrollElement,
  required double naturalHeight,
  required double availableHeight,
  required double minScrollHeight,
}) {
  final needsCap = naturalHeight > availableHeight + 0.5;

  if (scrollElement == null) {
    final style = floating.style;
    final maxHeight = needsCap ? '${availableHeight.floor()}px' : '';
    if (style.maxHeight != maxHeight) {
      style.maxHeight = maxHeight;
    }
    if (needsCap) {
      style.overflowY = 'auto';
      style.overflowX = 'hidden';
      style.setProperty('overscroll-behavior', 'contain');
    } else if (style.overflowY.isNotEmpty) {
      style.overflowY = '';
      style.overflowX = '';
      style.removeProperty('overscroll-behavior');
    }
    return needsCap;
  }

  final style = scrollElement.style;
  if (!needsCap) {
    if (style.maxHeight.isNotEmpty) {
      style.maxHeight = '';
    }
    return false;
  }

  // Everything of the panel that is not the scroll element's box.
  final panelHeight = floating.getBoundingClientRect().height.toDouble();
  final scrollBox = scrollElement.getBoundingClientRect().height.toDouble();
  final chrome = panelHeight - scrollBox;
  var limit = availableHeight - chrome;
  final computed = scrollElement.getComputedStyle();
  if (computed.boxSizing != 'border-box') {
    limit -= _px(computed.paddingTop) +
        _px(computed.paddingBottom) +
        _px(computed.borderTopWidth) +
        _px(computed.borderBottomWidth);
  }
  if (limit < minScrollHeight) {
    limit = minScrollHeight;
  }
  final maxHeight = '${limit.floor()}px';
  if (style.maxHeight != maxHeight) {
    style.maxHeight = maxHeight;
  }
  return true;
}

/// Vertical band an overlay may use: popper's clipping rect, cut to the
/// viewport.
({double top, double bottom}) _clippingBand(PopperLayout layout) {
  final clipping = layout.clippingRect;
  final viewportHeight = resolveViewportHeight();
  var top = clipping.top.toDouble();
  var bottom = top + clipping.height.toDouble();
  if (top < 0) {
    top = 0;
  }
  if (viewportHeight > 0 && bottom > viewportHeight) {
    bottom = viewportHeight;
  }
  return (top: top, bottom: bottom);
}

/// What popper added to a viewport `y` to get the CSS `y` it wrote (zero for
/// the `fixed` strategy, the scroll of the offset parent for `absolute`).
double _cssOffsetY(PopperLayout layout) => layout.y - layout.viewportY;

/// [placement] with its base swapped for [side], keeping the alignment.
String _withSide(String placement, String side) {
  final dash = placement.indexOf('-');
  return dash < 0 ? side : '$side${placement.substring(dash)}';
}

/// Parses a computed length such as `12px`; anything else reads as zero.
double _px(String value) =>
    double.tryParse(value.replaceAll('px', '').trim()) ?? 0.0;

/// Smallest of three numbers.
double _min3(double a, double b, double c) {
  final ab = a < b ? a : b;
  return ab < c ? ab : c;
}

/// [value] kept within [min]..[max]; [min] wins when the range is empty.
double _clampDouble(double value, double min, double max) {
  if (value > max) {
    value = max;
  }
  return value < min ? min : value;
}
