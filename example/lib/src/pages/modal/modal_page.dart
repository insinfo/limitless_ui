
import 'package:limitless_ui_example/limitless_ui_example.dart';

class ModalSizeShowcaseItem {
  final String sizeValue;
  final String titlePt;
  final String titleEn;
  final String descriptionPt;
  final String descriptionEn;
  final String useCasePt;
  final String useCaseEn;
  final String headerColor;

  const ModalSizeShowcaseItem({
    required this.sizeValue,
    required this.titlePt,
    required this.titleEn,
    required this.descriptionPt,
    required this.descriptionEn,
    required this.useCasePt,
    required this.useCaseEn,
    required this.headerColor,
  });
}

@Component(
  selector: 'modal-page',
  templateUrl: 'modal_page.html',
  styleUrls: ['modal_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiModalComponent,
  ],
)
class ModalPageComponent {
  ModalPageComponent(this.i18n);

  static const List<ModalSizeShowcaseItem> _sizeShowcaseItems =
      <ModalSizeShowcaseItem>[
    ModalSizeShowcaseItem(
      sizeValue: 'default',
      titlePt: 'Padrão',
      titleEn: 'Default',
      descriptionPt:
          'Largura base para confirmações, leitura e formulários curtos.',
      descriptionEn: 'Base width for confirmations, reading, and short forms.',
      useCasePt: 'Use quando não houver necessidade de um layout amplo.',
      useCaseEn: 'Use when the flow does not need a wide layout.',
      headerColor: 'primary',
    ),
    ModalSizeShowcaseItem(
      sizeValue: 'modal-xs',
      titlePt: 'Mini',
      titleEn: 'Extra small',
      descriptionPt:
          'Versão mais compacta para decisões rápidas e mensagens curtas.',
      descriptionEn:
          'The most compact version for quick decisions and short messages.',
      useCasePt: 'Ideal para confirmação binária ou avisos pequenos.',
      useCaseEn: 'Ideal for binary confirmations or small notices.',
      headerColor: 'dark',
    ),
    ModalSizeShowcaseItem(
      sizeValue: 'modal-sm',
      titlePt: 'Pequeno',
      titleEn: 'Small',
      descriptionPt:
          'Mantém mais espaço para conteúdo sem virar um modal padrão.',
      descriptionEn:
          'Keeps a bit more room without becoming a full default modal.',
      useCasePt:
          'Bom para resumos, confirmações enriquecidas e pequenos estados.',
      useCaseEn:
          'Good for summaries, richer confirmations, and compact states.',
      headerColor: 'warning',
    ),
    ModalSizeShowcaseItem(
      sizeValue: 'large',
      titlePt: 'Grande',
      titleEn: 'Large',
      descriptionPt:
          'Primeiro salto para fluxos com formulários ou listas maiores.',
      descriptionEn: 'First step up for flows with forms or larger lists.',
      useCasePt:
          'Use para formulários médios, tabelas curtas e combinações com scroll.',
      useCaseEn: 'Use for medium forms, short tables, and scrollable content.',
      headerColor: 'info',
    ),
    ModalSizeShowcaseItem(
      sizeValue: 'xtra-large',
      titlePt: 'Extra large',
      titleEn: 'Extra large',
      descriptionPt:
          'Equivalente ao modal XL tradicional para layouts mais largos.',
      descriptionEn:
          'Equivalent to the traditional XL modal for wider layouts.',
      useCasePt:
          'Funciona bem com dashboards resumidos e formulários em duas colunas.',
      useCaseEn: 'Works well with summarized dashboards and two-column forms.',
      headerColor: 'indigo',
    ),
    ModalSizeShowcaseItem(
      sizeValue: 'xx-large',
      titlePt: 'XX large',
      titleEn: 'XX large',
      descriptionPt: 'Passo intermediário acima do XL para telas mais densas.',
      descriptionEn: 'Intermediate step above XL for denser screens.',
      useCasePt: 'Use quando XL ainda apertar, mas fullscreen for exagero.',
      useCaseEn:
          'Use when XL still feels tight but fullscreen would be excessive.',
      headerColor: 'purple',
    ),
    ModalSizeShowcaseItem(
      sizeValue: 'xxx-large',
      titlePt: 'XXX large',
      titleEn: 'XXX large',
      descriptionPt:
          'Faixa ampla para grids e fluxos administrativos com muita informação.',
      descriptionEn:
          'Wide tier for grids and administrative flows with lots of information.',
      useCasePt:
          'Bom para layouts largos com muitas colunas visíveis ao mesmo tempo.',
      useCaseEn: 'Good for wide layouts with many visible columns at once.',
      headerColor: 'teal',
    ),
    ModalSizeShowcaseItem(
      sizeValue: 'fluid',
      titlePt: 'Fluido',
      titleEn: 'Fluid',
      descriptionPt:
          'Chega perto do fullscreen em largura sem virar shell de tela cheia.',
      descriptionEn:
          'Gets close to fullscreen width without becoming a fullscreen shell.',
      useCasePt:
          'Ideal para checklists, comparações lado a lado e fluxos largos no desktop.',
      useCaseEn:
          'Ideal for checklists, side-by-side comparisons, and wide desktop flows.',
      headerColor: 'dark',
    ),
    ModalSizeShowcaseItem(
      sizeValue: 'modal-full',
      titlePt: 'Fullscreen',
      titleEn: 'Fullscreen',
      descriptionPt:
          'Transforma o modal em shell de tela cheia, inclusive em altura.',
      descriptionEn:
          'Turns the modal into a full-screen shell, including full height.',
      useCasePt:
          'Reserve para fluxos longos, cadastros extensos e etapas com muita navegação.',
      useCaseEn:
          'Reserve it for long flows, extensive forms, and multi-step navigation.',
      headerColor: 'primary',
    ),
  ];

