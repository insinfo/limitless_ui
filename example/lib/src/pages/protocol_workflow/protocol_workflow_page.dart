import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'protocol-workflow-page',
  templateUrl: 'protocol_workflow_page.html',
  styleUrls: ['protocol_workflow_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DemoPageBreadcrumbComponent,
    LiDataTableComponent,
    LiCollapseToggleDirective,
    LiModalComponent,
  ],
)
class ProtocolWorkflowPageComponent implements OnInit {
  ProtocolWorkflowPageComponent() {
    processSettings = DatatableSettings(colsDefinitions: <DatatableCol>[
      DatatableCol(
        key: 'processCode',
        title: 'Código',
        width: '120px',
        responsiveAutoHideRequired: true,
        enableSorting: true,
      ),
      DatatableCol(
        key: 'requester',
        title: 'Requerente',
        minWidth: '220px',
        responsiveAutoHidePriority: 40,
        enableSorting: true,
      ),
      DatatableCol(
        key: 'classification',
        title: 'Classificação',
        responsiveAutoHidePriority: 50,
      ),
      DatatableCol(
        key: 'subject',
        title: 'Assunto',
        minWidth: '200px',
        responsiveAutoHidePriority: 20,
      ),
      DatatableCol(
        key: 'lastActivity',
        title: 'Último andamento',
        format: DatatableFormat.dateTimeShort,
        width: '150px',
        responsiveAutoHidePriority: 30,
      ),
      DatatableCol(
        key: 'digital',
        title: 'Digital',
        width: '90px',
        textAlign: 'center',
        titleTextAlign: 'center',
        customRenderHtml: _renderDigitalBadge,
        responsiveAutoHidePriority: 60,
      ),
      DatatableActionColumn(
        key: 'actions',
        title: 'Ações',
        maxVisibleActions: 1,
        actions: <DatatableAction>[
          DatatableAction(
            overflowBehavior: DatatableActionOverflowBehavior.overflowMenu,
            label: 'Criar despacho',
            iconClass: 'ph ph-scroll',
            iconOnly: true,
            size: 'sm',
            onTap: (context) => createDraft(_asMap(context.itemInstance)),
          ),
          DatatableAction(
            overflowBehavior: DatatableActionOverflowBehavior.overflowMenu,
            label: 'Anexar arquivo',
            iconClass: 'ph ph-paperclip',
            iconOnly: true,
            size: 'sm',
            visibleWhen: (context) =>
                _asMap(context.itemInstance)['digital'] == true,
            onTap: (context) => attachFile(_asMap(context.itemInstance)),
          ),
          DatatableAction(
            overflowBehavior: DatatableActionOverflowBehavior.overflowMenu,
            label: 'Despachos e anexos',
            iconClass: 'ph ph-chat-circle-text',
            iconOnly: true,
            size: 'sm',
            onTap: (context) => openDetails(_asMap(context.itemInstance)),
          ),
          DatatableAction(
            overflowBehavior: DatatableActionOverflowBehavior.alwaysVisible,
            label: 'Consultar processo',
            iconClass: 'ph ph-eye',
            iconOnly: true,
            size: 'sm',
            onTap: (context) => inspectProcess(_asMap(context.itemInstance)),
          ),
        ],
      ),
    ]);

    dispatchSettings = DatatableSettings(colsDefinitions: <DatatableCol>[
      DatatableCol(
        key: 'id',
        title: 'ID',
        width: '70px',
        responsiveAutoHideRequired: true,
      ),
      DatatableCol(
        key: 'title',
        title: 'Título',
        responsiveAutoHidePriority: 10,
        customRenderString: (itemMap, itemInstance) {
          final title = itemMap['title']?.toString().trim() ?? '';
          return title.isEmpty ? '-' : title;
        },
      ),
      DatatableCol(
        key: 'timestamp',
        title: 'Data/Hora',
        format: DatatableFormat.dateTimeShort,
        responsiveAutoHidePriority: 20,
      ),
      DatatableCol(
        key: 'userName',
        title: 'Usuário',
        customRenderHtml: (itemMap, itemInstance) => _textSpan(
          itemMap['userName']?.toString() ?? '-',
          title: itemMap['userFullName']?.toString(),
        ),
        responsiveAutoHidePriority: 30,
      ),
      DatatableCol(
        key: 'status',
        title: 'Status',
        hideOnMobile: true,
        customRenderHtml: _renderStatusBadge,
        responsiveAutoHidePriority: 35,
      ),
      DatatableCol(
        key: 'signatureStatus',
        title: 'Assinatura',
        customRenderHtml: _renderSignatureBadge,
        responsiveAutoHidePriority: 40,
      ),
      DatatableCol(
        key: 'accessLevel',
        title: 'Nível de acesso',
        responsiveAutoHidePriority: 50,
      ),
      DatatableActionColumn(
        key: 'actions',
        title: 'Ações',
        maxVisibleActions: 2,
        actions: <DatatableAction>[
          DatatableAction(
            overflowBehavior: DatatableActionOverflowBehavior.alwaysVisible,
            label: 'Visualizar despacho',
            iconClass: 'ph ph-eye',
            iconOnly: true,
            size: 'sm',
            onTap: (context) => viewDispatch(_asMap(context.itemInstance)),
          ),
          DatatableAction(
            label: 'Painel de assinaturas',
            iconClass: 'ph ph-signature',
            iconOnly: true,
            size: 'sm',
            visibleWhen: (context) =>
                _asMap(context.itemInstance)['status'] == 'Finalizado',
            onTap: (context) => openSignaturePanel(
              'Despacho ${_asMap(context.itemInstance)['id']}',
            ),
          ),
          DatatableAction(
            overflowBehavior: DatatableActionOverflowBehavior.overflowMenu,
            label: 'Editar rascunho',
            iconClass: 'ph ph-pencil',
            iconOnly: true,
            size: 'sm',
            visibleWhen: (context) =>
                _asMap(context.itemInstance)['status'] == 'Rascunho',
            onTap: (context) => editDraft(_asMap(context.itemInstance)),
          ),
          DatatableAction(
            overflowBehavior: DatatableActionOverflowBehavior.overflowMenu,
            label: 'Excluir rascunho',
            iconClass: 'ph ph-trash',
            iconOnly: true,
            size: 'sm',
            visibleWhen: (context) =>
                _asMap(context.itemInstance)['status'] == 'Rascunho',
            onTap: (context) => removeDraft(_asMap(context.itemInstance)),
          ),
        ],
      ),
    ]);

    attachmentSettings = DatatableSettings(colsDefinitions: <DatatableCol>[
      DatatableCol(
        key: 'id',
        title: 'ID',
        width: '70px',
        responsiveAutoHideRequired: true,
      ),
      DatatableCol(
        key: 'documentType',
        title: 'Tipo Documento',
        responsiveAutoHidePriority: 20,
      ),
      DatatableCol(
        key: 'description',
        title: 'Descrição',
        minWidth: '220px',
        responsiveAutoHidePriority: 10,
      ),
      DatatableCol(
        key: 'createdAt',
        title: 'Data/Hora',
        format: DatatableFormat.dateTimeShort,
        hideOnMobile: true,
        responsiveAutoHidePriority: 30,
      ),
      DatatableCol(
        key: 'status',
        title: 'Status',
        hideOnMobile: true,
        customRenderHtml: _renderStatusBadge,
        responsiveAutoHidePriority: 40,
      ),
      DatatableCol(
        key: 'signatureStatus',
        title: 'Assinatura',
        customRenderHtml: _renderAttachmentSignatureBadge,
        responsiveAutoHidePriority: 50,
      ),
      DatatableActionColumn(
        key: 'actions',
        title: 'Ações',
        maxVisibleActions: 2,
        actions: <DatatableAction>[
          DatatableAction(
            overflowBehavior: DatatableActionOverflowBehavior.alwaysVisible,
            label: 'Visualizar anexo',
            iconClass: 'ph ph-eye',
            iconOnly: true,
            size: 'sm',
            onTap: (context) => openAttachment(_asMap(context.itemInstance)),
          ),
          DatatableAction(
            label: 'Painel de assinaturas',
            iconClass: 'ph ph-signature',
            iconOnly: true,
            size: 'sm',
            visibleWhen: (context) =>
                _asMap(context.itemInstance)['status'] == 'Finalizado',
            onTap: (context) => openSignaturePanel(
              'Anexo ${_asMap(context.itemInstance)['id']}',
            ),
          ),
          DatatableAction(
            overflowBehavior: DatatableActionOverflowBehavior.overflowMenu,
            label: 'Finalizar rascunho',
            iconClass: 'ph ph-check',
            iconOnly: true,
            size: 'sm',
            visibleWhen: (context) =>
                _asMap(context.itemInstance)['status'] == 'Rascunho',
            onTap: (context) =>
                finalizeAttachment(_asMap(context.itemInstance)),
          ),
          DatatableAction(
            overflowBehavior: DatatableActionOverflowBehavior.overflowMenu,
            label: 'Excluir rascunho',
            iconClass: 'ph ph-trash',
            iconOnly: true,
            size: 'sm',
            visibleWhen: (context) =>
                _asMap(context.itemInstance)['status'] == 'Rascunho',
            onTap: (context) => removeDraft(_asMap(context.itemInstance)),
          ),
        ],
      ),
    ]);
  }

