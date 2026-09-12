import 'dart:async';
import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

/// Todos os overlays da biblioteca, prontos para abrir de dentro de qualquer
/// contêiner.
///
/// O mesmo kit é montado solto na página, dentro de um modal, de um segundo
/// modal empilhado, de um offcanvas e de um modal aberto sobre um offcanvas.
/// Se um overlay renderiza certo em um lugar e errado em outro, a diferença
/// está no contêiner — e é exatamente isso que a página quer mostrar.
///
/// Cada instância mede sozinha o que `LiOverlayStack.resolve` devolveria para
/// um overlay ancorado nela, então a faixa de diagnóstico no topo diz qual
/// contêiner bloqueante a envolve e a que z-index um menu, um tooltip e um
/// picker abertos daqui vão subir.
@Component(
  selector: 'overlay-lab-kit',
  templateUrl: 'overlay_lab_kit_component.html',
  styleUrls: ['overlay_lab_kit_component.css'],
  directives: [
    coreDirectives,
    formDirectives,
    LiColorPickerComponent,
    LiDataTableComponent,
    LiDatatableSelectComponent,
    LiDatePickerComponent,
    LiDateRangePickerComponent,
    LiDropdownDirective,
    LiDropdownToggleDirective,
    LiDropdownMenuDirective,
    LiDropdownItemDirective,
    LiDropdownButtonItemDirective,
    LiDropdownMenuComponent,
    LiDropdownMenuPositionDirective,
    LiMultiSelectComponent,
    LiPopoverComponent,
    LiSelectComponent,
    LiTagFilterComponent,
    LiTimePickerComponent,
    LiTokenFieldComponent,
    LiTooltipDirective,
    LiTreeviewSelectComponent,
    LiTypeaheadComponent,
  ],
)
class OverlayLabKitComponent implements AfterViewInit, OnDestroy {
  OverlayLabKitComponent(this.i18n, this._root) {
    arvore = _montarArvore();
    tabelaSettings = _montarTabela();
  }

  final DemoI18nService i18n;
  final html.Element _root;
  bool get _isPt => i18n.isPortuguese;

  /// Nome do contêiner que envolve esta instância, para o registro da página.
  @Input()
  String host = '';

  /// Chave estável do contêiner, para os testes de navegador acharem a
  /// instância certa: `[data-host="modal"] [data-label="li_select_toggle"]`.
  @Input()
  String hostKey = 'page';

  /// A página é dona do `li-toast-stack`; o kit só dispara nele.
  @Input()
  LiToastService? toastService;

  /// Idem para o `li-notification-outlet`.
  @Input()
  LiNotificationToastService? notificationService;

  final StreamController<String> _logCtrl =
      StreamController<String>.broadcast();

  /// O que acabou de acontecer, para a página mostrar num lugar só.
  @Output()
  Stream<String> get logged => _logCtrl.stream;

  @ViewChild('blocoCortina')
  html.Element? blocoCortina;

  Timer? _medicaoInicial;

  // ---------------------------------------------------------------------------
  // Diagnóstico: o que LiOverlayStack.resolve devolve para quem abre daqui.
  // ---------------------------------------------------------------------------

  String conteinerBloqueante = '';
  int? zDoConteiner;
  int zMenu = 0;
  int zTooltip = 0;
  int zPicker = 0;
  int zAncorado = 0;

  void medir() {
    final owner = LiOverlayStack.owningBlockingContainer(_root);
    conteinerBloqueante = _nomeDoConteiner(owner);
    zDoConteiner = _zIndexDe(owner);
    zAncorado = LiOverlayStack.resolve(
      referenceElement: _root,
      baseZIndex: LiOverlayLayers.anchored,
    );
    zMenu = LiOverlayStack.resolve(
      referenceElement: _root,
      baseZIndex: LiOverlayLayers.anchoredMenu,
    );
    zTooltip = LiOverlayStack.resolve(
      referenceElement: _root,
      baseZIndex: LiOverlayLayers.anchoredTooltip,
    );
    zPicker = LiOverlayStack.resolve(
      referenceElement: _root,
      baseZIndex: LiOverlayLayers.anchoredPicker,
    );
  }