  static const String basicSnippet = '''
<li-modal
    #demoModal
    title-text="Revisar publicação"
    headerColor="indigo"
    [verticalCenter]="true"
    [lazyContent]="true">
  <p>Conteúdo do modal.</p>
</li-modal>''';

  static const String advancedSnippet = '''
<li-modal
    #scrollableModal
    title-text="Checklist"
    size="large"
    [dialogScrollable]="true"
    [closeOnBackdropClick]="false"
    [fullScreenOnMobile]="true">
</li-modal>''';

  static const String sizesSnippet = '''
<li-modal title-text="Padrão"></li-modal>
<li-modal title-text="Mini" size="modal-xs"></li-modal>
<li-modal title-text="Pequeno" size="modal-sm"></li-modal>
<li-modal title-text="Grande" size="large"></li-modal>
<li-modal title-text="XL" size="xtra-large"></li-modal>
<li-modal title-text="XXL" size="xx-large"></li-modal>
<li-modal title-text="XXXL" size="xxx-large"></li-modal>
<li-modal title-text="Fluido" size="fluid"></li-modal>
<li-modal title-text="Tela cheia" size="modal-full"></li-modal>''';

  static const String imperativeSnippet = '''
@ViewChild('reviewModal')
LiModalComponent? reviewModal;

void openReviewModal() {
  reviewModal?.open();
}

void closeReviewModal() {
  reviewModal?.close();
}''';

  static const String fluidSnippet = '''
<li-modal
    #reviewModal
    title-text="Checklist ampliado"
    size="fluid"
    [enableShadow]="true"
    [fullScreenOnMobile]="true">
</li-modal>''';

  static const String fullScreenSnippet = '''
<li-modal
    #fullScreenFormModal
    title-text="Alterar CGM"
    size="modal-full"
        [fullScreenShell]="true"
    headerColor="primary"
    [smallHeader]="true"
    [lazyContent]="true">
</li-modal>''';

  static const String smallHeaderSnippet = '''
<li-modal
    title-text="Resumo rápido"
    size="modal-sm"
    [smallHeader]="true">
</li-modal>''';

  final DemoI18nService i18n;
  final List<ModalSizeShowcaseItem> modalSizeShowcaseItems = _sizeShowcaseItems;

  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;
  bool get isPortuguese => _isPt;

  late ModalSizeShowcaseItem activeSizeShowcase = modalSizeShowcaseItems.first;

  @ViewChild('demoModal')
  LiModalComponent? demoModal;

  @ViewChild('scrollableModal')
  LiModalComponent? scrollableModal;

  @ViewChild('warningModal')
  LiModalComponent? warningModal;

  @ViewChild('iconifiedModal')
  LiModalComponent? iconifiedModal;

  @ViewChild('sizeShowcaseModal')
  LiModalComponent? sizeShowcaseModal;

  @ViewChild('miniModal')
  LiModalComponent? miniModal;

