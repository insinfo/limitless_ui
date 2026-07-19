import 'package:limitless_ui/web_compat.dart';
import 'dart:math' as math;

import 'datatable_css_utils.dart';

/// Keeps virtual-scroll window state and calculations outside the component.
///
/// The controller is deliberately framework-agnostic apart from reading the
/// provided scroll container dimensions. It does not subscribe to events or
/// schedule frames; the component remains responsible for deciding when a sync
/// should happen.
class DatatableVirtualScrollController {
  int _startIndex = 0;
  int _endIndex = 0;
  int _topSpacerHeight = 0;
  int _bottomSpacerHeight = 0;
  bool _pendingReset = false;

  /// First item index included in the current virtual window.
  int get startIndex => _startIndex;

  /// Exclusive item index where the current virtual window ends.
  int get endIndex => _endIndex;

  /// Height, in pixels, of the spacer before rendered rows/items.
  int get topSpacerHeight => _topSpacerHeight;

  /// Height, in pixels, of the spacer after rendered rows/items.
  int get bottomSpacerHeight => _bottomSpacerHeight;

  /// Requests that the next sync resets the scroll container to the top.
  void requestReset() {
    _pendingReset = true;
  }

  /// Synchronizes the virtual window and returns whether state changed.
  bool sync({
    required bool isActive,
    required bool isGridActive,
    required int totalItems,
    required HtmlElement? scrollContainer,
    required int fallbackContainerWidth,
    required int windowInnerHeight,
    required String viewportHeight,
    required int overscan,
    required int rowHeight,
    required int gridItemHeight,
    required int gridMinItemWidth,
    required String gridTemplateColumns,
    required String gridGap,
  }) {
    if (!isActive) {
      return _syncInactive(totalItems);
    }

    final resolvedOverscan = math.max(0, overscan);

    if (_pendingReset) {
      scrollContainer?.scrollTop = 0;
      _pendingReset = false;
    }

    var resolvedViewportHeight = scrollContainer?.clientHeight ?? 0;
    final configuredViewportHeight = _resolveViewportHeightPx(
      viewportHeight: viewportHeight,
      windowInnerHeight: windowInnerHeight,
    );
    if (resolvedViewportHeight <= 0) {
      resolvedViewportHeight = configuredViewportHeight;
    } else if (configuredViewportHeight > 0) {
      resolvedViewportHeight = math.min(
        resolvedViewportHeight,
        configuredViewportHeight,
      );
    }

    return isGridActive
        ? _syncGridWindow(
            totalItems: totalItems,
            scrollContainer: scrollContainer,
            fallbackContainerWidth: fallbackContainerWidth,
            viewportHeight: resolvedViewportHeight,
            overscan: resolvedOverscan,
            gridItemHeight: gridItemHeight,
            gridMinItemWidth: gridMinItemWidth,
            gridTemplateColumns: gridTemplateColumns,
            gridGap: gridGap,
          )
        : _syncTableWindow(
            totalItems: totalItems,
            scrollContainer: scrollContainer,
            viewportHeight: resolvedViewportHeight,
            overscan: resolvedOverscan,
            rowHeight: rowHeight,
          );
  }

  bool _syncInactive(int totalItems) {
    final changed = _startIndex != 0 ||
        _endIndex != totalItems ||
        _topSpacerHeight != 0 ||
        _bottomSpacerHeight != 0;
    _startIndex = 0;
    _endIndex = totalItems;
    _topSpacerHeight = 0;
    _bottomSpacerHeight = 0;
    return changed;
  }

