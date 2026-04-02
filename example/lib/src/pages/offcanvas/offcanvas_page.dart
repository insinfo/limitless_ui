import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'offcanvas-page',
  templateUrl: 'offcanvas_page.html',
  styleUrls: ['offcanvas_page.css'],
  providers: [ClassProvider(LiOffcanvasService)],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    liOffcanvasDirectives,
  ],
)
class OffcanvasPageComponent {
  OffcanvasPageComponent(this.i18n, this.offcanvasService)
      : eventLog = i18n.isPortuguese
            ? 'Abra um exemplo para validar posição, backdrop, foco e lazy content.'
            : 'Open an example to validate position, backdrop, focus, and lazy content.';

  final DemoI18nService i18n;
  final LiOffcanvasService offcanvasService;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  @ViewChild('basicOffcanvas')
  LiOffcanvasComponent? basicOffcanvas;

  @ViewChild('startOffcanvas')
  LiOffcanvasComponent? startOffcanvas;

  @ViewChild('topOffcanvas')
  LiOffcanvasComponent? topOffcanvas;

  @ViewChild('footerOffcanvas')
  LiOffcanvasComponent? footerOffcanvas;

  @ViewChild('noBackdropOffcanvas')
  LiOffcanvasComponent? noBackdropOffcanvas;

  @ViewChild('lazyOffcanvas')
  LiOffcanvasComponent? lazyOffcanvas;

  @ViewChild('guardedOffcanvas')
  LiOffcanvasComponent? guardedOffcanvas;

  @ViewChild('serviceOffcanvas')
  LiOffcanvasComponent? serviceOffcanvas;

  @ViewChild('largeOffcanvas')
  LiOffcanvasComponent? largeOffcanvas;

    final List<String> _reviewStepsPt = <String>[
    'Conferir os filtros ativos antes de abrir a lista lateral.',
    'Revisar contexto adicional sem trocar de rota.',
    'Fechar ao concluir para devolver o foco ao gatilho.',
    ];

    final List<String> _reviewStepsEn = <String>[
    'Check the active filters before opening the side panel.',
    'Review extra context without changing routes.',
    'Close when done to return focus to the trigger.',
    ];

    List<String> get reviewSteps => _isPt ? _reviewStepsPt : _reviewStepsEn;

  String eventLog;
  bool blockGuardDismiss = true;
  LiOffcanvasRef? activeServiceRef;

