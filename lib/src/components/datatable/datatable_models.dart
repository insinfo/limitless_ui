//datatable_models.dart
import 'dart:async';

import 'datatable_col.dart';
import 'datatable_row.dart';

/// Callback for custom PDF export. Receives the same data the built-in
/// exporter uses so callers can build their own PDF layout.
typedef DatatableExportPdfCallback = FutureOr<void> Function(
  List<DatatableRow> rows,
  List<DatatableCol> exportColumns,
);

/// Callback for custom XLSX export.
typedef DatatableExportXlsxCallback = FutureOr<void> Function(
  List<DatatableRow> rows,
  List<DatatableCol> exportColumns,
);

/// A custom action that appears in the export/actions dropdown menu.
class DatatableMenuAction {
  final String label;
  final String? iconClass;
  final FutureOr<void> Function() action;

  DatatableMenuAction({
    required this.label,
    required this.action,
    this.iconClass,
  });
}

class DatatableSearchField {
  bool selected = false;
  final String label;
  final String field;
  final String operator;

  DatatableSearchField({
    this.selected = false,
    required this.label,
    required this.field,
    required this.operator,
  });

  void select() {
    selected = true;
  }
}

class LiDatatableInstrumentationEvent {
  LiDatatableInstrumentationEvent({
    required this.label,
    required this.stage,
    required this.timestamp,
    this.elapsedMicroseconds,
    Map<String, Object?> details = const <String, Object?>{},
  }) : details = Map<String, Object?>.unmodifiable(
          Map<String, Object?>.from(details),
        );

  final String label;
  final String stage;
  final DateTime timestamp;
  final int? elapsedMicroseconds;
  final Map<String, Object?> details;

  double? get elapsedMilliseconds => elapsedMicroseconds == null
      ? null
      : elapsedMicroseconds! / Duration.microsecondsPerMillisecond;

  String get formattedMessage {
    final buffer = StringBuffer(stage);
    final elapsed = elapsedMilliseconds;

    if (elapsed != null) {
      buffer.write(' ${elapsed.toStringAsFixed(3)}ms');
    }

    if (details.isNotEmpty) {
      buffer.write(' | ');
      buffer.write(
        details.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join(' | '),
      );
    }

    return buffer.toString();
  }
}

class DatatableRenderedRow {
  DatatableRenderedRow({
    required this.row,
    required this.hasResponsiveHiddenColumns,
    required this.responsiveHiddenColumns,
    required this.responsiveControlColumnKey,
  });

  final DatatableRow row;
  final bool hasResponsiveHiddenColumns;
  final List<DatatableCol> responsiveHiddenColumns;
  final String? responsiveControlColumnKey;
}
