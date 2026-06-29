// Run this browser benchmark from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/datatable/li_datatable_virtual_scroll_benchmark_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/ngtest.dart';
import 'package:test/test.dart';

import 'li_datatable_virtual_scroll_benchmark_test.template.dart' as ng;

@Component(
  selector: 'datatable-virtual-scroll-benchmark-host',
  template: '''
    <div style="width: 1120px;">
      <li-datatable
        [dataTableFilter]="filter"
        [data]="data"
        [settings]="settings"
        [searchInFields]="searchInFields"
        [limitPerPageOptions]="limitPerPageOptions"
        [virtualScroll]="true"
        [virtualRowHeight]="rowHeight"
        [virtualOverscan]="overscan"
        [virtualViewportHeight]="viewportHeight"
        [debugInstrumentation]="true"
        [debugInstrumentationLabel]="'virtual-scroll-benchmark'"
        [enableGridMode]="false"
        [enableResponsiveFeatures]="false"
        [showCheckboxToSelectRow]="false"
        [showExportMenu]="false"
        [disableRowClick]="true"
        [deferInitialDrawUntilData]="true"
        (instrumentation)="onInstrumentation(\$event)">
      </li-datatable>
    </div>
  ''',
  directives: [coreDirectives, LiDataTableComponent],
)
class DatatableVirtualScrollBenchmarkHostComponent {
  static const int itemCount = 2000;

  final Filters filter = Filters(limit: itemCount, offset: 0);
  final List<int> limitPerPageOptions = const <int>[itemCount];
  final List<DatatableSearchField> searchInFields = <DatatableSearchField>[];
  final int rowHeight = 40;
  final int overscan = 3;
  final String viewportHeight = '240px';
  final List<LiDatatableInstrumentationEvent> instrumentationEvents =
      <LiDatatableInstrumentationEvent>[];

  late DataFrame<Map<String, dynamic>> data = DataFrame<Map<String, dynamic>>(
    items: List<Map<String, dynamic>>.generate(
      itemCount,
      (index) => <String, dynamic>{
        'codigo': 'PROC-${index.toString().padLeft(5, '0')}',
        'requerente': 'Requerente ${index % 97}',
        'tipo': index.isEven ? 'Padrao' : 'Prioritario',
        'classificacao': 'Classe ${index % 13}',
        'assunto': 'Assunto operacional ${index % 29}',
        'situacao': index % 3 == 0 ? 'Recebido' : 'Em andamento',
        'unidade': 'Unidade ${index % 11}',
        'digital': index % 4 == 0 ? 'Sim' : 'Nao',
      },
    ),
    totalRecords: itemCount,
  );

  final DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'codigo', title: 'Codigo', width: '120px'),
      DatatableCol(key: 'requerente', title: 'Requerente', width: '220px'),
      DatatableCol(key: 'tipo', title: 'Tipo', width: '110px'),
      DatatableCol(
        key: 'classificacao',
        title: 'Classificacao',
        width: '160px',
      ),
      DatatableCol(key: 'assunto', title: 'Assunto', width: '220px'),
      DatatableCol(key: 'situacao', title: 'Situacao', width: '150px'),
      DatatableCol(key: 'unidade', title: 'Unidade', width: '130px'),
      DatatableCol(key: 'digital', title: 'Digital', width: '90px'),
    ],
  );

  @ViewChild(LiDataTableComponent)
  LiDataTableComponent? table;

  void onInstrumentation(LiDatatableInstrumentationEvent event) {
    instrumentationEvents.add(event);
  }
}

class DatatableVirtualScrollBenchmarkResult {
  DatatableVirtualScrollBenchmarkResult({
    required this.frames,
    required this.durationMilliseconds,
    required this.averageFrameMilliseconds,
    required this.p95FrameMilliseconds,
    required this.averageFps,
    required this.longFrameCount,
    required this.drawCount,
    required this.totalDrawMilliseconds,
    required this.drawCpuBudgetPercent,
    required this.drawFrameBudgetExceededCount,
    required this.longDrawCount,
    required this.averageDrawMilliseconds,
    required this.p95DrawMilliseconds,
    required this.maxDrawMilliseconds,
    required this.renderedRows,
    required this.visibleBodyRows,
    required this.maxVisibleDomNodes,
  });

