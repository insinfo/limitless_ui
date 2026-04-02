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
    LiDatatableSelectTriggerDirective,
    LiDatatableSelectModalContentDirective,
    LiDataTableComponent,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class DatatableSelectPageComponent implements OnInit {
  DatatableSelectPageComponent(this.i18n)
      : _demoServicePt = DatatableDemoService(_buildSeedRecords(
          departmentEngineering: 'Engenharia',
          departmentDesign: 'Design',
          departmentMarketing: 'Marketing',
          departmentFinance: 'Financeiro',
          departmentHr: 'RH',
        )),
        _demoServiceEn = DatatableDemoService(_buildSeedRecords(
          departmentEngineering: 'Engineering',
          departmentDesign: 'Design',
          departmentMarketing: 'Marketing',
          departmentFinance: 'Finance',
          departmentHr: 'HR',
        ));

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  final List<int> limitPerPageOptions = <int>[5, 10, 12, 20, 25];

  final DatatableDemoService _demoServicePt;
  final DatatableDemoService _demoServiceEn;

  DatatableDemoService get _demoService =>
      i18n.isPortuguese ? _demoServicePt : _demoServiceEn;

  // ---------------------------------------------------------------------------
  // Basic example
  // ---------------------------------------------------------------------------

  final Filters basicFilter = Filters(limit: 5, offset: 0);
  late final DatatableSettings _basicSettingsPt = _buildBasicSettings(
    idTitle: 'ID',
    nameTitle: 'Nome',
    emailTitle: 'E-mail',
    departmentTitle: 'Departamento',
  );
  late final DatatableSettings _basicSettingsEn = _buildBasicSettings(
    idTitle: 'ID',
    nameTitle: 'Name',
    emailTitle: 'Email',
    departmentTitle: 'Department',
  );
  DataFrame<Map<String, dynamic>> basicData = DataFrame<Map<String, dynamic>>(
      items: <Map<String, dynamic>>[], totalRecords: 0);
  late final List<DatatableSearchField> _basicSearchFieldsPt =
      _buildSearchFields(
    nameLabel: 'Nome',
    emailLabel: 'E-mail',
    departmentLabel: 'Departamento',
  );
  late final List<DatatableSearchField> _basicSearchFieldsEn =
      _buildSearchFields(
    nameLabel: 'Name',
    emailLabel: 'Email',
    departmentLabel: 'Department',
  );

  DatatableSettings get basicSettings =>
      i18n.isPortuguese ? _basicSettingsPt : _basicSettingsEn;

  List<DatatableSearchField> get basicSearchFields =>
      i18n.isPortuguese ? _basicSearchFieldsPt : _basicSearchFieldsEn;

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
  String? customTemplateValue;
  String customTemplateEventLog = '';

  @ViewChild('ngModelSelect')
  LiDatatableSelectComponent? ngModelSelect;

  @ViewChild('customTemplateSelect')
  LiDatatableSelectComponent? customTemplateSelect;

  final Filters ngModelFilter = Filters(limit: 5, offset: 0);
  DataFrame<Map<String, dynamic>> ngModelData = DataFrame<Map<String, dynamic>>(
      items: <Map<String, dynamic>>[], totalRecords: 0);
  final Filters customTemplateFilter = Filters(limit: 5, offset: 0);
  DataFrame<Map<String, dynamic>> customTemplateData =
      DataFrame<Map<String, dynamic>>(
          items: <Map<String, dynamic>>[], totalRecords: 0);

  @override
  Future<void> ngOnInit() async {
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

  Future<void> onCustomTemplateDataRequest(Filters filters) async {
    customTemplateFilter.fillFromFilters(filters);
    customTemplateData = await _demoService.query(customTemplateFilter);
  }

  void onBasicValueChanged(dynamic value) {
    selectedPersonId = value?.toString();
    selectedPersonLabel = basicSelect?.selectedLabel ?? '';
  }

  void onNgModelValueChanged(dynamic value) {
    ngModelValue = value?.toString();
    ngModelEventLog =
        '${t.pages.datatableSelect.ngModelValuePrefix}: $ngModelValue (${t.common.label}: ${ngModelSelect?.selectedLabel ?? ''})';
  }

  void onCustomTemplateValueChanged(dynamic value) {
    customTemplateValue = value?.toString();
    customTemplateEventLog =
        '$customTemplateLogPrefix: ${customTemplateValue ?? 'null'} (${t.common.label}: ${customTemplateSelect?.selectedLabel ?? ''})';
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
    customTemplateData = await _demoService.query(customTemplateFilter);
  }

  String get customTemplateIntro => i18n.isPortuguese
      ? 'Exemplo mais proximo do SALI: o trigger pode mostrar resumo rico e o modal pode incluir contexto extra sem perder os callbacks de selecao.'
      : 'A SALI-like example: the trigger can show a richer summary and the modal can include extra context without losing the selection callbacks.';

  String get customTemplateLabel => i18n.isPortuguese
      ? 'Selecionar responsavel com template customizado'
      : 'Select owner with custom template';

  String get customTemplateHint =>
      i18n.isPortuguese ? 'Contexto do modal' : 'Modal context';

  String get customTemplateDescription => i18n.isPortuguese
      ? 'O TemplateRef recebe dados, filtros, configuracao da tabela, valor selecionado e funcoes para selecionar, fechar e requisitar dados.'
      : 'The TemplateRef receives data, filters, table settings, selected value, and functions to select, close, and request data.';

  String get customTemplateLogPrefix =>
      i18n.isPortuguese ? 'Template customizado' : 'Custom template';

  String get customTemplateSelectedCaption =>
      i18n.isPortuguese ? 'Selecionado' : 'Selected';

  String get customTemplateOpenCaption =>
      i18n.isPortuguese ? 'Abrir busca' : 'Open picker';

  static DatatableSettings _buildBasicSettings({
    required String idTitle,
    required String nameTitle,
    required String emailTitle,
    required String departmentTitle,
  }) {
    return DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(
          key: 'id',
          title: idTitle,
          enableSorting: true,
          sortingBy: 'id',
          width: '80px',
        ),
        DatatableCol(
          key: 'name',
          title: nameTitle,
          enableSorting: true,
          sortingBy: 'name',
        ),
        DatatableCol(
          key: 'email',
          title: emailTitle,
          enableSorting: true,
          sortingBy: 'email',
          hideOnMobile: true,
        ),
        DatatableCol(
          key: 'department',
          title: departmentTitle,
          enableSorting: true,
          sortingBy: 'department',
          hideOnMobile: true,
        ),
      ],
    );
  }

  static List<DatatableSearchField> _buildSearchFields({
    required String nameLabel,
    required String emailLabel,
    required String departmentLabel,
  }) {
    return <DatatableSearchField>[
      DatatableSearchField(
        label: nameLabel,
        field: 'name',
        operator: 'like',
        selected: true,
      ),
      DatatableSearchField(
        label: emailLabel,
        field: 'email',
        operator: 'like',
      ),
      DatatableSearchField(
        label: departmentLabel,
        field: 'department',
        operator: 'like',
      ),
    ];
  }

  static List<Map<String, dynamic>> _buildSeedRecords({
    required String departmentEngineering,
    required String departmentDesign,
    required String departmentMarketing,
    required String departmentFinance,
    required String departmentHr,
  }) {
    return <Map<String, dynamic>>[
      {
        'id': '1',
        'name': 'João Oliveira',
        'email': 'joao@example.com',
        'department': departmentEngineering
      },
      {
        'id': '2',
        'name': 'Maria Silva',
        'email': 'maria@example.com',
        'department': departmentDesign
      },
      {
        'id': '3',
        'name': 'Pedro Santos',
        'email': 'pedro@example.com',
        'department': departmentMarketing
      },
      {
        'id': '4',
        'name': 'Ana Costa',
        'email': 'ana@example.com',
        'department': departmentEngineering
      },
      {
        'id': '5',
        'name': 'Carlos Ferreira',
        'email': 'carlos@example.com',
        'department': departmentFinance
      },
      {
        'id': '6',
        'name': 'Juliana Lima',
        'email': 'juliana@example.com',
        'department': departmentHr
      },
      {
        'id': '7',
        'name': 'Lucas Almeida',
        'email': 'lucas@example.com',
        'department': departmentEngineering
      },
      {
        'id': '8',
        'name': 'Fernanda Souza',
        'email': 'fernanda@example.com',
        'department': departmentDesign
      },
      {
        'id': '9',
        'name': 'Ricardo Mendes',
        'email': 'ricardo@example.com',
        'department': departmentMarketing
      },
      {
        'id': '10',
        'name': 'Camila Rocha',
        'email': 'camila@example.com',
        'department': departmentFinance
      },
      {
        'id': '11',
        'name': 'Bruno Pereira',
        'email': 'bruno@example.com',
        'department': departmentEngineering
      },
      {
        'id': '12',
        'name': 'Patrícia Gomes',
        'email': 'patricia@example.com',
        'department': departmentHr
      },
      {
        'id': '13',
        'name': 'Rafael Nunes',
        'email': 'rafael@example.com',
        'department': departmentDesign
      },
      {
        'id': '14',
        'name': 'Isabela Barbosa',
        'email': 'isabela@example.com',
        'department': departmentEngineering
      },
      {
        'id': '15',
        'name': 'Thiago Cardoso',
        'email': 'thiago@example.com',
        'department': departmentMarketing
      },
      {
        'id': '16',
        'name': 'Amanda Ribeiro',
        'email': 'amanda@example.com',
        'department': departmentFinance
      },
      {
        'id': '17',
        'name': 'Gustavo Martins',
        'email': 'gustavo@example.com',
        'department': departmentHr
      },
      {
        'id': '18',
        'name': 'Larissa Araújo',
        'email': 'larissa@example.com',
        'department': departmentDesign
      },
    ];
  }
}