  bool _syncTableWindow({
    required int totalItems,
    required HtmlElement? scrollContainer,
    required int viewportHeight,
    required int overscan,
    required int rowHeight,
  }) {
    final resolvedRowHeight = math.max(1, rowHeight);
    var resolvedViewportHeight = viewportHeight;
    if (resolvedViewportHeight <= 0) {
      resolvedViewportHeight = resolvedRowHeight * 10;
    }

    final visibleCount = math.max(
      1,
      (resolvedViewportHeight / resolvedRowHeight).ceil(),
    );

    late final int startIndex;
    late final int endIndex;
    late final int topSpacerHeight;
    late final int bottomSpacerHeight;

    if (_isPinnedToEnd(
      scrollContainer: scrollContainer,
      fallbackItemExtent: resolvedRowHeight,
      totalExtentUnits: totalItems,
      viewportHeight: resolvedViewportHeight,
    )) {
      final pinnedWindowSize = math.max(1, visibleCount + overscan);
      startIndex = math.max(0, totalItems - pinnedWindowSize);
      endIndex = totalItems;
      topSpacerHeight = startIndex * resolvedRowHeight;
      bottomSpacerHeight = 0;
    } else {
      final firstVisibleIndex =
          (scrollContainer?.scrollTop ?? 0) ~/ resolvedRowHeight;

      startIndex = math.max(0, firstVisibleIndex - overscan);
      endIndex = math.min(
        totalItems,
        firstVisibleIndex + visibleCount + overscan,
      );
      topSpacerHeight = startIndex * resolvedRowHeight;
      bottomSpacerHeight = math.max(
        0,
        (totalItems - endIndex) * resolvedRowHeight,
      );
    }

    return _applyWindow(
      startIndex: startIndex,
      endIndex: endIndex,
      topSpacerHeight: topSpacerHeight,
      bottomSpacerHeight: bottomSpacerHeight,
    );
  }

  bool _syncGridWindow({
    required int totalItems,
    required HtmlElement? scrollContainer,
    required int fallbackContainerWidth,
    required int viewportHeight,
    required int overscan,
    required int gridItemHeight,
    required int gridMinItemWidth,
    required String gridTemplateColumns,
    required String gridGap,
  }) {
    final resolvedItemHeight = math.max(1, gridItemHeight);
    var resolvedViewportHeight = viewportHeight;
    if (resolvedViewportHeight <= 0) {
      resolvedViewportHeight = resolvedItemHeight * 4;
    }

    final columnsPerRow = _resolveGridColumnCount(
      scrollContainer: scrollContainer,
      fallbackContainerWidth: fallbackContainerWidth,
      gridMinItemWidth: gridMinItemWidth,
      gridTemplateColumns: gridTemplateColumns,
      gridGap: gridGap,
    );
    final visibleRowCount = math.max(
      1,
      (resolvedViewportHeight / resolvedItemHeight).ceil(),
    );
    final totalGridRows =
        columnsPerRow <= 0 ? 0 : (totalItems / columnsPerRow).ceil();

    late final int startIndex;
    late final int endIndex;
    late final int topSpacerHeight;
    late final int bottomSpacerHeight;

    if (_isPinnedToEnd(
      scrollContainer: scrollContainer,
      fallbackItemExtent: resolvedItemHeight,
      totalExtentUnits: totalGridRows,
      viewportHeight: resolvedViewportHeight,
    )) {
      final pinnedStartRow = math.max(
        0,
        totalGridRows - visibleRowCount - overscan,
      );
      startIndex = math.min(totalItems, pinnedStartRow * columnsPerRow);
      endIndex = totalItems;
      topSpacerHeight = pinnedStartRow * resolvedItemHeight;
      bottomSpacerHeight = 0;
    } else {
      final firstVisibleRow =
          (scrollContainer?.scrollTop ?? 0) ~/ resolvedItemHeight;
      final startRow = math.max(0, firstVisibleRow - overscan);
      final endRow = firstVisibleRow + visibleRowCount + overscan;

      startIndex = math.min(totalItems, startRow * columnsPerRow);
      endIndex = math.min(totalItems, endRow * columnsPerRow);
      topSpacerHeight = startRow * resolvedItemHeight;
      final renderedRowsCount = columnsPerRow <= 0
          ? 0
          : ((math.max(0, totalItems - endIndex)) / columnsPerRow).ceil();
      bottomSpacerHeight = math.max(0, renderedRowsCount * resolvedItemHeight);
    }

    return _applyWindow(
      startIndex: startIndex,
      endIndex: endIndex,
      topSpacerHeight: topSpacerHeight,
      bottomSpacerHeight: bottomSpacerHeight,
    );
  }

