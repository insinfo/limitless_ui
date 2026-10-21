// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/datatable/datatable_exporter_test.dart

@TestOn('browser')
library;

import 'dart:html';
import 'dart:js_util' as js_util;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:limitless_ui/src/components/datatable/datatable_exporter.dart';
import 'package:test/test.dart';

void main() {
  group('DatatableExporter.plainTextFromHtml', () {
    test('extracts the visible text of HTML cell values', () {
      expect(
        DatatableExporter.plainTextFromHtml(
            '  <b>Processo</b>\n  <span>123/2026</span> '),
        'Processo 123/2026',
      );
      expect(DatatableExporter.plainTextFromHtml('Texto puro'), 'Texto puro');
      expect(DatatableExporter.plainTextFromHtml('   '), '');
    });

    test('does not run handlers or fetch resources from the cell HTML',
        () async {
      final probe = 'li-export-probe-${DateTime.now().microsecondsSinceEpoch}';
      js_util.setProperty(window, '__liExportXss', 0);
      final imagesBefore = document.querySelectorAll('img').length;

      final text = DatatableExporter.plainTextFromHtml(
        '<img src="$probe.png" '
        'onerror="window.__liExportXss = window.__liExportXss + 1">'
        '<svg onload="window.__liExportXss = window.__liExportXss + 1"></svg>'
        '<script>window.__liExportXss = window.__liExportXss + 1</script>'
        'Valor',
      );

      // Give a live <img> plenty of time to fail and fire onerror.
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(text, contains('Valor'));
      expect(js_util.getProperty<Object?>(window, '__liExportXss'), 0,
          reason: 'no handler from the exported value may run');
      expect(document.querySelectorAll('img').length, imagesBefore);
      final requested = window.performance
          .getEntriesByType('resource')
          .map((entry) => entry.name)
          .where((name) => name.contains(probe));
      expect(requested, isEmpty,
          reason: 'the image of the exported value must not be fetched');
    });
  });

  group('DatatableExporter.exportPdf', () {
    test('exports values outside Latin-1 without throwing', () async {
      final settings = DatatableSettings(colsDefinitions: [
        DatatableCol(key: 'nome', title: 'Descrição'),
        DatatableCol(key: 'valor', title: 'Valor'),
      ]);
      final rows = [
        DatatableRow(columns: [
          DatatableCol(
              key: 'nome', title: 'Descrição', value: '“Olá” — teste…'),
          DatatableCol(key: 'valor', title: 'Valor', value: '€ 10 ‐ 😀 中文'),
        ]),
        DatatableRow(columns: [
          DatatableCol(
              key: 'nome',
              title: 'Descrição',
              value: '<b>Ação</b> ‘ok’ ${'😀' * 80}'),
          DatatableCol(key: 'valor', title: 'Valor', value: '™ • ‰'),
        ]),
      ];

      await expectLater(
        DatatableExporter.exportPdf(
          settings: settings,
          rows: rows,
          isDownload: false,
        ),
        completes,
      );
    });
  });
}