  @ViewChild('backdroplessModal')
  LiModalComponent? backdroplessModal;

  @ViewChild('smallHeaderModal')
  LiModalComponent? smallHeaderModal;

  @ViewChild('formModal')
  LiModalComponent? formModal;

  @ViewChild('fullModal')
  LiModalComponent? fullModal;

  @ViewChild('fullScreenFormModal')
  LiModalComponent? fullScreenFormModal;

  @ViewChild('lockedModal')
  LiModalComponent? lockedModal;

  @ViewChild('lazyPreviewModal')
  LiModalComponent? lazyPreviewModal;

  final List<int> scrollLines = List<int>.generate(18, (index) => index + 1);

  List<String> get rolloutSteps => _isPt
      ? const <String>[
          'Validar escopo com operação e produto.',
          'Gerar PDF com os indicadores do período.',
          'Publicar o pacote e avisar as áreas impactadas.',
        ]
      : const <String>[
          'Validate scope with operations and product.',
          'Generate a PDF with the period indicators.',
          'Publish the package and notify impacted teams.',
        ];

  String modalEventLog = '';

  String get launchMatrixTitle =>
      _isPt ? 'Cenários prontos' : 'Ready-made scenarios';
  String get launchMatrixLead => _isPt
      ? 'Cada linha abaixo abre um caso de uso real e mostra quais inputs valem a pena observar.'
      : 'Each row below opens a real use case and shows which inputs are worth inspecting.';
  String get fullScreenShellExplainTitle => _isPt
      ? 'modal-full x fullScreenShell:'
      : 'modal-full vs fullScreenShell:';
  String get fullScreenShellExplainBody => _isPt
      ? ' modal-full já leva o diálogo para 100vw x 100dvh. fullScreenShell não aumenta esse tamanho; ele só remove o aspecto de modal arredondado e faz o componente parecer uma tela inteira do sistema.'
      : ' modal-full already takes the dialog to 100vw x 100dvh. fullScreenShell does not make it bigger; it only removes the rounded modal look and makes the component feel like a full system screen.';
  String get sizeShowcaseTitle =>
      _isPt ? 'Escala completa de tamanhos' : 'Complete size scale';
  String get sizeShowcaseIntro => _isPt
      ? 'A galeria abaixo abre o mesmo modal com todos os valores aceitos em size, do padrão ao modal-full.'
      : 'The gallery below opens the same modal with every accepted size value, from default to modal-full.';
  String get implementationPatternsTitle =>
      _isPt ? 'Padrões de implementação' : 'Implementation patterns';
  String get implementationPatternsIntro => _isPt
      ? 'Além do visual, a demo deixa claro o que é suportado pelo componente e o que depende de composição no host.'
      : 'Beyond visuals, the demo makes it clear what the component supports directly and what depends on host composition.';
  String get apiIntro => _isPt
      ? 'A configuração principal passa por title-text, headerColor, size, backdrop, lazyContent, fullScreenOnMobile e controle por métodos.'
      : 'The main configuration goes through title-text, headerColor, size, backdrop, lazyContent, fullScreenOnMobile, and method-based control.';
  String get mainInputsTitle => _isPt ? 'Entradas principais' : 'Main inputs';
  String get behaviorApiTitle =>
      _isPt ? 'Comportamento e métodos' : 'Behavior and methods';
  String get outputsApiTitle =>
      _isPt ? 'Saídas e ciclo' : 'Outputs and lifecycle';
  String get supportMatrixTitle =>
      _isPt ? 'Matriz de tamanhos suportados' : 'Supported size matrix';
  String get supportMatrixLead => _isPt
      ? 'Os valores abaixo refletem a régua atual do componente, incluindo os novos degraus entre XL e fullscreen.'
      : 'The values below reflect the current modal scale, including the new steps between XL and fullscreen.';
  String get examplesTitle =>
      _isPt ? 'Snippets operacionais' : 'Operational snippets';
  String get fullScreenSnippetTitle => _isPt
      ? 'Shell fullscreen (modal-full + fullScreenShell)'
      : 'Fullscreen shell (modal-full + fullScreenShell)';
  String get sizeSnippetTitle => _isPt ? 'Todos os tamanhos' : 'All sizes';
  String get imperativeSnippetTitle => _isPt
      ? 'Métodos e controle imperativo'
      : 'Methods and imperative control';
  String get basicSnippetTitle => _isPt ? 'Modal básico' : 'Basic modal';
  String get advancedSnippetTitle =>
      _isPt ? 'Combinações avançadas' : 'Advanced combinations';
  String get sizeUseCaseLabel => _isPt ? 'Quando usar' : 'When to use';
  String get sizeValueLabel => _isPt ? 'Valor' : 'Value';
  String get sizeWidthLabelTitle => _isPt ? 'Largura' : 'Width';
  String get openSizeDemoLabel => _isPt ? 'Abrir demonstração' : 'Open preview';
  String get livePreviewEyebrow =>
      _isPt ? 'Visualização ativa' : 'Active preview';
  String get livePreviewColumnsTitle =>
      _isPt ? 'Blocos lado a lado' : 'Side-by-side blocks';
  String get livePreviewColumnsBody => _isPt
      ? 'Use este espaço para validar colunas, cards, listas e ações sem precisar montar um fluxo inteiro.'
      : 'Use this space to validate columns, cards, lists, and actions without building a full workflow.';
  String get livePreviewDecisionTitle =>
      _isPt ? 'Decisão de layout' : 'Layout decision';
  String get livePreviewDecisionBody => _isPt
      ? 'Se o conteúdo ainda parecer comprimido, avance um tamanho. Se sobrar área demais, recue um degrau.'
      : 'If content still feels compressed, move one size up. If there is too much empty area, step back one size.';
  String get implementationCardOneTitle =>
      _isPt ? 'Header e identidade visual' : 'Header and visual identity';
  String get implementationCardOneBody => _isPt
      ? 'Use headerColor, enableShadow, compactHeader e smallHeader para aproximar o visual do layout que chamou o modal.'
      : 'Use headerColor, enableShadow, compactHeader, and smallHeader to align the modal with the surrounding layout.';
  String get implementationCardTwoTitle =>
      _isPt ? 'Backdrops e bloqueio de fluxo' : 'Backdrops and flow locking';
  String get implementationCardTwoBody => _isPt
      ? 'enableBackdrop, closeOnBackdropClick, closeOnEscape e enableCloseBtn resolvem a maior parte dos fluxos de confirmação, atenção e obrigatoriedade.'
      : 'enableBackdrop, closeOnBackdropClick, closeOnEscape, and enableCloseBtn cover most confirmation, warning, and mandatory flows.';
  String get implementationCardThreeTitle =>
      _isPt ? 'Montagem sob demanda' : 'On-demand rendering';
  String get implementationCardThreeBody => _isPt
      ? 'lazyContent evita custo de renderização antecipada quando o corpo possui tabelas, gráficos, formulários grandes ou componentes caros.'
      : 'lazyContent avoids eager rendering costs when the body contains tables, charts, large forms, or expensive child components.';
  String get waitingLog => _isPt
      ? 'Abra um dos exemplos para validar combinações de tamanho, cor, backdrop e lazyContent.'
      : 'Open one of the examples to validate combinations of size, color, backdrop, and lazyContent.';
  String get basicTitle => _isPt ? 'Básico centralizado' : 'Centered basic';
  String get basicBody => _isPt
      ? 'Header colorido, sombra e alinhamento vertical no centro.'
      : 'Colored header, shadow, and centered vertical alignment.';
  String get scrollableCardTitle => 'Scrollable';
  String get scrollableCardBody => _isPt
      ? 'Mantém o header fixo e move o conteúdo longo dentro do corpo.'
      : 'Keeps the header fixed and moves long content inside the body.';
  String get warningCardTitle =>
      _isPt ? 'Header contextual' : 'Contextual header';
  String get warningCardBody => _isPt
      ? 'Exemplo curto para confirmar uso de cor sem recriar o template inteiro.'
      : 'Short example to confirm color usage without recreating the full template.';
  String get warningOpenButton =>
      _isPt ? 'Abrir modal de alerta' : 'Open warning modal';
  String get iconifiedCardTitle => _isPt ? 'Com ícones' : 'Iconified';
  String get iconifiedCardBody => _isPt
      ? 'Título, corpo e ações com ícones para feedback mais explícito.'
      : 'Title, body, and actions with icons for more explicit feedback.';
  String get iconifiedOpenButton =>
      _isPt ? 'Abrir modal com ícones' : 'Open iconified modal';
  String get miniCardTitle => _isPt ? 'Tamanho mini' : 'Mini size';
  String get miniCardBody => _isPt
      ? 'Útil para confirmações rápidas ou pequenas decisões.'
      : 'Useful for quick confirmations or small decisions.';
  String get miniOpenButton => _isPt ? 'Abrir modal mini' : 'Open mini modal';
  String get backdroplessCardTitle =>
      _isPt ? 'Sem backdrop' : 'Backdrop disabled';
  String get backdroplessCardBody => _isPt
      ? 'Mostra o diálogo sem a camada escura atrás da janela.'
      : 'Displays the dialog without the dimmed layer behind it.';
  String get backdroplessOpenButton =>
      _isPt ? 'Abrir sem backdrop' : 'Open without backdrop';
  String get smallHeaderCardTitle => 'Small header';
  String get smallHeaderCardBody => _isPt
      ? 'Reduz ainda mais a altura do cabeçalho, mais próximo do padrão visual do Limitless.'
      : 'Reduces the header height further, closer to the Limitless visual pattern.';
  String get smallHeaderOpenButton =>
      _isPt ? 'Abrir header pequeno' : 'Open small header modal';
  String get formCardTitle => _isPt ? 'Modal com formulário' : 'Form modal';
  String get formCardBody => _isPt
      ? 'Exemplo de formulário vertical dentro do modal para fluxos curtos.'
      : 'Vertical form example inside the modal for short flows.';
  String get formOpenButton =>
      _isPt ? 'Abrir modal com formulário' : 'Open form modal';
  String get fullTitle =>
      _isPt ? 'Fluido / full no mobile' : 'Fluid / full on mobile';
  String get fullBody => _isPt
      ? 'Usa o novo size fluid, entre xtra-large e modal-full, para fluxos com muita largura sem ocupar a tela inteira em altura.'
      : 'Uses the new fluid size, between xtra-large and modal-full, for wide flows without taking over the full screen height.';
  String get fullOpenButton =>
      _isPt ? 'Abrir modal fluido' : 'Open fluid modal';
  String get fullScreenCardTitle =>
      _isPt ? 'Shell fullscreen com formulário' : 'Fullscreen shell with form';
  String get fullScreenCardBody => _isPt
      ? 'Demonstra modal-full com fullScreenShell: o tamanho já é fullscreen, e o acabamento reto faz o modal parecer uma tela de trabalho completa.'
      : 'Demonstrates modal-full with fullScreenShell: the size is already fullscreen, and the straight shell styling makes the modal feel like a complete work screen.';
  String get fullScreenOpenButton =>
      _isPt ? 'Abrir modal full' : 'Open fullscreen modal';
  String get lockedTitle => _isPt ? 'Backdrop travado' : 'Locked backdrop';
  String get lockedBody => _isPt
      ? 'O usuário só sai pelo botão, útil para confirmação obrigatória.'
      : 'The user can only leave through the button, useful for mandatory confirmation.';
  String get lockedOpenButton =>
      _isPt ? 'Abrir modal bloqueado' : 'Open locked modal';
  String get lazyTitle => 'Lazy content';
  String get lazyBody => _isPt
      ? 'O conteúdo pesado só entra no DOM quando o modal abre.'
      : 'Heavy content only enters the DOM when the modal opens.';
  String get lazyOpenButton => _isPt ? 'Abrir lazy modal' : 'Open lazy modal';
  String get warningModalTitle => _isPt
      ? 'Revisar pendências antes de publicar'
      : 'Review pending items before publishing';
  String get warningModalBody => _isPt
      ? 'Este fluxo encontrou registros com saúde crítica. Revise os itens antes de seguir para a publicação.'
      : 'This flow found records with critical health. Review the items before moving on to publication.';
  String get cancelLabel => _isPt ? 'Cancelar' : 'Cancel';
  String get understoodLabel => _isPt ? 'Entendi' : 'Understood';
  String get iconifiedModalTitle =>
      _isPt ? 'Checklist com ícones' : 'Iconified checklist';
  String get iconifiedModalLead => _isPt
      ? 'Exemplo inspirado no Limitless para destacar contexto, status e ações principais.'
      : 'Limitless-inspired example to emphasize context, status, and main actions.';
  String get miniModalTitle =>
      _isPt ? 'Confirmar ação rápida' : 'Confirm quick action';
  String get miniModalBody => _isPt
      ? 'Use o tamanho mini para ações pequenas em que a pessoa só precisa decidir entre seguir ou cancelar.'
      : 'Use the mini size for small actions where the person only needs to continue or cancel.';
  String get backdroplessModalTitle =>
      _isPt ? 'Dialog sem backdrop' : 'Dialog without backdrop';
  String get backdroplessModalBody => _isPt
      ? 'O diálogo aparece sem a máscara escura, útil em ambientes controlados onde o conteúdo ao fundo continua relevante.'
      : 'The dialog appears without the dark mask, useful in controlled environments where the background content remains relevant.';
  String get smallHeaderModalTitle =>
      _isPt ? 'Resumo com header pequeno' : 'Summary with small header';
  String get smallHeaderModalBody => _isPt
      ? 'Esta variação usa o input smallHeader para reduzir ao máximo a altura do cabeçalho.'
      : 'This variation uses the smallHeader input to minimize header height.';
  String get formModalTitle =>
      _isPt ? 'Solicitar validação' : 'Request validation';
  String get formModalLead => _isPt
      ? 'Fluxo curto com formulário vertical e ações no final do modal.'
      : 'Short flow with a vertical form and actions at the end of the modal.';
  String get fullModalTitle =>
      _isPt ? 'Checklist de rollout' : 'Rollout checklist';
  String get fullSequenceTitle =>
      _isPt ? 'Sequência recomendada' : 'Recommended sequence';
  String get fullWhenToUseTitle =>
      _isPt ? 'Quando usar estes tamanhos' : 'When to use these sizes';
  String get fullWhenToUseBody => _isPt
      ? 'Use xx-large para um passo acima do XL, xxx-large para layouts ainda mais largos e fluid quando precisar chegar perto do fullscreen sem virar um shell de tela cheia.'
      : 'Use xx-large for a step above XL, xxx-large for even wider layouts, and fluid when you need to get close to fullscreen without becoming a full screen shell.';
  String get closeChecklistLabel =>
      _isPt ? 'Fechar checklist' : 'Close checklist';
  String get fullScreenModalTitle => _isPt ? 'Alterar CGM' : 'Update record';
  String get fullScreenLead => _isPt
      ? 'Exemplo de modal-full com fullScreenShell para formulários extensos, várias seções e comportamento de shell de tela inteira.'
      : 'Example of modal-full with fullScreenShell for long forms, multiple sections, and full-screen shell behavior.';
  String get fullScreenSaveLabel =>
      _isPt ? 'Salvar alterações' : 'Save changes';
  String get fullScreenCancelLabel => _isPt ? 'Cancelar edição' : 'Cancel edit';
  String get lockedModalTitle =>
      _isPt ? 'Confirmação obrigatória' : 'Mandatory confirmation';
  String get lockedModalBody => _isPt
      ? 'Este exemplo mantém o backdrop ativo, desliga o ESC, impede fechamento por clique fora e esconde o X do header para sair apenas pelos botões.'
      : 'This example keeps the backdrop active, disables Escape, prevents outside-click closing, and hides the header close button so exit happens only through the action buttons.';
  String get backLabel => _isPt ? 'Voltar' : 'Back';
  String get confirmLabel => _isPt ? 'Confirmar' : 'Confirm';
  String get lazyModalTitle => _isPt
      ? 'Conteúdo lazy montado sob demanda'
      : 'Lazy content built on demand';
  String get lazyProofTitle =>
      _isPt ? 'O que este exemplo prova' : 'What this example proves';
  List<String> get lazyProofItems => _isPt
      ? const <String>[
          'O conteúdo projetado não é criado enquanto o modal estiver fechado.',
          'Ao abrir, o bloco entra no DOM e pode inicializar tabelas, gráficos ou formulários pesados.',
          'Ao fechar, o corpo volta a ser removido.',
        ]
      : const <String>[
          'Projected content is not created while the modal is closed.',
          'When opened, the block enters the DOM and can initialize tables, charts, or heavy forms.',
          'When closed, the body is removed again.',
        ];
  String get closeLabel => _isPt ? 'Fechar' : 'Close';

