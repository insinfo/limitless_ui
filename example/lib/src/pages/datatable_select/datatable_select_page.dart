import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

import '../datatable/datatable_demo_service.dart';

@Component(
  selector: 'datatable-select-page',
  templateUrl: 'datatable_select_page.html',
  styleUrls: ['datatable_select_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiDatatableSelectComponent,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class DatatableSelectPageComponent implements OnInit {
  DatatableSelectPageComponent(this.i18n)
      : _demoService = DatatableDemoService(_buildSeedRecords());

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  final DatatableDemoService _demoService;

  // ---------------------------------------------------------------------------
  // Basic example
  // ---------------------------------------------------------------------------

  final Filters basicFilter = Filters(limit: 5, offset: 0);
  late final DatatableSettings basicSettings;
  DataFrame<Map<String, dynamic>> basicData =
      DataFrame<Map<String, dynamic>>(items: <Map<String, dynamic>>[], totalRecords: 0);
  late final List<DatatableSearchField> basicSearchFields;

  String? selectedPersonId;
  String selectedPersonLabel = '';

  @ViewChild('basicSelect')
  LiDatatableSelectComponent? basicSelect;

  // ---------------------------------------------------------------------------
  // Disabled example
  // ---------------------------------------------------------------------------

  String? disabledValue = '3';

  // ---------------------------------------------------------------------------
  // NgModel example
  // ---------------------------------------------------------------------------

  String? ngModelValue;
  String ngModelEventLog = '';

  @ViewChild('ngModelSelect')
  LiDatatableSelectComponent? ngModelSelect;

  final Filters ngModelFilter = Filters(limit: 5, offset: 0);
  DataFrame<Map<String, dynamic>> ngModelData =
      DataFrame<Map<String, dynamic>>(items: <Map<String, dynamic>>[], totalRecords: 0);

  @override
  Future<void> ngOnInit() async {
    basicSettings = DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'id',
          title: 'ID',
          enableSorting: true,
          sortingBy: 'id',
          width: '80px',
        ),
        DatatableCol(
          key: 'name',
          title: 'Nome',
          enableSorting: true,
          sortingBy: 'name',
        ),
        DatatableCol(
          key: 'email',
          title: 'E-mail',
          enableSorting: true,
          sortingBy: 'email',
          hideOnMobile: true,
        ),
        DatatableCol(
          key: 'department',
          title: 'Departamento',
          enableSorting: true,
          sortingBy: 'department',
          hideOnMobile: true,
        ),
      ],
    );

    basicSearchFields = <DatatableSearchField>[
      DatatableSearchField(
        label: 'Nome',
        field: 'name',
        operator: 'like',
        selected: true,
      ),
      DatatableSearchField(
        label: 'E-mail',
        field: 'email',
        operator: 'like',
      ),
      DatatableSearchField(
        label: 'Departamento',
        field: 'department',
        operator: 'like',
      ),
    ];

    await _loadBasicData(basicFilter);
  }

  Future<void> onBasicDataRequest(Filters filters) async {
    basicFilter.fillFromFilters(filters);
    await _loadBasicData(basicFilter);
  }

  Future<void> onNgModelDataRequest(Filters filters) async {
    ngModelFilter.fillFromFilters(filters);
    ngModelData = await _demoService.query(ngModelFilter);
  }

  void onBasicValueChanged(dynamic value) {
    selectedPersonId = value?.toString();
    selectedPersonLabel = basicSelect?.selectedLabel ?? '';
  }

  void onNgModelValueChanged(dynamic value) {
    ngModelValue = value?.toString();
    ngModelEventLog =
        'ngModel value: $ngModelValue (label: ${ngModelSelect?.selectedLabel ?? ''})';
  }

  void clearBasic() {
    basicSelect?.clear();
    selectedPersonId = null;
    selectedPersonLabel = '';
  }

  void setBasicProgrammatically() {
    basicSelect?.setSelectedItem(label: 'Maria Silva', value: '2');
    selectedPersonId = '2';
    selectedPersonLabel = 'Maria Silva';
  }

  Future<void> _loadBasicData(Filters filters) async {
    basicData = await _demoService.query(filters);
    // Also load the same data into the ngModel example.
    ngModelData = await _demoService.query(ngModelFilter);
  }

  static List<Map<String, dynamic>> _buildSeedRecords() {
    return <Map<String, dynamic>>[
      {'id': '1', 'name': 'João Oliveira', 'email': 'joao@example.com', 'department': 'Engenharia'},
      {'id': '2', 'name': 'Maria Silva', 'email': 'maria@example.com', 'department': 'Design'},
      {'id': '3', 'name': 'Pedro Santos', 'email': 'pedro@example.com', 'department': 'Marketing'},
      {'id': '4', 'name': 'Ana Costa', 'email': 'ana@example.com', 'department': 'Engenharia'},
      {'id': '5', 'name': 'Carlos Ferreira', 'email': 'carlos@example.com', 'department': 'Financeiro'},
      {'id': '6', 'name': 'Juliana Lima', 'email': 'juliana@example.com', 'department': 'RH'},
      {'id': '7', 'name': 'Lucas Almeida', 'email': 'lucas@example.com', 'department': 'Engenharia'},
      {'id': '8', 'name': 'Fernanda Souza', 'email': 'fernanda@example.com', 'department': 'Design'},
      {'id': '9', 'name': 'Ricardo Mendes', 'email': 'ricardo@example.com', 'department': 'Marketing'},
      {'id': '10', 'name': 'Camila Rocha', 'email': 'camila@example.com', 'department': 'Financeiro'},
      {'id': '11', 'name': 'Bruno Pereira', 'email': 'bruno@example.com', 'department': 'Engenharia'},
      {'id': '12', 'name': 'Patrícia Gomes', 'email': 'patricia@example.com', 'department': 'RH'},
      {'id': '13', 'name': 'Rafael Nunes', 'email': 'rafael@example.com', 'department': 'Design'},
      {'id': '14', 'name': 'Isabela Barbosa', 'email': 'isabela@example.com', 'department': 'Engenharia'},
      {'id': '15', 'name': 'Thiago Cardoso', 'email': 'thiago@example.com', 'department': 'Marketing'},
      {'id': '16', 'name': 'Amanda Ribeiro', 'email': 'amanda@example.com', 'department': 'Financeiro'},
      {'id': '17', 'name': 'Gustavo Martins', 'email': 'gustavo@example.com', 'department': 'RH'},
      {'id': '18', 'name': 'Larissa Araújo', 'email': 'larissa@example.com', 'department': 'Design'},
    ];
  }
}
