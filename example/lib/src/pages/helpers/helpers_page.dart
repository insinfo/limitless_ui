import 'dart:async';
import 'dart:convert';
import 'package:web/web.dart' as web;
import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'helpers-page',
  templateUrl: 'helpers_page.html',
  styleUrls: ['helpers_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiModalComponent,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class HelpersPageComponent implements OnDestroy {
  HelpersPageComponent(this.i18n);

  static const Duration _demoDuration = Duration(seconds: 2);
  static const Duration _narratedDemoDuration = Duration(milliseconds: 3400);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  final LiSimpleLoading _loading = LiSimpleLoading();
  LiNarratedFullScreenLoading? _narratedLoading;
  Timer? _loadingTimer;
  Timer? _fullscreenTimer;
  String helperState = '';

  String get overviewIntro => _isPt
      ? 'Helpers cobrem overlays, diálogos, popovers e notificações rápidas reutilizáveis no app administrativo.'
      : 'Helpers cover overlays, dialogs, popovers, and reusable quick notifications in the administrative app.';

  String get loadingCoverageIntro => _isPt
      ? 'Esta seção cobre os cinco métodos públicos atuais de LiSimpleLoading usando a área alvo abaixo e a viewport completa.'
      : 'This section covers the five current public LiSimpleLoading methods using the target area below and the full viewport.';

  String get loadingCoverageNote => _isPt
      ? 'showOnBody() cobre a viewport inteira; os demais botões usam a área alvo abaixo para facilitar a comparação visual.'
      : 'showOnBody() covers the full viewport; the other buttons use the target area below for easier visual comparison.';

  String get narratedLoadingSectionTitle => 'LiNarratedFullScreenLoading';

  String get narratedLoadingCoverageIntro => _isPt
      ? 'Este helper cobre fluxos longos de viewport inteira, com rotação automática de mensagens e barra animada.'
      : 'This helper covers longer full-viewport flows with rotating messages and an animated progress bar.';

  String get narratedLoadingMethodLabel => 'pdfGeneration().showOnBody()';

  String get dialogCoverageIntro => _isPt
      ? 'Aqui ficam os métodos públicos atuais de LiSimpleDialogComponent. O demo fullscreen fecha automaticamente após 2 segundos para não deixar overlay preso na página.'
      : 'This section covers the current public LiSimpleDialogComponent methods. The fullscreen demos auto-dismiss after 2 seconds so the page does not keep stale overlays.';

  String get dialogSectionTitle => 'LiSimpleDialogComponent';

  String get otherHelpersSectionTitle =>
      _isPt ? 'Outros helpers estáticos' : 'Other static helpers';

  String get loadingTargetMethodLabel => 'show(target:)';

  String get loadingBodyMethodLabel => 'showOnBody()';

  String get loadingSimpleMethodLabel => 'showSimple(target:)';

  String get loadingHorizontalMethodLabel => 'showHorizontal(target:)';

  String get loadingHorizontal2MethodLabel => 'showHorizontal2(target:)';

  String get dialogAlertMethodLabel => 'showAlert()';

  String get dialogConfirmMethodLabel => 'showConfirm()';

  String get dialogPromptMethodLabel => 'showPrompt()';

  String get dialogTextareaPromptMethodLabel =>
      _isPt ? 'showPrompt() textarea' : 'showPrompt() textarea';

  String get dialogFullScreenMethodLabel => 'showFullScreenDialog()';

  String get dialogFullScreenAlertMethodLabel => 'showFullScreenAlert()';

  String get _dialogAlertDetailLabel => _isPt ? 'Detalhe' : 'Details';

  String get _dialogAlertDetailBody => _isPt
      ? 'A fila foi criada e o processamento continuará mesmo se você sair desta página.'
      : 'The queue item was created and processing will continue even if you leave this page.';

  String get _dialogConfirmDetailBody => _isPt
      ? 'Os consumidores conectados receberão a nova configuração em até 5 minutos.'
      : 'Connected consumers will receive the new configuration within 5 minutes.';

  String get _fullScreenDialogTitle => _isPt
      ? 'Demo fullscreen do helper simples'
      : 'Simple helper fullscreen demo';

  String get _fullScreenDialogBody => _isPt
      ? 'Este bloco usa showFullScreenDialog() com HTML arbitrário e encerra automaticamente após 2 segundos.'
      : 'This block uses showFullScreenDialog() with arbitrary HTML and auto-dismisses after 2 seconds.';

  String get _fullScreenDialogHint =>
      _isPt ? 'Encerramento automático' : 'Auto dismiss';

  String get _fullScreenAlertMessage => _isPt
      ? 'Sincronização em tela cheia em andamento...'
      : 'Fullscreen synchronization in progress...';

  String get _fullScreenDialogApi =>
      'LiSimpleDialogComponent.showFullScreenDialog()';

  String get _fullScreenAlertApi =>
      'LiSimpleDialogComponent.showFullScreenAlert()';

  String get modalStackSectionTitle =>
      _isPt ? 'Stack visual em li-modal' : 'Visual stack in li-modal';

  String get modalStackIntro => _isPt
      ? 'Abra um li-modal de demonstração e acione helpers imperativos a partir dele para comparar overlays de viewport com overlays ancoradas no conteúdo do modal.'
      : 'Open a demo li-modal and trigger imperative helpers from inside it to compare viewport overlays with overlays anchored to the modal content.';

  String get modalStackLaunchLabel =>
      _isPt ? 'Abrir demo em li-modal' : 'Open li-modal demo';

  String get modalStackDialogTitle => _isPt
      ? 'Helpers imperativos sobre li-modal'
      : 'Imperative helpers above li-modal';

  String get modalStackDialogIntro => _isPt
      ? 'Os botões abaixo partem do corpo do modal. Os overlays de viewport devem aparecer acima da janela, enquanto o loading de alvo permanece preso à área interna.'
      : 'The buttons below start from the modal body. Viewport overlays should appear above the dialog, while target loading stays attached to the inner area.';

  String get modalViewportSectionTitle =>
      _isPt ? 'Acima do modal' : 'Above the modal';

  String get modalAnchoredSectionTitle =>
      _isPt ? 'Ancorado dentro do modal' : 'Anchored inside the modal';

  String get modalTargetTitle =>
      _isPt ? 'Área alvo dentro do modal' : 'Target area inside the modal';

  String get modalTargetHelp => _isPt
      ? 'Use show(target:) para comparar a overlay interna com os helpers que cobrem a viewport inteira.'
      : 'Use show(target:) to compare the inner overlay with helpers that cover the full viewport.';

  String get modalDialogAlertMethodLabel => 'showAlert()';

  String get modalBodyLoadingMethodLabel => 'showOnBody()';

  String get modalNarratedLoadingMethodLabel =>
      'LiNarratedFullScreenLoading.showOnBody()';

  String get modalCloseLabel => _isPt ? 'Fechar modal' : 'Close modal';

  String get _narratedLoadingApi =>
      'LiNarratedFullScreenLoading.pdfGeneration().showOnBody()';

  String get _narratedModalApi =>
      'LiNarratedFullScreenLoading.showOnBody() dentro de li-modal';

  String get _narratedLoadingTitle => _isPt ? 'Gerando PDF' : 'Generating PDF';

  List<String> get _narratedLoadingMessages => _isPt
      ? const <String>[
          'Preparando estrutura do documento...',
          'Organizando seções e anexos...',
          'Convertendo conteúdo para PDF...',
          'Finalizando páginas e metadados...',
        ]
      : const <String>[
          'Preparing document structure...',
          'Organizing sections and attachments...',
          'Converting content to PDF...',
          'Finalizing pages and metadata...',
        ];

  String get _narratedModalTitle =>
      _isPt ? 'Sincronizando workspace' : 'Synchronizing workspace';

  List<String> get _narratedModalMessages => _isPt
      ? const <String>[
          'Conferindo permissões do operador...',
          'Sincronizando atalhos da sessão...',
          'Publicando estado do modal para o servidor...',
        ]
      : const <String>[
          'Checking operator permissions...',
          'Synchronizing session shortcuts...',
          'Publishing modal state to the server...',
        ];

  String _methodShownForTwoSeconds(String api) =>
      _isPt ? '$api exibido por 2 segundos.' : '$api shown for 2 seconds.';

  String _methodPreviewing(String api) =>
      _isPt ? '$api em execução.' : '$api is running.';

  String _methodExecuted(String api) =>
      _isPt ? '$api executado.' : '$api executed.';

  String _methodDismissed(String api) =>
      _isPt ? '$api encerrado automaticamente.' : '$api auto-dismissed.';

  String _methodConfirmed(String api) => _isPt
      ? '$api retornou confirmação positiva.'
      : '$api returned a positive confirmation.';

  String _methodCancelled(String api) =>
      _isPt ? '$api foi cancelado.' : '$api was cancelled.';

  String _escapeHtml(String value) => const HtmlEscape().convert(value);

  @ViewChild('loadingHost')
  web.HTMLDivElement? loadingHost;

  @ViewChild('stackDemoModal')
  LiModalComponent? stackDemoModal;

  @ViewChild('modalLoadingHost')
  web.HTMLDivElement? modalLoadingHost;

  void _resetLoadingPreview() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
    _loading.hide();
  }

  void _removeFullScreenDialogDemo() {
    final marker =
        web.document.querySelector('[data-li-simple-fullscreen-demo="true"]');
    final overlay = marker?.parentElement;
    final root = overlay?.parentElement;
    root?.remove();
  }

  void _removeFullScreenAlertDemo() {
    web.document.querySelector('.FullScreenAlert')?.remove();
  }

  void _removeNarratedLoadingDemo() {
    _narratedLoading?.hide();
    _narratedLoading = null;
  }

  void _resetFullscreenPreview() {
    _fullscreenTimer?.cancel();
    _fullscreenTimer = null;
    _removeFullScreenDialogDemo();
    _removeFullScreenAlertDemo();
    _removeNarratedLoadingDemo();
  }

  void _resetTransientPreviews() {
    _resetLoadingPreview();
    _resetFullscreenPreview();
  }

  void _runTimedLoadingPreview({
    required void Function() showAction,
    required String api,
  }) {
    _resetTransientPreviews();
    showAction();
    helperState = _methodShownForTwoSeconds(api);
    _loadingTimer = Timer(_demoDuration, () {
      _loading.hide();
      helperState = t.pages.helpers.loadingHidden;
    });
  }

  void _showNarratedLoadingPreview({
    required String title,
    required List<String> messages,
    required String api,
    Duration duration = _narratedDemoDuration,
  }) {
    _resetTransientPreviews();
    final narratedLoading = LiNarratedFullScreenLoading.pdfGeneration(
      title: title,
      messages: messages,
      stepDuration: const Duration(milliseconds: 800),
    );
    _narratedLoading = narratedLoading;
    narratedLoading.showOnBody();
    helperState = _methodPreviewing(api);
    _fullscreenTimer = Timer(duration, () {
      _removeNarratedLoadingDemo();
      helperState = _methodDismissed(api);
    });
  }

  void showLoadingOverlay() {
    final host = loadingHost;
    if (host == null) {
      return;
    }

    _runTimedLoadingPreview(
      showAction: () => _loading.show(target: host),
      api: 'LiSimpleLoading.show(target:)',
    );
  }

  void showBodyLoadingOverlay() {
    _runTimedLoadingPreview(
      showAction: _loading.showOnBody,
      api: 'LiSimpleLoading.showOnBody()',
    );
  }

  void showSimpleLoadingOverlay() {
    final host = loadingHost;
    if (host == null) {
      return;
    }

    _runTimedLoadingPreview(
      showAction: () => _loading.showSimple(target: host),
      api: 'LiSimpleLoading.showSimple(target:)',
    );
  }

  void showHorizontalLoadingOverlay() {
    final host = loadingHost;
    if (host == null) {
      return;
    }

    _runTimedLoadingPreview(
      showAction: () => _loading.showHorizontal(target: host),
      api: 'LiSimpleLoading.showHorizontal(target:)',
    );
  }

  void showHorizontal2LoadingOverlay() {
    final host = loadingHost;
    if (host == null) {
      return;
    }

    _runTimedLoadingPreview(
      showAction: () => _loading.showHorizontal2(target: host),
      api: 'LiSimpleLoading.showHorizontal2(target:)',
    );
  }

  void showNarratedLoadingDemo() {
    _showNarratedLoadingPreview(
      title: _narratedLoadingTitle,
      messages: _narratedLoadingMessages,
      api: _narratedLoadingApi,
    );
  }

  void showDialogAlert() {
    _resetTransientPreviews();
    LiSimpleDialogComponent.showAlert(
      t.pages.helpers.dialogAlertBody,
      title: t.pages.helpers.dialogAlertTitle,
      detailLabel: _dialogAlertDetailLabel,
      subMessage: _dialogAlertDetailBody,
      dialogColor: LiDialogColor.INFO,
    );
    helperState = _methodExecuted('LiSimpleDialogComponent.showAlert()');
  }

  Future<void> showDialogConfirm() async {
    _resetTransientPreviews();
    final confirmed = await LiSimpleDialogComponent.showConfirm(
      t.pages.helpers.dialogConfirmBody,
      title: t.pages.helpers.dialogConfirmTitle,
      confirmButtonText: t.pages.helpers.dialogConfirmOk,
      cancelButtonText: t.pages.helpers.dialogConfirmCancel,
      subMessage: _dialogConfirmDetailBody,
      dialogColor: LiDialogColor.WARNING,
    );

    helperState = confirmed
        ? _methodConfirmed('LiSimpleDialogComponent.showConfirm()')
        : _methodCancelled('LiSimpleDialogComponent.showConfirm()');
  }

  Future<void> showDialogPrompt() async {
    _resetTransientPreviews();
    final value = await LiSimpleDialogComponent.showPrompt(
      _isPt
          ? 'Informe o nome da fila que deve receber prioridade.'
          : 'Enter the queue name that should receive priority.',
      title: _isPt ? 'Priorizar fila' : 'Prioritize queue',
      inputLabel: _isPt ? 'Nome da fila' : 'Queue name',
      inputPlaceholder:
          _isPt ? 'Ex.: protocolo-urgente' : 'e.g. urgent-protocol',
      confirmButtonText: _isPt ? 'Salvar' : 'Save',
      cancelButtonText: _isPt ? 'Cancelar' : 'Cancel',
      dialogColor: LiDialogColor.PRIMARY,
      inputValidator: (value) {
        if (value.trim().isEmpty) {
          return _isPt
              ? 'Informe um nome antes de continuar.'
              : 'Enter a name before continuing.';
        }
        return null;
      },
    );

    helperState = value == null
        ? _methodCancelled('LiSimpleDialogComponent.showPrompt()')
        : (_isPt
            ? 'LiSimpleDialogComponent.showPrompt() retornou: $value'
            : 'LiSimpleDialogComponent.showPrompt() returned: $value');
  }

  Future<void> showDialogTextareaPrompt() async {
    _resetTransientPreviews();
    final value = await LiSimpleDialogComponent.showPrompt(
      _isPt
          ? 'Informe o motivo obrigatório para registrar a correção.'
          : 'Enter the required reason to register the correction.',
      title: _isPt ? 'Tachar despacho' : 'Mark dispatch',
      inputType: LiSimpleDialogInputType.textarea,
      inputLabel: _isPt ? 'Motivo' : 'Reason',
      inputPlaceholder: _isPt
          ? 'Descreva o motivo da correção'
          : 'Describe the correction reason',
      confirmButtonText: _isPt ? 'Confirmar' : 'Confirm',
      cancelButtonText: _isPt ? 'Cancelar' : 'Cancel',
      dialogColor: LiDialogColor.WARNING,
      inputConfig: const LiSimpleDialogInputConfig(
        className: 'li-simple-dialog-demo-textarea',
        rows: 6,
        maxLength: 240,
        attributes: <String, String>{
          'aria-label': 'Correction reason',
        },
        style: <String, String>{
          'min-height': '10rem',
        },
      ),
      inputValidator: (value) {
        if (value.trim().isEmpty) {
          return _isPt ? 'O motivo é obrigatório.' : 'The reason is required.';
        }
        if (value.trim().length < 10) {
          return _isPt
              ? 'Descreva o motivo com pelo menos 10 caracteres.'
              : 'Describe the reason with at least 10 characters.';
        }
        return null;
      },
    );

    helperState = value == null
        ? _methodCancelled('LiSimpleDialogComponent.showPrompt() textarea')
        : (_isPt
            ? 'Textarea confirmado: $value'
            : 'Textarea confirmed: $value');
  }

  void showFullScreenDialogDemo() {
    _resetTransientPreviews();
    LiSimpleDialogComponent.showFullScreenDialog('''
<div data-li-simple-fullscreen-demo="true" class="d-flex align-items-center justify-content-center w-100 h-100 p-4">
  <div class="card border-0 shadow-sm" style="width:min(28rem,100%);">
    <div class="card-body text-center p-4">
      <div class="mb-3 text-primary"><i class="ph-arrows-out-cardinal fs-1"></i></div>
      <h6 class="mb-2">${_escapeHtml(_fullScreenDialogTitle)}</h6>
      <p class="text-muted mb-3">${_escapeHtml(_fullScreenDialogBody)}</p>
      <span class="badge bg-primary">${_escapeHtml(_fullScreenDialogHint)}</span>
    </div>
  </div>
</div>
''');
    helperState = _methodShownForTwoSeconds(_fullScreenDialogApi);
    _fullscreenTimer = Timer(_demoDuration, () {
      _removeFullScreenDialogDemo();
      helperState = _methodDismissed(_fullScreenDialogApi);
    });
  }

  void showFullScreenAlertDemo() {
    _resetTransientPreviews();
    LiSimpleDialogComponent.showFullScreenAlert(
      _fullScreenAlertMessage,
      backgroundColor: '#0d6efd',
    );
    helperState = _methodShownForTwoSeconds(_fullScreenAlertApi);
    _fullscreenTimer = Timer(_demoDuration, () {
      _removeFullScreenAlertDemo();
      helperState = _methodDismissed(_fullScreenAlertApi);
    });
  }

  void openHelperStackModal() {
    _resetTransientPreviews();
    stackDemoModal?.open();
    helperState = _isPt
        ? 'Demo de stack em li-modal aberta.'
        : 'li-modal stack demo opened.';
  }

  void onHelperStackModalClose() {
    _resetTransientPreviews();
    helperState = _isPt
        ? 'Demo de stack em li-modal fechada.'
        : 'li-modal stack demo closed.';
  }

  void showModalDialogAlert() {
    _resetTransientPreviews();
    LiSimpleDialogComponent.showAlert(
      _isPt
          ? 'Este alerta foi aberto a partir do corpo de um li-modal para validar a pilha visual do helper.'
          : 'This alert was opened from inside a li-modal body to validate the helper visual stack.',
      title: _isPt ? 'Alerta acima do modal' : 'Alert above modal',
      dialogColor: LiDialogColor.INFO,
    );
    helperState = _methodExecuted(
      'LiSimpleDialogComponent.showAlert() dentro de li-modal',
    );
  }

  void showModalBodyLoadingOverlay() {
    _runTimedLoadingPreview(
      showAction: _loading.showOnBody,
      api: 'LiSimpleLoading.showOnBody() dentro de li-modal',
    );
  }

  void showModalTargetLoadingOverlay() {
    final host = modalLoadingHost;
    if (host == null) {
      return;
    }

    _runTimedLoadingPreview(
      showAction: () => _loading.show(target: host),
      api: 'LiSimpleLoading.show(target:) dentro de li-modal',
    );
  }

  void showModalNarratedLoadingOverlay() {
    _showNarratedLoadingPreview(
      title: _narratedModalTitle,
      messages: _narratedModalMessages,
      api: _narratedModalApi,
    );
  }

  void showSimplePopover(web.Element target) {
    LiSimplePopover.showWarning(
      target,
      t.pages.helpers.simplePopoverBody,
    );
    helperState = t.pages.helpers.simplePopoverState;
  }

  void showSweetPopover(web.Element target) {
    SweetAlertPopover.showPopover(
      target,
      t.pages.helpers.sweetPopoverBody,
      title: t.pages.helpers.sweetPopoverTitle,
    );
    helperState = t.pages.helpers.sweetPopoverState;
  }

  void showSimpleSuccessToast() {
    LiSimpleToast.showSuccess(t.pages.helpers.simpleSuccessBody);
    helperState = t.pages.helpers.simpleSuccessState;
  }

  void showSimpleWarningToast() {
    LiSimpleToast.showWarning(t.pages.helpers.simpleWarningBody);
    helperState = t.pages.helpers.simpleWarningState;
  }

  void showSweetSuccessToast() {
    SweetAlertSimpleToast.showSuccessToast(t.pages.helpers.sweetSuccessBody);
    helperState = t.pages.helpers.sweetSuccessState;
  }

  void showSweetWarningToast() {
    SweetAlertSimpleToast.showWarningToast(t.pages.helpers.sweetWarningBody);
    helperState = t.pages.helpers.sweetWarningState;
  }

  Future<void> showSweetModal() async {
    final result = await SweetAlert.show(
      title: t.pages.helpers.sweetModalTitle,
      message: t.pages.helpers.sweetModalBody,
      type: SweetAlertType.success,
      confirmButtonText: _isPt ? 'OK' : 'OK',
      showCloseButton: true,
      footer: t.pages.helpers.sweetSuccessState,
    );

    helperState = result.isConfirmed
        ? t.pages.helpers.sweetModalState
        : t.pages.helpers.sweetModalDismissed;
  }

  Future<void> showSweetConfirm() async {
    final result = await SweetAlert.confirm(
      title: t.pages.helpers.sweetConfirmTitle,
      message: t.pages.helpers.sweetConfirmBody,
      type: SweetAlertType.question,
      confirmButtonText: t.pages.helpers.sweetConfirmOk,
      cancelButtonText: t.pages.helpers.sweetConfirmCancel,
      showCloseButton: true,
    );

    helperState = result.isConfirmed
        ? t.pages.helpers.sweetConfirmTrue
        : t.pages.helpers.sweetConfirmFalse;
  }

  Future<void> showSweetPrompt() async {
    final result = await SweetAlert.prompt(
      title: t.pages.helpers.sweetPromptTitle,
      message: t.pages.helpers.sweetPromptBody,
      type: SweetAlertType.info,
      inputPlaceholder: t.pages.helpers.sweetPromptPlaceholder,
      confirmButtonText: t.pages.helpers.sweetPromptOk,
      cancelButtonText: t.pages.helpers.sweetPromptCancel,
      inputValidator: (value) {
        if (value.trim().isEmpty) {
          return t.pages.helpers.sweetPromptValidation;
        }
        return null;
      },
    );

    helperState = result.isConfirmed
        ? '${t.pages.helpers.sweetPromptFilledPrefix}: ${result.value}'
        : t.pages.helpers.sweetPromptDismissed;
  }

  void showSweetErrorToast() {
    SweetAlertSimpleToast.showToast(
      t.pages.helpers.sweetErrorBody,
      type: SweetAlertType.error,
      position: SweetAlertPosition.bottomEnd,
      duration: 4000,
    );
    helperState = t.pages.helpers.sweetErrorState;
  }

  @override
  void ngOnDestroy() {
    _resetTransientPreviews();
  }
}