    String get pageTitle => _isPt ? 'Componentes' : 'Components';
    String get pageSubtitle => 'Offcanvas';
    String get breadcrumb => _isPt
      ? 'Painéis laterais e overlays contextuais'
      : 'Side panels and contextual overlays';
    String get overviewIntro => _isPt
      ? 'O li-offcanvas cobre fluxo declarativo e também uma API de service/ref inspirada no ng-bootstrap: posições start/end/top/bottom, backdrop opcional, beforeDismiss, tamanhos, foco inicial, eventos shown/hidden e lazyContent.'
      : 'li-offcanvas covers the declarative flow and also a service/ref API inspired by ng-bootstrap: start/end/top/bottom positions, optional backdrop, beforeDismiss, sizes, initial focus, shown/hidden events, and lazyContent.';
    String get basicTitle => _isPt ? 'Básico à direita' : 'Basic end panel';
    String get basicBody => _isPt
      ? 'Padrão mais comum para filtros, detalhe de item e navegação auxiliar.'
      : 'Most common pattern for filters, item details, and helper navigation.';
    String get basicButton => _isPt ? 'Abrir offcanvas' : 'Open offcanvas';
    String get startTitle => _isPt ? 'Esquerda com autofocus' : 'Start with autofocus';
    String get startBody => _isPt
      ? 'Move o foco para a ação principal usando [attr.liOffcanvasAutofocus].'
      : 'Moves focus to the main action using [attr.liOffcanvasAutofocus].';
    String get startButton => _isPt ? 'Abrir à esquerda' : 'Open on the left';
    String get topTitle => _isPt ? 'Topo para aviso' : 'Top banner';
    String get topBody => _isPt
      ? 'Bom para avisos largos, consentimento e ações rápidas sem tomar a tela toda.'
      : 'Good for wide notices, consent, and quick actions without taking the whole screen.';
    String get topButton => _isPt ? 'Abrir no topo' : 'Open at the top';
    String get footerTitle => _isPt ? 'Header e footer customizados' : 'Custom header and footer';
    String get footerBody => _isPt
      ? 'Usa slots com liOffcanvasHeader e liOffcanvasFooter.'
      : 'Uses slots with liOffcanvasHeader and liOffcanvasFooter.';
    String get footerButton => _isPt ? 'Abrir customizado' : 'Open custom panel';
    String get noBackdropTitle => _isPt ? 'Sem backdrop' : 'No backdrop';
    String get noBackdropBody => _isPt
      ? 'Mantém a página interativa, útil para painéis auxiliares de baixa fricção.'
      : 'Keeps the page interactive, useful for low-friction helper panels.';
    String get noBackdropButton => _isPt ? 'Abrir sem backdrop' : 'Open without backdrop';
    String get lazyTitle => _isPt ? 'Lazy content' : 'Lazy content';
    String get lazyBody => _isPt
      ? 'Só monta o corpo quando abre, evitando custo inicial de renderização.'
      : 'Builds the body only when opened, avoiding initial render cost.';
    String get lazyButton => _isPt ? 'Abrir lazy' : 'Open lazy panel';
    String get serviceTitle => _isPt ? 'API de serviço/ref' : 'Service/ref API';
    String get serviceBody => _isPt
      ? 'Abre um offcanvas registrado por id usando LiOffcanvasService.open().' 
      : 'Opens an offcanvas registered by id using LiOffcanvasService.open().';
    String get openServiceButton => _isPt ? 'Abrir via service' : 'Open via service';
    String get closeRefButton => _isPt ? 'Fechar via ref' : 'Close via ref';
    String get guardedTitle => 'beforeDismiss';
    String get guardedBody => _isPt
      ? 'Bloqueia ESC e backdrop até o usuário liberar explicitamente a dispensa.'
      : 'Blocks ESC and backdrop until the user explicitly allows dismissal.';
    String get guardedButton => _isPt ? 'Abrir guardado' : 'Open guarded panel';
    String get largeTitle => _isPt ? 'Tamanho grande' : 'Large size';
    String get largeBody => _isPt
      ? 'Demonstra o input size para painéis de revisão com mais densidade.'
      : 'Demonstrates the size input for denser review panels.';
    String get largeButton => _isPt ? 'Abrir tamanho lg' : 'Open large size';
    String get idleEventLog => _isPt
      ? 'Abra um exemplo para validar posição, backdrop, foco e lazy content.'
      : 'Open an example to validate position, backdrop, focus, and lazy content.';
    String get basicPanelTitle => _isPt ? 'Resumo operacional' : 'Operational summary';
    String get basicPanelHeading => _isPt ? 'Quando usar' : 'When to use';
    String get basicPanelBody => _isPt
      ? 'Prefira este formato quando o usuário precisa consultar detalhes ou filtros sem perder o contexto da página principal.'
      : 'Prefer this format when users need to inspect details or filters without losing the main page context.';
    String get startPanelTitle => _isPt ? 'Atalhos rápidos' : 'Quick actions';
    String get startPanelBody => _isPt
      ? 'O primeiro foco vai para a ação marcada logo abaixo.'
      : 'The first focus moves to the main action below.';
    String get primaryActionLabel => _isPt ? 'Ação principal' : 'Primary action';
    String get secondaryActionLabel => _isPt ? 'Ação secundária' : 'Secondary action';
    String get configureLaterLabel => _isPt ? 'Configurar depois' : 'Configure later';
    String get topHeadline => _isPt
      ? 'Janela de manutenção hoje às 22:00'
      : 'Maintenance window today at 10:00 PM';
    String get topPanelBody => _isPt
      ? 'Use o painel superior para anúncios e consentimentos que precisam aparecer em largura total.'
      : 'Use the top panel for announcements and consents that need full-width visibility.';
    String get understoodLabel => _isPt ? 'Entendi' : 'Understood';
    String get laterLabel => _isPt ? 'Depois' : 'Later';
    String get footerPanelTitle => _isPt ? 'Checklist de publicação' : 'Publishing checklist';
    String get footerPanelSubtitle => _isPt
      ? 'Header customizado com duas linhas'
      : 'Custom header with two lines';
    String get footerPanelHeading => _isPt ? 'Corpo do painel' : 'Panel body';
    String get footerPanelBody => _isPt
      ? 'O conteúdo principal continua no fluxo padrão do componente, enquanto o footer fica separado para ações persistentes.'
      : 'The main content stays in the standard component flow while the footer remains separate for persistent actions.';
    String get cancelLabel => _isPt ? 'Cancelar' : 'Cancel';
    String get publishLabel => _isPt ? 'Publicar' : 'Publish';
    String get helperPanelTitle => _isPt ? 'Painel auxiliar' : 'Helper panel';
    String get helperPanelBody => _isPt
      ? 'Com enableBackdrop=false, a tela continua clicável. Este modo funciona melhor para contextos não bloqueantes.'
      : 'With enableBackdrop=false, the screen remains clickable. This mode works best for non-blocking contexts.';
    String get closePanelLabel => _isPt ? 'Fechar painel' : 'Close panel';
    String get lazyPanelTitle => _isPt ? 'Conteúdo lazy sob demanda' : 'Lazy content on demand';
    String get lazyPanelHeading => _isPt ? 'O que este exemplo valida' : 'What this example validates';
    List<String> get lazyChecks => _isPt
      ? const <String>[
        'O corpo só é montado quando o painel abre.',
        'Ao fechar, a subtree projetada é removida.',
        'Fluxos pesados podem entrar aqui sem custo inicial na página.',
      ]
      : const <String>[
        'The body is built only when the panel opens.',
        'When it closes, the projected subtree is removed.',
        'Heavy flows can live here without initial page cost.',
      ];
    String get closeLabel => _isPt ? 'Fechar' : 'Close';
    String get servicePanelTitle => _isPt ? 'Abertura via service' : 'Opened through service';
    String get serviceFlowTitle => _isPt ? 'Fluxo programático' : 'Programmatic flow';
    String get serviceFlowBody => _isPt
      ? 'Este painel foi registrado com offcanvasId e pode ser aberto em qualquer ponto da página usando LiOffcanvasService.'
      : 'This panel was registered with offcanvasId and can be opened anywhere on the page using LiOffcanvasService.';
    String get dismissProgrammaticLabel => _isPt ? 'Dismiss programático' : 'Programmatic dismiss';
    String get guardedPanelTitle => _isPt ? 'Painel com beforeDismiss' : 'Panel with beforeDismiss';
    String get guardedWarning => _isPt
      ? 'ESC e clique no backdrop não fecham enquanto a guarda estiver ativa.'
      : 'ESC and backdrop clicks do not close the panel while the guard is active.';
    String get allowAutoDismissLabel => _isPt ? 'Permitir dismiss automático' : 'Allow automatic dismiss';
    String get tryDismissLabel => _isPt ? 'Tentar dismiss' : 'Try dismiss';
    String get releaseDismissLabel => _isPt ? 'Liberar e dispensar' : 'Release and dismiss';
    String get closeWithoutDismissLabel => _isPt ? 'Fechar sem dismiss' : 'Close without dismiss';
    String get largePanelTitle => _isPt ? 'Revisão editorial completa' : 'Complete editorial review';
    String get xlReasonTitle => _isPt ? 'Por que usar tamanho xl' : 'Why use xl size';
    String get xlReasonBody => _isPt
      ? 'Painéis maiores funcionam melhor para filtros complexos, revisões de conteúdo, tabelas auxiliares e combinações de metadados com ações fixas.'
      : 'Larger panels work better for complex filters, content reviews, helper tables, and metadata combinations with fixed actions.';
    String get monitoredEventsTitle => _isPt ? 'Eventos monitorados' : 'Observed events';
    List<String> get monitoredEvents => _isPt
      ? const <String>[
        'open para início do fluxo',
        'shown quando a transição termina',
        'close para fechamento explícito',
        'dismiss com motivo detalhado',
        'hidden quando o painel já saiu do DOM visível',
      ]
      : const <String>[
        'open for flow start',
        'shown when the transition ends',
        'close for explicit closing',
        'dismiss with a detailed reason',
        'hidden when the panel has left the visible DOM',
      ];
    String get saveReviewLabel => _isPt ? 'Salvar revisão' : 'Save review';

