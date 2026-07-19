import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'datatable_col.dart';
import 'datatable_collection_utils.dart';
import 'datatable_css_utils.dart';

List<web.Element> _queryElements(web.Element root, String selectors) {
  final nodes = root.querySelectorAll(selectors);
  return <web.Element>[
    for (var index = 0; index < nodes.length; index++)
      nodes.item(index)! as web.Element,
  ];
}

/// Owns responsive datatable state and calculations.
///
/// The component still decides when to sync based on Angular lifecycle and
/// animation frames. This controller only stores measured widths, forced-visible
/// columns, auto-hidden columns, and fixed-column offsets.
class DatatableResponsiveController {
  final Map<String, double> _columnWidthCache = <String, double>{};
  final Map<int, double> _fixedLeftOffsets = <int, double>{};
  final Map<int, double> _fixedRightOffsets = <int, double>{};
  final Set<String> _autoHiddenColumnKeys = <String>{};
  final Set<String> _forcedVisibleColumnKeys = <String>{};
  double _checkboxWidth = 44;

  /// Runtime column keys hidden by responsive auto-hide.
  Set<String> get autoHiddenColumnKeys => _autoHiddenColumnKeys;

  /// Runtime column keys forced visible by user interaction.
  Set<String> get forcedVisibleColumnKeys => _forcedVisibleColumnKeys;

  /// Number of left-fixed columns with resolved offsets.
  int get leftFixedCount => _fixedLeftOffsets.length;

  /// Number of right-fixed columns with resolved offsets.
  int get rightFixedCount => _fixedRightOffsets.length;

  /// Clears DOM measurements used to estimate responsive widths.
  void resetMeasurementCache() {
    _columnWidthCache.clear();
    _checkboxWidth = 44;
  }

  /// Clears all runtime responsive state.
  void clearRuntimeState() {
    _autoHiddenColumnKeys.clear();
    _fixedLeftOffsets.clear();
    _fixedRightOffsets.clear();
  }

  /// Removes forced-visible keys that no longer exist in settings.
  void removeInvalidForcedKeys(Set<String> validKeys) {
    _forcedVisibleColumnKeys.removeWhere((key) => !validKeys.contains(key));
  }

  /// Marks or unmarks [columnKey] as forced visible.
  void setForcedVisible(String columnKey, bool forced) {
    final normalized = columnKey.trim();
    if (normalized.isEmpty) {
      return;
    }

    if (forced) {
      _forcedVisibleColumnKeys.add(normalized);
    } else {
      _forcedVisibleColumnKeys.remove(normalized);
    }
  }

  /// Whether [column] is forced visible despite responsive rules.
  bool isColumnForcedVisible(DatatableCol column) {
    final columnKey = column.key.trim();
    if (columnKey.isEmpty) {
      return false;
    }

    return _forcedVisibleColumnKeys.contains(columnKey);
  }

  /// Whether [column] is currently hidden only by runtime responsive behavior.
  bool isRuntimeResponsiveHidden({
    required DatatableCol column,
    required bool responsiveEnabled,
    required bool collapseActive,
  }) {
    if (!responsiveEnabled || isColumnForcedVisible(column)) {
      return false;
    }

    final hiddenOnMobile = collapseActive && column.hideOnMobile;
    final hiddenByPriority = _autoHiddenColumnKeys.contains(column.key);
    return hiddenOnMobile || hiddenByPriority;
  }

  /// Whether [column] should be visible after static and responsive visibility.
  bool isColumnEffectivelyVisible({
    required DatatableCol column,
    required bool responsiveEnabled,
    required bool collapseActive,
  }) {
    return column.visibility &&
        !isRuntimeResponsiveHidden(
          column: column,
          responsiveEnabled: responsiveEnabled,
          collapseActive: collapseActive,
        );
  }

