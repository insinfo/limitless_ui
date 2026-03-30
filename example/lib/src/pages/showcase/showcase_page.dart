import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'showcase-page',
  templateUrl: 'showcase_page.html',
  styleUrls: ['showcase_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiCarouselComponent,
    LiCarouselItemComponent,
    LiDataTableComponent,
    LiTooltipComponent,
  ],
)
class ShowcasePageComponent {
  final Filters filters = Filters(limit: 5, offset: 0);

  final DataFrame<Map<String, dynamic>> tableData = DataFrame<Map<String, dynamic>>(
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

  late final DatatableSettings tableSettings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'feature', title: 'Entrega', enableSorting: true, sortingBy: 'feature'),
      DatatableCol(key: 'owner', title: 'Squad', enableSorting: true, sortingBy: 'owner'),
      DatatableCol(key: 'status', title: 'Status', enableSorting: true, sortingBy: 'status'),
      DatatableCol(key: 'health', title: 'Saude'),
    ],
  );

  late final List<DatatableSearchField> searchFields = <DatatableSearchField>[
    DatatableSearchField(label: 'Entrega', field: 'feature', operator: 'like'),
    DatatableSearchField(label: 'Squad', field: 'owner', operator: 'like'),
    DatatableSearchField(label: 'Status', field: 'status', operator: '='),
  ];

  void onTableRequest(Filters nextFilters) {
    filters.fillFromFilters(nextFilters);
  }
}