  final int frames;
  final double durationMilliseconds;
  final double averageFrameMilliseconds;
  final double p95FrameMilliseconds;
  final double averageFps;
  final int longFrameCount;
  final int drawCount;
  final double totalDrawMilliseconds;
  final double drawCpuBudgetPercent;
  final int drawFrameBudgetExceededCount;
  final int longDrawCount;
  final double averageDrawMilliseconds;
  final double p95DrawMilliseconds;
  final double maxDrawMilliseconds;
  final int renderedRows;
  final int visibleBodyRows;
  final int maxVisibleDomNodes;

  @override
  String toString() {
    return 'frames=$frames, '
        'duration=${durationMilliseconds.toStringAsFixed(1)}ms, '
        'avgFrame=${averageFrameMilliseconds.toStringAsFixed(2)}ms, '
        'p95Frame=${p95FrameMilliseconds.toStringAsFixed(2)}ms, '
        'avgFps=${averageFps.toStringAsFixed(1)}, '
        'longFrames=$longFrameCount, '
        'draws=$drawCount, '
        'totalDraw=${totalDrawMilliseconds.toStringAsFixed(2)}ms, '
        'drawCpuBudget=${drawCpuBudgetPercent.toStringAsFixed(1)}%, '
        'drawFrameBudgetExceeded=$drawFrameBudgetExceededCount, '
        'longDraws=$longDrawCount, '
        'avgDraw=${averageDrawMilliseconds.toStringAsFixed(2)}ms, '
        'p95Draw=${p95DrawMilliseconds.toStringAsFixed(2)}ms, '
        'maxDraw=${maxDrawMilliseconds.toStringAsFixed(2)}ms, '
        'renderedRows=$renderedRows, '
        'visibleBodyRows=$visibleBodyRows, '
        'maxVisibleDomNodes=$maxVisibleDomNodes';
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DatatableVirtualScrollBenchmarkHostComponent>(
    ng.DatatableVirtualScrollBenchmarkHostComponentNgFactory,
  );

  test('mantem FPS e custo de draw dentro do envelope no scroll virtual',
      () async {
    final fixture = await testBed.create();
    await _settleBenchmark(fixture);

    final host = fixture.assertOnlyInstance;
    final scrollContainer = fixture.rootElement.querySelector(
      '.datatable-scroll',
    ) as html.HtmlElement?;
    expect(scrollContainer, isNotNull);
    expect(host.table, isNotNull);
    expect(host.table!.isTableVirtualScrollActive, isTrue);

    host.instrumentationEvents.clear();

    final result = await _runScrollBenchmark(
      fixture: fixture,
      host: host,
      scrollContainer: scrollContainer!,
    );

    expect(result.frames, greaterThanOrEqualTo(90));
    expect(result.renderedRows, lessThanOrEqualTo(18));
    expect(result.visibleBodyRows, lessThanOrEqualTo(20));
    expect(result.drawCount, greaterThan(8));

    // These are regression envelopes, not a claim that every machine will run
    // at exactly 60 FPS. They intentionally leave room for headless Chrome and
    // shared CI hosts while still catching accidental full-table rendering or
    // very expensive draw paths.
    expect(result.averageFps, greaterThanOrEqualTo(24));
    expect(result.p95FrameMilliseconds, lessThanOrEqualTo(60));
    expect(result.drawCpuBudgetPercent, lessThanOrEqualTo(35));
    expect(result.longDrawCount, 0);
    expect(result.maxVisibleDomNodes, lessThanOrEqualTo(320));
    expect(result.averageDrawMilliseconds, lessThanOrEqualTo(20));
    expect(result.p95DrawMilliseconds, lessThanOrEqualTo(45));
    expect(result.maxDrawMilliseconds, lessThanOrEqualTo(120));
  });
}

Future<DatatableVirtualScrollBenchmarkResult> _runScrollBenchmark({
  required NgTestFixture<DatatableVirtualScrollBenchmarkHostComponent> fixture,
  required DatatableVirtualScrollBenchmarkHostComponent host,
  required html.HtmlElement scrollContainer,
}) async {
  const framesToSample = 96;
  final frameTimestamps = <num>[];
  final firstTimestamp = await _nextAnimationFrameTime();
  var previousTimestamp = firstTimestamp;
  final maxScrollTop = math.max(
    1,
    scrollContainer.scrollHeight - scrollContainer.clientHeight,
  );

  for (var frame = 0; frame < framesToSample; frame++) {
    final progress = frame / (framesToSample - 1);
    final waveProgress = frame.isEven ? progress : 1 - progress;
    scrollContainer.scrollTop = (maxScrollTop * waveProgress).round();
    scrollContainer.dispatchEvent(html.Event('scroll'));
    final timestamp = await _nextAnimationFrameTime();
    frameTimestamps.add(timestamp - previousTimestamp);
    previousTimestamp = timestamp;
  }

  await _nextAnimationFrameTime();
  await _nextAnimationFrameTime();
  await fixture.update((_) {});

  final frameDurations = frameTimestamps
      .map((value) => value.toDouble())
      .where((value) => value > 0)
      .toList(growable: false);
  final drawDurations = host.instrumentationEvents
      .where((event) => event.stage == 'draw.finish')
      .map((event) => event.elapsedMilliseconds)
      .whereType<double>()
      .toList(growable: false);
  final drawEvents = host.instrumentationEvents
      .where((event) => event.stage == 'draw.finish')
      .toList(growable: false);
  final renderedRows = host.table?.rows.length ?? 0;
  final visibleBodyRows = fixture.rootElement
      .querySelectorAll('tbody > tr:not(.datatable-virtual-spacer)')
      .length;
  final durationMilliseconds = frameDurations.fold<double>(0, _sum);
  final totalDrawMilliseconds = drawDurations.fold<double>(0, _sum);
  final visibleDomNodeCounts = drawEvents
      .map((event) => event.details['visibleDomNodes'])
      .whereType<int>()
      .toList(growable: false);

  return DatatableVirtualScrollBenchmarkResult(
    frames: frameDurations.length,
    durationMilliseconds: durationMilliseconds,
    averageFrameMilliseconds: _average(frameDurations),
    p95FrameMilliseconds: _percentile(frameDurations, 0.95),
    averageFps: 1000 / _average(frameDurations),
    longFrameCount: frameDurations.where((value) => value > 50).length,
    drawCount: drawDurations.length,
    totalDrawMilliseconds: totalDrawMilliseconds,
    drawCpuBudgetPercent: durationMilliseconds <= 0
        ? 0
        : (totalDrawMilliseconds / durationMilliseconds) * 100,
    drawFrameBudgetExceededCount: drawEvents
        .where((event) => event.details['frameBudgetExceeded'] == true)
        .length,
    longDrawCount:
        drawEvents.where((event) => event.details['longDraw'] == true).length,
    averageDrawMilliseconds: _average(drawDurations),
    p95DrawMilliseconds: _percentile(drawDurations, 0.95),
    maxDrawMilliseconds:
        drawDurations.isEmpty ? 0 : drawDurations.reduce(math.max),
    renderedRows: renderedRows,
    visibleBodyRows: visibleBodyRows,
    maxVisibleDomNodes: visibleDomNodeCounts.isEmpty
        ? 0
        : visibleDomNodeCounts.reduce(math.max),
  );
}

Future<void> _settleBenchmark(
  NgTestFixture<DatatableVirtualScrollBenchmarkHostComponent> fixture,
) async {
  await fixture.update((_) {});
  await _nextAnimationFrameTime();
  await _nextAnimationFrameTime();
  await _nextAnimationFrameTime();
  await fixture.update((_) {});
}

Future<num> _nextAnimationFrameTime() {
  final completer = Completer<num>();
  html.window.requestAnimationFrame((timestamp) {
    completer.complete(timestamp);
  });
  return completer.future;
}

double _average(List<double> values) {
  if (values.isEmpty) {
    return 0;
  }

  return values.fold<double>(0, _sum) / values.length;
}

double _percentile(List<double> values, double percentile) {
  if (values.isEmpty) {
    return 0;
  }

  final sorted = values.toList(growable: false)..sort();
  final index = ((sorted.length - 1) * percentile).ceil();
  return sorted[index.clamp(0, sorted.length - 1)];
}

double _sum(double left, double right) => left + right;
