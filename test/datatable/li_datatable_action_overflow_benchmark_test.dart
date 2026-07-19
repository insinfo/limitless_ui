// Run this browser benchmark from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/datatable/li_datatable_action_overflow_benchmark_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:async';
import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_test/ngx_test.dart';
import 'package:test/test.dart';

import 'li_datatable_action_overflow_benchmark_test.template.dart' as ng;

@Component(
  selector: 'datatable-action-overflow-benchmark-host',
  template: '''
    <div style="width: 1120px;">
      <li-datatable
        [dataTableFilter]="filter"
        [data]="data"
        [settings]="settings"
        [searchInFields]="searchInFields"
        [limitPerPageOptions]="limitPerPageOptions"
        [performanceProfile]="performanceProfile"
        [debugInstrumentation]="true"
        [debugInstrumentationLabel]="'action-overflow-benchmark'"
        [enableGridMode]="false"
        [enableResponsiveFeatures]="false"
        [showCheckboxToSelectRow]="false"
        [showExportMenu]="false"
        [disableRowClick]="true"
        [deferInitialDrawUntilData]="true">
      </li-datatable>
    </div>
  ''',
  directives: [coreDirectives, LiDataTableComponent],
)
class DatatableActionOverflowBenchmarkHostComponent {
  static const int itemCount = 12;

  final Filters filter = Filters(limit: itemCount, offset: 0);
  final List<int> limitPerPageOptions = const <int>[itemCount];
  final List<DatatableSearchField> searchInFields =
      const <DatatableSearchField>[];
  final DatatablePerformanceProfile performanceProfile =
      DatatablePerformanceProfile.saliPaged;

  final DataFrame<Map<String, dynamic>> data = DataFrame<Map<String, dynamic>>(
    items: List<Map<String, dynamic>>.generate(
      itemCount,
      (index) => <String, dynamic>{
        'codigo': 'PROC-${index + 1}',
        'nome': 'Processo ${index + 1}',
      },
    ),
    totalRecords: itemCount,
  );

  final DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'codigo', title: 'Codigo', width: '140px'),
      DatatableCol(key: 'nome', title: 'Nome', width: '240px'),
      DatatableActionColumn(
        key: 'acoes',
        title: 'Acoes',
        maxVisibleActions: 1,
        actions: <DatatableAction>[
          DatatableAction(
            label: 'Visualizar',
            iconClass: 'ph ph-eye',
            overflowBehavior: DatatableActionOverflowBehavior.alwaysVisible,
            onTap: (_) {},
          ),
          DatatableAction(
            label: 'Arquivar',
            iconClass: 'ph ph-archive-box',
            onTap: (_) {},
          ),
          DatatableAction(
            label: 'Excluir',
            iconClass: 'ph ph-trash',
            overflowBehavior: DatatableActionOverflowBehavior.overflowMenu,
            onTap: (_) {},
          ),
        ],
      ),
    ],
  );
}

class DatatableActionOverflowBenchmarkResult {
  DatatableActionOverflowBenchmarkResult({
    required this.cycles,
    required this.totalMilliseconds,
    required this.averageMilliseconds,
    required this.p95Milliseconds,
    required this.maxMilliseconds,
    required this.portalHosts,
    required this.menuElements,
  });

  final int cycles;
  final double totalMilliseconds;
  final double averageMilliseconds;
  final double p95Milliseconds;
  final double maxMilliseconds;
  final int portalHosts;
  final int menuElements;

  @override
  String toString() {
    return 'cycles=$cycles, '
        'total=${totalMilliseconds.toStringAsFixed(3)}ms, '
        'avg=${averageMilliseconds.toStringAsFixed(3)}ms, '
        'p95=${p95Milliseconds.toStringAsFixed(3)}ms, '
        'max=${maxMilliseconds.toStringAsFixed(3)}ms, '
        'portalHosts=$portalHosts, '
        'menuElements=$menuElements';
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DatatableActionOverflowBenchmarkHostComponent>(
    ng.DatatableActionOverflowBenchmarkHostComponentNgFactory,
  );

  test('mantem o overflow de actions estavel ao abrir e fechar repetidamente',
      () async {
    final fixture = await testBed.create();
    await _settleBenchmark(fixture);

    final toggle = fixture.rootElement.querySelector(
      '[data-li-datatable-action-overflow-toggle="true"]',
    ) as html.ButtonElement?;
    expect(toggle, isNotNull);

    final result = await _runOverflowBenchmark(
      fixture: fixture,
      toggle: toggle!,
    );

    expect(result.cycles, 24);
    expect(result.portalHosts, lessThanOrEqualTo(1));
    expect(result.menuElements, lessThanOrEqualTo(1));
    expect(result.averageMilliseconds, lessThanOrEqualTo(120));
    expect(result.p95Milliseconds, lessThanOrEqualTo(220));
    expect(
      html.document.body?.querySelectorAll(
        '[data-li-datatable-action-overflow-menu="true"].show',
      ),
      isEmpty,
    );
  });
}

Future<DatatableActionOverflowBenchmarkResult> _runOverflowBenchmark({
  required NgTestFixture<DatatableActionOverflowBenchmarkHostComponent> fixture,
  required html.ButtonElement toggle,
}) async {
  const cycles = 24;
  final durations = <double>[];

  for (var index = 0; index < cycles; index++) {
    final stopwatch = Stopwatch()..start();

    toggle.click();
    await _settleBenchmark(fixture);

    final openMenu = html.document.body?.querySelector(
      '[data-li-datatable-action-overflow-menu="true"]',
    ) as html.HtmlElement?;
    expect(openMenu, isNotNull);
    expect(openMenu!.classes.contains('show'), isTrue);
    expect(
      openMenu.querySelectorAll('button[data-li-datatable-action="true"]'),
      hasLength(2),
    );

    toggle.click();
    await _settleBenchmark(fixture);

    final closedMenu = html.document.body?.querySelector(
      '[data-li-datatable-action-overflow-menu="true"]',
    ) as html.HtmlElement?;
    expect(closedMenu?.classes.contains('show') ?? false, isFalse);

    stopwatch.stop();
    durations.add(
        stopwatch.elapsedMicroseconds / Duration.microsecondsPerMillisecond);
  }

  final sortedDurations = durations.toList()..sort();
  final p95Index = ((sortedDurations.length - 1) * 0.95).round();
  final totalMilliseconds = durations.fold<double>(0, _sum);

  return DatatableActionOverflowBenchmarkResult(
    cycles: cycles,
    totalMilliseconds: totalMilliseconds,
    averageMilliseconds: totalMilliseconds / cycles,
    p95Milliseconds: sortedDurations[p95Index],
    maxMilliseconds: sortedDurations.last,
    portalHosts: html.document.body
            ?.querySelectorAll('.DatatableActionOverflowPortal')
            .length ??
        0,
    menuElements: html.document.body
            ?.querySelectorAll(
                '[data-li-datatable-action-overflow-menu="true"]')
            .length ??
        0,
  );
}

Future<void> _settleBenchmark(
  NgTestFixture<DatatableActionOverflowBenchmarkHostComponent> fixture,
) async {
  await fixture.update((_) {});
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

double _sum(double left, double right) => left + right;