  @ViewChild('detailsModal')
  LiModalComponent? detailsModal;

  @ViewChild('dispatchViewerModal')
  LiModalComponent? dispatchViewerModal;

  @ViewChild('signaturePanelModal')
  LiModalComponent? signaturePanelModal;

  @ViewChild('previewModal')
  LiModalComponent? previewModal;

  final Filters processFilters = Filters(limit: 12, offset: 0);
  final Filters dispatchFilters = Filters(limit: 12, offset: 0);
  final Filters attachmentFilters = Filters(limit: 12, offset: 0);
  final List<int> limitPerPageOptions = <int>[5, 12, 20, 50];
  final List<DatatableSearchField> searchFields = <DatatableSearchField>[
    DatatableSearchField(
      field: 'processCode',
      operator: 'like',
      label: 'Nº Processo',
    ),
    DatatableSearchField(
      field: 'requester',
      operator: 'like',
      label: 'Requerente',
    ),
    DatatableSearchField(
      field: 'subject',
      operator: 'like',
      label: 'Assunto',
    ),
  ];

  late final DatatableSettings processSettings;
  late final DatatableSettings dispatchSettings;
  late final DatatableSettings attachmentSettings;
  DataFrame<Map<String, dynamic>> processData = DataFrame.newClear();
  DataFrame<Map<String, dynamic>> dispatchData = DataFrame.newClear();
  DataFrame<Map<String, dynamic>> attachmentData = DataFrame.newClear();
  Map<String, dynamic>? selectedProcess;
  Map<String, dynamic>? selectedDispatch;
  String selectedTab = 'dispatches';
  String lastAction = 'Aguardando seleção de processo.';
  String signaturePanelTitle = 'Painel de assinaturas';
  String previewTitle = 'Documento';
  String? previewUrl;

