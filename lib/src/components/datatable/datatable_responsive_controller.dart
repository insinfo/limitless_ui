import 'dart:html';

import 'datatable_col.dart';
import 'datatable_collection_utils.dart';
import 'datatable_css_utils.dart';

/// Owns responsive datatable state and calculations.
///
/// The component still decides when to sync based on Angular lifecycle and
/// animation frames. This controller only stores measured widths, forced-visible
/// columns, auto-hidden columns, and fixed-column offsets.
class DatatableResponsiveController {
  /// Extra width the container must gain before an auto-hidden column returns.
  ///
  /// Hiding a column makes the table narrower and usually shorter, which can
  /// retract the page scrollbar and hand the container back ~16px. Without a
  /// margin that gain alone makes every column fit again, the columns come
  /// back, the scrollbar returns, and the layout flips between the two states
  /// forever. Fractional browser zoom (110%) is where the two states land on
  /// either side of the threshold, so that is where the loop shows up.
  static const double autoHideRestoreMargin = 24;

  final Map<String, double> _columnWidthCache = <String, double>{};
  final Map<int, double> _fixedLeftOffsets = <int, double>{};
  final Map<int, double> _fixedRightOffsets = <int, double>{};
  final Set<String> _autoHiddenColumnKeys = <String>{};
  final Set<String> _forcedVisibleColumnKeys = <String>{};
  double _checkboxWidth = 44;
  bool _needsMeasurement = true;

  /// Runtime column keys hidden by responsive auto-hide.
  Set<String> get autoHiddenColumnKeys => _autoHiddenColumnKeys;

  /// Runtime column keys forced visible by user interaction.
  Set<String> get forcedVisibleColumnKeys => _forcedVisibleColumnKeys;

  /// Number of left-fixed columns with resolved offsets.
  int get leftFixedCount => _fixedLeftOffsets.length;

  /// Number of right-fixed columns with resolved offsets.
  int get rightFixedCount => _fixedRightOffsets.length;

  /// Whether the next sync has to re-measure the columns.
  bool get hasPendingMeasurement => _needsMeasurement;

  /// Larguras que [measureMinimumColumnWidths] gravou, por chave de coluna.
  ///
  /// Exposto para teste: é o resultado da medição, e a única forma de
  /// verificar que uma coluna escondida foi de fato medida em vez de cair no
  /// palpite do fallback.
  Map<String, double> get measuredColumnWidths =>
      Map<String, double>.unmodifiable(_columnWidthCache);

