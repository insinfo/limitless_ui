import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'sweet-alert-page',
  templateUrl: 'sweet_alert_page.html',
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiHighlightComponent,
    LiSweetAlertDirective,
  ],
  providers: [ClassProvider(SweetAlertService)],
)
class SweetAlertPageComponent {
  SweetAlertPageComponent(this.i18n, this.sweetAlertService);

  final DemoI18nService i18n;
  final SweetAlertService sweetAlertService;
  Messages get t => i18n.t;

  bool get _isPt => i18n.isPortuguese;
  bool get isPt => _isPt;

  String lastAction = '';

  final String _customImageUrl = 'assets/images/1.jpg';
  final String _backgroundImageUrl = 'assets/images/carousel/slide-02.jpg';

  final String angularServiceSnippet =
      '''final result = await sweetAlertService.confirm(
  title: 'Promover release',
  message: 'Deseja publicar esta configuração agora?',
  confirmButtonText: 'Promover',
  cancelButtonText: 'Revisar',
  type: SweetAlertType.question,
);

if (result.isConfirmed) {
  sweetAlertService.toast(
    'Release enviado para produção.',
    type: SweetAlertType.success,
  );
}''';

  final String advancedServiceSnippet =
      '''final environment = await sweetAlertService.prompt(
  title: 'Escolha o ambiente',
  inputType: SweetAlertInputType.select,
  inputOptions: const {
    'prod': 'Produção',
    'staging': 'Homologação',
    'dev': 'Desenvolvimento',
  },
  inputPlaceholder: 'Selecione um ambiente',
  reverseButtons: true,
  width: '38rem',
  confirmButtonText: 'Continuar',
  cancelButtonText: 'Cancelar',
);

await sweetAlertService.show(
  title: 'Publicação preparada',
  message: 'Destino: \${environment.value}',
  type: SweetAlertType.success,
  grow: SweetAlertGrowMode.row,
);''';

  final String callbackSnippet = '''await sweetAlertService.show(
  title: 'Sincronizando widgets',
  message: 'Observe o callback enquanto o popup abre e fecha.',
  type: SweetAlertType.info,
  showCloseButton: true,
  onOpen: (popup) {
    popup.classes.addAll(['border', 'border-primary']);
  },
  onClose: (_) {
    logger.info('SweetAlert fechado');
  },
);''';

  final String staticSnippet = '''SweetAlert.toast(
  'Fallback concluído.',
  type: SweetAlertType.info,
  position: SweetAlertPosition.centerEnd,
  timer: const Duration(seconds: 4),
);

final prompt = await SweetAlert.prompt(
  title: 'Prioridade da fila',
  inputType: SweetAlertInputType.radio,
  inputOptions: const {
    'fast': 'Fast track',
    'normal': 'Normal',
    'safe': 'Safe mode',
  },
);''';

  final String providerSnippet = '''@Component(
  selector: 'review-page',
  providers: [ClassProvider(SweetAlertService)],
)
class ReviewPageComponent {
  ReviewPageComponent(this.sweetAlertService);

  final SweetAlertService sweetAlertService;
}''';

  final String directiveSnippet = '''<button
    class="btn btn-outline-primary"
    type="button"
    liSweetAlert="Atalho declarativo acionado."
    liSweetAlertTitle="SweetAlert directive"
    liSweetAlertType="info"
    liSweetAlertPosition="top-end"
    liSweetAlertWidth="34rem"
    [liSweetAlertReverseButtons]="true"
    (liSweetAlertResult)="handleDirectiveResult(\$event)">
  Trigger declarativo
</button>''';