  String _nomeDoConteiner(html.Element? owner) {
    if (owner == null) {
      return _isPt ? 'nenhum' : 'none';
    }
    if (owner.matches('.li-offcanvas-shell')) {
      return 'li-offcanvas';
    }
    if (owner.matches('[data-li-simple-dialog="true"]')) {
      return 'LiSimpleDialog';
    }
    if (owner.matches('.swal2-container')) {
      return 'SweetAlert';
    }
    if (owner.matches('.modal')) {
      return 'li-modal';
    }
    return owner.tagName.toLowerCase();
  }

  int? _zIndexDe(html.Element? element) {
    if (element == null) {
      return null;
    }
    return int.tryParse(element.style.zIndex) ??
        int.tryParse(element.getComputedStyle().zIndex);
  }

  String get diagnosticoResumo {
    final owner = zDoConteiner == null
        ? conteinerBloqueante
        : '$conteinerBloqueante (z-index $zDoConteiner)';
    return _isPt
        ? 'Contêiner bloqueante em volta: $owner.'
        : 'Blocking container around: $owner.';
  }

  @override
  void ngAfterViewInit() {
    remedir();
  }

  /// Mede de novo daqui a pouco.
  ///
  /// O conteúdo projetado num `li-modal` ou `li-offcanvas` é criado junto com
  /// a página — `lazyContent` só adia a inserção no DOM — então esta instância
  /// nasce solta, sem contêiner em volta, e só ganha um quando o contêiner
  /// abre e o move para dentro. A página chama isto no `(open)` de cada um;
  /// o atraso dá tempo de o nó ser inserido e de o contêiner marcar
  /// `data-status="open"`.
  void remedir() {
    _medicaoInicial?.cancel();
    _medicaoInicial = Timer(const Duration(milliseconds: 350), medir);
  }

  @override
  void ngOnDestroy() {
    _medicaoInicial?.cancel();
    _logCtrl.close();
  }

  // ---------------------------------------------------------------------------
  // Registro
  // ---------------------------------------------------------------------------

  void _registrar(String overlay, int camada) {
    final onde = host.isEmpty ? hostKey : host;
    _logCtrl.add(_isPt
        ? '$overlay em "$onde" — camada base $camada, contêiner bloqueante: '
            '$conteinerBloqueante.'
        : '$overlay in "$onde" — base layer $camada, blocking container: '
            '$conteinerBloqueante.');
  }

  // ---------------------------------------------------------------------------
  // Menus e listas
  // ---------------------------------------------------------------------------

