//datatable_row_builder.dart
import 'dart:html';

import 'package:essential_core/essential_core.dart';
import 'package:intl/intl.dart';

import 'datatable_col.dart';
import 'datatable_models.dart';
import 'datatable_row.dart';
import 'datatable_settings.dart';

class DatatableRowBuildResult {
  DatatableRowBuildResult({
    required this.rows,
    required this.renderedRows,
  });

  final List<DatatableRow> rows;
  final List<DatatableRenderedRow> renderedRows;
}

class DatatableRowBuilder {
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');
  final DateFormat _dateTimeShortFormatter = DateFormat('dd/MM/yyyy HH:mm');

  void applyComputedColumnMetadataToSettings(DatatableSettings settings) {
    for (final col in settings.colsDefinitions) {
      col.headerStyleCss = _resolveHeaderStyle(col);
      col.renderedTitle = _resolveTitle(col);
      col.titleHtmlElement = _resolveTitleHtmlElement(col);
    }
  }

  DatatableRowBuildResult build({
    required DataFrame data,
    required DatatableSettings settings,
    required bool nullIsEmpty,
    required bool gridMode,
    required bool responsiveCollapse,
    required int responsiveCollapseMaxWidth,
    int rowIndexOffset = 0,
    bool? responsiveCollapseActive,
    Set<String> autoHiddenColumnKeys = const <String>{},
  }) {
    return buildRange(
      data: data,
      settings: settings,
      nullIsEmpty: nullIsEmpty,
      gridMode: gridMode,
      responsiveCollapse: responsiveCollapse,
      responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
      startIndex: 0,
      endIndex: data.length,
      rowIndexOffset: rowIndexOffset,
      responsiveCollapseActive: responsiveCollapseActive,
      autoHiddenColumnKeys: autoHiddenColumnKeys,
    );
  }

  DatatableRowBuildResult buildRange({
    required DataFrame data,
    required DatatableSettings settings,
    required bool nullIsEmpty,
    required bool gridMode,
    required bool responsiveCollapse,
    required int responsiveCollapseMaxWidth,
    required int startIndex,
    required int endIndex,
    int rowIndexOffset = 0,
    bool? responsiveCollapseActive,
    Set<String> autoHiddenColumnKeys = const <String>{},
  }) {
    final rows = <DatatableRow>[];
    String? previousGroupingValue;

    List<Map<String, dynamic>>? itemsAsMap;
    Map<String, dynamic> itemMapAt(int index) {
      final itemInstance = data[index];
      if (itemInstance is Map) {
        return _coerceItemMap(itemInstance);
      }

      itemsAsMap ??= data.itemsAsMap;
      return index < itemsAsMap!.length
          ? itemsAsMap![index]
          : _coerceItemMap(itemInstance);
    }

    final safeStartIndex = startIndex.clamp(0, data.length).toInt();
    final safeEndIndex = endIndex.clamp(safeStartIndex, data.length).toInt();

    for (var absoluteIndex = safeStartIndex;
        absoluteIndex < safeEndIndex;
        absoluteIndex++) {
      final itemMap = itemMapAt(absoluteIndex);
      final itemInstance = data[absoluteIndex];
      final row = DatatableRow(
        index: rowIndexOffset + absoluteIndex,
        instance: itemInstance,
        itemMap: itemMap,
        columns: <DatatableCol>[],
      );

      for (final colDefinition in settings.colsDefinitions) {
        row.addColumn(
          _buildComputedColumn(
            colDefinition: colDefinition,
            itemMap: itemMap,
            itemInstance: itemInstance,
            nullIsEmpty: nullIsEmpty,
            gridMode: gridMode,
          ),
        );
      }

      _decorateRow(
        row: row,
        itemMap: itemMap,
        itemInstance: itemInstance,
        settings: settings,
        gridMode: gridMode,
      );

      if (settings.enableGrouping) {
        final groupingColumns = row.columns
            .where(
                (column) => column.enableGrouping && column.groupByKey != null)
            .toList(growable: false);
        final groupBys = groupingColumns
            .map((column) => column.groupByKey!)
            .toList(growable: false);

        if (groupBys.isNotEmpty) {
          final currentGroupingValue = itemMap.entries
              .where((entry) => groupBys.contains(entry.key))
              .map((entry) => entry.value)
              .join('.');

          if (absoluteIndex > 0) {
            previousGroupingValue = itemMapAt(absoluteIndex - 1)
                .entries
                .where((entry) => groupBys.contains(entry.key))
                .map((entry) => entry.value)
                .join('.');
          }

          if (currentGroupingValue != previousGroupingValue) {
            final divTitle = DivElement()
              ..text =
                  groupingColumns.map((column) => column.value).join(' / ');
            rows.add(
              DatatableRow(
                type: DatatableRowType.groupTitle,
                columns: <DatatableCol>[
                  DatatableCol(
                    type: DatatableColType.groupTitle,
                    htmlElement: divTitle,
                    key: '',
                    title: '',
                    visibility: true,
                    colspan: row.columns.length,
                    styleCss: 'text-align: center;',
                    cellClass: 'datatable-group-title-cell',
                  ),
                ],
              ),
            );
          }
        }
      }

      rows.add(row);
    }

    return DatatableRowBuildResult(
      rows: rows,
      renderedRows: rebuildRenderedRows(
        rows: rows,
        responsiveCollapse: responsiveCollapse,
        responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
        responsiveCollapseActive: responsiveCollapseActive,
        responsiveControlColumnKey: settings.responsiveControlColumnKey,
        autoHiddenColumnKeys: autoHiddenColumnKeys,
      ),
    );
  }

