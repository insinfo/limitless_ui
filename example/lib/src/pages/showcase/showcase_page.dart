import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'showcase-page',
  templateUrl: 'showcase_page.html',
  styleUrls: ['showcase_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiCarouselComponent,
    LiCarouselItemComponent,
    LiDataTableComponent,
    LiTooltipComponent,
  ],
)
class ShowcasePageComponent {
  ShowcasePageComponent(this.i18n);

  final DemoI18nService i18n;
  bool get _isPt => i18n.isPortuguese;

  final Filters filters = Filters(limit: 5, offset: 0);

  late final DataFrame<Map<String, dynamic>> _tableDataPt =
      DataFrame<Map<String, dynamic>>(
    items: <Map<String, dynamic>>[
      <String, dynamic>{
        'feature': 'Painel executivo',
        'owner': 'Produto',
        'status': 'Em andamento',
        'health': 'Atencao',
      },
      <String, dynamic>{
        'feature': 'Exportacao PDF',
        'owner': 'Backoffice',
        'status': 'Concluido',
        'health': 'Ok',
      },
      <String, dynamic>{
        'feature': 'Fluxo de aprovacao',
        'owner': 'Operacoes',
        'status': 'Planejado',
        'health': 'Ok',
      },
      <String, dynamic>{
        'feature': 'Alertas em tempo real',
        'owner': 'Infra',
        'status': 'Bloqueado',
        'health': 'Critico',
      },
    ],
    totalRecords: 4,
  );

  late final DataFrame<Map<String, dynamic>> _tableDataEn =
      DataFrame<Map<String, dynamic>>(
    items: <Map<String, dynamic>>[
      <String, dynamic>{
        'feature': 'Executive dashboard',
        'owner': 'Product',
        'status': 'In progress',
        'health': 'Warning',
      },
      <String, dynamic>{
        'feature': 'PDF export',
        'owner': 'Backoffice',
        'status': 'Done',
        'health': 'OK',
      },
      <String, dynamic>{
        'feature': 'Approval flow',
        'owner': 'Operations',
        'status': 'Planned',
        'health': 'OK',
      },
      <String, dynamic>{
        'feature': 'Real-time alerts',
        'owner': 'Infra',
        'status': 'Blocked',
        'health': 'Critical',
      },
    ],
    totalRecords: 4,
  );

  DataFrame<Map<String, dynamic>> get tableData =>
      _isPt ? _tableDataPt : _tableDataEn;

  late final DatatableSettings _tableSettingsPt = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(
          key: 'feature',
          title: 'Entrega',
          enableSorting: true,
          sortingBy: 'feature'),
      DatatableCol(
          key: 'owner',
          title: 'Squad',
          enableSorting: true,
          sortingBy: 'owner'),
      DatatableCol(
          key: 'status',
          title: 'Status',
          enableSorting: true,
          sortingBy: 'status'),
      DatatableCol(key: 'health', title: 'Saude'),
    ],
  );

  late final DatatableSettings _tableSettingsEn = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(
          key: 'feature',
          title: 'Delivery',
          enableSorting: true,
          sortingBy: 'feature'),
      DatatableCol(
          key: 'owner',
          title: 'Squad',
          enableSorting: true,
          sortingBy: 'owner'),
      DatatableCol(
          key: 'status',
          title: 'Status',
          enableSorting: true,
          sortingBy: 'status'),
      DatatableCol(key: 'health', title: 'Health'),
    ],
  );

  DatatableSettings get tableSettings =>
      _isPt ? _tableSettingsPt : _tableSettingsEn;

  late final List<DatatableSearchField> _searchFieldsPt =
      <DatatableSearchField>[
    DatatableSearchField(label: 'Entrega', field: 'feature', operator: 'like'),
    DatatableSearchField(label: 'Squad', field: 'owner', operator: 'like'),
    DatatableSearchField(label: 'Status', field: 'status', operator: '='),
  ];

  late final List<DatatableSearchField> _searchFieldsEn =
      <DatatableSearchField>[
    DatatableSearchField(label: 'Delivery', field: 'feature', operator: 'like'),
    DatatableSearchField(label: 'Squad', field: 'owner', operator: 'like'),
    DatatableSearchField(label: 'Status', field: 'status', operator: '='),
  ];

  List<DatatableSearchField> get searchFields =>
      _isPt ? _searchFieldsPt : _searchFieldsEn;

  String get pageTitle => _isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'Showcase';
  String get breadcrumb => _isPt
      ? 'Carousel, tooltip e datatable'
      : 'Carousel, tooltip, and datatable';
  String get cardTitle => 'Showcase';
  String get overviewIntro => _isPt
      ? 'Esta página combina vários componentes na mesma composição para validar convivência visual e integração entre APIs.'
      : 'This page combines several components in the same composition to validate visual coexistence and API integration.';
  String get examplesTabLabel => _isPt ? 'Exemplos' : 'Examples';
  String get carouselCardTitle =>
      _isPt ? 'Carousel e tooltip' : 'Carousel and tooltip';
  String get slideOneTag => _isPt ? 'Setup' : 'Setup';
  String get slideOneTitle =>
      _isPt ? 'Arquitetura consistente' : 'Consistent architecture';
  String get slideOneBody => _isPt
      ? 'Organize a documentação em cards, rotas e exemplos vivos.'
      : 'Organize documentation into cards, routes, and live examples.';
  String get slideTwoTag => _isPt ? 'Composicao' : 'Composition';
  String get slideTwoTitle =>
      _isPt ? 'Componentes empilhados' : 'Stacked components';
  String get slideTwoBody => _isPt
      ? 'Tabs, alertas, selects e datatables coexistem sem gambiarras visuais.'
      : 'Tabs, alerts, selects, and datatables coexist without visual hacks.';
  String get slideThreeTag => _isPt ? 'Entrega' : 'Delivery';
  String get slideThreeTitle =>
      _isPt ? 'Documentacao utilizavel' : 'Usable documentation';
  String get slideThreeBody => _isPt
      ? 'Uma galeria executavel evita exemplos quebrados e acelera onboarding.'
      : 'An executable gallery avoids broken examples and speeds up onboarding.';
  String get hoverTooltipText =>
      _isPt ? 'Mostra dicas ao passar o mouse.' : 'Shows tips on hover.';
  String get hoverTooltipButton => _isPt ? 'Tooltip hover' : 'Hover tooltip';
  String get clickTooltipText => _isPt
      ? 'Também funciona com trigger de click.'
      : 'Also works with a click trigger.';
  String get clickTooltipButton => _isPt ? 'Tooltip click' : 'Click tooltip';
  String get datatableCardTitle => 'Datatable';
  String get searchLabel => _isPt ? 'Buscar sprint' : 'Search sprint';
  String get searchPlaceholder =>
      _isPt ? 'Digite para buscar' : 'Type to search';

  void onTableRequest(Filters nextFilters) {
    filters.fillFromFilters(nextFilters);
  }
}
