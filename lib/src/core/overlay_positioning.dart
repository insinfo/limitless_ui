import 'package:limitless_ui/web_compat.dart' as html;

import 'package:popper/popper.dart';

PopperPortalOptions resolveModalAwarePortalOptions({
  required String hostClassName,
  required html.Element referenceElement,
  required int baseHostZIndex,
  int? baseFloatingZIndex,
  int modalZIndexOffset = 1,
}) {
  final effectiveFloatingZIndex = baseFloatingZIndex ?? baseHostZIndex;
  final modalAwareHostZIndex = _resolveModalAwareHostZIndex(
    referenceElement: referenceElement,
    baseHostZIndex: baseHostZIndex,
    modalZIndexOffset: modalZIndexOffset,
  );
  final floatingDelta = effectiveFloatingZIndex - baseHostZIndex;
  final modalAwareFloatingZIndex =
      modalAwareHostZIndex + (floatingDelta > 0 ? floatingDelta : 0);

  return PopperPortalOptions(
    hostClassName: hostClassName,
    hostZIndex: '$modalAwareHostZIndex',
    floatingZIndex: '$modalAwareFloatingZIndex',
  );
}

int _resolveModalAwareHostZIndex({
  required html.Element referenceElement,
  required int baseHostZIndex,
  required int modalZIndexOffset,
}) {
  final owningModal = referenceElement.closest('.modal');
  final owningModalZIndex = _parseElementZIndex(owningModal);
  if (owningModalZIndex != null) {
    return _max(baseHostZIndex, owningModalZIndex + modalZIndexOffset);
  }

  final openModals = html.document.queryAll('.modal[data-status="open"]');
  var highestModalZIndex = -1;
  for (final modal in openModals) {
    final zIndex = _parseElementZIndex(modal);
    if (zIndex != null && zIndex > highestModalZIndex) {
      highestModalZIndex = zIndex;
    }
  }

  if (highestModalZIndex >= 0) {
    return _max(baseHostZIndex, highestModalZIndex + modalZIndexOffset);
  }

  return baseHostZIndex;
}

int? _parseElementZIndex(html.Element? element) {
  if (element == null) {
    return null;
  }

  final inlineZIndex = int.tryParse(element.style.zIndex.trim());
  if (inlineZIndex != null) {
    return inlineZIndex;
  }

  return int.tryParse(element.getComputedStyle().zIndex.trim());
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
  final windowHeight = html.window.innerHeight.toDouble();
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
  final floatingHeight = layout.floatingRect.height.toDouble();
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