  final List<Map<String, dynamic>> opcoesStatus = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'draft', 'label': 'Rascunho'},
    <String, dynamic>{'id': 'review', 'label': 'Em revisão'},
    <String, dynamic>{'id': 'approved', 'label': 'Aprovado'},
    <String, dynamic>{'id': 'archived', 'label': 'Arquivado'},
  ];
  dynamic statusEscolhido = 'review';

  final List<Map<String, dynamic>> opcoesCanais = <Map<String, dynamic>>[
    <String, dynamic>{'id': 'email', 'label': 'E-mail'},
    <String, dynamic>{'id': 'push', 'label': 'Push'},
    <String, dynamic>{'id': 'sms', 'label': 'SMS'},
    <String, dynamic>{'id': 'portal', 'label': 'Portal'},
  ];
  List<dynamic> canaisEscolhidos = <dynamic>['email'];

  final List<String> cidades = <String>[
    'Belo Horizonte',
    'Brasília',
    'Curitiba',
    'Florianópolis',
    'Fortaleza',
    'Manaus',
    'Porto Alegre',
    'Recife',
    'Rio de Janeiro',
    'Salvador',
    'São Paulo',
    'Vitória',
  ];
  dynamic cidadeEscolhida;

  late final List<TreeViewNode> arvore;
  dynamic noEscolhido;

  final List<Map<String, dynamic>> etiquetas = <Map<String, dynamic>>[
    <String, dynamic>{'id': 1, 'nome': 'Financeiro', 'cor': '#0c83ff'},
    <String, dynamic>{'id': 2, 'nome': 'Sigiloso', 'cor': '#ef4444'},
    <String, dynamic>{'id': 3, 'nome': 'Prioridade alta', 'cor': '#f59e0b'},
    <String, dynamic>{'id': 4, 'nome': 'Jurídico', 'cor': '#10b981'},
  ];
  List<dynamic> etiquetasEscolhidas = <dynamic>[2];

  /// Montada uma vez: um getter que devolvesse uma lista nova a cada ciclo
  /// faria o `ngFor` do menu recriar os itens em todo change detection.
  late final List<LiDropdownMenuOption> opcoesDoMenu = <LiDropdownMenuOption>[
    LiDropdownMenuOption(
      value: 'open',
      label: _isPt ? 'Abrir' : 'Open',
      iconClass: 'ph-eye',
    ),
    LiDropdownMenuOption(
      value: 'edit',
      label: _isPt ? 'Editar' : 'Edit',
      iconClass: 'ph-pencil',
    ),
    LiDropdownMenuOption(
      value: 'share',
      label: _isPt ? 'Compartilhar' : 'Share',
      iconClass: 'ph-share-network',
    ),
    LiDropdownMenuOption(
      value: 'archive',
      label: _isPt ? 'Arquivar' : 'Archive',
      iconClass: 'ph-archive',
    ),
  ];
  String acaoDoMenu = '';

  /// O menu de ações do token field é um `li-dropdown-menu` em container
  /// "body", portalado como os outros — só que aberto de dentro de um campo.
  List<String> codigosDeProcesso = <String>['2026.00341', '2026.00342'];
  String get placeholderCodigos =>
      _isPt ? 'Cole ou digite códigos' : 'Paste or type codes';

  void aoEscolherNoMenu(String valor) {
    acaoDoMenu = valor;
    _registrar('li-dropdown-menu', LiOverlayLayers.anchoredMenu);
  }

  static List<TreeViewNode> _montarArvore() {
    final atendimento = TreeViewNode(
      treeViewNodeLabel: 'Atendimento',
      treeViewNodeLevel: 0,
      value: 'atendimento',
    )
      ..addChild(TreeViewNode(
        treeViewNodeLabel: 'Triagem',
        treeViewNodeLevel: 1,
        value: 'triagem',
      ))
      ..addChild(TreeViewNode(
        treeViewNodeLabel: 'Encaminhamentos',
        treeViewNodeLevel: 1,
        value: 'encaminhamentos',
      ));

    final beneficios = TreeViewNode(
      treeViewNodeLabel: 'Benefícios',
      treeViewNodeLevel: 0,
      value: 'beneficios',
    )
      ..addChild(TreeViewNode(
        treeViewNodeLabel: 'Cesta básica',
        treeViewNodeLevel: 1,
        value: 'cesta-basica',
      ))
      ..addChild(TreeViewNode(
        treeViewNodeLabel: 'Auxílio moradia',
        treeViewNodeLevel: 1,
        value: 'auxilio-moradia',
      ));

    return <TreeViewNode>[atendimento, beneficios];
  }

  // ---------------------------------------------------------------------------
  // Datatable com menu de excedente (DatatableActionOverflowPortal)
  // ---------------------------------------------------------------------------

  final Filters tabelaFiltro = Filters(limit: 5, offset: 0);
  late final DatatableSettings tabelaSettings;
  final DataFrame<Map<String, dynamic>> tabelaDados =
      DataFrame<Map<String, dynamic>>(
    items: <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'protocolo': '2026.00341',
        'assunto': 'Renovação de alvará',
      },
      <String, dynamic>{
        'id': 2,
        'protocolo': '2026.00342',
        'assunto': 'Pedido de vista',
      },
      <String, dynamic>{
        'id': 3,
        'protocolo': '2026.00343',
        'assunto': 'Recurso administrativo',
      },
    ],
    totalRecords: 3,
  );
  String acaoDaTabela = '';

  DatatableSettings _montarTabela() {
    return DatatableSettings(
      colsDefinitions: <DatatableCol>[
        DatatableCol(key: 'protocolo', title: 'Protocolo', width: '130px'),
        DatatableCol(key: 'assunto', title: _isPt ? 'Assunto' : 'Subject'),
        DatatableActionColumn(
          key: 'acoes',
          title: _isPt ? 'Ações' : 'Actions',
          maxVisibleActions: 1,
          overflowButtonTitle: _isPt ? 'Mais ações' : 'More actions',
          actions: <DatatableAction>[
            DatatableAction(
              label: _isPt ? 'Abrir' : 'Open',
              iconClass: 'ph ph-eye',
              appearance: DatatableActionAppearance.linkIcon,
              iconOnly: true,
              onTap: (ctx) => _aoAgirNaTabela(_isPt ? 'Abrir' : 'Open', ctx),
            ),
            DatatableAction(
              label: _isPt ? 'Despachar' : 'Dispatch',
              iconClass: 'ph ph-note-pencil',
              onTap: (ctx) =>
                  _aoAgirNaTabela(_isPt ? 'Despachar' : 'Dispatch', ctx),
            ),
            DatatableAction(
              label: _isPt ? 'Anexar arquivo' : 'Attach file',
              iconClass: 'ph ph-paperclip',
              onTap: (ctx) => _aoAgirNaTabela(
                _isPt ? 'Anexar arquivo' : 'Attach file',
                ctx,
              ),
            ),
            DatatableAction(
              label: _isPt ? 'Etiquetas' : 'Tags',
              iconClass: 'ph ph-tag',
              onTap: (ctx) =>
                  _aoAgirNaTabela(_isPt ? 'Etiquetas' : 'Tags', ctx),
            ),
          ],
        ),
      ],
    );
  }

  void _aoAgirNaTabela(String acao, DatatableActionContext ctx) {
    acaoDaTabela = '$acao — ${ctx.itemMap['protocolo']}';
    _registrar('li-datatable overflow', LiOverlayLayers.anchoredMenu);
  }

  void aoPedirDadosDaTabela(Filters _) {
    // Os dados são estáticos; a tabela não tem o que recarregar.
  }

  // ---------------------------------------------------------------------------
  // Datatable select: abre um li-modal próprio — dentro de um modal, vira
  // modal empilhado; dentro do offcanvas, modal sobre offcanvas.
  // ---------------------------------------------------------------------------

  final Filters selecaoFiltro = Filters(limit: 5, offset: 0);
  late final DatatableSettings selecaoSettings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'nome', title: _isPt ? 'Nome' : 'Name'),
      DatatableCol(key: 'setor', title: _isPt ? 'Setor' : 'Sector', width: '160px'),
    ],
  );
  final DataFrame<Map<String, dynamic>> selecaoDados =
      DataFrame<Map<String, dynamic>>(
    items: <Map<String, dynamic>>[
      <String, dynamic>{'id': 1, 'nome': 'Ana Souza', 'setor': 'Triagem'},
      <String, dynamic>{'id': 2, 'nome': 'Bruno Lima', 'setor': 'Benefícios'},
      <String, dynamic>{'id': 3, 'nome': 'Carla Nunes', 'setor': 'Jurídico'},
      <String, dynamic>{'id': 4, 'nome': 'Diego Alves', 'setor': 'Atendimento'},
    ],
    totalRecords: 4,
  );
  late final List<DatatableSearchField> selecaoCampos = <DatatableSearchField>[
    DatatableSearchField(
      selected: true,
      label: _isPt ? 'Nome' : 'Name',
      field: 'nome',
      operator: 'ilike',
    ),
  ];
  dynamic pessoaEscolhida;

  String get tituloDaSelecao =>
      _isPt ? 'Escolha uma pessoa' : 'Pick a person';
  String get placeholderDaSelecao =>
      _isPt ? 'Selecionar pessoa' : 'Select a person';

  void aoEscolherPessoa(dynamic valor) {
    pessoaEscolhida = valor;
    _registrar('li-datatable-select', LiOverlayLayers.modal);
  }

  // ---------------------------------------------------------------------------
  // Pickers
  // ---------------------------------------------------------------------------

  DateTime? dataEscolhida = DateTime(2026, 9, 11);
  DateTime? inicioDoPeriodo = DateTime(2026, 9, 1);
  DateTime? fimDoPeriodo = DateTime(2026, 9, 15);
  Duration? horaEscolhida = const Duration(hours: 14, minutes: 30);
  String? corEscolhida = '#27ADCA';

  // ---------------------------------------------------------------------------
  // Dicas e avisos ancorados
  // ---------------------------------------------------------------------------

  String get textoDoTooltip => _isPt
      ? 'Tooltip em container="body". Deve ficar acima do contêiner que o contém.'
      : 'Tooltip with container="body". It has to sit above its container.';

  String get tituloDoPopover => _isPt ? 'Popover ancorado' : 'Anchored popover';
  String get textoDoPopover => _isPt
      ? 'li-popover em container="body", aberto de dentro deste contêiner.'
      : 'li-popover with container="body", opened from inside this container.';

  void mostrarPopoverSimples(html.Element alvo) {
    LiSimplePopover.showWarning(
      alvo,
      _isPt
          ? 'LiSimplePopover nasce em anchoredMenu e sobe pelo contêiner.'
          : 'LiSimplePopover is born at anchoredMenu and clears the container.',
      title: _isPt ? 'Aviso ancorado' : 'Anchored warning',
    );
    _registrar('LiSimplePopover', LiOverlayLayers.anchoredMenu);
  }

  void mostrarPopoverDoAlerta(html.Element alvo) {
    SweetAlertPopover.showPopover(
      alvo,
      _isPt
          ? 'SweetAlertPopover, o popover do SweetAlert, ancorado aqui.'
          : 'SweetAlertPopover, the SweetAlert popover, anchored here.',
      title: 'SweetAlertPopover',
    );
    _registrar('SweetAlertPopover', LiOverlayLayers.anchoredMenu);
  }

  // ---------------------------------------------------------------------------
  // Bloqueantes disparados daqui
  // ---------------------------------------------------------------------------

  Future<void> abrirDialogo() async {
    final ok = await LiSimpleDialogComponent.showConfirm(
      _isPt
          ? 'Este diálogo desenha em ${LiOverlayLayers.dialog} e precisa ficar '
              'acima do contêiner de onde foi aberto.'
          : 'This dialog draws at ${LiOverlayLayers.dialog} and has to sit '
              'above the container it was opened from.',
      title: _isPt ? 'Diálogo sobre "$host"' : 'Dialog over "$host"',
      dialogColor: LiDialogColor.PRIMARY,
    );
    _logCtrl.add(_isPt
        ? 'LiSimpleDialog (${LiOverlayLayers.dialog}) sobre "$host": '
            '${ok ? 'confirmado' : 'cancelado'}.'
        : 'LiSimpleDialog (${LiOverlayLayers.dialog}) over "$host": '
            '${ok ? 'confirmed' : 'cancelled'}.');
  }

  Future<void> abrirAlerta() async {
    final resultado = await SweetAlert.confirm(
      title: _isPt ? 'Alerta sobre "$host"' : 'Alert over "$host"',
      message: _isPt
          ? 'O SweetAlert desenha em ${LiOverlayLayers.alert}: acima do modal, '
              'do offcanvas e do diálogo.'
          : 'SweetAlert draws at ${LiOverlayLayers.alert}: above the modal, '
              'the offcanvas and the dialog.',
      type: SweetAlertType.question,
      confirmButtonText: 'OK',
      cancelButtonText: _isPt ? 'Cancelar' : 'Cancel',
    );
    _logCtrl.add(_isPt
        ? 'SweetAlert (${LiOverlayLayers.alert}) sobre "$host": '
            '${resultado.isConfirmed ? 'confirmado' : 'cancelado'}.'
        : 'SweetAlert (${LiOverlayLayers.alert}) over "$host": '
            '${resultado.isConfirmed ? 'confirmed' : 'cancelled'}.');
  }

  void dispararToast() {
    toastService?.show(
      header: _isPt ? 'Toast da pilha' : 'Stack toast',
      body: _isPt
          ? 'li-toast-stack em ${LiOverlayLayers.toastStack}, disparado de "$host".'
          : 'li-toast-stack at ${LiOverlayLayers.toastStack}, fired from "$host".',
      iconClass: 'ph-stack',
      toastClass: 'bg-primary text-white border-0',
      headerClass: 'bg-black bg-opacity-10 text-white',
      delay: 4000,
      pauseOnHover: true,
    );
    _registrar('li-toast-stack', LiOverlayLayers.toastStack);
  }

  void dispararNotificacao() {
    notificationService?.notify(
      _isPt
          ? 'li-notification-toast em ${LiOverlayLayers.notificationToast}, '
              'disparado de "$host".'
          : 'li-notification-toast at ${LiOverlayLayers.notificationToast}, '
              'fired from "$host".',
      title: _isPt ? 'Notificação' : 'Notification',
      type: LiNotificationToastColor.success,
      durationSeconds: 4,
    );
    _registrar('li-notification-toast', LiOverlayLayers.notificationToast);
  }

  void dispararToastSimples() {
    LiSimpleToast.showSuccess(_isPt
        ? 'LiSimpleToast (toast do SweetAlert) disparado de "$host".'
        : 'LiSimpleToast (the SweetAlert toast) fired from "$host".');
    _registrar('LiSimpleToast', LiOverlayLayers.notificationToast);
  }

  /// Cortina só sobre este bloco: cobre o kit e nada além dele.
  Future<void> cortinaNoBloco() async {
    final alvo = blocoCortina;
    if (alvo == null) {
      return;
    }
    final cortina = LiSimpleLoading()..show(target: alvo);
    _registrar('LiSimpleLoading(target)', LiOverlayLayers.loadingTarget);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    } finally {
      cortina.hide();
    }
  }

  /// Cortina na página inteira: acima de tudo, inclusive deste contêiner.
  Future<void> cortinaNaPagina() async {
    final cortina = LiSimpleLoading()..showOnBody();
    _registrar('LiSimpleLoading(body)', LiOverlayLayers.loadingBody);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    } finally {
      cortina.hide();
    }
  }

  // ---------------------------------------------------------------------------
  // Textos
  // ---------------------------------------------------------------------------

  String get tituloMenus => _isPt ? 'Menus e listas' : 'Menus and lists';
  String get tituloPickers => 'Pickers';
  String get tituloDicas =>
      _isPt ? 'Dicas e avisos ancorados' : 'Anchored hints and warnings';
  String get tituloBloqueantes => _isPt
      ? 'Bloqueantes disparados daqui'
      : 'Blocking overlays fired from here';
  String get rotuloMedir => _isPt ? 'Medir de novo' : 'Measure again';
  String get rotuloTooltip => _isPt ? 'Abrir tooltip' : 'Open tooltip';
  String get rotuloPopover => _isPt ? 'Abrir li-popover' : 'Open li-popover';
  String get rotuloCortinaBloco =>
      _isPt ? 'Cortina neste bloco (1,2 s)' : 'Curtain on this block (1.2 s)';
  String get rotuloCortinaPagina =>
      _isPt ? 'Cortina na página (1,2 s)' : 'Curtain on the page (1.2 s)';
  String get placeholderCidade => _isPt ? 'Digite uma cidade' : 'Type a city';
  String get placeholderArvore => _isPt ? 'Escolha um setor' : 'Pick a sector';
  String get placeholderBuscaArvore => _isPt ? 'Buscar' : 'Search';
  String get placeholderEtiquetas =>
      _isPt ? 'Filtrar por etiquetas' : 'Filter by tags';
  String get notaDropdownDiretiva => 'anchoredMenu · container="body"';
  String get notaPopover => 'anchoredTooltip · container="body"';
  String get rotuloUltimaAcao => _isPt ? 'Última ação' : 'Last action';
}
