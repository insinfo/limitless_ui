import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'inputs-page',
  templateUrl: 'inputs_page.html',
  styleUrls: ['inputs_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
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

  final List<Map<String, dynamic>> statusOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'review', 'label': 'Em revisao'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
    <String, dynamic>{'id': 'archived', 'label': 'Arquivado', 'disabled': true},
  ];

  final List<Map<String, dynamic>> channelOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'E-mail'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
    <String, dynamic>{'id': 'webhook', 'label': 'Webhook'},
  ];

  final List<Map<String, dynamic>> priorityOptions = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'p0', 'label': 'P0 - Bloqueante'},
    <String, dynamic>{'id': 'p1', 'label': 'P1 - Alta'},
    <String, dynamic>{'id': 'p2', 'label': 'P2 - Normal'},
    <String, dynamic>{'id': 'p3', 'label': 'P3 - Baixa'},
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

  bool get _isPt => i18n.isPortuguese;

  String get pageTitle => _isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'Inputs';
  String get breadcrumb => _isPt
      ? 'Campo de texto, textarea, selects e intervalo de datas'
      : 'Text field, textarea, selects, and date range';
  String get intro => _isPt
      ? 'LiInput cobre o básico de formulários com integração de ngModel, floating label opcional e addons de prefixo ou sufixo sem exigir markup repetitivo.'
      : 'LiInput covers common form basics with ngModel integration, optional floating label, and prefix or suffix addons without repeated markup.';
  String get currentInputSummary => _isPt
      ? 'Nome: $customerName | Email: $releaseEmail | Lote: $amount'
      : 'Name: $customerName | Email: $releaseEmail | Batch: $amount';

  String get advancedInputSummary => _isPt
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
      return _isPt
          ? 'Periodo parcial ou nao definido'
          : 'Partial or undefined range';
    }

    return _isPt
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
