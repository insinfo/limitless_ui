import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'inputs-page',
  templateUrl: 'inputs_page.html',
  styleUrls: ['inputs_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiInputComponent,
    LiDateRangePickerComponent,
    LiMultiSelectComponent,
    LiSelectComponent,
  ],
)
class InputsPageComponent {
  InputsPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  static const String inputSnippet = '''
<li-input
    [label]="clientLabel"
    [helperText]="clientHelp"
    [(ngModel)]="customerName">
</li-input>''';

  static const String inputEventsSnippet = '''
<li-input
    label="CGM"
    type="number"
    (inputBlur)="loadPersonByCode(\$event.target.value)"
    (inputFocus)="onFocusField(\$event)"
    (inputClick)="openPicker()"
    (inputKeydown)="onFieldKeydown(\$event)"
    (inputEnter)="loadPersonByCode(\$event.target.value)">
</li-input>''';

  static const String validationSnippet = '''
<li-input
    label="CPF"
    liType="cpf"
    [liMessages]="{
      'required': 'Informe o CPF.',
      'cpf': 'Digite um CPF valido.'
    }"
    liValidationMode="submitted"
    [(ngModel)]="cpf">
</li-input>

<li-input
    label="Nome completo"
    liType="requiredText"
    [liRules]="[LiRule.minLength(3)]"
    [liMessages]="{
      'minLength': 'Informe ao menos 3 caracteres.'
    }"
    [(ngModel)]="customerName">
</li-input>''';

  static const String selectSnippet = '''
<li-select
    [dataSource]="statusOptions"
    labelKey="label"
    valueKey="id"
    [(ngModel)]="selectedStatus">
</li-select>

<li-multi-select
    [dataSource]="channelOptions"
    labelKey="label"
    valueKey="id"
    [(ngModel)]="selectedChannels">
</li-multi-select>''';

  static const String dateRangeSnippet = '''
<li-date-range-picker
    [inicio]="rangeStart"
    [fim]="rangeEnd"
    [placeholder]="sprintRangePlaceholder"
    (inicioChange)="onRangeStartChange(\$event)"
    (fimChange)="onRangeEndChange(\$event)">
</li-date-range-picker>''';