  Map<String, dynamic> _coerceItemMap(dynamic itemInstance) {
    if (itemInstance is Map<String, dynamic>) {
      return itemInstance;
    }

    if (itemInstance is Map) {
      try {
        return Map<String, dynamic>.from(itemInstance);
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    try {
      final dynamic rawMap = (itemInstance as dynamic).toMap();
      if (rawMap is Map<String, dynamic>) {
        return rawMap;
      }
      if (rawMap is Map) {
        return Map<String, dynamic>.from(rawMap);
      }
    } catch (_) {
      // ignora itens que nao expõem um mapa utilizável
    }

    return <String, dynamic>{};
  }

  List<DatatableRenderedRow> rebuildRenderedRows({
    required List<DatatableRow> rows,
    required bool responsiveCollapse,
    required int responsiveCollapseMaxWidth,
    bool? responsiveCollapseActive,
    String? responsiveControlColumnKey,
    Set<String> autoHiddenColumnKeys = const <String>{},
  }) {
    final responsiveActive = responsiveCollapseActive ??
        _isResponsiveViewportActive(
          responsiveCollapse: responsiveCollapse,
          responsiveCollapseMaxWidth: responsiveCollapseMaxWidth,
        );
    final hasAutoHiddenColumns = autoHiddenColumnKeys.isNotEmpty;

    return rows.map((row) {
      if ((!responsiveActive && !hasAutoHiddenColumns) ||
          row.type != DatatableRowType.normal) {
        return DatatableRenderedRow(
          row: row,
          hasResponsiveHiddenColumns: false,
          responsiveHiddenColumns: const <DatatableCol>[],
          responsiveControlColumnKey: null,
        );
      }

      final hiddenColumns = row.columns.where((column) {
        if (!column.visibility) {
          return false;
        }

        final hiddenOnMobile = responsiveActive && column.hideOnMobile;
        final hiddenByPriority = autoHiddenColumnKeys.contains(column.key);
        return hiddenOnMobile || hiddenByPriority;
      }).toList(growable: false);

      String? controlColumnKey;
      if (hiddenColumns.isNotEmpty) {
        final normalizedRequestedControlColumnKey =
            responsiveControlColumnKey?.trim();
        DatatableCol? fallbackVisibleColumn;
        DatatableCol? requiredVisibleColumn;
        DatatableCol? requestedVisibleColumn;

        for (final candidate in row.columns) {
          final hiddenOnMobile = responsiveActive && candidate.hideOnMobile;
          final hiddenByPriority = autoHiddenColumnKeys.contains(candidate.key);
          if (!candidate.visibility || hiddenOnMobile || hiddenByPriority) {
            continue;
          }

          fallbackVisibleColumn ??= candidate;

          if (normalizedRequestedControlColumnKey != null &&
              normalizedRequestedControlColumnKey.isNotEmpty &&
              candidate.key == normalizedRequestedControlColumnKey) {
            requestedVisibleColumn ??= candidate;
          }

          if (candidate.responsiveAutoHideRequired) {
            requiredVisibleColumn ??= candidate;
          }
        }

        controlColumnKey = requestedVisibleColumn?.key ??
            requiredVisibleColumn?.key ??
            fallbackVisibleColumn?.key;
      }

      return DatatableRenderedRow(
        row: row,
        hasResponsiveHiddenColumns: hiddenColumns.isNotEmpty,
        responsiveHiddenColumns: hiddenColumns,
        responsiveControlColumnKey: controlColumnKey,
      );
    }).toList(growable: false);
  }

  String buildGridLayoutStyle(DatatableSettings settings) {
    return _mergeStyleDeclarations(<String?>[
          'grid-template-columns: ${settings.gridTemplateColumns}',
          'gap: ${settings.gridGap}',
        ]) ??
        '';
  }

  DatatableCol _buildComputedColumn({
    required DatatableCol colDefinition,
    required Map<String, dynamic> itemMap,
    required dynamic itemInstance,
    required bool nullIsEmpty,
    required bool gridMode,
  }) {
    final rawValue = _resolveRawColumnValue(
      colDefinition: colDefinition,
      itemMap: itemMap,
      itemInstance: itemInstance,
    );

    final htmlElement = colDefinition.customRenderHtml != null
        ? colDefinition.customRenderHtml!(itemMap, itemInstance)
        : null;

    final value = htmlElement != null
        ? ''
        : _normalizeDisplayValue(
            value: rawValue,
            format: colDefinition.format,
            nullIsEmpty: nullIsEmpty,
          );

    return DatatableCol(
      type: colDefinition.type,
      value: value,
      key: colDefinition.key,
      title: colDefinition.title,
      visibility: colDefinition.visibility,
      styleCss: _resolveCellStyle(
        colDefinition,
        itemMap,
        itemInstance,
        gridMode: gridMode,
      ),
      headerStyleCss: colDefinition.headerStyleCss,
      headerClass: colDefinition.headerClass,
      cellClass: _resolveCellClass(colDefinition),
      width: colDefinition.width,
      minWidth: colDefinition.minWidth,
      maxWidth: colDefinition.maxWidth,
      textAlign: colDefinition.textAlign,
      titleTextAlign: colDefinition.titleTextAlign,
      nowrap: colDefinition.nowrap,
      cellStyleResolver: colDefinition.cellStyleResolver,
      customRenderTitleString: colDefinition.customRenderTitleString,
      customRenderTitleHtml: colDefinition.customRenderTitleHtml,
      titleTooltip: colDefinition.titleTooltip,
      titlePopover: colDefinition.titlePopover,
      htmlElement: htmlElement,
      enableGrouping: colDefinition.enableGrouping,
      groupByKey: colDefinition.groupByKey,
      visibilityOnCard: colDefinition.visibilityOnCard,
      showTitleOnCard: colDefinition.showTitleOnCard,
      hideOnMobile: colDefinition.hideOnMobile,
      responsiveAutoHideRequired: colDefinition.responsiveAutoHideRequired,
      responsiveAutoHidePriority: colDefinition.responsiveAutoHidePriority,
      fixedPosition: colDefinition.fixedPosition,
      showAsFooterOnCard: colDefinition.showAsFooterOnCard,
      colspan: colDefinition.colspan,
      multiValSeparator: colDefinition.multiValSeparator,
      defaultSortDirection: colDefinition.defaultSortDirection,
      sortingBy: colDefinition.sortingBy,
      enableSorting: colDefinition.enableSorting,
    )
      ..renderedTitle = colDefinition.renderedTitle
      ..titleHtmlElement = colDefinition.titleHtmlElement;
  }

  dynamic _resolveRawColumnValue({
    required DatatableCol colDefinition,
    required Map<String, dynamic> itemMap,
    required dynamic itemInstance,
  }) {
    dynamic value;
    if (colDefinition.key.contains('||')) {
      final keys =
          colDefinition.key.split('||').map((key) => key.trim()).toList();
      value =
          keys.map((key) => itemMap[key]).join(colDefinition.multiValSeparator);
    } else if (colDefinition.key.contains('.')) {
      final keys = colDefinition.key.split('.');
      value = getValRecursive(itemMap, keys);
    } else {
      value = itemMap[colDefinition.key];
    }

    if (colDefinition.customRenderString != null) {
      return colDefinition.customRenderString!(itemMap, itemInstance);
    }

    return value;
  }

  String _normalizeDisplayValue({
    required dynamic value,
    required DatatableFormat? format,
    required bool nullIsEmpty,
  }) {
    dynamic normalized = value;

    switch (format) {
      case DatatableFormat.boolHighlightedBadge:
        if (normalized is bool) {
          normalized =
              normalized ? '<span class="badge bg-primary">Sim</span>' : 'Não';
        }
        break;
      case DatatableFormat.bool:
        if (normalized is bool) {
          normalized = normalized ? 'Sim' : 'Não';
        }
        break;
      case DatatableFormat.date:
        if (normalized != null) {
          final parsed = normalized is DateTime
              ? normalized
              : DateTime.tryParse(normalized.toString());
          normalized = parsed != null ? _dateFormatter.format(parsed) : null;
        }
        break;
      case DatatableFormat.dateTime:
        if (normalized != null) {
          final parsed = normalized is DateTime
              ? normalized
              : DateTime.tryParse(normalized.toString());
          normalized =
              parsed != null ? _dateTimeFormatter.format(parsed) : null;
        }
        break;
      case DatatableFormat.dateTimeShort:
        if (normalized != null) {
          final parsed = normalized is DateTime
              ? normalized
              : DateTime.tryParse(normalized.toString());
          normalized =
              parsed != null ? _dateTimeShortFormatter.format(parsed) : null;
        }
        break;
      case DatatableFormat.text:
        normalized = normalized?.toString();
        break;
      case null:
        break;
    }

    if (nullIsEmpty) {
      return normalized == null ? '' : normalized.toString();
    }

    return normalized?.toString() ?? '';
  }

  void _decorateRow({
    required DatatableRow row,
    required Map<String, dynamic> itemMap,
    required dynamic itemInstance,
    required DatatableSettings settings,
    required bool gridMode,
  }) {
    if (settings.rowStyleResolver != null) {
      try {
        row.styleCss = settings.rowStyleResolver!(itemMap, itemInstance);
      } catch (_) {
        // ignora falhas do resolver customizado
      }
    }

    if (gridMode &&
        row.type == DatatableRowType.normal &&
        settings.customCardBuilder != null) {
      try {
        row.customCardElement =
            settings.customCardBuilder!(itemMap, itemInstance, row);
      } catch (_) {
        row.customCardElement = null;
      }
    } else {
      row.customCardElement = null;
    }
  }

  dynamic getValRecursive(Map<String, dynamic> itemMap, List<String> keys) {
    final key = keys[0];
    if (keys.length > 1) {
      keys.remove(key);
      final map = itemMap[key];
      if (map is Map<String, dynamic>) {
        return getValRecursive(map, keys);
      }
      return map;
    }
    return itemMap[key];
  }

  String? _resolveHeaderStyle(DatatableCol colDefinition) {
    return _mergeStyleDeclarations(<String?>[
      _buildHeaderColumnStyle(colDefinition),
      colDefinition.headerStyleCss,
    ]);
  }

  String _resolveTitle(DatatableCol colDefinition) {
    final customRenderTitleString = colDefinition.customRenderTitleString;
    if (customRenderTitleString == null) {
      return colDefinition.title;
    }

    try {
      return customRenderTitleString(colDefinition);
    } catch (_) {
      return colDefinition.title;
    }
  }

  Element? _resolveTitleHtmlElement(DatatableCol colDefinition) {
    final customRenderTitleHtml = colDefinition.customRenderTitleHtml;
    if (customRenderTitleHtml == null) {
      return null;
    }

    try {
      return customRenderTitleHtml(colDefinition);
    } catch (_) {
      return null;
    }
  }

  String? _resolveCellStyle(DatatableCol colDefinition,
      Map<String, dynamic> itemMap, dynamic itemInstance,
      {required bool gridMode}) {
    String? resolvedCellStyle;
    if (colDefinition.cellStyleResolver != null) {
      try {
        resolvedCellStyle =
            colDefinition.cellStyleResolver!(itemMap, itemInstance);
      } catch (_) {
        resolvedCellStyle = null;
      }
    }

    return _mergeStyleDeclarations(<String?>[
      gridMode
          ? _buildCardColumnStyle(colDefinition)
          : _buildBaseColumnStyle(colDefinition),
      colDefinition.styleCss,
      resolvedCellStyle,
    ]);
  }

  String _resolveCellClass(DatatableCol colDefinition) {
    return _joinClasses(<String?>['sorting_1', colDefinition.cellClass]);
  }

  String? _buildBaseColumnStyle(DatatableCol colDefinition) {
    final declarations = <String>[];

    if (colDefinition.width?.trim().isNotEmpty == true) {
      declarations.add('width: ${colDefinition.width!.trim()}');
    }
    if (colDefinition.minWidth?.trim().isNotEmpty == true) {
      declarations.add('min-width: ${colDefinition.minWidth!.trim()}');
    }
    if (colDefinition.maxWidth?.trim().isNotEmpty == true) {
      declarations.add('max-width: ${colDefinition.maxWidth!.trim()}');
    }
    if (colDefinition.textAlign?.trim().isNotEmpty == true) {
      declarations.add('text-align: ${colDefinition.textAlign!.trim()}');
    }
    if (colDefinition.nowrap) {
      declarations.add('white-space: nowrap');
    }

    if (declarations.isEmpty) {
      return null;
    }

    return '${declarations.join('; ')};';
  }

  String? _buildHeaderColumnStyle(DatatableCol colDefinition) {
    final declarations = <String>[];

    if (colDefinition.width?.trim().isNotEmpty == true) {
      declarations.add('width: ${colDefinition.width!.trim()}');
    }
    if (colDefinition.minWidth?.trim().isNotEmpty == true) {
      declarations.add('min-width: ${colDefinition.minWidth!.trim()}');
    }
    if (colDefinition.maxWidth?.trim().isNotEmpty == true) {
      declarations.add('max-width: ${colDefinition.maxWidth!.trim()}');
    }

    final titleTextAlign = colDefinition.titleTextAlign?.trim();
    if (titleTextAlign != null && titleTextAlign.isNotEmpty) {
      declarations.add('text-align: $titleTextAlign');
    } else if (colDefinition.textAlign?.trim().isNotEmpty == true) {
      declarations.add('text-align: ${colDefinition.textAlign!.trim()}');
    }

    if (colDefinition.nowrap) {
      declarations.add('white-space: nowrap');
    }

    if (declarations.isEmpty) {
      return null;
    }

    return '${declarations.join('; ')};';
  }

  String? _buildCardColumnStyle(DatatableCol colDefinition) {
    return null;
  }

  String? _mergeStyleDeclarations(Iterable<String?> declarations) {
    final normalized = declarations
        .whereType<String>()
        .map((declaration) => declaration.trim())
        .where((declaration) => declaration.isNotEmpty)
        .map((declaration) =>
            declaration.endsWith(';') ? declaration : '$declaration;')
        .toList(growable: false);

    if (normalized.isEmpty) {
      return null;
    }

    return normalized.join(' ');
  }

  String _joinClasses(Iterable<String?> classes) {
    return classes
        .whereType<String>()
        .map((className) => className.trim())
        .where((className) => className.isNotEmpty)
        .join(' ');
  }

  bool _isResponsiveViewportActive({
    required bool responsiveCollapse,
    required int responsiveCollapseMaxWidth,
  }) {
    if (!responsiveCollapse) {
      return false;
    }

    final viewportWidth = window.innerWidth;
    if (viewportWidth == null) {
      return false;
    }

    return viewportWidth <= responsiveCollapseMaxWidth;
  }
}
