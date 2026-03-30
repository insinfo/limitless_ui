import 'dart:async';
import 'dart:html';
import 'dart:js_util' as js_util;
import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../../core/lite_xlsx.dart';
import '../../core/tine_pdf.dart' as tine_pdf;
import 'datatable_col.dart';
import 'datatable_row.dart';
import 'datatable_settings.dart';

class _PreparedPdfRow {
  final bool isGroupTitle;
  final List<List<String>> cellLines;
  final double height;

  const _PreparedPdfRow({
    required this.isGroupTitle,
    required this.cellLines,
    required this.height,
  });

  factory _PreparedPdfRow.groupTitle({
    required List<String> lines,
    required double height,
  }) {
    return _PreparedPdfRow(
      isGroupTitle: true,
      cellLines: <List<String>>[lines],
      height: height,
    );
  }

  factory _PreparedPdfRow.normal({
    required List<List<String>> cellLines,
    required double height,
  }) {
    return _PreparedPdfRow(
      isGroupTitle: false,
      cellLines: cellLines,
      height: height,
    );
  }
}

class DatatableExporter {
  static void exportXlsx({
    required DatatableSettings settings,
    required List<DatatableRow> rows,
    DivElement? card,
  }) {
    // Always export all columns regardless of visibility.
    final allColumns = settings.colsDefinitions;
    if (allColumns.isEmpty) {
      return;
    }

    final workbook = <String, dynamic>{
      'sheets': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': _exportSheetName(card),
          'data': <List<dynamic>>[
            allColumns.map((col) => col.title).toList(),
            ..._buildExportRows(rows, allColumns),
          ],
        },
      ],
    };

    final bytes = LiteXlsx.create(workbook);
    _downloadBytes(
      bytes,
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      '${_exportFileBaseName(card)}.xlsx',
    );
  }

  static Future<void> exportPdf({
    required DatatableSettings settings,
    required List<DatatableRow> rows,
    DivElement? card,
    bool isPrint = false,
    bool isDownload = true,
  }) async {
    final visibleColumns = _visibleExportColumns(settings);
    if (visibleColumns.isEmpty) {
      return;
    }

    final rowsData = _buildExportRows(rows, visibleColumns);
    final doc = tine_pdf.TinePDF();

    final useA3Landscape = visibleColumns.length > 8;
    final pageWidth = useA3Landscape ? 1191.0 : 842.0;
    final pageHeight = useA3Landscape ? 842.0 : 595.0;

    const margin = 32.0;
    const titleSize = 16.0;
    const metaSize = 9.0;
    final textSize = visibleColumns.length >= 10 ? 8.0 : 9.0;
    const cellPaddingX = 4.0;
    const cellPaddingY = 5.0;
    const lineSpacing = 2.0;

    final tableWidth = pageWidth - (margin * 2);
    final colWidths = _buildPdfColumnWidths(
      visibleColumns: visibleColumns,
      rowsData: rowsData,
      tableWidth: tableWidth,
      fontSize: textSize,
      horizontalPadding: cellPaddingX * 2,
    );

    final title = _exportFileBaseName(card);
    final issuedAt = DateFormat("dd/MM/yyyy 'às' HH:mm").format(DateTime.now());

    final headerLines = <List<String>>[
      for (var i = 0; i < visibleColumns.length; i++)
        _wrapTextForPdf(
          visibleColumns[i].title,
          math.max(12.0, colWidths[i] - (cellPaddingX * 2)),
          textSize,
        ),
    ];

    final headerMaxLines = headerLines.fold<int>(
      1,
      (acc, lines) => math.max(acc, lines.length),
    );

    final headerHeight = _rowHeightForLines(
      headerMaxLines,
      fontSize: textSize,
      paddingY: cellPaddingY,
      lineSpacing: lineSpacing,
    );

    final preparedRows = <_PreparedPdfRow>[];
    for (final row in rowsData) {
      if (row.length == 1 && visibleColumns.length > 1) {
        final lines = _wrapTextForPdf(
          row.first,
          math.max(12.0, tableWidth - (cellPaddingX * 2)),
          textSize,
        );
        preparedRows.add(
          _PreparedPdfRow.groupTitle(
            lines: lines,
            height: _rowHeightForLines(
              lines.length,
              fontSize: textSize,
              paddingY: cellPaddingY,
              lineSpacing: lineSpacing,
            ),
          ),
        );
        continue;
      }

      final cellLines = <List<String>>[];
      var maxLines = 1;

      for (var i = 0; i < visibleColumns.length; i++) {
        final value = i < row.length ? row[i] : '';
        final lines = _wrapTextForPdf(
          value,
          math.max(12.0, colWidths[i] - (cellPaddingX * 2)),
          textSize,
        );
        cellLines.add(lines);
        maxLines = math.max(maxLines, lines.length);
      }

      preparedRows.add(
        _PreparedPdfRow.normal(
          cellLines: cellLines,
          height: _rowHeightForLines(
            maxLines,
            fontSize: textSize,
            paddingY: cellPaddingY,
            lineSpacing: lineSpacing,
          ),
        ),
      );
    }

    final titleBlockHeight = titleSize + 6 + metaSize + 13;
    final firstPageAvailableHeight =
        pageHeight - (margin * 2) - titleBlockHeight - headerHeight;

    final pages = <List<_PreparedPdfRow>>[];
    var currentPageRows = <_PreparedPdfRow>[];
    var remainingHeight = firstPageAvailableHeight;

    for (final row in preparedRows) {
      final rowHeight = row.height;

      if (currentPageRows.isNotEmpty && rowHeight > remainingHeight) {
        pages.add(currentPageRows);
        currentPageRows = <_PreparedPdfRow>[];
        remainingHeight = firstPageAvailableHeight;
      }

      currentPageRows.add(row);
      remainingHeight -= rowHeight;
    }

    if (currentPageRows.isNotEmpty) {
      pages.add(currentPageRows);
    }

    if (pages.isEmpty) {
      pages.add(const <_PreparedPdfRow>[]);
    }

    for (var pageIndex = 0; pageIndex < pages.length; pageIndex++) {
      final pageRows = pages[pageIndex];

      doc.page(
        width: pageWidth,
        height: pageHeight,
        build: (ctx) {
          var cursorTop = pageHeight - margin;

          ctx.text(
            title,
            margin,
            cursorTop - titleSize,
            titleSize,
            color: '#1f2937',
          );
          cursorTop -= titleSize + 6;

          ctx.text(
            'Emitido em $issuedAt | Página ${pageIndex + 1}',
            margin,
            cursorTop - metaSize,
            metaSize,
            color: '#6b7280',
          );
          cursorTop -= metaSize + 13;

          final headerBottom = cursorTop - headerHeight;
          ctx.rect(margin, headerBottom, tableWidth, headerHeight, '#e9ecef');

          var x = margin;
          for (var i = 0; i < visibleColumns.length; i++) {
            _drawWrappedText(
              ctx: ctx,
              lines: headerLines[i],
              x: x,
              top: cursorTop,
              width: colWidths[i],
              fontSize: textSize,
              paddingX: cellPaddingX,
              paddingY: cellPaddingY,
              lineSpacing: lineSpacing,
              color: '#111827',
            );

            if (i > 0) {
              ctx.line(x, headerBottom, x, cursorTop, '#d1d5db', 0.5);
            }

            x += colWidths[i];
          }

          ctx.line(
            margin,
            headerBottom,
            margin + tableWidth,
            headerBottom,
            '#cbd5e1',
            0.75,
          );

          cursorTop = headerBottom;

          for (final row in pageRows) {
            final rowBottom = cursorTop - row.height;

            if (row.isGroupTitle) {
              ctx.rect(margin, rowBottom, tableWidth, row.height, '#f8f9fa');
              _drawWrappedText(
                ctx: ctx,
                lines: row.cellLines.first,
                x: margin,
                top: cursorTop,
                width: tableWidth,
                fontSize: textSize,
                paddingX: cellPaddingX,
                paddingY: cellPaddingY,
                lineSpacing: lineSpacing,
                color: '#374151',
              );
            } else {
              var cellX = margin;
              for (var i = 0; i < visibleColumns.length; i++) {
                _drawWrappedText(
                  ctx: ctx,
                  lines: row.cellLines[i],
                  x: cellX,
                  top: cursorTop,
                  width: colWidths[i],
                  fontSize: textSize,
                  paddingX: cellPaddingX,
                  paddingY: cellPaddingY,
                  lineSpacing: lineSpacing,
                  color: '#111827',
                );

                if (i > 0) {
                  ctx.line(cellX, rowBottom, cellX, cursorTop, '#e5e7eb', 0.5);
                }

                cellX += colWidths[i];
              }
            }

            ctx.line(
              margin,
              rowBottom,
              margin + tableWidth,
              rowBottom,
              '#e5e7eb',
              0.5,
            );

            cursorTop = rowBottom;
          }
        },
      );
    }

    final bytes = doc.build();
    if (isDownload) {
      _downloadBytes(bytes, 'application/pdf', '$title.pdf');
    }
    if (isPrint) {
      _openForPrint(bytes, 'application/pdf');
    }
  }

  static List<DatatableCol> _visibleExportColumns(DatatableSettings settings) {
    return settings.colsDefinitions.where((col) => col.visibility).toList();
  }

  static List<List<String>> _buildExportRows(
    List<DatatableRow> rows,
    List<DatatableCol> visibleColumns,
  ) {
    final exportRows = <List<String>>[];
    for (final row in rows) {
      if (row.type == DatatableRowType.groupTitle) {
        final label = row.columns
            .map(_plainTextFromColumn)
            .where((value) => value.isNotEmpty)
            .join(' / ');
        if (label.isNotEmpty) {
          exportRows.add(<String>[label]);
        }
        continue;
      }

      exportRows.add(<String>[
        for (final visibleColumn in visibleColumns)
          _plainTextFromColumn(
            row.columns.firstWhere(
              (column) => column.key == visibleColumn.key,
              orElse: () => DatatableCol(
                key: visibleColumn.key,
                title: visibleColumn.title,
              ),
            ),
          ),
      ]);
    }
    return exportRows;
  }

  static String _plainTextFromColumn(DatatableCol col) {
    if (col.htmlElement != null) {
      return col.htmlElement!.text?.trim() ?? '';
    }

    final raw = col.value.trim();
    if (raw.isEmpty) {
      return '';
    }

    final container = DivElement()
      ..setInnerHtml(raw, treeSanitizer: NodeTreeSanitizer.trusted);

    final normalized =
        container.text?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';

    return normalized.isNotEmpty ? normalized : raw;
  }

  static String _exportSheetName(DivElement? card) {
    final base = _exportFileBaseName(card)
        .replaceAll(RegExp(r'[\[\]\*:/\\?]'), ' ')
        .trim();

    if (base.isEmpty) {
      return 'Relatório';
    }

    return base.length > 31 ? base.substring(0, 31) : base;
  }

  static String _exportFileBaseName(DivElement? card) {
    final title =
        (card?.querySelector('.card-title, .datatable-title')?.text ?? '')
            .trim();
    return title.isNotEmpty ? title : 'Relatório';
  }

  static List<double> _buildPdfColumnWidths({
    required List<DatatableCol> visibleColumns,
    required List<List<String>> rowsData,
    required double tableWidth,
    required double fontSize,
    required double horizontalPadding,
  }) {
    if (visibleColumns.isEmpty) {
      return const <double>[];
    }

    final sampleRows = rowsData.take(200).toList(growable: false);
    final rawWidths = <double>[];

    for (var i = 0; i < visibleColumns.length; i++) {
      var preferredWidth = tine_pdf.TinePDF.measureText(
            visibleColumns[i].title,
            fontSize,
          ) +
          horizontalPadding;

      for (final row in sampleRows) {
        if (row.length == 1 && visibleColumns.length > 1) {
          continue;
        }

        final value = i < row.length ? row[i] : '';
        if (value.isEmpty) {
          continue;
        }

        preferredWidth = math.max(
          preferredWidth,
          tine_pdf.TinePDF.measureText(value, fontSize) + horizontalPadding,
        );
      }

      preferredWidth = preferredWidth.clamp(72.0, tableWidth * 0.35).toDouble();
      rawWidths.add(preferredWidth);
    }

    final totalPreferred = rawWidths.fold<double>(0.0, (a, b) => a + b);
    if (totalPreferred <= 0) {
      return List<double>.filled(
        visibleColumns.length,
        tableWidth / visibleColumns.length,
      );
    }

    return rawWidths
        .map((width) => (width / totalPreferred) * tableWidth)
        .toList(growable: false);
  }

  static List<String> _wrapTextForPdf(
    String value,
    double width,
    double fontSize,
  ) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return const <String>[''];
    }

    if (tine_pdf.TinePDF.measureText(normalized, fontSize) <= width) {
      return <String>[normalized];
    }

    final words = normalized.split(' ');
    final lines = <String>[];
    var current = '';

    for (final word in words) {
      if (current.isEmpty) {
        if (tine_pdf.TinePDF.measureText(word, fontSize) <= width) {
          current = word;
        } else {
          lines.addAll(_breakLongToken(word, width, fontSize));
        }
        continue;
      }

      final candidate = '$current $word';
      if (tine_pdf.TinePDF.measureText(candidate, fontSize) <= width) {
        current = candidate;
        continue;
      }

      lines.add(current);

      if (tine_pdf.TinePDF.measureText(word, fontSize) <= width) {
        current = word;
      } else {
        lines.addAll(_breakLongToken(word, width, fontSize));
        current = '';
      }
    }

    if (current.isNotEmpty) {
      lines.add(current);
    }

    return lines.isEmpty ? const <String>[''] : lines;
  }

  static List<String> _breakLongToken(
    String token,
    double width,
    double fontSize,
  ) {
    final parts = <String>[];
    var remaining = token;

    while (remaining.isNotEmpty) {
      var end = 1;

      while (end <= remaining.length &&
          tine_pdf.TinePDF.measureText(
                remaining.substring(0, end),
                fontSize,
              ) <=
              width) {
        end++;
      }

      var safeEnd = end - 1;
      if (safeEnd <= 0) {
        safeEnd = 1;
      }

      parts.add(remaining.substring(0, safeEnd));
      remaining = remaining.substring(safeEnd);
    }

    return parts;
  }

  static double _rowHeightForLines(
    int lineCount, {
    required double fontSize,
    required double paddingY,
    required double lineSpacing,
  }) {
    final safeLineCount = math.max(1, lineCount);
    return (paddingY * 2) +
        (safeLineCount * fontSize) +
        ((safeLineCount - 1) * lineSpacing);
  }

  static void _drawWrappedText({
    required dynamic ctx,
    required List<String> lines,
    required double x,
    required double top,
    required double width,
    required double fontSize,
    required double paddingX,
    required double paddingY,
    required double lineSpacing,
    required String color,
  }) {
    var baseline = top - paddingY - fontSize;
    for (final line in lines) {
      ctx.text(
        line,
        x + paddingX,
        baseline,
        fontSize,
        color: color,
      );
      baseline -= fontSize + lineSpacing;
    }
  }

  static void _downloadBytes(List<int> bytes, String mimeType, String fileName) {
    final blob = Blob(<Object>[bytes], mimeType);
    final url = Url.createObjectUrlFromBlob(blob);

    final anchor = AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';

    document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    Url.revokeObjectUrl(url);
  }

  static void _openForPrint(List<int> bytes, String mimeType) {
    final blob = Blob(<Object>[bytes], mimeType);
    final url = Url.createObjectUrlFromBlob(blob);
    final win = window.open(url, '_blank');

    Timer(const Duration(milliseconds: 300), () {
      js_util.callMethod(win, 'focus', const <Object>[]);
      js_util.callMethod(win, 'print', const <Object>[]);
      Url.revokeObjectUrl(url);
    });
  }
}