  void openBasic() {
    basicOffcanvas?.open();
    eventLog = _isPt ? 'Offcanvas lateral direito aberto.' : 'Right offcanvas opened.';
  }

  void openStart() {
    startOffcanvas?.open();
    eventLog = _isPt
        ? 'Offcanvas lateral esquerdo aberto com foco inicial.'
        : 'Left offcanvas opened with initial focus.';
  }

  void openTop() {
    topOffcanvas?.open();
    eventLog = _isPt ? 'Top offcanvas opened.' : 'Top offcanvas opened.';
  }

  void openFooter() {
    footerOffcanvas?.open();
    eventLog = _isPt
        ? 'Offcanvas com header/footer customizados aberto.'
        : 'Offcanvas with custom header/footer opened.';
  }

  void openNoBackdrop() {
    noBackdropOffcanvas?.open();
    eventLog = _isPt
        ? 'Offcanvas sem backdrop aberto; a página continua interativa.'
        : 'Backdrop-free offcanvas opened; the page remains interactive.';
  }

  void openLazy() {
    lazyOffcanvas?.open();
    eventLog = _isPt
        ? 'Offcanvas lazy aberto. O conteúdo só entrou no DOM agora.'
        : 'Lazy offcanvas opened. Content has just entered the DOM.';
  }