  bool _applyWindow({
    required int startIndex,
    required int endIndex,
    required int topSpacerHeight,
    required int bottomSpacerHeight,
  }) {
    final changed = _startIndex != startIndex ||
        _endIndex != endIndex ||
        _topSpacerHeight != topSpacerHeight ||
        _bottomSpacerHeight != bottomSpacerHeight;

    _startIndex = startIndex;
    _endIndex = endIndex;
    _topSpacerHeight = topSpacerHeight;
    _bottomSpacerHeight = bottomSpacerHeight;
    return changed;
  }

  int _resolveViewportHeightPx({
    required String viewportHeight,
    required int windowInnerHeight,
  }) {
    final normalized = viewportHeight.trim().toLowerCase();
    if (normalized.endsWith('px')) {
      return int.tryParse(normalized.replaceAll('px', '').trim()) ?? 0;
    }

    if (normalized.endsWith('vh')) {
      final value = double.tryParse(normalized.replaceAll('vh', '').trim());
      if (value == null || windowInnerHeight <= 0) {
        return 0;
      }
      return ((windowInnerHeight * value) / 100).round();
    }

    return int.tryParse(normalized) ?? 0;
  }

  int _resolveGridColumnCount({
    required HtmlElement? scrollContainer,
    required int fallbackContainerWidth,
    required int gridMinItemWidth,
    required String gridTemplateColumns,
    required String gridGap,
  }) {
    final containerWidth =
        (scrollContainer?.clientWidth ?? fallbackContainerWidth).toDouble();
    if (containerWidth <= 0) {
      return 1;
    }

    final minItemWidth = _resolveGridMinItemWidthPx(
      gridMinItemWidth: gridMinItemWidth,
      gridTemplateColumns: gridTemplateColumns,
    ).toDouble();
    final gapWidth = DatatableCssUtils.parseLength(gridGap) ?? 20.0;
    final columnCount =
        ((containerWidth + gapWidth) / (minItemWidth + gapWidth)).floor();
    return math.max(1, columnCount);
  }

  int _resolveGridMinItemWidthPx({
    required int gridMinItemWidth,
    required String gridTemplateColumns,
  }) {
    final configured = math.max(1, gridMinItemWidth);
    final templateColumns = gridTemplateColumns.trim().toLowerCase();
    final minmaxMatch = RegExp(r'minmax\(([^,]+),').firstMatch(
      templateColumns,
    );
    final parsed = DatatableCssUtils.parseLength(minmaxMatch?.group(1));
    if (parsed == null || parsed <= 0) {
      return configured;
    }

    return math.max(1, parsed.round());
  }

  bool _isPinnedToEnd({
    required HtmlElement? scrollContainer,
    required int fallbackItemExtent,
    required int totalExtentUnits,
    required int viewportHeight,
  }) {
    if (scrollContainer == null) {
      final maxScrollTop = math.max(
        0,
        (totalExtentUnits * fallbackItemExtent) - viewportHeight,
      );
      return maxScrollTop <= 0;
    }

    final scrollTop = scrollContainer.scrollTop.toDouble();
    final measuredMaxScrollTop = math
        .max(
          0,
          scrollContainer.scrollHeight - scrollContainer.clientHeight,
        )
        .toDouble();
    final fallbackMaxScrollTop = math
        .max(
          0,
          (totalExtentUnits * fallbackItemExtent) - viewportHeight,
        )
        .toDouble();
    final resolvedMaxScrollTop =
        measuredMaxScrollTop > 0 ? measuredMaxScrollTop : fallbackMaxScrollTop;
    final tolerance = math.max(2.0, fallbackItemExtent / 4);
    return resolvedMaxScrollTop <= 0 ||
        scrollTop >= (resolvedMaxScrollTop - tolerance);
  }
}