  String get activeSizeShowcaseTitle =>
      _isPt ? activeSizeShowcase.titlePt : activeSizeShowcase.titleEn;
  String get activeSizeShowcaseDescription => _isPt
      ? activeSizeShowcase.descriptionPt
      : activeSizeShowcase.descriptionEn;
  String get activeSizeShowcaseUseCase =>
      _isPt ? activeSizeShowcase.useCasePt : activeSizeShowcase.useCaseEn;
  String get activeSizeWidth => sizeWidthLabel(activeSizeShowcase);
  bool get activeSizeIsFull => activeSizeShowcase.sizeValue == 'modal-full';
  bool get activeSizeIsCompact =>
      activeSizeShowcase.sizeValue == 'modal-xs' ||
      activeSizeShowcase.sizeValue == 'modal-sm';
    bool get activeSizeUsesFullScreenShell => activeSizeIsFull;

  String sizeTitle(ModalSizeShowcaseItem item) =>
      _isPt ? item.titlePt : item.titleEn;

  String sizeDescription(ModalSizeShowcaseItem item) =>
      _isPt ? item.descriptionPt : item.descriptionEn;

  String sizeUseCase(ModalSizeShowcaseItem item) =>
      _isPt ? item.useCasePt : item.useCaseEn;

  String sizeValueChip(ModalSizeShowcaseItem item) {
    if (item.sizeValue == 'default') {
      return _isPt ? 'default / sem classe extra' : 'default / no extra class';
    }
    return item.sizeValue;
  }

