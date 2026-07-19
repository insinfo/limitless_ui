// Run this browser benchmark from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/datatable/li_datatable_feature_cost_benchmark_test.dart
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

import 'li_datatable_feature_cost_benchmark_test.template.dart' as ng;

@Component(
  selector: 'datatable-feature-cost-benchmark-host',
  template: '''
    <div [attr.style]="containerStyle">
      <li-datatable
        [dataTableFilter]="filter"
        [data]="data"
        [settings]="settings"
        [searchInFields]="searchInFields"
        [limitPerPageOptions]="limitPerPageOptions"
        [performanceProfile]="performanceProfile"
        [debugInstrumentation]="true"
        [debugInstrumentationLabel]="scenarioName"
        [enableGridMode]="true"
        [enableResponsiveFeatures]="enableResponsiveFeatures"
        [responsiveAutoHideColumns]="responsiveAutoHideColumns"
        [responsiveCollapse]="responsiveCollapse"
        [responsiveCollapseMaxWidth]="responsiveCollapseMaxWidth"
        [responsiveCollapseByContainer]="responsiveCollapseByContainer"
        [responsiveCollapseContainerMaxWidth]="responsiveCollapseContainerMaxWidth"
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
class DatatableFeatureCostBenchmarkHostComponent {
  static const int itemCount = 12;

  Filters filter = Filters(limit: itemCount, offset: 0);
  List<int> limitPerPageOptions = const <int>[itemCount];
  List<DatatableSearchField> searchInFields = <DatatableSearchField>[];
  DataFrame<Map<String, dynamic>> data = _buildData();
  DatatableSettings settings = _buildSettings();
  DatatablePerformanceProfile performanceProfile =
      DatatablePerformanceProfile.flexible;
  String containerStyle = 'width: 1120px;';
  String scenarioName = 'baseline';
  bool enableResponsiveFeatures = false;
  bool responsiveAutoHideColumns = false;
  bool responsiveCollapse = false;
  bool responsiveCollapseByContainer = false;
  int responsiveCollapseMaxWidth = 767;
  int responsiveCollapseContainerMaxWidth = 767;
  final List<LiDatatableInstrumentationEvent> instrumentationEvents =
      <LiDatatableInstrumentationEvent>[];

  @ViewChild(LiDataTableComponent)
  LiDataTableComponent? table;

  void configure(DatatableFeatureCostScenario scenario) {
    scenarioName = scenario.name;
    containerStyle = 'width: ${scenario.containerWidth}px;';
    enableResponsiveFeatures = scenario.enableResponsiveFeatures;
    responsiveAutoHideColumns = scenario.responsiveAutoHideColumns;
    responsiveCollapse = scenario.responsiveCollapse;
    responsiveCollapseByContainer = scenario.responsiveCollapseByContainer;
    responsiveCollapseMaxWidth = scenario.responsiveCollapseMaxWidth;
    responsiveCollapseContainerMaxWidth =
        scenario.responsiveCollapseContainerMaxWidth;
    performanceProfile = scenario.performanceProfile;
    filter = Filters(limit: itemCount, offset: 0);
    data = _buildData();
    settings = scenario.buildSettings();
  }

  void onInstrumentation(LiDatatableInstrumentationEvent event) {
    instrumentationEvents.add(event);
  }
}

class DatatableFeatureCostScenario {
  DatatableFeatureCostScenario({
    required this.name,
    required this.buildSettings,
    this.containerWidth = 1120,
    this.enableResponsiveFeatures = false,
    this.responsiveAutoHideColumns = false,
    this.responsiveCollapse = false,
    this.responsiveCollapseByContainer = false,
    this.responsiveCollapseMaxWidth = 767,
    this.responsiveCollapseContainerMaxWidth = 767,
    this.performanceProfile = DatatablePerformanceProfile.flexible,
  });

  final String name;
  final DatatableSettings Function() buildSettings;
  final int containerWidth;
  final bool enableResponsiveFeatures;
  final bool responsiveAutoHideColumns;
  final bool responsiveCollapse;
  final bool responsiveCollapseByContainer;
  final int responsiveCollapseMaxWidth;
  final int responsiveCollapseContainerMaxWidth;
  final DatatablePerformanceProfile performanceProfile;
}

class DatatableFeatureCostBenchmarkResult {
  DatatableFeatureCostBenchmarkResult({
    required this.scenarioName,
    required this.initialMeasuredMilliseconds,
    required this.switchMeasuredMilliseconds,
    required this.switchWallMilliseconds,
    required this.drawFinishMilliseconds,
    required this.templateMilliseconds,
    required this.projectedContextMilliseconds,
    required this.responsiveViewportMilliseconds,
    required this.postRenderMilliseconds,
    required this.responsiveMilliseconds,
    required this.maxVisibleDomNodes,
    required this.maxConfiguredActionColumns,
    required this.maxActionCells,
    required this.maxActionElements,
    required this.maxLegacyActionButtons,
    required this.maxActionButtons,
    required this.maxCellContexts,
    required this.maxHiddenColumns,
    required this.maxAutoHiddenColumns,
  });

  final String scenarioName;
  final double initialMeasuredMilliseconds;
  final double switchMeasuredMilliseconds;
  final double switchWallMilliseconds;
  final double drawFinishMilliseconds;
  final double templateMilliseconds;
  final double projectedContextMilliseconds;
  final double responsiveViewportMilliseconds;
  final double postRenderMilliseconds;
  final double responsiveMilliseconds;
  final int maxVisibleDomNodes;
  final int maxConfiguredActionColumns;
  final int maxActionCells;
  final int maxActionElements;
  final int maxLegacyActionButtons;
  final int maxActionButtons;
  final int maxCellContexts;
  final int maxHiddenColumns;
  final int maxAutoHiddenColumns;

  double get totalMeasuredMilliseconds =>
      initialMeasuredMilliseconds + switchMeasuredMilliseconds;

  @override
  String toString() {
    return '$scenarioName | '
        'total=${totalMeasuredMilliseconds.toStringAsFixed(3)}ms | '
        'initial=${initialMeasuredMilliseconds.toStringAsFixed(3)}ms | '
        'switchMeasured=${switchMeasuredMilliseconds.toStringAsFixed(3)}ms | '
        'switchWall=${switchWallMilliseconds.toStringAsFixed(3)}ms | '
        'drawFinish=${drawFinishMilliseconds.toStringAsFixed(3)}ms | '
        'templates=${templateMilliseconds.toStringAsFixed(3)}ms | '
        'projected=${projectedContextMilliseconds.toStringAsFixed(3)}ms | '
        'responsiveViewport=${responsiveViewportMilliseconds.toStringAsFixed(3)}ms | '
        'postRender=${postRenderMilliseconds.toStringAsFixed(3)}ms | '
        'responsive=${responsiveMilliseconds.toStringAsFixed(3)}ms | '
        'dom=$maxVisibleDomNodes | '
        'configuredActionColumns=$maxConfiguredActionColumns | '
        'actionCells=$maxActionCells | '
        'actionElements=$maxActionElements | '
        'legacyActionButtons=$maxLegacyActionButtons | '
        'actionButtons=$maxActionButtons | '
        'cellContexts=$maxCellContexts | '
        'hiddenColumns=$maxHiddenColumns | '
        'autoHiddenColumns=$maxAutoHiddenColumns';
  }
}

void main() {
  tearDown(disposeAnyRunningTest);

  final testBed = NgTestBed<DatatableFeatureCostBenchmarkHostComponent>(
    ng.DatatableFeatureCostBenchmarkHostComponentNgFactory,
  );

  test('compara custo de features do li-datatable paginado', () async {
    final scenarios = <DatatableFeatureCostScenario>[
      DatatableFeatureCostScenario(
        name: 'sali-paged-baseline',
        performanceProfile: DatatablePerformanceProfile.saliPaged,
        buildSettings: () => _buildSettings(),
      ),
      DatatableFeatureCostScenario(
        name: 'sali-paged-action-column',
        performanceProfile: DatatablePerformanceProfile.saliPaged,
        buildSettings: () => _buildSettings(actionColumn: true),
      ),
      DatatableFeatureCostScenario(
        name: 'baseline-plain',
        buildSettings: () => _buildSettings(),
      ),
      DatatableFeatureCostScenario(
        name: 'custom-title-html',
        buildSettings: () => _buildSettings(customTitleHtml: true),
      ),
      DatatableFeatureCostScenario(
        name: 'title-tooltip-popover',
        buildSettings: () => _buildSettings(titleHelp: true),
      ),
      DatatableFeatureCostScenario(
        name: 'responsive-priority-autohide',
        containerWidth: 420,
        enableResponsiveFeatures: true,
        responsiveAutoHideColumns: true,
        buildSettings: () => _buildSettings(responsivePriority: true),
      ),
      DatatableFeatureCostScenario(
        name: 'collapse-on-mobile',
        enableResponsiveFeatures: true,
        responsiveCollapse: true,
        responsiveCollapseMaxWidth: 100000,
        buildSettings: () => _buildSettings(mobileCollapse: true),
      ),
      DatatableFeatureCostScenario(
        name: 'collapse-by-container',
        containerWidth: 420,
        enableResponsiveFeatures: true,
        responsiveCollapse: true,
        responsiveCollapseByContainer: true,
        responsiveCollapseContainerMaxWidth: 100000,
        buildSettings: () => _buildSettings(mobileCollapse: true),
      ),
      DatatableFeatureCostScenario(
        name: 'action-column',
        buildSettings: () => _buildSettings(actionColumn: true),
      ),
      DatatableFeatureCostScenario(
        name: 'combined-rich-features',
        containerWidth: 420,
        enableResponsiveFeatures: true,
        responsiveAutoHideColumns: true,
        responsiveCollapse: true,
        responsiveCollapseByContainer: true,
        responsiveCollapseContainerMaxWidth: 100000,
        buildSettings: () => _buildSettings(
          titleHelp: true,
          responsivePriority: true,
          mobileCollapse: true,
          actionColumn: true,
        ),
      ),
    ];

    await _measureScenario(
      testBed,
      DatatableFeatureCostScenario(
        name: 'warmup-baseline',
        buildSettings: () => _buildSettings(),
      ),
    );
    await disposeAnyRunningTest();

    final results = <DatatableFeatureCostBenchmarkResult>[];
    for (final scenario in scenarios) {
      await _measureScenario(testBed, scenario);
      await disposeAnyRunningTest();

      results.add(await _measureScenario(testBed, scenario));
      await disposeAnyRunningTest();
    }

    expect(results, hasLength(scenarios.length));
    expect(results.map((result) => result.scenarioName),
        containsAll(scenarios.map((scenario) => scenario.name)));
    for (final result in results) {
      expect(result.maxVisibleDomNodes, greaterThan(0));
    }
    final saliActionResult = results.firstWhere(
      (result) => result.scenarioName == 'sali-paged-action-column',
    );
    expect(saliActionResult.maxConfiguredActionColumns, 1);
    expect(saliActionResult.maxActionCells, greaterThan(0));
    expect(saliActionResult.maxActionElements, greaterThan(0));
  });
}

Future<DatatableFeatureCostBenchmarkResult> _measureScenario(
  NgTestBed<DatatableFeatureCostBenchmarkHostComponent> testBed,
  DatatableFeatureCostScenario scenario,
) async {
  final fixture = await testBed.create(beforeChangeDetection: (component) {
    component.configure(scenario);
  });
  await _settleBenchmark(fixture);
  final host = fixture.assertOnlyInstance;
  final initialEvents = host.instrumentationEvents.toList(growable: false);

  host.instrumentationEvents.clear();
  final switchStopwatch = Stopwatch()..start();
  for (var index = 0; index < 8; index++) {
    await fixture.update((component) {
      component.table!.changeViewMode();
    });
    await _settleBenchmark(fixture);
  }
  switchStopwatch.stop();

  final switchEvents = host.instrumentationEvents.toList(growable: false);
  final allEvents = <LiDatatableInstrumentationEvent>[
    ...initialEvents,
    ...switchEvents,
  ];

  return DatatableFeatureCostBenchmarkResult(
    scenarioName: scenario.name,
    initialMeasuredMilliseconds: _measuredMilliseconds(initialEvents),
    switchMeasuredMilliseconds: _measuredMilliseconds(switchEvents),
    switchWallMilliseconds: switchStopwatch.elapsedMicroseconds /
        Duration.microsecondsPerMillisecond,
    drawFinishMilliseconds: _sumStage(allEvents, 'draw.finish'),
    templateMilliseconds: _sumStage(allEvents, 'syncTemplateContexts'),
    projectedContextMilliseconds:
        _sumStage(allEvents, 'syncProjectedTemplateContextCaches'),
    responsiveViewportMilliseconds: _sumStagesStartingWith(
      allEvents,
      'responsiveViewportState',
    ),
    postRenderMilliseconds: _sumStage(allEvents, 'postRenderSync.frame'),
    responsiveMilliseconds: _sumStagesStartingWith(
      allEvents,
      'responsiveAutoHideSync',
    ),
    maxVisibleDomNodes: _maxDetailInt(allEvents, 'visibleDomNodes'),
    maxConfiguredActionColumns:
        _maxDetailInt(allEvents, 'configuredActionColumns'),
    maxActionCells: _maxDetailInt(allEvents, 'actionCells'),
    maxActionElements: _maxDetailInt(allEvents, 'actionElements'),
    maxLegacyActionButtons: _maxDetailInt(allEvents, 'legacyActionButtons'),
    maxActionButtons: _maxDetailInt(allEvents, 'actionButtons'),
    maxCellContexts: _maxDetailInt(allEvents, 'cellContexts'),
    maxHiddenColumns: _maxDetailInt(allEvents, 'hiddenColumns'),
    maxAutoHiddenColumns: _maxDetailInt(allEvents, 'autoHiddenColumns'),
  );
}

double _measuredMilliseconds(List<LiDatatableInstrumentationEvent> events) {
  return _sumStage(events, 'draw.finish') +
      _sumStage(events, 'draw.buildRows') +
      _sumStage(events, 'draw.rebuildRenderedRows') +
      _sumStage(events, 'syncTemplateContexts') +
      _sumStage(events, 'syncProjectedTemplateContextCaches') +
      _sumStagesStartingWith(events, 'responsiveViewportState') +
      _sumStage(events, 'postRenderSync.frame') +
      _sumStagesStartingWith(events, 'responsiveAutoHideSync');
}

double _sumStage(
  List<LiDatatableInstrumentationEvent> events,
  String stage,
) {
  return events
      .where((event) => event.stage == stage)
      .map((event) => event.elapsedMilliseconds ?? 0)
      .fold<double>(0, _sum);
}

double _sumStagesStartingWith(
  List<LiDatatableInstrumentationEvent> events,
  String prefix,
) {
  return events
      .where((event) => event.stage.startsWith(prefix))
      .map((event) => event.elapsedMilliseconds ?? 0)
      .fold<double>(0, _sum);
}

int _maxDetailInt(
  List<LiDatatableInstrumentationEvent> events,
  String key,
) {
  final values = events
      .map((event) => event.details[key])
      .whereType<int>()
      .toList(growable: false);
  if (values.isEmpty) {
    return 0;
  }
  values.sort();
  return values.last;
}

Future<void> _settleBenchmark(
  NgTestFixture<DatatableFeatureCostBenchmarkHostComponent> fixture,
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

DataFrame<Map<String, dynamic>> _buildData() {
  return DataFrame<Map<String, dynamic>>(
    items: List<Map<String, dynamic>>.generate(
      DatatableFeatureCostBenchmarkHostComponent.itemCount,
      (index) => <String, dynamic>{
        'codigo': '${index + 1}/2026',
        'requerente': 'Requerente ${index % 4}',
        'tipo': index.isEven ? 'Padrao' : 'Prioritario',
        'classificacao': 'Classe ${index % 3}',
        'assunto': 'Assunto operacional ${index % 5}',
        'createdAt': DateTime(2026, 5, 1 + index, 9, index),
        'status': index % 3 == 0 ? 'Anexado' : 'Em andamento',
        'digitalLabel': index.isEven ? 'Sim' : 'Nao',
        'digitalOrder': index.isEven ? 1 : 0,
        'canEdit': index % 3 != 0,
      },
    ),
    totalRecords: DatatableFeatureCostBenchmarkHostComponent.itemCount,
  );
}

DatatableSettings _buildSettings({
  bool customTitleHtml = false,
  bool titleHelp = false,
  bool responsivePriority = false,
  bool mobileCollapse = false,
  bool actionColumn = false,
}) {
  final columns = <DatatableCol>[
    _column(
      key: 'codigo',
      title: 'Codigo',
      width: '110px',
      priority: 90,
      customTitleHtml: customTitleHtml,
      titleHelp: titleHelp,
      responsivePriority: responsivePriority,
      mobileCollapse: mobileCollapse,
    ),
    _column(
      key: 'requerente',
      title: 'Requerente',
      width: '220px',
      priority: 60,
      customTitleHtml: customTitleHtml,
      titleHelp: titleHelp,
      responsivePriority: responsivePriority,
      mobileCollapse: mobileCollapse,
    ),
    _column(
      key: 'tipo',
      title: 'Tipo Cgm',
      width: '120px',
      priority: 70,
      customTitleHtml: customTitleHtml,
      titleHelp: titleHelp,
      responsivePriority: responsivePriority,
      mobileCollapse: mobileCollapse,
    ),
    _column(
      key: 'classificacao',
      title: 'Classificacao',
      width: '150px',
      priority: 20,
      customTitleHtml: customTitleHtml,
      titleHelp: titleHelp,
      responsivePriority: responsivePriority,
      mobileCollapse: mobileCollapse,
    ),
    _column(
      key: 'assunto',
      title: 'Assunto',
      width: '220px',
      priority: 10,
      customTitleHtml: customTitleHtml,
      titleHelp: titleHelp,
      responsivePriority: responsivePriority,
      mobileCollapse: mobileCollapse,
    ),
    _column(
      key: 'createdAt',
      title: 'Inclusao',
      width: '160px',
      priority: 30,
      format: DatatableFormat.dateTimeShort,
      customTitleHtml: customTitleHtml,
      titleHelp: titleHelp,
      responsivePriority: responsivePriority,
      mobileCollapse: mobileCollapse,
    ),
    _column(
      key: 'status',
      title: 'Situacao',
      width: '170px',
      priority: 40,
      customTitleHtml: customTitleHtml,
      titleHelp: titleHelp,
      responsivePriority: responsivePriority,
      mobileCollapse: mobileCollapse,
    ),
    _column(
      key: 'digitalLabel',
      title: 'Digital',
      width: '90px',
      priority: 50,
      customTitleHtml: customTitleHtml,
      titleHelp: titleHelp,
      responsivePriority: responsivePriority,
      mobileCollapse: mobileCollapse,
    ),
  ];

  if (actionColumn) {
    columns.add(
      DatatableActionColumn(
        key: 'actions',
        actions: _buildActions(),
      ),
    );
  }

  return DatatableSettings(colsDefinitions: columns);
}

DatatableCol _column({
  required String key,
  required String title,
  required String width,
  required int priority,
  DatatableFormat? format,
  required bool customTitleHtml,
  required bool titleHelp,
  required bool responsivePriority,
  required bool mobileCollapse,
}) {
  return DatatableCol(
    key: key,
    title: title,
    width: width,
    minWidth: width,
    format: format,
    sortingBy: key,
    enableSorting: true,
    responsiveAutoHidePriority: responsivePriority ? priority : null,
    hideOnMobile: mobileCollapse && priority <= 50,
    customRenderTitleHtml: customTitleHtml ? _renderTitleHtml : null,
    titleTooltip: titleHelp
        ? DatatableTitleTooltipConfig(
            text: 'Ajuda para $title',
            displayMode: DatatableTitleTooltipDisplayMode.title,
          )
        : null,
    titlePopover: titleHelp
        ? DatatableTitlePopoverConfig(
            title: title,
            body: 'Detalhes da coluna $title',
          )
        : null,
  );
}

html.Element _renderTitleHtml(DatatableCol column) {
  final shell = html.SpanElement()
    ..classes.addAll(<String>[
      'd-inline-flex',
      'align-items-center',
      'gap-1',
    ]);
  shell.append(html.Element.tag('i')..classes.addAll(<String>['ph', 'ph-tag']));
  shell.append(html.SpanElement()..text = column.title);
  return shell;
}

List<DatatableAction> _buildActions() {
  return <DatatableAction>[
    DatatableAction(
      label: 'Abrir',
      iconClass: 'ph ph-eye',
      iconOnly: true,
      size: 'sm',
      onTap: (_) {},
    ),
    DatatableAction(
      label: 'Editar',
      iconClass: 'ph ph-pencil',
      iconOnly: true,
      size: 'sm',
      visibleWhen: (context) => context.itemMap['canEdit'] == true,
      onTap: (_) {},
    ),
    DatatableAction(
      label: 'Anexar',
      iconClass: 'ph ph-paperclip',
      iconOnly: true,
      size: 'sm',
      enabledWhen: (context) => context.itemMap['digitalOrder'] == 1,
      onTap: (_) {},
    ),
    DatatableAction(
      label: 'Historico',
      iconClass: 'ph ph-clock-counter-clockwise',
      iconOnly: true,
      size: 'sm',
      onTap: (_) {},
    ),
  ];
}
