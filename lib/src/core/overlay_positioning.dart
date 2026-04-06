import 'dart:html' as html;

import 'package:popper/popper.dart';

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