  void openGuarded() {
    guardedOffcanvas?.open();
    eventLog = _isPt
        ? 'Offcanvas com beforeDismiss aberto.'
        : 'Offcanvas with beforeDismiss opened.';
  }

  void openLarge() {
    largeOffcanvas?.open();
    eventLog = _isPt ? 'Offcanvas largo aberto.' : 'Large offcanvas opened.';
  }

  void openViaService() {
    final ref = offcanvasService.open('service-demo');
    activeServiceRef = ref;
    eventLog = _isPt
      ? 'LiOffcanvasService.open("service-demo") abriu o painel e retornou uma ref reutilizável.'
      : 'LiOffcanvasService.open("service-demo") opened the panel and returned a reusable ref.';
  }

  void closeViaServiceRef() {
    activeServiceRef?.close();
    eventLog = _isPt
        ? 'LiOffcanvasRef.close() acionado pela ref salva no componente.'
        : 'LiOffcanvasRef.close() triggered through the ref saved in the component.';
  }

  Future<bool> guardBeforeDismiss(LiOffcanvasDismissReason reason) async {
    if (!blockGuardDismiss) {
      return true;
    }

    eventLog =
      _isPt
        ? 'beforeDismiss bloqueou a saída por ${reason.name}. Libere manualmente para dispensar.'
        : 'beforeDismiss blocked the exit because of ${reason.name}. Release it manually to dismiss.';
    return false;
  }

  Future<void> forceGuardDismiss() async {
    blockGuardDismiss = false;
    await guardedOffcanvas?.dismiss();
    blockGuardDismiss = true;
  }

  void onShown(String label) {
    eventLog = _isPt
        ? '$label exibido e pronto para interação.'
        : '$label shown and ready for interaction.';
  }

  void onClosed(String label) {
    eventLog = _isPt ? '$label fechado.' : '$label closed.';
  }

  void onHidden(String label) {
    eventLog = _isPt
        ? '$label ocultado e removido do fluxo visível.'
        : '$label hidden and removed from the visible flow.';
  }

  void onDismissed(String label, LiOffcanvasDismissReason reason) {
    eventLog = _isPt
        ? '$label dispensado por ${reason.name}.'
        : '$label dismissed by ${reason.name}.';
  }
}