  String sizeWidthLabel(ModalSizeShowcaseItem item) {
    switch (item.sizeValue) {
      case 'modal-xs':
        return '300px';
      case 'modal-sm':
        return '400px';
      case 'large':
        return '900px';
      case 'xtra-large':
        return '1140px';
      case 'xx-large':
        return '1320px';
      case 'xxx-large':
        return 'min(1480px, 100vw - 4rem)';
      case 'fluid':
        return 'calc(100vw - 2rem)';
      case 'modal-full':
        return '100vw x 100dvh';
      case 'default':
        return '600px';
      default:
        return 'auto';
    }
  }

  Object? trackByModalSize(int index, dynamic item) =>
      (item as ModalSizeShowcaseItem).sizeValue;

  void _setInitialLog() {
    if (modalEventLog.isEmpty) {
      modalEventLog = waitingLog;
    }
  }

  void openModal() {
    _setInitialLog();
    demoModal?.open();
    modalEventLog = 'Modal básico aberto.';
  }

  void openScrollableModal() {
    _setInitialLog();
    scrollableModal?.open();
    modalEventLog = 'Modal scrollable aberto.';
  }

  void openWarningModal() {
    _setInitialLog();
    warningModal?.open();
    modalEventLog = 'Modal com header contextual aberto.';
  }