  late final List<Map<String, dynamic>> _statusOptionsPt =
      <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'review', 'label': 'Em revisao'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
    <String, dynamic>{'id': 'archived', 'label': 'Arquivado', 'disabled': true},
  ];

  late final List<Map<String, dynamic>> _statusOptionsEn =
      <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Draft'},
    <String, dynamic>{'id': 'review', 'label': 'In review'},
    <String, dynamic>{'id': 'approved', 'label': 'Approved'},
    <String, dynamic>{'id': 'archived', 'label': 'Archived', 'disabled': true},
  ];

  late final List<Map<String, dynamic>> _channelOptionsPt =
      <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'E-mail'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
    <String, dynamic>{'id': 'webhook', 'label': 'Webhook'},
  ];

  late final List<Map<String, dynamic>> _channelOptionsEn =
      <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'Email'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
    <String, dynamic>{'id': 'webhook', 'label': 'Webhook'},
  ];

  late final List<Map<String, dynamic>> _priorityOptionsPt =
      <Map<String, dynamic>>[
    <String, dynamic>{'id': 'p0', 'label': 'P0 - Bloqueante'},
    <String, dynamic>{'id': 'p1', 'label': 'P1 - Alta'},
    <String, dynamic>{'id': 'p2', 'label': 'P2 - Normal'},
    <String, dynamic>{'id': 'p3', 'label': 'P3 - Baixa'},
  ];

  late final List<Map<String, dynamic>> _priorityOptionsEn =
      <Map<String, dynamic>>[
    <String, dynamic>{'id': 'p0', 'label': 'P0 - Blocking'},
    <String, dynamic>{'id': 'p1', 'label': 'P1 - High'},
    <String, dynamic>{'id': 'p2', 'label': 'P2 - Normal'},
    <String, dynamic>{'id': 'p3', 'label': 'P3 - Low'},
  ];

  String selectedStatus = 'review';
  String selectedPriority = 'p1';
  List<dynamic> selectedChannels = <dynamic>['email', 'push'];
  List<dynamic> selectedEscalationChannels = <dynamic>['sms'];
  DateTime? rangeStart = DateTime(2026, 3, 1);
  DateTime? rangeEnd = DateTime(2026, 3, 21);
  DateTime? contractStart = DateTime(2026, 4, 1);
  DateTime? contractEnd = DateTime(2026, 4, 15);
  String customerName = 'Equipe Limitless';
  String releaseEmail = 'release@limitless.dev';
  String amount = '42';
  String notes = 'Monitorar rollout por 30 minutos.';
  String cpf = '12345678901';
  String phone = '21987654321';
  String seats = '25';
  String searchTerm = 'deploy canary';
  String adminPassword = 'Limitless@2026';
  String readonlyToken = 'REL-2026.03.31';
  String disabledOwner = 'Conta sincronizada';
  String disabledBatch = '314';
  String disabledPriority = 'p0';
  List<dynamic> disabledChannels = <dynamic>['email', 'webhook'];
  DateTime? frozenRangeStart = DateTime(2026, 4, 18);
  DateTime? frozenRangeEnd = DateTime(2026, 4, 22);
  String eventDrivenLookup = '1024';
  String lastInputEvent = '';

  bool get isPt => i18n.isPortuguese;
  List<Map<String, dynamic>> get statusOptions =>
      isPt ? _statusOptionsPt : _statusOptionsEn;
  List<Map<String, dynamic>> get channelOptions =>
      isPt ? _channelOptionsPt : _channelOptionsEn;
  List<Map<String, dynamic>> get priorityOptions =>
      isPt ? _priorityOptionsPt : _priorityOptionsEn;

  String get pageTitle => isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'Inputs';
  String get breadcrumb => isPt
      ? 'Campo de texto, textarea, selects e intervalo de datas'
      : 'Text field, textarea, selects, and date range';
  String get intro => isPt
      ? 'LiInput cobre o básico de formulários com integração de ngModel, floating label opcional e addons de prefixo ou sufixo sem exigir markup repetitivo.'
      : 'LiInput covers common form basics with ngModel integration, optional floating label, and prefix or suffix addons without repeated markup.';
  String get apiIntro => isPt
      ? 'A API desta página se divide em três blocos: `li-input`, selects/multi-select e date range picker.'
      : 'The API on this page is split into three blocks: `li-input`, select/multi-select, and the date range picker.';
  String get inputSnippetTitle => 'LiInput';
  String get inputEventsSnippetTitle =>
      isPt ? 'Eventos do LiInput' : 'LiInput events';
  String get selectSnippetTitle =>
      isPt ? 'Select e multi-select' : 'Select and multi-select';
  String get dateRangeSnippetTitle =>
      isPt ? 'Date range picker' : 'Date range picker';
  String get basicInputsTitle => 'LiInput';
  String get clientLabel => isPt ? 'Cliente' : 'Customer';
  String get clientHelp => isPt
      ? 'Campo conectado ao ngModel do AngularDart.'
      : 'Field connected to AngularDart ngModel.';
  String get releaseEmailLabel => isPt ? 'Release e-mail' : 'Release email';
  String get releaseEmailHelp => isPt
      ? 'Floating label com estilo do Limitless.'
      : 'Floating label with Limitless styling.';
  String get batchLabel => isPt ? 'Lote' : 'Batch';
  String get batchHelp =>
      isPt ? 'Addon de prefixo e sufixo.' : 'Prefix and suffix addon.';
  String get notesLabel => isPt ? 'Observações' : 'Notes';
  String get notesHelp => isPt
      ? 'Textarea declarativa usando o mesmo componente.'
      : 'Declarative textarea using the same component.';
  String get inputsSummaryLabel => isPt ? 'Inputs' : 'Inputs';
  String get notesSummaryLabel => isPt ? 'Notas' : 'Notes';
  String get advancedInputsTitle =>
      isPt ? 'LiInput avançado' : 'Advanced LiInput';
  String get cpfLabel => isPt ? 'CPF do responsável' : 'Owner CPF';
  String get cpfHelp => isPt
      ? 'Máscara declarativa aplicada no próprio LiInput.'
      : 'Declarative mask applied directly in LiInput.';
  String get phoneLabel => isPt ? 'Telefone de plantão' : 'On-call phone';
  String get phoneHelp => isPt
      ? 'Útil para contatos de incidente ou suporte.'
      : 'Useful for incident or support contacts.';
  String get seatsLabel => isPt ? 'Quantidade de assentos' : 'Seat count';
  String get seatsHelp => isPt
      ? 'Exemplo numérico com min, max e step.'
      : 'Numeric example with min, max, and step.';
  String get seatsSuffix => isPt ? 'vagas' : 'seats';
  String get searchLabel => isPt ? 'Busca operacional' : 'Operational search';
  String get searchHelp => isPt
      ? 'Busca rápida dentro da documentação ou de incidentes.'
      : 'Quick search across documentation or incidents.';
  String get passwordLabel =>
      isPt ? 'Senha de administração' : 'Admin password';
  String get passwordHelp => isPt
      ? 'Demonstra o modo overlay do olho dentro do campo, mais próximo do padrão usado em fluxos sensíveis como autenticação e assinatura.'
      : 'Demonstrates the overlay eye button inside the field, closer to the pattern used in sensitive flows like authentication and signing.';
  String get tokenLabel => isPt ? 'Token da release' : 'Release token';
  String get tokenHelp => isPt
      ? 'Campo somente leitura para referências imutáveis.'
      : 'Read-only field for immutable references.';
  String get stateExamplesTitle =>
      isPt ? 'Readonly e disabled' : 'Read-only and disabled';
  String get disabledOwnerLabel =>
      isPt ? 'Responsável bloqueado' : 'Locked owner';
  String get disabledOwnerHelp => isPt
      ? 'Campo desabilitado mantendo o valor visível para consulta.'
      : 'Disabled field while keeping the visible value for consultation.';
  String get disabledBatchLabel => isPt ? 'Lote travado' : 'Locked batch';
  String get disabledBatchHelp => isPt
      ? 'Exemplo de input desabilitado com addon ativo apenas visualmente.'
      : 'Disabled input example with the addon kept only for visual context.';
  String get shortSummaryLabel => isPt ? 'Resumo curto' : 'Short summary';
  String get shortSummaryHelp => isPt
      ? 'Combina maxlength com textarea curta.'
      : 'Combines maxlength with a short textarea.';
  String get advancedSummaryLabel =>
      isPt ? 'Entradas avançadas' : 'Advanced inputs';
  String get tokenSummaryLabel => isPt ? 'Token' : 'Token';
  String get eventsTitle => isPt ? 'Eventos de input' : 'Input events';
  String get eventsHelp => isPt
      ? 'Use os outputs para blur, foco, clique, keydown e Enter quando o formulário precisar reagir sem acessar o elemento nativo.'
      : 'Use the outputs for blur, focus, click, keydown, and Enter when the form must react without reaching into the native element.';
  String get eventsLabel => isPt ? 'CGM com callbacks' : 'CGM with callbacks';
  String get lastEventLabel => isPt ? 'Último evento' : 'Last event';
  String get selectsTitle => isPt ? 'Selects' : 'Selects';
  String get deliveryStatusLabel =>
      isPt ? 'Status da entrega' : 'Delivery status';
  String get notificationChannelsLabel =>
      isPt ? 'Canais de notificacao' : 'Notification channels';
  String get priorityLabel =>
      isPt ? 'Prioridade operacional' : 'Operational priority';
  String get escalationLabel =>
      isPt ? 'Escalações automáticas' : 'Automatic escalations';
  String get disabledPriorityLabel =>
      isPt ? 'Prioridade bloqueada' : 'Locked priority';
  String get disabledChannelsLabel =>
      isPt ? 'Canais bloqueados' : 'Locked channels';
  String get disabledSelectionHelp => isPt
      ? 'Estado desabilitado para fluxos em que o valor deve aparecer, mas não pode ser alterado.'
      : 'Disabled state for flows where the value must remain visible but cannot be changed.';
  String get statusSummaryLabel => t.common.status;
  String get channelsSummaryLabel => isPt ? 'Canais' : 'Channels';
  String get prioritySummaryLabel => isPt ? 'Prioridade' : 'Priority';
  String get escalationSummaryLabel => isPt ? 'Escalações' : 'Escalations';
  String get dateRangeTitle => isPt ? 'Date range picker' : 'Date range picker';
  String get sprintRangePlaceholder =>
      isPt ? 'Selecione o periodo da sprint' : 'Select the sprint range';
  String get currentPeriodLabel => t.common.currentPeriod;
  String get rangeConfigHint => isPt
      ? 'Configure minDate, maxDate, placeholder e locale conforme o fluxo.'
      : 'Configure minDate, maxDate, placeholder, and locale according to the flow.';
  String get contractReviewPlaceholder => 'Contract review window';
  String get parallelWindowLabel =>
      isPt ? 'Janela paralela' : 'Parallel window';
  String get undefinedWindowLabel => isPt ? 'Nao definida' : 'Undefined';
  String get frozenWindowLabel => isPt ? 'Janela congelada' : 'Frozen window';
  String get frozenWindowPlaceholder =>
      isPt ? 'Periodo bloqueado para edicao' : 'Window locked for editing';
  String get frozenWindowNote => isPt
      ? 'Use disabled quando o periodo precisar ser exibido sem permitir ajuste no calendário.'
      : 'Use disabled when the range must be displayed without allowing calendar changes.';
  String get secondaryRangeNote => isPt
      ? 'Segundo range com locale em inglês para validar a API em contextos distintos.'
      : 'Second range with English locale to validate the API in distinct contexts.';
  String get currentInputSummary => isPt
      ? 'Nome: $customerName | Email: $releaseEmail | Lote: $amount'
      : 'Name: $customerName | Email: $releaseEmail | Batch: $amount';

  String get advancedInputSummary => isPt
      ? 'CPF: $cpf | Telefone: $phone | Assentos: $seats | Busca: $searchTerm'
      : 'CPF: $cpf | Phone: $phone | Seats: $seats | Search: $searchTerm';

  String get selectedStatusLabel => _labelFor(selectedStatus, statusOptions);

  String get selectedPriorityLabel =>
      _labelFor(selectedPriority, priorityOptions);

  String get selectedChannelsLabel => selectedChannels
      .map((dynamic id) => _labelFor(id.toString(), channelOptions))
      .join(', ');

  String get selectedEscalationChannelsLabel => selectedEscalationChannels
      .map((dynamic id) => _labelFor(id.toString(), channelOptions))
      .join(', ');

  String get selectedRangeLabel {
    if (rangeStart == null || rangeEnd == null) {
      return isPt
          ? 'Periodo parcial ou nao definido'
          : 'Partial or undefined range';
    }

    return isPt
        ? '${formatDate(rangeStart!)} ate ${formatDate(rangeEnd!)}'
        : '${formatDate(rangeStart!)} to ${formatDate(rangeEnd!)}';
  }

  void onRangeStartChange(DateTime? value) {
    rangeStart = value;
  }

  void onRangeEndChange(DateTime? value) {
    rangeEnd = value;
  }

  void onContractStartChange(DateTime? value) {
    contractStart = value;
  }

  void onContractEndChange(DateTime? value) {
    contractEnd = value;
  }

  void onInputBlur(dynamic _) {
    lastInputEvent =
        isPt ? 'blur: buscar pessoa por código' : 'blur: lookup person by code';
  }

  void onInputFocus(dynamic _) {
    lastInputEvent = isPt ? 'focus: campo ativo' : 'focus: field focused';
  }

  void onInputClick(dynamic _) {
    lastInputEvent =
        isPt ? 'click: abrir busca modal' : 'click: open modal picker';
  }

  void onInputKeydown(dynamic event) {
    final key = event?.key?.toString() ?? '?';
    lastInputEvent = isPt ? 'keydown: tecla $key' : 'keydown: key $key';
  }

  void onInputEnter(dynamic _) {
    lastInputEvent = isPt
        ? 'enter: confirmar busca por código'
        : 'enter: confirm lookup by code';
  }

  String _labelFor(String id, List<Map<String, dynamic>> source) {
    for (final item in source) {
      if (item['id'] == id) {
        return item['label'] as String;
      }
    }
    return id;
  }

  String formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