  final List<Map<String, dynamic>> _processes = <Map<String, dynamic>>[
    <String, dynamic>{
      'processCode': '40596/2012',
      'requester': 'Isaque Neves Sant Ana',
      'classification': 'Requerimento',
      'subject': 'Solicitação, faz',
      'lastActivity': DateTime(2026, 5, 6, 20),
      'currentStep': 4,
      'digital': true,
    },
    <String, dynamic>{
      'processCode': '38506/2011',
      'requester': 'Marcos Henrique da Silva',
      'classification': 'Promoção vertical',
      'subject': 'Revisão funcional',
      'lastActivity': DateTime(2017, 1, 27),
      'currentStep': 9,
      'digital': false,
    },
    <String, dynamic>{
      'processCode': '36117/2011',
      'requester': 'Jorgina Maria Araujo da Silva',
      'classification': 'Solicitação',
      'subject': 'Atendimento administrativo',
      'lastActivity': DateTime(2017, 1, 27),
      'currentStep': 7,
      'digital': false,
    },
    <String, dynamic>{
      'processCode': '39326/2012',
      'requester': 'Secretaria de Gestão de Pessoas',
      'classification': 'Encaminhamento',
      'subject': 'Análise de pessoal',
      'lastActivity': DateTime(2017, 1, 27),
      'currentStep': 13,
      'digital': true,
    },
    <String, dynamic>{
      'processCode': '33512/2012',
      'requester': 'Vanderlea Moreira Jorge Duarte',
      'classification': 'Solicitação',
      'subject': 'Cadastro e documentos',
      'lastActivity': DateTime(2017, 1, 27),
      'currentStep': 2,
      'digital': false,
    },
    <String, dynamic>{
      'processCode': '33507/2012',
      'requester': 'Erenice Pinheiro Ferreira Nagibe',
      'classification': 'Solicitação',
      'subject': 'Revisão cadastral',
      'lastActivity': DateTime(2017, 1, 27),
      'currentStep': 6,
      'digital': true,
    },
  ];