  void openIconifiedModal() {
    _setInitialLog();
    iconifiedModal?.open();
    modalEventLog = 'Modal com ícones aberto.';
  }

  void openSizeShowcaseModal(ModalSizeShowcaseItem item) {
    _setInitialLog();
    activeSizeShowcase = item;
    sizeShowcaseModal?.open();
    modalEventLog = 'Modal ${item.sizeValue} aberto.';
  }

  void onSizeShowcaseClosed() {
    onModalClosed('Modal ${activeSizeShowcase.sizeValue}');
  }

  void openMiniModal() {
    _setInitialLog();
    miniModal?.open();
    modalEventLog = 'Modal mini aberto.';
  }

  void openBackdroplessModal() {
    _setInitialLog();
    backdroplessModal?.open();
    modalEventLog = 'Modal sem backdrop aberto.';
  }

  void openSmallHeaderModal() {
    _setInitialLog();
    smallHeaderModal?.open();
    modalEventLog = 'Modal com smallHeader aberto.';
  }

  void openFormModal() {
    _setInitialLog();
    formModal?.open();
    modalEventLog = 'Modal com formulário aberto.';
  }

  void openFullModal() {
    _setInitialLog();
    fullModal?.open();
    modalEventLog = 'Modal fluido aberto.';
  }

  void openFullScreenFormModal() {
    _setInitialLog();
    fullScreenFormModal?.open();
    modalEventLog = 'Modal full com formulário aberto.';
  }

  void openLockedModal() {
    _setInitialLog();
    lockedModal?.open();
    modalEventLog = 'Modal com backdrop travado aberto.';
  }

  void openLazyPreviewModal() {
    _setInitialLog();
    lazyPreviewModal?.open();
    modalEventLog = 'Modal lazy aberto. O conteúdo só foi montado agora.';
  }

  void onModalClosed(String label) {
    modalEventLog = '$label fechado.';
  }
}