  /// Measures visible table header widths for auto-hide and fixed offsets.
  void syncColumnWidthCache({
    required web.HTMLElement? tableElement,
    required bool showCheckboxToSelectRow,
  }) {
    if (tableElement == null) {
      return;
    }

    final headerCells = _queryElements(tableElement, 'thead th[data-key]');
    for (final element in headerCells) {
      if (!element.isA<web.HTMLTableCellElement>()) {
        continue;
      }
      final cell = element as web.HTMLTableCellElement;
      if (cell.classList.contains('hide')) {
        continue;
      }

      final key = cell.getAttribute('data-key')?.trim() ?? '';
      if (key.isEmpty) {
        continue;
      }

      final rectWidth = cell.getBoundingClientRect().width.toDouble();
      final measuredWidth =
          rectWidth > 0 ? rectWidth : cell.offsetWidth.toDouble();
      if (measuredWidth > 0) {
        final cachedWidth = _columnWidthCache[key];
        _columnWidthCache[key] = cachedWidth == null
            ? measuredWidth
            : (measuredWidth < cachedWidth ? measuredWidth : cachedWidth);
      }
    }

    if (!showCheckboxToSelectRow) {
      return;
    }

    final checkboxCell =
        tableElement.querySelector('thead th.datatable-first-col');
    if (!(checkboxCell?.isA<web.HTMLTableCellElement>() ?? false)) {
      return;
    }
    final firstCol = checkboxCell as web.HTMLTableCellElement;

    final rectWidth = firstCol.getBoundingClientRect().width.toDouble();
    final measuredWidth =
        rectWidth > 0 ? rectWidth : firstCol.offsetWidth.toDouble();
    if (measuredWidth > 0) {
      _checkboxWidth =
          measuredWidth < _checkboxWidth ? measuredWidth : _checkboxWidth;
    }
  }

  /// Synchronizes auto-hidden columns and returns whether the hidden set changed.
  bool syncAutoHiddenColumns({
    required bool responsiveEnabled,
    required bool autoHideEnabled,
    required bool gridMode,
    required double availableWidth,
    required List<DatatableCol> columns,
    required bool collapseActive,
    required bool showCheckboxToSelectRow,
  }) {
    final nextKeys = computeAutoHiddenColumnKeys(
      responsiveEnabled: responsiveEnabled,
      autoHideEnabled: autoHideEnabled,
      gridMode: gridMode,
      availableWidth: availableWidth,
      columns: columns,
      collapseActive: collapseActive,
      showCheckboxToSelectRow: showCheckboxToSelectRow,
    );
    if (DatatableCollectionUtils.setEquals(nextKeys, _autoHiddenColumnKeys)) {
      return false;
    }

    _autoHiddenColumnKeys
      ..clear()
      ..addAll(nextKeys);
    return true;
  }

  /// Computes which columns should be hidden by priority for the given width.
  Set<String> computeAutoHiddenColumnKeys({
    required bool responsiveEnabled,
    required bool autoHideEnabled,
    required bool gridMode,
    required double availableWidth,
    required List<DatatableCol> columns,
    required bool collapseActive,
    required bool showCheckboxToSelectRow,
  }) {
    if (!responsiveEnabled || !autoHideEnabled || gridMode) {
      return const <String>{};
    }

    if (availableWidth <= 0) {
      return const <String>{};
    }

    final baseVisibleColumns = columns.where((column) {
      final hiddenOnMobile = collapseActive &&
          column.hideOnMobile &&
          !isColumnForcedVisible(column);
      return column.visibility && !hiddenOnMobile;
    }).toList(growable: false);

    if (baseVisibleColumns.isEmpty) {
      return const <String>{};
    }

    final totalWidth = baseVisibleColumns.fold<double>(
      showCheckboxToSelectRow ? _checkboxWidth : 0,
      (sum, column) => sum + resolveColumnWidth(column),
    );

    if (totalWidth <= availableWidth) {
      return const <String>{};
    }

    final candidates = baseVisibleColumns
        .where((column) =>
            !column.responsiveAutoHideRequired &&
            column.fixedPosition == null &&
            !isColumnForcedVisible(column) &&
            column.responsiveAutoHidePriority != null)
        .toList(growable: false);

    if (candidates.isEmpty) {
      return const <String>{};
    }

    candidates.sort((left, right) {
      final priorityCompare = left.responsiveAutoHidePriority!
          .compareTo(right.responsiveAutoHidePriority!);
      if (priorityCompare != 0) {
        return priorityCompare;
      }

      final widthCompare =
          resolveColumnWidth(right).compareTo(resolveColumnWidth(left));
      if (widthCompare != 0) {
        return widthCompare;
      }

      return columns.indexOf(left).compareTo(columns.indexOf(right));
    });

    final hiddenKeys = <String>{};
    var remainingWidth = totalWidth;
    for (final candidate in candidates) {
      if (remainingWidth <= availableWidth) {
        break;
      }

      hiddenKeys.add(candidate.key);
      remainingWidth -= resolveColumnWidth(candidate);
    }

    return hiddenKeys;
  }