  final List<Map<String, dynamic>> _dispatches = <Map<String, dynamic>>[
    <String, dynamic>{
      'processCode': '40596/2012',
      'id': 4424750,
      'title': '',
      'timestamp': DateTime(2026, 5, 6, 20),
      'userName': 'isaque.santana',
      'userFullName': 'Isaque Neves Sant Ana',
      'status': 'Rascunho',
      'signatureStatus': 'none',
      'accessLevel': 'Público interno',
      'body':
          'Minuta em rascunho para validar ações, colunas responsivas e detalhe expandido.',
    },
    <String, dynamic>{
      'processCode': '40596/2012',
      'id': 4388542,
      'title': '',
      'timestamp': DateTime(2026, 3, 19, 16, 16),
      'userName': 'tauana.nunes',
      'userFullName': 'Tauana Nunes',
      'status': 'Finalizado',
      'signatureStatus': 'signed',
      'accessLevel': 'Público interno',
      'body': 'Despacho finalizado com assinatura interna concluída.',
    },
    <String, dynamic>{
      'processCode': '40596/2012',
      'id': 4388458,
      'title': '',
      'timestamp': DateTime(2026, 3, 19, 15, 41),
      'userName': 'tauana.nunes',
      'userFullName': 'Tauana Nunes',
      'status': 'Finalizado',
      'signatureStatus': 'pending',
      'accessLevel': 'Público interno',
      'body': 'Despacho finalizado aguardando assinatura.',
    },
    <String, dynamic>{
      'processCode': '39326/2012',
      'id': 4387001,
      'title': 'Encaminhamento interno',
      'timestamp': DateTime(2026, 4, 12, 11, 5),
      'userName': 'operacao.demo',
      'userFullName': 'Operação Demo',
      'status': 'Finalizado',
      'signatureStatus': 'none',
      'accessLevel': 'Público interno',
      'body': 'Encaminhamento registrado para análise da unidade destino.',
    },
  ];

  final List<Map<String, dynamic>> _attachments = <Map<String, dynamic>>[
    <String, dynamic>{
      'processCode': '40596/2012',
      'id': 90021,
      'documentType': 'Requerimento',
      'description': 'requerimento_assinado.pdf',
      'createdAt': DateTime(2026, 5, 6, 20, 4),
      'status': 'Finalizado',
      'signatureStatus': 'Interno',
      'url': 'demo://documento/90021',
    },
    <String, dynamic>{
      'processCode': '40596/2012',
      'id': 90022,
      'documentType': 'Documento comprobatório',
      'description': 'comprovante.pdf',
      'createdAt': DateTime(2026, 5, 6, 20, 8),
      'status': 'Rascunho',
      'signatureStatus': 'Não',
      'url': 'demo://documento/90022',
    },
    <String, dynamic>{
      'processCode': '39326/2012',
      'id': 90031,
      'documentType': 'Memorando',
      'description': 'memorando_pessoal.pdf',
      'createdAt': DateTime(2026, 4, 12, 12, 5),
      'status': 'Finalizado',
      'signatureStatus': 'Externo',
      'url': 'demo://documento/90031',
    },
  ];

