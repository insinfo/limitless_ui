import 'package:web/web.dart' as web;

import 'datatable_exporter.dart';
import 'datatable_models.dart';
import 'datatable_row.dart';
import 'datatable_settings.dart';

/// Handles built-in and custom datatable export flows.
class DatatableExportController {
  /// Exports rows to XLSX using a custom callback when provided.
  Future<void> exportXlsx({
    required DatatableSettings settings,
    required List<DatatableRow> rows,
    required web.HTMLDivElement? card,
    required DatatableExportXlsxCallback? onExportXlsx,
  }) async {
    if (onExportXlsx != null) {
      await onExportXlsx(rows, settings.exportColumns);
      return;
    }

    DatatableExporter.exportXlsx(
      settings: settings,
      rows: rows,
      card: card,
    );
  }

  /// Exports rows to PDF using a custom callback when provided.
  Future<void> exportPdf({
    required DatatableSettings settings,
    required List<DatatableRow> rows,
    required web.HTMLDivElement? card,
    required DatatableExportPdfCallback? onExportPdf,
    bool isPrint = false,
    bool isDownload = true,
  }) async {
    if (onExportPdf != null) {
      await onExportPdf(rows, settings.visibleExportColumns);
      return;
    }

    await DatatableExporter.exportPdf(
      settings: settings,
      rows: rows,
      card: card,
      isPrint: isPrint,
      isDownload: isDownload,
    );
  }
}