  /// Recomputes sticky offsets for fixed columns.
  void syncFixedColumnOffsets({
    required bool gridMode,
    required List<DatatableCol> columns,
    required bool responsiveEnabled,
    required bool collapseActive,
  }) {
    _fixedLeftOffsets.clear();
    _fixedRightOffsets.clear();

    if (gridMode || columns.isEmpty) {
      return;
    }

    var leftOffset = 0.0;
    for (var index = 0; index < columns.length; index++) {
      final column = columns[index];
      if (!isLeftFixedColumn(
        column: column,
        responsiveEnabled: responsiveEnabled,
        collapseActive: collapseActive,
      )) {
        continue;
      }

      _fixedLeftOffsets[index] = leftOffset;
      leftOffset += resolveColumnWidth(column);
    }

    var rightOffset = 0.0;
    for (var index = columns.length - 1; index >= 0; index--) {
      final column = columns[index];
      if (!isRightFixedColumn(
        column: column,
        responsiveEnabled: responsiveEnabled,
        collapseActive: collapseActive,
      )) {
        continue;
      }

      _fixedRightOffsets[index] = rightOffset;
      rightOffset += resolveColumnWidth(column);
    }
  }

  /// Whether [column] has an active fixed position.
  bool isFixedColumn({
    required DatatableCol column,
    required bool responsiveEnabled,
    required bool collapseActive,
  }) {
    return column.fixedPosition != null &&
        isColumnEffectivelyVisible(
          column: column,
          responsiveEnabled: responsiveEnabled,
          collapseActive: collapseActive,
        );
  }

  /// Whether [column] is fixed to the left.
  bool isLeftFixedColumn({
    required DatatableCol column,
    required bool responsiveEnabled,
    required bool collapseActive,
  }) {
    return column.fixedPosition == DatatableFixedColumnPosition.left &&
        isFixedColumn(
          column: column,
          responsiveEnabled: responsiveEnabled,
          collapseActive: collapseActive,
        );
  }

  /// Whether [column] is fixed to the right.
  bool isRightFixedColumn({
    required DatatableCol column,
    required bool responsiveEnabled,
    required bool collapseActive,
  }) {
    return column.fixedPosition == DatatableFixedColumnPosition.right &&
        isFixedColumn(
          column: column,
          responsiveEnabled: responsiveEnabled,
          collapseActive: collapseActive,
        );
  }

  /// Inline CSS for a fixed column offset.
  String? fixedColumnStyleCss({
    required DatatableCol column,
    required int index,
    required bool responsiveEnabled,
    required bool collapseActive,
  }) {
    if (!isFixedColumn(
      column: column,
      responsiveEnabled: responsiveEnabled,
      collapseActive: collapseActive,
    )) {
      return null;
    }

    if (column.fixedPosition == DatatableFixedColumnPosition.left) {
      final offset = _fixedLeftOffsets[index] ?? 0;
      return 'left: ${DatatableCssUtils.formatPixelValue(offset)}';
    }

    if (column.fixedPosition == DatatableFixedColumnPosition.right) {
      final offset = _fixedRightOffsets[index] ?? 0;
      return 'right: ${DatatableCssUtils.formatPixelValue(offset)}';
    }

    return null;
  }

  /// Resolves a column width from measurement, configured CSS length, or default.
  double resolveColumnWidth(DatatableCol column) {
    final cachedWidth = _columnWidthCache[column.key];
    if (cachedWidth != null && cachedWidth > 0) {
      return cachedWidth;
    }

    return DatatableCssUtils.parseLength(column.width, allowRelative: false) ??
        DatatableCssUtils.parseLength(
          column.minWidth,
          allowRelative: false,
        ) ??
        DatatableCssUtils.parseLength(
          column.maxWidth,
          allowRelative: false,
        ) ??
        (column.nowrap ? 140.0 : 120.0);
  }
}
