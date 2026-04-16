import 'package:limitless_ui_example/limitless_ui_example.dart';

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

  static const String fullScreenSnippet = '''
<li-modal
    #fullScreenFormModal
    title-text="Alterar CGM"
    size="modal-full"
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
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  @ViewChild('demoModal')
  LiModalComponent? demoModal;

  @ViewChild('scrollableModal')
  LiModalComponent? scrollableModal;

  @ViewChild('warningModal')
  LiModalComponent? warningModal;

  @ViewChild('iconifiedModal')
  LiModalComponent? iconifiedModal;

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

  String get waitingLog => _isPt
      ? 'Abra um dos exemplos para validar combinações de tamanho, cor, backdrop e lazyContent.'
      : 'Open one of the examples to validate combinations of size, color, backdrop, and lazyContent.';
  String get overviewIntro => _isPt
      ? 'A implementação cobre os cenários mais comuns de Bootstrap/Limitless: modal básico, scroll interno, backdrop bloqueado, tamanho amplo e conteúdo lazy para evitar renderização antecipada.'
      : 'The implementation covers the most common Bootstrap/Limitless scenarios: basic modal, internal scrolling, locked backdrop, wide size, and lazy content to avoid early rendering.';
  String get apiIntro => _isPt
      ? 'A configuração principal passa por `title-text`, `headerColor`, tamanho, backdrop, lazy content e comportamento no mobile.'
      : 'The main configuration goes through `title-text`, `headerColor`, size, backdrop, lazy content, and mobile behavior.';
  String get mainInputsTitle => _isPt ? 'Entradas principais' : 'Main inputs';
  String get basicSnippetTitle => _isPt ? 'Modal básico' : 'Basic modal';
  String get advancedSnippetTitle =>
      _isPt ? 'Combinações avançadas' : 'Advanced combinations';
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
      _isPt ? 'Amplo / full no mobile' : 'Wide / full on mobile';
  String get fullBody => _isPt
      ? 'Boa opção para fluxos com checklist, revisão de dados e múltiplas ações.'
      : 'A good option for flows with checklists, data review, and multiple actions.';
  String get fullOpenButton => _isPt ? 'Abrir modal amplo' : 'Open wide modal';
  String get fullScreenCardTitle =>
      _isPt ? 'Full screen com formulário' : 'Fullscreen with form';
  String get fullScreenCardBody => _isPt
      ? 'Demonstra o size modal-full com cabeçalho reduzido e conteúdo longo parecido com um fluxo administrativo real.'
      : 'Demonstrates modal-full with a reduced header and long content similar to a real administrative flow.';
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
      ? 'Esta variação usa o novo input `smallHeader` para reduzir ao máximo a altura do cabeçalho.'
      : 'This variation uses the new `smallHeader` input to minimize header height.';
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
      _isPt ? 'Quando usar este tamanho' : 'When to use this size';
  String get fullWhenToUseBody => _isPt
      ? 'Prefira o modal amplo quando o conteúdo precisa de duas colunas, revisão de tabelas ou múltiplas ações sem quebrar a leitura no desktop.'
      : 'Prefer the wide modal when the content needs two columns, table review, or multiple actions without breaking desktop readability.';
  String get closeChecklistLabel =>
      _isPt ? 'Fechar checklist' : 'Close checklist';
  String get fullScreenModalTitle => _isPt ? 'Alterar CGM' : 'Update record';
  String get fullScreenLead => _isPt
      ? 'Exemplo de modal full para formulários extensos, com várias seções e ações no rodapé.'
      : 'Fullscreen modal example for long forms with multiple sections and footer actions.';
  String get fullScreenSaveLabel =>
      _isPt ? 'Salvar alterações' : 'Save changes';
  String get fullScreenCancelLabel => _isPt ? 'Cancelar edição' : 'Cancel edit';
  String get lockedModalTitle =>
      _isPt ? 'Confirmação obrigatória' : 'Mandatory confirmation';
  String get lockedModalBody => _isPt
      ? 'Este exemplo mantém o backdrop ativo, mas impede fechamento por clique fora e esconde o X do header.'
      : 'This example keeps the backdrop active, but prevents closing on outside click and hides the header close button.';
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
    modalEventLog = 'Modal wide/full aberto.';
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