  String get pageTitle => _isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'SweetAlert';
  String get breadcrumb => _isPt
      ? 'Modais, prompts e toasts imperativos'
      : 'Imperative modals, prompts, and toasts';
  String get intro => _isPt
      ? 'SweetAlert agora tem uma API central única, wrappers legados preservados e uma camada AngularDart melhor resolvida via serviço injetável.'
      : 'SweetAlert now has a single core API, preserved legacy wrappers, and a cleaner AngularDart layer through an injectable service.';
  String get descriptionTitle => _isPt ? 'Base técnica' : 'Technical base';
  String get descriptionBody => _isPt
      ? 'O núcleo SweetAlert continua imperativo porque ele cria overlays globais no body, mas a API pública agora concentra modal, confirmação, prompt e toast no mesmo ponto.'
      : 'The SweetAlert core remains imperative because it creates global body overlays, but the public API now centralizes modal, confirmation, prompt, and toast in one place.';
  String get angularTitle => _isPt ? 'API AngularDart' : 'AngularDart API';
  String get angularBody => _isPt
      ? 'Para uso em componentes AngularDart, o caminho mais estável é injetar SweetAlertService. Isso evita acoplamento direto com chamadas estáticas no template ou no lifecycle.'
      : 'For AngularDart component usage, the most stable path is to inject SweetAlertService. That avoids direct coupling to static calls from templates or lifecycle code.';
  String get guidanceTitle =>
      _isPt ? 'Quando usar diretiva' : 'When to use a directive';
  String get guidanceBody => _isPt
      ? 'Diretiva funciona bem para overlays ancorados como tooltip e popover. Para SweetAlert modal, um serviço é mais idiomático porque a interação normalmente parte de evento de negócio, não do host visual em si.'
      : 'A directive works well for anchored overlays like tooltips and popovers. For SweetAlert modals, a service is more idiomatic because the interaction usually starts from business events, not the visual host itself.';
  String get serviceActionsTitle =>
      _isPt ? 'Ações via serviço' : 'Service-driven actions';
  String get serviceActionsBody => _isPt
      ? 'Os botões abaixo exercitam o fluxo AngularDart recomendado.'
      : 'The buttons below exercise the recommended AngularDart flow.';
  String get visualActionsTitle =>
      _isPt ? 'Variações visuais' : 'Visual variants';
  String get visualActionsBody => _isPt
      ? 'Casos extras para validar backdrop, HTML, timer e posições de toast.'
      : 'Extra cases to validate backdrop, HTML, timer, and toast positions.';
  String get notificationIntro => _isPt
      ? 'A aba replica as famílias principais da página original: tipos de notificação, exemplos básicos e opções visuais.'
      : 'This tab mirrors the main families from the original page: notification types, basic examples, and visual options.';
  String get inputIntro => _isPt
      ? 'Os exemplos abaixo validam inputs nativos, posições centrais/laterais e a variação toast do SweetAlert.'
      : 'The examples below validate native inputs, side/center positions, and the toast variant of SweetAlert.';
  String get apiIntro => _isPt
      ? 'O componente AngularDart não precisa renderizar um host específico. Basta injetar o serviço ou, se preferir, usar a API estática diretamente.'
      : 'The AngularDart component does not need to render a specific host. You can inject the service or call the static API directly if preferred.';
  String get directiveIntro => _isPt
      ? 'Para botões simples, a diretiva opcional encapsula o serviço e remove código repetitivo sem criar uma API paralela.'
      : 'For simple buttons, the optional directive wraps the service and removes repetitive code without creating a parallel API.';
  String get idleState => _isPt
      ? 'SweetAlert: aguardando interação'
      : 'SweetAlert: waiting for interaction';
  String get summaryText => lastAction.isEmpty ? idleState : lastAction;

  void _setLastAction(String pt, String en) {
    lastAction = _isPt ? pt : en;
  }

  SweetAlertType _resolveType(String value) {
    switch (value.trim().toLowerCase()) {
      case 'success':
        return SweetAlertType.success;
      case 'error':
        return SweetAlertType.error;
      case 'warning':
        return SweetAlertType.warning;
      case 'question':
        return SweetAlertType.question;
      case 'info':
      default:
        return SweetAlertType.info;
    }
  }

  SweetAlertPosition _resolvePosition(String value) {
    switch (value.trim().toLowerCase()) {
      case 'top':
        return SweetAlertPosition.top;
      case 'top-left':
      case 'topstart':
      case 'top-start':
        return SweetAlertPosition.topStart;
      case 'top-right':
      case 'topend':
      case 'top-end':
        return SweetAlertPosition.topEnd;
      case 'center-left':
      case 'centerstart':
      case 'center-start':
        return SweetAlertPosition.centerStart;
      case 'center-right':
      case 'centerend':
      case 'center-end':
        return SweetAlertPosition.centerEnd;
      case 'bottom':
        return SweetAlertPosition.bottom;
      case 'bottom-left':
      case 'bottomstart':
      case 'bottom-start':
        return SweetAlertPosition.bottomStart;
      case 'bottom-right':
      case 'bottomend':
      case 'bottom-end':
        return SweetAlertPosition.bottomEnd;
      case 'center':
      default:
        return SweetAlertPosition.center;
    }
  }