  bool get isDispatchTab => selectedTab == 'dispatches';
  bool get isAttachmentTab => selectedTab == 'attachments';
  bool get hasNoDispatches => dispatchData.items.isEmpty;
  bool get hasNoAttachments => attachmentData.items.isEmpty;
  String get selectedProcessCode =>
      selectedProcess?['processCode']?.toString() ?? '-';
  String get currentStepLabel =>
      selectedProcess?['currentStep']?.toString() ?? '-';
  String get dispatchViewerTitle =>
      'Visualizar despacho ${selectedDispatch?['id'] ?? ''}'.trim();
  String get dispatchViewerBody =>
      selectedDispatch?['body']?.toString() ?? 'Documento não disponível.';

  @override
  void ngOnInit() {
    _loadProcesses();
  }

  void onProcessRequest(Filters nextFilters) {
    processFilters.fillFromFilters(nextFilters);
    _loadProcesses();
  }

  void onDispatchRequest(Filters nextFilters) {
    dispatchFilters.fillFromFilters(nextFilters);
    _loadDetails();
  }

  void onAttachmentRequest(Filters nextFilters) {
    attachmentFilters.fillFromFilters(nextFilters);
    _loadDetails();
  }

  void openDetails(Map<String, dynamic> process, [String tab = 'dispatches']) {
    selectedProcess = process;
    selectedTab = tab;
    dispatchFilters.offset = 0;
    attachmentFilters.offset = 0;
    _loadDetails();
    detailsModal?.open();
    lastAction =
        'Modal de andamento aberto para o processo $selectedProcessCode.';
  }

  void selectTab(String tab) {
    if (selectedTab == tab) {
      return;
    }
    selectedTab = tab;
    _loadDetails();
  }

  void reloadDetails() {
    _loadDetails();
    lastAction = 'Dados do andamento atual recarregados.';
  }

  void createDraft(Map<String, dynamic> process) {
    lastAction = 'Novo despacho iniciado para ${process['processCode']}.';
  }

  void attachFile(Map<String, dynamic> process) {
    selectedProcess = process;
    openDetails(process, 'attachments');
    lastAction = 'Fluxo de anexo simulado para ${process['processCode']}.';
  }

  void inspectProcess(Map<String, dynamic> process) {
    lastAction = 'Consulta simulada do processo ${process['processCode']}.';
  }

  void viewDispatch(Map<String, dynamic> dispatch) {
    selectedDispatch = dispatch;
    if (dispatch['signatureStatus'] == 'signed') {
      previewTitle = 'Despacho ${dispatch['id']} assinado';
      previewUrl = 'demo://despacho/${dispatch['id']}';
      previewModal?.open();
      return;
    }
    dispatchViewerModal?.open();
  }

  void openAttachment(Map<String, dynamic> attachment) {
    previewTitle = 'Anexo ${attachment['id']} · ${attachment['description']}';
    previewUrl = attachment['url']?.toString();
    previewModal?.open();
  }

  void openSignaturePanel(String targetTitle) {
    signaturePanelTitle = targetTitle;
    signaturePanelModal?.open();
  }

  void editDraft(Map<String, dynamic> item) {
    lastAction = 'Edição do rascunho ${item['id']} simulada.';
  }

  void removeDraft(Map<String, dynamic> item) {
    lastAction = 'Exclusão do rascunho ${item['id']} simulada.';
  }

  void finalizeAttachment(Map<String, dynamic> item) {
    lastAction = 'Finalização do anexo ${item['id']} simulada.';
  }

  void onPreviewClose() {
    previewUrl = null;
  }

  void _loadProcesses() {
    processData = _frameFrom(_filterProcesses(_processes), processFilters);
  }