  /// Clears DOM measurements used to estimate responsive widths.
  ///
  /// Marks a re-measurement instead of leaving the cache empty: an empty cache
  /// would fall back to the declared widths, and those under-estimate a column
  /// whose content is wider than what was declared.
  void resetMeasurementCache() {
    _columnWidthCache.clear();
    _checkboxWidth = 44;
    _needsMeasurement = true;
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

  /// Classes que tiram uma coluna do layout.
  ///
  /// São três, e todas precisam sair do clone: esconder uma coluna aplica
  /// `hide` sempre, mais `datatable-mobile-hidden` quando o modo colapsado
  /// entra e `dtr-hidden` na marcação herdada do DataTables. Limpar só a
  /// primeira deixava a célula com `display: none` pelas outras duas, e a
  /// coluna media zero -- que é o mesmo que não medir.
  /// Classes do modo colapsado, que mudam como as células quebram texto.
  ///
  /// Saem do clone porque ele mede o estado com todas as colunas visíveis —
  /// que, por definição, não é o estado colapsado.
  static const List<String> _collapsedClasses = <String>[
    'collapsed',
    'dtr-inline',
  ];

  static const List<String> _hidingClasses = <String>[
    'hide',
    'datatable-mobile-hidden',
    'dtr-hidden',
  ];

  /// Mede a largura mínima de cada coluna num clone da tabela fora da tela.
  ///
  /// A técnica é a mesma do DataTables Responsive (`_resizeAuto`), e resolve
  /// dois problemas que medir a tabela renderizada não resolve:
  ///
  /// - **Coluna escondida não pode ser medida no lugar.** Ela não está no
  ///   layout, então a largura dela seria um palpite -- e um palpite baixo faz
  ///   o cálculo devolver a coluna cedo demais, gerando rolagem horizontal. No
  ///   clone todas as colunas estão presentes.
  /// - **Coluna visível medida no lugar mente para cima.** Com alguma coluna
  ///   escondida as demais esticam para ocupar o espaço vago, e gravar essa
  ///   medida realimentava o cálculo: escondia uma, as outras engordavam, o
  ///   total não cabia mais, escondia outra.
  ///
  /// O clone recebe `width: auto` e vai para dentro de um contêiner de 1px com
  /// `overflow: hidden`. Sem espaço para esticar e sem largura imposta, cada
  /// coluna encolhe até o menor tamanho que o conteúdo dela permite -- que é
  /// exatamente o número que o auto-hide quer.
  ///
  /// Todas as colunas são lidas na mesma passada, no mesmo estado: medir em
  /// momentos diferentes produz números que não podem ser somados entre si.
  void measureMinimumColumnWidths({
    required HtmlElement? tableElement,
    required bool showCheckboxToSelectRow,
  }) {
    if (tableElement == null || !hasPendingMeasurement) {
      return;
    }

    final host = tableElement.parent;
    if (host == null) {
      return;
    }

    final clone = tableElement.clone(true) as HtmlElement;

    // As linhas de detalhe não descrevem coluna nenhuma: são um `colspan` com
    // o conteúdo das escondidas, e deixá-las no clone empurra a largura da
    // tabela inteira para cima.
    for (final detailRow in clone.querySelectorAll('tbody tr.child')) {
      detailRow.remove();
    }

    // Toda coluna entra na medição, inclusive a que está escondida agora.
    for (final cell in clone.querySelectorAll('th, td')) {
      cell.classes.removeAll(_hidingClasses);
    }

    // O clone representa a tabela como ela seria com tudo visível, e nesse
    // estado ela não está colapsada. Manter as classes do modo colapsado
    // trazia junto o `white-space: nowrap` que o tema aplica ali: nenhuma
    // célula quebrava, cada coluna media o texto inteiro numa linha, e o total
    // saía quase o dobro do real (1159 viravam 1923). Com um total inflado o
    // auto-hide escondia colunas que cabiam folgadas.
    clone.classes.removeAll(_collapsedClasses);

    // Dois elementos com o mesmo `name` no documento interferem um no outro --
    // clonar um rádio marcado limparia o original.
    for (final named in clone.querySelectorAll('[name]')) {
      named.attributes.remove('name');
    }

    clone.style
      ..width = 'auto'
      ..tableLayout = 'auto'
      ..position = 'relative';

    final holder = DivElement()
      ..style.width = '1px'
      ..style.height = '1px'
      ..style.overflow = 'hidden'
      ..append(clone);

    host.insertBefore(holder, tableElement);

    try {
      final measured = <String, double>{};
      for (final cell in clone
          .querySelectorAll('thead th[data-key]')
          .whereType<TableCellElement>()) {
        final key = cell.getAttribute('data-key')?.trim() ?? '';
        if (key.isEmpty) {
          continue;
        }

        final width = cell.offsetWidth.toDouble();
        if (width <= 0) {
          // Uma coluna que ainda mede zero continua fora do layout, e gravar
          // esse zero faria o cálculo tratá-la como se não ocupasse espaço.
          // Melhor descartar a passada inteira do que misturar medidas boas
          // com uma inventada.
          return;
        }

        measured[key] = width;
      }

      if (measured.isEmpty) {
        return;
      }

      _columnWidthCache
        ..clear()
        ..addAll(measured);

      if (showCheckboxToSelectRow) {
        final checkboxCell =
            clone.querySelector('thead th.datatable-first-col');
        if (checkboxCell is TableCellElement) {
          final width = checkboxCell.offsetWidth.toDouble();
          if (width > 0) {
            _checkboxWidth = width;
          }
        }
      }

      _needsMeasurement = false;
    } finally {
      holder.remove();
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

    // Asymmetric threshold: columns start hiding as soon as they overflow, but
    // only come back once there is [autoHideRestoreMargin] to spare. See the
    // constant for why a symmetric threshold oscillates.
    final fitWidth = _autoHiddenColumnKeys.isEmpty
        ? availableWidth
        : _restoreThreshold(availableWidth);

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

    if (totalWidth <= fitWidth) {
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
      if (remainingWidth <= fitWidth) {
        break;
      }

      hiddenKeys.add(candidate.key);
      remainingWidth -= resolveColumnWidth(candidate);
    }

    return hiddenKeys;
  }

  /// Width everything has to fit into before hidden columns are restored.
  ///
  /// Never drops below half the available width: on a very narrow container the
  /// margin would otherwise eat the whole budget and hide every column.
  double _restoreThreshold(double availableWidth) {
    final threshold = availableWidth - autoHideRestoreMargin;
    final floor = availableWidth / 2;
    return threshold < floor ? floor : threshold;
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
  /// Largura que a coluna precisa ocupar, para efeito de auto-hide.
  ///
  /// A medição vem primeiro porque [syncColumnWidthCache] só grava com a
  /// tabela espremida, e ali ela é a largura mínima de verdade — já embute o
  /// `minWidth` declarado e o que o conteúdo exige além dele. Confiar só na
  /// declaração subestimava a coluna de texto longo: o cálculo achava que
  /// cabia, nada era escondido, e a tabela ganhava rolagem horizontal em vez
  /// de recolher.
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