  SweetAlertInputType _resolveInputType(String value) {
    switch (value.trim().toLowerCase()) {
      case 'email':
        return SweetAlertInputType.email;
      case 'url':
        return SweetAlertInputType.url;
      case 'password':
        return SweetAlertInputType.password;
      case 'textarea':
        return SweetAlertInputType.textarea;
      case 'select':
        return SweetAlertInputType.select;
      case 'radio':
        return SweetAlertInputType.radio;
      case 'checkbox':
        return SweetAlertInputType.checkbox;
      case 'range':
        return SweetAlertInputType.range;
      case 'number':
        return SweetAlertInputType.number;
      case 'text':
      default:
        return SweetAlertInputType.text;
    }
  }

  SweetAlertGrowMode _resolveGrowMode(String value) {
    switch (value.trim().toLowerCase()) {
      case 'fullscreen':
        return SweetAlertGrowMode.fullscreen;
      case 'column':
        return SweetAlertGrowMode.column;
      case 'row':
      default:
        return SweetAlertGrowMode.row;
    }
  }

  String _typeLabel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'success':
        return _isPt ? 'sucesso' : 'success';
      case 'error':
        return _isPt ? 'erro' : 'error';
      case 'warning':
        return _isPt ? 'aviso' : 'warning';
      case 'question':
        return _isPt ? 'pergunta' : 'question';
      case 'info':
      default:
        return _isPt ? 'informação' : 'info';
    }
  }

  String _positionLabel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'top-left':
        return _isPt ? 'topo à esquerda' : 'top left';
      case 'top-right':
        return _isPt ? 'topo à direita' : 'top right';
      case 'center-left':
        return _isPt ? 'centro à esquerda' : 'center left';
      case 'center-right':
        return _isPt ? 'centro à direita' : 'center right';
      case 'bottom-left':
        return _isPt ? 'base à esquerda' : 'bottom left';
      case 'bottom-right':
        return _isPt ? 'base à direita' : 'bottom right';
      case 'top':
        return _isPt ? 'topo' : 'top';
      case 'bottom':
        return _isPt ? 'base' : 'bottom';
      case 'center':
      default:
        return _isPt ? 'centro' : 'center';
    }
  }

  String _inputLabel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'textarea':
        return 'textarea';
      case 'checkbox':
        return _isPt ? 'checkbox' : 'checkbox';
      case 'range':
        return 'range';
      default:
        return value;
    }
  }

  Future<void> showServiceModal() async {
    final result = await sweetAlertService.show(
      title: _isPt ? 'Build concluído' : 'Build complete',
      message: _isPt
          ? 'A pipeline terminou e o resumo do deploy já está disponível para revisão.'
          : 'The pipeline finished and the deployment summary is now available for review.',
      type: SweetAlertType.success,
      showCloseButton: true,
      footer: _isPt ? 'Origem: SweetAlertService' : 'Source: SweetAlertService',
    );

    lastAction = result.isConfirmed
        ? (_isPt
            ? 'SweetAlertService.show confirmado.'
            : 'SweetAlertService.show confirmed.')
        : (_isPt
            ? 'SweetAlertService.show foi fechado.'
            : 'SweetAlertService.show was closed.');
  }

  Future<void> showServiceConfirm() async {
    final result = await sweetAlertService.confirm(
      title: _isPt ? 'Promover release' : 'Promote release',
      message: _isPt
          ? 'Deseja publicar esta configuração no ambiente principal agora?'
          : 'Do you want to publish this configuration to the main environment now?',
      type: SweetAlertType.question,
      confirmButtonText: _isPt ? 'Promover' : 'Promote',
      cancelButtonText: _isPt ? 'Revisar' : 'Review',
      showCloseButton: true,
    );

    lastAction = result.isConfirmed
        ? (_isPt
            ? 'SweetAlertService.confirm retornou true.'
            : 'SweetAlertService.confirm returned true.')
        : (_isPt
            ? 'SweetAlertService.confirm foi cancelado.'
            : 'SweetAlertService.confirm was cancelled.');
  }

  Future<void> showServicePrompt() async {
    final result = await sweetAlertService.prompt(
      title: _isPt ? 'Lote prioritário' : 'Priority batch',
      message: _isPt
          ? 'Informe o identificador do lote que deve receber monitoramento extra.'
          : 'Enter the batch identifier that should receive extra monitoring.',
      type: SweetAlertType.info,
      inputPlaceholder: _isPt ? 'Ex.: lote-42' : 'e.g. batch-42',
      confirmButtonText: _isPt ? 'Salvar' : 'Save',
      cancelButtonText: _isPt ? 'Agora não' : 'Not now',
      inputValidator: (value) {
        if (value.trim().isEmpty) {
          return _isPt
              ? 'Informe um identificador antes de continuar.'
              : 'Enter an identifier before continuing.';
        }
        return null;
      },
    );

    lastAction = result.isConfirmed
        ? (_isPt
            ? 'Prompt confirmado com valor: ${result.value}'
            : 'Prompt confirmed with value: ${result.value}')
        : (_isPt ? 'Prompt cancelado.' : 'Prompt cancelled.');
  }

  void showServiceToast() {
    sweetAlertService.toast(
      _isPt
          ? 'Sincronização concluída com sucesso.'
          : 'Synchronization completed successfully.',
      title: _isPt ? 'Sucesso' : 'Success',
      type: SweetAlertType.success,
      position: SweetAlertPosition.topEnd,
      timer: const Duration(seconds: 3),
    );
    lastAction = _isPt
        ? 'SweetAlertService.toast executado.'
        : 'SweetAlertService.toast executed.';
  }

  void showStaticToast() {
    SweetAlert.toast(
      _isPt
          ? 'Fluxo alternativo notificado pela API estática.'
          : 'Fallback flow notified by the static API.',
      title: 'SweetAlert',
      type: SweetAlertType.warning,
      position: SweetAlertPosition.bottomEnd,
      timer: const Duration(seconds: 4),
    );
    lastAction = _isPt
        ? 'SweetAlert.toast executado pela API estática.'
        : 'SweetAlert.toast executed through the static API.';
  }

  Future<void> showNoBackdropModal() async {
    final result = await sweetAlertService.show(
      title: _isPt ? 'Sem backdrop' : 'No backdrop',
      message: _isPt
          ? 'Modal exibido sem escurecer o restante da interface.'
          : 'Modal displayed without dimming the rest of the interface.',
      type: SweetAlertType.info,
      backdrop: false,
      allowOutsideClick: true,
      showCloseButton: true,
    );

    lastAction = result.isConfirmed
        ? (_isPt
            ? 'Modal sem backdrop confirmado.'
            : 'No-backdrop modal confirmed.')
        : (_isPt ? 'Modal sem backdrop fechado.' : 'No-backdrop modal closed.');
  }

  Future<void> showHtmlModal() async {
    final result = await sweetAlertService.show(
      title: _isPt ? 'Resumo da release' : 'Release summary',
      htmlContent: _isPt
          ? '<div class="text-start"><strong>Janela:</strong> 22:30<br><strong>Cluster:</strong> blue-east<br><span class="badge bg-success mt-2">Pronto para publicar</span></div>'
          : '<div class="text-start"><strong>Window:</strong> 22:30<br><strong>Cluster:</strong> blue-east<br><span class="badge bg-success mt-2">Ready to publish</span></div>',
      type: SweetAlertType.success,
      confirmButtonText: _isPt ? 'Entendi' : 'Understood',
      showCloseButton: true,
    );

    lastAction = result.isConfirmed
        ? (_isPt ? 'Modal HTML confirmado.' : 'HTML modal confirmed.')
        : (_isPt ? 'Modal HTML fechado.' : 'HTML modal closed.');
  }

  Future<void> showTimedModal() async {
    final result = await sweetAlertService.show(
      title: _isPt ? 'Sincronizando' : 'Synchronizing',
      message: _isPt
          ? 'Este modal fecha sozinho após alguns segundos.'
          : 'This modal closes by itself after a few seconds.',
      type: SweetAlertType.warning,
      timer: const Duration(seconds: 3),
      timerProgressBar: true,
      allowOutsideClick: false,
    );

    lastAction = result.isConfirmed
        ? (_isPt ? 'Modal com timer confirmado.' : 'Timed modal confirmed.')
        : (_isPt ? 'Modal com timer finalizado.' : 'Timed modal finished.');
  }

  void showBottomToast() {
    sweetAlertService.toast(
      _isPt ? 'Fila de exportação iniciada.' : 'Export queue started.',
      title: _isPt ? 'Processando' : 'Processing',
      type: SweetAlertType.info,
      position: SweetAlertPosition.bottomEnd,
      timer: const Duration(seconds: 4),
    );
    lastAction = _isPt ? 'Toast inferior exibido.' : 'Bottom toast displayed.';
  }

  void dismissAll() {
    sweetAlertService.dismissAll();
    _setLastAction(
      'Todos os overlays SweetAlert foram fechados.',
      'All SweetAlert overlays were dismissed.',
    );
  }

  Future<void> showTypedAlert(String typeName) async {
    final type = _resolveType(typeName);
    final label = _typeLabel(typeName);
    final result = await sweetAlertService.show(
      title: _isPt ? 'Exemplo de $label' : '$label example',
      message: _isPt
          ? 'Este alerta demonstra o tipo visual $label.'
          : 'This alert demonstrates the $label visual type.',
      type: type,
      showCloseButton: true,
    );

    _setLastAction(
      result.isConfirmed ? 'Tipo $label confirmado.' : 'Tipo $label fechado.',
      result.isConfirmed ? '$label type confirmed.' : '$label type closed.',
    );
  }

  Future<void> showCombinedFlow() async {
    final result = await sweetAlertService.confirm(
      title: _isPt ? 'Combinar ações' : 'Combine actions',
      message: _isPt
          ? 'Deseja executar a etapa principal e avisar o restante da equipe?'
          : 'Do you want to execute the main step and notify the rest of the team?',
      type: SweetAlertType.question,
      confirmButtonText: _isPt ? 'Executar' : 'Run',
      cancelButtonText: _isPt ? 'Cancelar' : 'Cancel',
      reverseButtons: true,
    );

    if (result.isConfirmed) {
      sweetAlertService.toast(
        _isPt ? 'Fluxo combinado concluído.' : 'Combined flow completed.',
        title: _isPt ? 'Concluído' : 'Completed',
        type: SweetAlertType.success,
        position: SweetAlertPosition.topEnd,
      );
      _setLastAction(
        'Fluxo combinado executado com sucesso.',
        'Combined flow executed successfully.',
      );
      return;
    }

    _setLastAction(
      'Fluxo combinado cancelado.',
      'Combined flow cancelled.',
    );
  }

  Future<void> showBasicAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Alerta básico' : 'Basic alert',
      type: SweetAlertType.info,
    );
    _setLastAction('Alerta básico exibido.', 'Basic alert displayed.');
  }

  Future<void> showTitleTextAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Título com texto' : 'Title with text',
      message: _isPt
          ? 'Texto adicional abaixo do título, como no exemplo original.'
          : 'Additional text below the title, like in the original example.',
      type: SweetAlertType.info,
    );
    _setLastAction('Alerta com texto exibido.', 'Alert with text displayed.');
  }

  Future<void> showCloseButtonExample() async {
    await sweetAlertService.show(
      title: _isPt ? 'Botão de fechar' : 'Close button',
      message: _isPt
          ? 'O canto superior direito recebe um botão explícito de fechamento.'
          : 'The top-right corner gets an explicit close button.',
      type: SweetAlertType.info,
      showCloseButton: true,
    );
    _setLastAction(
      'Exemplo com botão de fechar executado.',
      'Close button example executed.',
    );
  }

  Future<void> showPaddingAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Padding customizado' : 'Custom padding',
      message: _isPt
          ? 'Este popup usa preenchimento maior para destacar conteúdo denso.'
          : 'This popup uses larger padding to emphasize dense content.',
      type: SweetAlertType.info,
      padding: '3rem 3.5rem',
      footer: 'padding: 3rem 3.5rem',
    );
    _setLastAction('Padding customizado aplicado.', 'Custom padding applied.');
  }

  Future<void> showWidthAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Largura customizada' : 'Custom width',
      message: _isPt
          ? 'A largura do popup foi aumentada para acomodar conteúdo mais largo.'
          : 'The popup width was increased to fit wider content.',
      type: SweetAlertType.info,
      width: '44rem',
    );
    _setLastAction('Largura customizada aplicada.', 'Custom width applied.');
  }

  Future<void> showAjaxValidationAlert() async {
    final result = await sweetAlertService.prompt(
      title: _isPt ? 'Validação assíncrona' : 'Async validation',
      message: _isPt
          ? 'Digite "release-2026" para simular a aprovação do backend.'
          : 'Type "release-2026" to simulate backend approval.',
      inputPlaceholder: 'release-2026',
      confirmButtonText: _isPt ? 'Validar' : 'Validate',
      cancelButtonText: _isPt ? 'Cancelar' : 'Cancel',
      inputValidator: (value) async {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        if (value.trim() != 'release-2026') {
          return _isPt
              ? 'Backend recusou o valor informado.'
              : 'Backend rejected the informed value.';
        }
        return null;
      },
    );

    _setLastAction(
      result.isConfirmed
          ? 'Validação assíncrona aprovada com ${result.value}.'
          : 'Validação assíncrona cancelada.',
      result.isConfirmed
          ? 'Async validation approved with ${result.value}.'
          : 'Async validation cancelled.',
    );
  }

  Future<void> showImageAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Imagem customizada' : 'Custom image',
      message: _isPt
          ? 'O popup abaixo usa uma imagem local do exemplo.'
          : 'The popup below uses a local image from the example app.',
      imageUrl: _customImageUrl,
      imageWidth: 120,
      imageHeight: 120,
      imageAlt: _isPt ? 'Imagem de demonstração' : 'Demo image',
      showCloseButton: true,
    );
    _setLastAction('Imagem customizada exibida.', 'Custom image displayed.');
  }

  Future<void> showBackgroundAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Imagem de fundo' : 'Background image',
      message: _isPt
          ? 'O popup recebeu imagem de fundo e overlay claro para legibilidade.'
          : 'The popup received a background image plus a light overlay for legibility.',
      background: 'rgba(255,255,255,0.94)',
      backgroundImageUrl: _backgroundImageUrl,
      width: '42rem',
      padding: '3rem',
    );
    _setLastAction(
      'Imagem de fundo aplicada ao popup.',
      'Background image applied to popup.',
    );
  }

  Future<void> showChainedAlerts() async {
    final first = await sweetAlertService.show(
      title: _isPt ? 'Passo 1' : 'Step 1',
      message: _isPt
          ? 'Preparando configuração inicial.'
          : 'Preparing initial configuration.',
      type: SweetAlertType.info,
      confirmButtonText: _isPt ? 'Continuar' : 'Continue',
    );
    if (!first.isConfirmed) {
      _setLastAction(
          'Fluxo encadeado interrompido.', 'Chained flow interrupted.');
      return;
    }

    final second = await sweetAlertService.prompt(
      title: _isPt ? 'Passo 2' : 'Step 2',
      message: _isPt ? 'Nomeie a release.' : 'Name the release.',
      inputPlaceholder: _isPt ? 'release-abril' : 'april-release',
      confirmButtonText: _isPt ? 'Salvar' : 'Save',
      cancelButtonText: _isPt ? 'Cancelar' : 'Cancel',
    );
    if (!second.isConfirmed) {
      _setLastAction('Fluxo encadeado cancelado no passo 2.',
          'Chained flow cancelled on step 2.');
      return;
    }

    await sweetAlertService.show(
      title: _isPt ? 'Passo 3' : 'Step 3',
      message: _isPt
          ? 'Release ${second.value} pronta para publicação.'
          : 'Release ${second.value} is ready to publish.',
      type: SweetAlertType.success,
    );
    _setLastAction('Fluxo encadeado concluído.', 'Chained flow completed.');
  }

  Future<void> showReverseButtonsAlert() async {
    final result = await sweetAlertService.confirm(
      title: _isPt ? 'Botões invertidos' : 'Reversed buttons',
      message: _isPt
          ? 'Os botões foram invertidos para seguir outro padrão visual.'
          : 'Buttons were reversed to follow a different visual pattern.',
      reverseButtons: true,
      confirmButtonText: _isPt ? 'Confirmar' : 'Confirm',
      cancelButtonText: _isPt ? 'Cancelar' : 'Cancel',
    );
    _setLastAction(
      result.isConfirmed
          ? 'Exemplo de botões invertidos confirmado.'
          : 'Exemplo de botões invertidos cancelado.',
      result.isConfirmed
          ? 'Reversed buttons example confirmed.'
          : 'Reversed buttons example cancelled.',
    );
  }

  Future<void> showGrowExample(String growName) async {
    await sweetAlertService.show(
      title: _isPt ? 'Modo expandido' : 'Grow mode',
      message: _isPt
          ? 'Este exemplo valida grow: $growName.'
          : 'This example validates grow: $growName.',
      type: SweetAlertType.info,
      grow: _resolveGrowMode(growName),
      width: growName == 'fullscreen' ? null : '38rem',
    );
    _setLastAction(
      'Modo $growName exibido.',
      '$growName mode displayed.',
    );
  }

  Future<void> showDisabledKeyboardAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Teclado desabilitado' : 'Keyboard disabled',
      message: _isPt
          ? 'Escape e Enter não fecham este popup; confirme manualmente.'
          : 'Escape and Enter do not close this popup; confirm manually.',
      allowEscapeKey: false,
      allowOutsideClick: false,
      type: SweetAlertType.warning,
    );
    _setLastAction(
      'Interação por teclado desabilitada testada.',
      'Keyboard-disabled interaction tested.',
    );
  }

  Future<void> showDisabledAnimationAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Sem animação' : 'Animation disabled',
      message: _isPt
          ? 'A animação de entrada e saída foi removida.'
          : 'Entry and exit animation was removed.',
      animation: false,
      type: SweetAlertType.info,
    );
    _setLastAction(
        'Exemplo sem animação exibido.', 'Animation-free example displayed.');
  }

  Future<void> showDisabledBackdropAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Backdrop desabilitado' : 'Backdrop disabled',
      message: _isPt
          ? 'O restante da página permanece sem escurecimento.'
          : 'The rest of the page remains without dimming.',
      backdrop: false,
      showCloseButton: true,
      type: SweetAlertType.info,
    );
    _setLastAction(
        'Backdrop desabilitado testado.', 'Backdrop-disabled example tested.');
  }

  Future<void> showDisabledOutsideClickAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Clique externo bloqueado' : 'Outside click disabled',
      message: _isPt
          ? 'Clique fora do popup não o fecha neste exemplo.'
          : 'Clicking outside the popup does not close it in this example.',
      allowOutsideClick: false,
      showCloseButton: true,
      type: SweetAlertType.warning,
    );
    _setLastAction('Bloqueio de clique externo testado.',
        'Outside-click blocking tested.');
  }

  Future<void> showInputExample(String inputName) async {
    final normalized = inputName.trim().toLowerCase();
    late SweetAlertResult<String> result;

    switch (normalized) {
      case 'select':
        result = await sweetAlertService.prompt(
          title: _isPt ? 'Selecionar ambiente' : 'Select environment',
          inputType: SweetAlertInputType.select,
          inputOptions: const <String, String>{
            'prod': 'Produção',
            'staging': 'Homologação',
            'dev': 'Desenvolvimento',
          },
          inputPlaceholder:
              _isPt ? 'Selecione um ambiente' : 'Select an environment',
        );
        break;
      case 'radio':
        result = await sweetAlertService.prompt(
          title: _isPt ? 'Escolha a estratégia' : 'Choose strategy',
          inputType: SweetAlertInputType.radio,
          inputOptions: const <String, String>{
            'fast': 'Fast track',
            'normal': 'Normal',
            'safe': 'Safe mode',
          },
        );
        break;
      case 'checkbox':
        result = await sweetAlertService.prompt(
          title: _isPt ? 'Notificar equipe' : 'Notify team',
          inputType: SweetAlertInputType.checkbox,
          inputLabel: _isPt
              ? 'Enviar aviso para o canal de operações'
              : 'Send a notice to the operations channel',
          inputChecked: true,
        );
        break;
      case 'range':
        result = await sweetAlertService.prompt(
          title: _isPt ? 'Ajustar intensidade' : 'Adjust intensity',
          inputType: SweetAlertInputType.range,
          inputMin: 0,
          inputMax: 100,
          inputStep: 10,
          inputValue: '40',
        );
        break;
      default:
        result = await sweetAlertService.prompt(
          title: _isPt ? 'Input $inputName' : '$inputName input',
          inputType: _resolveInputType(normalized),
          inputPlaceholder: normalized == 'textarea'
              ? (_isPt
                  ? 'Descreva o contexto da publicação'
                  : 'Describe the publication context')
              : (_isPt ? 'Informe um valor' : 'Enter a value'),
          inputValidator: (value) {
            if (value.trim().isEmpty) {
              return _isPt
                  ? 'Preencha o campo antes de continuar.'
                  : 'Fill the field before continuing.';
            }
            if (normalized == 'url' && !value.startsWith('http')) {
              return _isPt
                  ? 'Use uma URL iniciando com http.'
                  : 'Use a URL starting with http.';
            }
            return null;
          },
        );
        break;
    }

    _setLastAction(
      result.isConfirmed
          ? 'Input ${_inputLabel(normalized)} confirmou com ${result.value}.'
          : 'Input ${_inputLabel(normalized)} cancelado.',
      result.isConfirmed
          ? '${_inputLabel(normalized)} input confirmed with ${result.value}.'
          : '${_inputLabel(normalized)} input cancelled.',
    );
  }

  Future<void> showPositionExample(String positionName) async {
    await sweetAlertService.show(
      title: _isPt
          ? 'Posição ${_positionLabel(positionName)}'
          : '${_positionLabel(positionName)} position',
      message: _isPt
          ? 'Este modal valida a posição ${_positionLabel(positionName)}.'
          : 'This modal validates the ${_positionLabel(positionName)} position.',
      position: _resolvePosition(positionName),
      type: SweetAlertType.info,
      showCloseButton: true,
    );
    _setLastAction(
      'Posição ${_positionLabel(positionName)} validada.',
      '${_positionLabel(positionName)} position validated.',
    );
  }

  void showTypedToast(String typeName) {
    final type = _resolveType(typeName);
    final label = _typeLabel(typeName);
    sweetAlertService.toast(
      _isPt ? 'Toast do tipo $label.' : '$label toast.',
      title: _isPt ? 'Toast' : 'Toast',
      type: type,
      position: SweetAlertPosition.topEnd,
      timer: const Duration(seconds: 3),
    );
    _setLastAction('Toast $label exibido.', '$label toast displayed.');
  }

  void showToastPositionExample(String positionName) {
    sweetAlertService.toast(
      _isPt
          ? 'Toast na posição ${_positionLabel(positionName)}.'
          : 'Toast at ${_positionLabel(positionName)} position.',
      title: 'SweetAlert',
      type: SweetAlertType.success,
      position: _resolvePosition(positionName),
      timer: const Duration(seconds: 3),
    );
    _setLastAction(
      'Toast em ${_positionLabel(positionName)} exibido.',
      'Toast at ${_positionLabel(positionName)} displayed.',
    );
  }

  Future<void> showOnOpenCallbackAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Callback onOpen' : 'onOpen callback',
      message: _isPt
          ? 'Ao abrir, o popup recebe borda extra e atualiza o resumo abaixo.'
          : 'When opening, the popup gets an extra border and updates the summary below.',
      type: SweetAlertType.info,
      showCloseButton: true,
      onOpen: (popup) {
        popup.classes.addAll(<String>['border', 'border-primary']);
        _setLastAction(
          'Callback onOpen disparado.',
          'onOpen callback fired.',
        );
      },
    );
  }

  Future<void> showOnCloseCallbackAlert() async {
    await sweetAlertService.show(
      title: _isPt ? 'Callback onClose' : 'onClose callback',
      message: _isPt
          ? 'Feche o popup para disparar o callback de encerramento.'
          : 'Close the popup to trigger the closing callback.',
      type: SweetAlertType.info,
      showCloseButton: true,
      onClose: (_) {
        _setLastAction(
          'Callback onClose disparado.',
          'onClose callback fired.',
        );
      },
    );
  }

  void handleDirectiveResult(Object result) {
    if (result is! SweetAlertResult) {
      lastAction = _isPt ? 'Diretiva executada.' : 'Directive executed.';
      return;
    }

    if (result.isConfirmed) {
      final value = result.value;
      lastAction = value == null || '$value'.isEmpty
          ? (_isPt
              ? 'Diretiva confirmou o fluxo.'
              : 'Directive confirmed the flow.')
          : (_isPt
              ? 'Diretiva confirmou com valor: $value'
              : 'Directive confirmed with value: $value');
      return;
    }

    lastAction = _isPt
        ? 'Diretiva fechou com motivo: ${result.dismissReason}'
        : 'Directive closed with reason: ${result.dismissReason}';
  }
}
