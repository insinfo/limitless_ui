// Puppeteer driver for the limitless_ui benchmark app.
//
// Usage (from the benchmarks/ directory, after serving a release build):
//   dart run tool/bench.dart <url> <label>
//
// Measures, against a release build of exemplo2 served at <url>:
//   - datatable: click #btn-render and wait until 2500 tbody rows exist and
//     two animation frames have painted;
//   - dropdown: click the li-dropdown-menu trigger and wait for
//     [data-open="true"] plus two frames;
//   - select: click the li-select trigger and wait for
//     .dropdown-container.dropdown-open plus two frames.
// Every wait loop has a frame budget so a wrong selector fails loudly with a
// DOM snapshot instead of hanging. Progress goes to stderr; the final line on
// stdout is one JSON document with all samples and medians.
import 'dart:convert';
import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

const int tableIterations = 9;
const int overlayIterations = 15;

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln('usage: dart run tool/bench_exemplo2.dart <url> <label>');
    exit(2);
  }
  final url = args[0];
  final label = args[1];

  final executablePath = Platform.environment['CHROME_EXECUTABLE'];
  final browser = await puppeteer.launch(
    headless: true,
    executablePath:
        executablePath != null && executablePath.isNotEmpty ? executablePath : null,
    noSandboxFlag: true,
    defaultViewport: DeviceViewport(width: 1600, height: 1000),
    args: const ['--window-size=1600,1000', '--disable-dev-shm-usage'],
  );

  try {
    final page = await browser.newPage();
    page.onError.listen((e) => stderr.writeln('[pageerror] $e'));
    await page.goto(url, wait: Until.networkIdle);
    await page.waitForSelector('#btn-render', timeout: const Duration(seconds: 60));

    Future<num> timedStep(String clickSel, String doneExpr, String stepLabel) async {
      final result = await page.evaluate<String>('''async (clickSel, doneExpr) => {
  const raf = () => new Promise(r => requestAnimationFrame(r));
  const done = new Function('return (' + doneExpr + ');');
  const t0 = performance.now();
  document.querySelector(clickSel).click();
  for (let i = 0; i < 3600; i++) {
    if (done()) {
      await raf(); await raf();
      return JSON.stringify({ok: true, ms: performance.now() - t0});
    }
    await raf();
  }
  return JSON.stringify({
    ok: false,
    rows: document.querySelectorAll('li-datatable tbody tr').length,
    ddOpen: !!document.querySelector('#dd [data-open="true"]'),
    selOpen: !!document.querySelector('#sel .dropdown-container.dropdown-open'),
  });
}''', args: [clickSel, doneExpr]);
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      if (decoded['ok'] != true) {
        throw StateError('timeout em "$stepLabel": $result');
      }
      return decoded['ms'] as num;
    }

    Future<void> settle(String clickSel, String doneExpr, String stepLabel) async {
      final result = await page.evaluate<String>('''async (clickSel, doneExpr) => {
  const raf = () => new Promise(r => requestAnimationFrame(r));
  const done = new Function('return (' + doneExpr + ');');
  document.querySelector(clickSel).click();
  for (let i = 0; i < 3600; i++) {
    if (done()) { await raf(); return JSON.stringify({ok: true}); }
    await raf();
  }
  return JSON.stringify({ok: false});
}''', args: [clickSel, doneExpr]);
      if ((jsonDecode(result) as Map<String, dynamic>)['ok'] != true) {
        throw StateError('timeout ao restaurar estado em "$stepLabel"');
      }
    }

    const rowsFull =
        "document.querySelectorAll('li-datatable tbody tr').length >= 2500";
    const rowsEmpty =
        "document.querySelectorAll('li-datatable tbody tr').length <= 10";
    const ddOpen = "!!document.querySelector('#dd [data-open=\\'true\\']')";
    const ddClosed = "!document.querySelector('#dd [data-open=\\'true\\']')";
    // The select panel is moved to a popper portal on <body> while open, so
    // the open marker must be looked up globally, not inside #sel.
    const selOpen =
        "!!document.querySelector('.dropdown-container.dropdown-open')";
    const selClosed =
        "!document.querySelector('.dropdown-container.dropdown-open')";

    final table = <num>[];
    for (var i = 0; i < tableIterations; i++) {
      table.add(await timedStep('#btn-render', rowsFull, 'render tabela'));
      await settle('#btn-clear', rowsEmpty, 'limpar tabela');
      stderr.writeln('[bench] table ${i + 1}/$tableIterations: ${table.last.toStringAsFixed(1)} ms');
    }

    final dropdown = <num>[];
    for (var i = 0; i < overlayIterations; i++) {
      dropdown.add(await timedStep('#dd button', ddOpen, 'abrir dropdown'));
      await settle('#dd button', ddClosed, 'fechar dropdown');
      stderr.writeln('[bench] dropdown ${i + 1}/$overlayIterations: ${dropdown.last.toStringAsFixed(1)} ms');
    }

    final select = <num>[];
    for (var i = 0; i < overlayIterations; i++) {
      select.add(await timedStep(
          '#sel [data-label="li_select_toggle"]', selOpen, 'abrir select'));
      await settle(
          '#sel [data-label="li_select_toggle"]', selClosed, 'fechar select');
      stderr.writeln('[bench] select ${i + 1}/$overlayIterations: ${select.last.toStringAsFixed(1)} ms');
    }

    num median(List<num> xs) {
      final s = [...xs]..sort();
      final n = s.length;
      return n.isOdd ? s[n ~/ 2] : (s[n ~/ 2 - 1] + s[n ~/ 2]) / 2;
    }

    stdout.writeln(jsonEncode({
      'label': label,
      'url': url,
      'table': {
        'samples': table,
        'first': table.first,
        'median': median(table),
        'medianWarm': median(table.sublist(1)),
      },
      'dropdown': {
        'samples': dropdown,
        'first': dropdown.first,
        'median': median(dropdown),
        'medianWarm': median(dropdown.sublist(1)),
      },
      'select': {
        'samples': select,
        'first': select.first,
        'median': median(select),
        'medianWarm': median(select.sublist(1)),
      },
    }));
  } finally {
    await browser.close();
  }
}
