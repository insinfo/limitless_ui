import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

import '../datatable/datatable_demo_service.dart';

@Component(
  selector: 'datatable-select-page',
  templateUrl: 'datatable_select_page.html',
  styleUrls: ['datatable_select_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiDatatableSelectComponent,
    LiDatatableSelectTriggerDirective,
    LiDatatableSelectModalContentDirective,
    LiDataTableComponent,
    LiHighlightComponent,
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

  static const String basicApiSnippet = '''
<li-datatable-select
  [settings]="dtSettings"
  [dataTableFilter]="filtro"
  [data]="items"
  [searchInFields]="sInFields"
  [labelKey]="'name'"
  [valueKey]="'id'"
  [title]="'Selecionar pessoa'"
  [placeholder]="'Clique para selecionar...'"
  (dataRequest)="onDataRequest(\$event)"
  (currentValueChange)="onValueChanged(\$event)">
</li-datatable-select>''';

  static const String ngModelApiSnippet = '''
<li-datatable-select
  [settings]="dtSettings"
  [dataTableFilter]="filtro"
  [data]="items"
  [searchInFields]="sInFields"
  [labelKey]="'name'"
  [valueKey]="'id'"
  [(ngModel)]="selectedValue"
  (dataRequest)="onDataRequest(\$event)">
</li-datatable-select>''';

  static const String multipleApiSnippet = '''
<li-datatable-select
  [settings]="dtSettings"
  [dataTableFilter]="filtro"
  [data]="items"
  [searchInFields]="sInFields"
  [labelKey]="'name'"
  [valueKey]="'id'"
  [multiple]="true"
  [clearButtonLabel]="'Limpar'"
  [triggerIconMode]="'addon'"
  [triggerIconClass]="'ph ph-users-three'"
  [(ngModel)]="selectedValues">
</li-datatable-select>''';

  static const String builderApiSnippet = '''
<li-datatable-select
  [settings]="dtSettings"
  [dataTableFilter]="filtro"
  [data]="items"
  [searchInFields]="sInFields"
  [itemLabelBuilder]="personLabel"
  [itemValueBuilder]="personId"
  [compareWith]="comparePersonById"
  [(ngModel)]="selectedPerson">
</li-datatable-select>''';

  static const String arbitraryModalSnippet = '''
<li-datatable-select
  [itemLabelBuilder]="cgmLabel"
  [itemValueBuilder]="cgmValue"
  [compareWith]="compareCgm"
  [(ngModel)]="pessoaSelecionada">
  <template liDatatableSelectModalContent let-ctx>
    <consultar-cgm-page
      [insideModal]="true"
      [filtroAtivo]="true"
      (onSelect)="ctx.select(\$event)">
    </consultar-cgm-page>
  </template>
</li-datatable-select>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get isPt => i18n.isPortuguese;

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
  late final DatatableSettings _typedBuilderSettingsPt =
      _buildTypedBuilderSettings(
    idTitle: 'ID',
    nameTitle: 'Nome',
    emailTitle: 'E-mail',
    departmentTitle: 'Departamento',
  );
  late final DatatableSettings _typedBuilderSettingsEn =
      _buildTypedBuilderSettings(
    idTitle: 'ID',
    nameTitle: 'Name',
    emailTitle: 'Email',
    departmentTitle: 'Department',
  );
  DataFrame<Map<String, dynamic>> basicData = DataFrame<Map<String, dynamic>>(
      items: <Map<String, dynamic>>[], totalRecords: 0);
  final Filters multipleFilter = Filters(limit: 5, offset: 0);
  DataFrame<Map<String, dynamic>> multipleData =
      DataFrame<Map<String, dynamic>>(
          items: <Map<String, dynamic>>[], totalRecords: 0);
  List<dynamic> multipleSelectedIds = <dynamic>[];
  final Filters typedBuilderFilter = Filters(limit: 5, offset: 0);
  late final DataFrame<TypedPersonRecord> _typedBuilderDataPt =
      _buildTypedBuilderData(
    departmentEngineering: 'Engenharia',
    departmentDesign: 'Design',
    departmentMarketing: 'Marketing',
  );
  late final DataFrame<TypedPersonRecord> _typedBuilderDataEn =
      _buildTypedBuilderData(
    departmentEngineering: 'Engineering',
    departmentDesign: 'Design',
    departmentMarketing: 'Marketing',
  );
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

  DatatableSettings get typedBuilderSettings =>
      i18n.isPortuguese ? _typedBuilderSettingsPt : _typedBuilderSettingsEn;

  List<DatatableSearchField> get basicSearchFields =>
      i18n.isPortuguese ? _basicSearchFieldsPt : _basicSearchFieldsEn;

  DataFrame<TypedPersonRecord> get typedBuilderData =>
      i18n.isPortuguese ? _typedBuilderDataPt : _typedBuilderDataEn;

  String? selectedPersonId;
  String selectedPersonLabel = '';
  dynamic selectedTypedPerson = const SelectedPersonRef(2);

  @ViewChild('basicSelect')
  LiDatatableSelectComponent? basicSelect;

  @ViewChild('multipleSelect')
  LiDatatableSelectComponent? multipleSelect;

  @ViewChild('typedBuilderSelect')
  LiDatatableSelectComponent? typedBuilderSelect;

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

  Future<void> onMultipleDataRequest(Filters filters) async {
    multipleFilter.fillFromFilters(filters);
    multipleData = await _demoService.query(multipleFilter);
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
    multipleData = await _demoService.query(multipleFilter);
    customTemplateData = await _demoService.query(customTemplateFilter);
  }

  String personLabel(dynamic instance) => (instance as TypedPersonRecord).name;

  dynamic personValue(dynamic instance) =>
      SelectedPersonRef((instance as TypedPersonRecord).id);

  bool compareById(dynamic itemValue, dynamic selectedValue) {
    return itemValue is SelectedPersonRef &&
        selectedValue is SelectedPersonRef &&
        itemValue.id == selectedValue.id;
  }

  String get multipleSelectedValueText => multipleSelectedIds.isEmpty
      ? t.common.none
      : multipleSelectedIds.join(', ');

  String get multipleSelectedLabelText {
    final labels = multipleSelect?.selectedLabels ?? const <String>[];
    return labels.isEmpty ? t.common.none : labels.join(', ');
  }

  String get selectedTypedPersonValueText {
    final value = selectedTypedPerson;
    if (value is SelectedPersonRef) {
      return value.id.toString();
    }
    return t.common.none;
  }

  String get selectedTypedPersonLabelText {
    final label = typedBuilderSelect?.selectedLabel ?? '';
    return label.isEmpty ? t.common.none : label;
  }

  String get multipleSelectIntro => i18n.isPortuguese
      ? 'A seleção múltipla reutiliza os checkboxes do datatable e confirma a escolha quando o usuário fecha o modal, sem exigir um passo extra de confirmação.'
      : 'Multiple selection reuses the datatable checkboxes and commits the choice when the user closes the modal, without requiring an extra confirmation step.';

  String get multipleSelectLabel => i18n.isPortuguese
      ? 'Selecionar responsáveis da frente'
      : 'Select squad owners';

  String get multipleSelectModalTitle =>
      i18n.isPortuguese ? 'Selecionar responsáveis' : 'Select owners';

  String get multipleSelectPlaceholder => i18n.isPortuguese
      ? 'Escolha uma ou mais pessoas'
      : 'Choose one or more people';

  String get multipleSelectClearButtonLabel =>
      i18n.isPortuguese ? 'Limpar modal' : 'Clear modal';

  String get builderDemoIntro => i18n.isPortuguese
      ? 'Quando o modal trabalha com linhas tipadas, os builders mantêm o modelo forte e o compareWith preserva o rótulo sincronizado mesmo com novas instâncias. Para a tabela interna renderizar colunas por chave, a linha tipada expõe toMap().'
      : 'When the modal works with typed rows, the builders keep the model strongly typed and compareWith preserves the synchronized label even with fresh instances. For the internal table to render key-based columns, the typed row exposes toMap().';

  String get builderDemoLabel => i18n.isPortuguese
      ? 'Lista tipada com builders'
      : 'Typed list with builders';

  String get builderDemoModalTitle =>
      i18n.isPortuguese ? 'Selecionar pessoa tipada' : 'Select typed person';

  String get builderDemoPlaceholder =>
      i18n.isPortuguese ? 'Abra a lista tipada' : 'Open the typed list';

  String get multipleOptionText => i18n.isPortuguese
      ? '[multiple] muda o modelo para List<dynamic>, usa os checkboxes da tabela e confirma a seleção ao fechar o modal.'
      : '[multiple] switches the model to List<dynamic>, uses the table checkboxes, and commits the selection when the modal closes.';

  String get triggerIconOptionText => i18n.isPortuguese
      ? '[triggerIconMode] e [triggerIconClass] ajustam o ícone do trigger sem exigir template customizado.'
      : '[triggerIconMode] and [triggerIconClass] adjust the trigger icon without requiring a custom template.';

  String get modalActionOptionText => i18n.isPortuguese
      ? '[showClearButton] e [clearButtonLabel] refinam o fluxo da seleção múltipla sem exigir um botão de confirmação.'
      : '[showClearButton] and [clearButtonLabel] refine the multiple selection flow without requiring a confirmation button.';

  String get multipleApiTitle => i18n.isPortuguese
      ? 'Seleção múltipla + ícone do trigger'
      : 'Multiple selection + trigger icon';

  String get customTemplateIntro => i18n.isPortuguese
      ? 'Exemplo mais proximo de uma tela de consulta: o trigger pode mostrar resumo rico e o modal pode incluir contexto extra sem perder os callbacks de selecao.'
      : 'A process-lookup example: the trigger can show a richer summary and the modal can include extra context without losing the selection callbacks.';

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
  String get arbitraryModalTitle => i18n.isPortuguese
      ? 'Conteúdo arbitrário no modal'
      : 'Arbitrary modal content';
  String get arbitraryModalBody => i18n.isPortuguese
      ? 'Além do datatable interno, o modal pode hospedar um componente inteiro de busca. Nesses casos, use `ctx.select(item)` quando o componente emite o objeto completo, `ctx.selectItem(label, value)` quando você já possui os dois valores e recorra a `ctx.clear()`, `ctx.apply()` ou `ctx.close()` para controlar o fluxo do modal.'
      : 'Besides the built-in datatable, the modal can host a full search component. In those cases, use `ctx.select(item)` when the child emits the full object, `ctx.selectItem(label, value)` when you already have both values, and rely on `ctx.clear()`, `ctx.apply()`, or `ctx.close()` to control the modal flow.';

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

  static DataFrame<TypedPersonRecord> _buildTypedBuilderData({
    required String departmentEngineering,
    required String departmentDesign,
    required String departmentMarketing,
  }) {
    return DataFrame<TypedPersonRecord>(
      items: <TypedPersonRecord>[
        TypedPersonRecord(
          id: 1,
          name: 'Ana Souza',
          email: 'ana@example.com',
          department: departmentEngineering,
        ),
        TypedPersonRecord(
          id: 2,
          name: 'Maria Silva',
          email: 'maria@example.com',
          department: departmentDesign,
        ),
        TypedPersonRecord(
          id: 3,
          name: 'Pedro Santos',
          email: 'pedro@example.com',
          department: departmentMarketing,
        ),
      ],
      totalRecords: 3,
    );
  }

  static DatatableSettings _buildTypedBuilderSettings({
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
          customRenderString: (_, dynamic instance) =>
              '${(instance as TypedPersonRecord).id}',
        ),
        DatatableCol(
          key: 'name',
          title: nameTitle,
          customRenderString: (_, dynamic instance) =>
              (instance as TypedPersonRecord).name,
        ),
        DatatableCol(
          key: 'email',
          title: emailTitle,
          customRenderString: (_, dynamic instance) =>
              (instance as TypedPersonRecord).email,
        ),
        DatatableCol(
          key: 'department',
          title: departmentTitle,
          customRenderString: (_, dynamic instance) =>
              (instance as TypedPersonRecord).department,
        ),
      ],
    );
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

class TypedPersonRecord {
  const TypedPersonRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  final int id;
  final String name;
  final String email;
  final String department;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'department': department,
    };
  }
}

class SelectedPersonRef {
  const SelectedPersonRef(this.id);

  final int id;
}