  void _loadDetails() {
    final code = selectedProcess?['processCode']?.toString();
    if (code == null || code.isEmpty) {
      dispatchData = DataFrame.newClear();
      attachmentData = DataFrame.newClear();
      return;
    }

    dispatchData = _frameFrom(
      _dispatches
          .where((item) => item['processCode'] == code)
          .toList(growable: false),
      dispatchFilters,
    );
    attachmentData = _frameFrom(
      _attachments
          .where((item) => item['processCode'] == code)
          .toList(growable: false),
      attachmentFilters,
    );
  }

  List<Map<String, dynamic>> _filterProcesses(
    List<Map<String, dynamic>> records,
  ) {
    final query = processFilters.searchString?.trim().toLowerCase() ?? '';
    if (query.isEmpty) {
      return records;
    }

    return records.where((record) {
      return <String>[
        record['processCode']?.toString() ?? '',
        record['requester']?.toString() ?? '',
        record['subject']?.toString() ?? '',
      ].any((value) => value.toLowerCase().contains(query));
    }).toList(growable: false);
  }

  DataFrame<Map<String, dynamic>> _frameFrom(
    List<Map<String, dynamic>> records,
    Filters filters,
  ) {
    final offset = filters.offset ?? 0;
    final limit = filters.limit ?? records.length;
    final pageItems = records.skip(offset).take(limit).toList(growable: false);
    return DataFrame<Map<String, dynamic>>(
      items: pageItems,
      totalRecords: records.length,
    );
  }

  static Map<String, dynamic> _asMap(dynamic item) =>
      Map<String, dynamic>.from(item as Map);

  static html.SpanElement _textSpan(String text, {String? title}) {
    final span = html.SpanElement()..text = text;
    final normalizedTitle = title?.trim();
    if (normalizedTitle != null && normalizedTitle.isNotEmpty) {
      span.title = normalizedTitle;
    }
    return span;
  }

  static html.SpanElement _badge(
    String text,
    String classes, {
    String? iconClass,
    String? title,
  }) {
    final badge = html.SpanElement()
      ..classes.addAll(classes.split(' ').where((item) => item.isNotEmpty));
    final normalizedTitle = title?.trim();
    if (normalizedTitle != null && normalizedTitle.isNotEmpty) {
      badge.title = normalizedTitle;
    }

    final normalizedIconClass = iconClass?.trim();
    if (normalizedIconClass != null && normalizedIconClass.isNotEmpty) {
      badge.append(html.Element.tag('i')
        ..classes.addAll(
          normalizedIconClass.split(' ').where((item) => item.isNotEmpty),
        )
        ..classes.add('me-1'));
    }

    badge.appendText(text);
    return badge;
  }

  static html.Element _renderDigitalBadge(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    final digital = itemMap['digital'] == true;
    return _badge(
      digital ? 'Sim' : 'Não',
      digital ? 'badge bg-primary' : 'badge bg-light text-body border',
    );
  }

  static html.Element _renderStatusBadge(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    final status = itemMap['status']?.toString() ?? '-';
    return _badge(
      status.toUpperCase(),
      status == 'Rascunho' ? 'badge bg-warning text-dark' : 'badge bg-primary',
    );
  }

  static html.Element _renderSignatureBadge(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    switch (itemMap['signatureStatus']) {
      case 'signed':
        return _badge(
          'Assinado',
          'badge bg-success',
          iconClass: 'ph ph-seal-check',
        );
      case 'pending':
        return _badge(
          'Pendente',
          'badge bg-secondary',
          iconClass: 'ph ph-hourglass',
        );
      case 'canceled':
        return _badge(
          'Cancelada',
          'badge bg-danger',
          iconClass: 'ph ph-x-circle',
        );
      default:
        return html.SpanElement()
          ..classes.addAll(<String>['text-muted', 'small'])
          ..text = '-';
    }
  }

  static html.Element _renderAttachmentSignatureBadge(
    Map<String, dynamic> itemMap,
    dynamic itemInstance,
  ) {
    final status = itemMap['signatureStatus']?.toString() ?? 'Não';
    if (status == 'Interno') {
      return _badge('Interno', 'badge bg-success');
    }
    if (status == 'Externo') {
      return _badge('Externo', 'badge bg-info');
    }
    return _badge('Não', 'badge bg-secondary');
  }
}
