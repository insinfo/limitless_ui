import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'toast-page',
  templateUrl: 'toast_page.html',
  styleUrls: ['toast_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiToastComponent,
    LiToastStackComponent,
  ],
)
class ToastPageComponent {
  ToastPageComponent(this.i18n);

  static const String apiSnippet = '''
<li-toast-stack [service]="toastService" placement="top-end"></li-toast-stack>

toastService.show(
  header: 'Processamento concluído',
  body: 'A operação foi concluída com sucesso.',
  iconClass: 'ph-check-circle',
  toastClass: 'bg-success text-white border-0',
  headerClass: 'bg-black bg-opacity-10 text-white',
  delay: 3500,
);''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  final LiToastService toastService = LiToastService();
  String lastAction = '';

  @ViewChild('manualToast')
  LiToastComponent? manualToast;

  @ViewChild('roundedToast')
  LiToastComponent? roundedToast;

  String get pageTitle => 'Toast';
  String get pageSubtitle => _isPt ? 'mensagens de feedback' : 'feedback messages';
  String get breadcrumb => _isPt
      ? 'Notifications inline e em stack'
      : 'Inline and stacked notifications';
  String get overviewIntro => _isPt
      ? 'li-toast cobre o uso declarativo inline e o fluxo global com LiToastService + li-toast-stack, próximo do padrão Bootstrap/ng-bootstrap.'
      : 'li-toast covers inline declarative usage and the global flow with LiToastService + li-toast-stack, close to the Bootstrap/ng-bootstrap pattern.';
  String get basicToastTitle => _isPt
      ? 'Toast declarativo básico'
      : 'Basic declarative toast';
  String get basicToastBody => _isPt
      ? 'Header, body e dismiss button controlados pelo componente.'
      : 'Header, body, and dismiss button controlled by the component.';
  String get reopenLabel => _isPt ? 'Reabrir' : 'Reopen';
  String get manualHeader => 'Hello';
  String get manualBody => _isPt
      ? 'Sou um toast declarativo que pode ser aberto novamente via ViewChild.'
      : 'I am a declarative toast that can be shown again via ViewChild.';
  String get manualHelper => _isPt ? 'inline' : 'inline';
  String get roundedTitle => _isPt ? 'Rounded toast' : 'Rounded toast';
  String get roundedBody => _isPt
      ? 'A variação pill funciona melhor em mensagens curtas, compactas e sem muito chrome visual.'
      : 'The pill variation works better for short, compact messages with less visual chrome.';
  String get roundedToastBody =>
      _isPt ? 'Salvo com sucesso' : 'Saved successfully';
  String get customHeaderTitle =>
      _isPt ? 'Header customizado' : 'Custom header background';
  String get customHeaderText => _isPt ? 'Cabeçalho do toast' : 'Toast header';
  String get customHeaderBody => _isPt
      ? 'Um toast contextual com cabeçalho colorido e botão de fechar.'
      : 'A contextual toast with colored header and close button.';
  String get projectedTitle =>
      _isPt ? 'Markup customizado com painel de ações' : 'Custom markup with action panel';
  String get projectedHeader => _isPt ? 'Cabeçalho do toast' : 'Toast header';
  String get projectedHelper => _isPt ? '1 hora atrás' : '1 hour ago';
  String get projectedBody => _isPt
      ? 'Olá, mundo! Este toast usa markup projetado para uma segunda linha de ações.'
      : 'Hello, world! This toast uses projected markup for a second action row.';
  String get cancelLabel => _isPt ? 'Cancelar' : 'Cancel';
  String get confirmLabel => _isPt ? 'Confirmar' : 'Confirm';
  String get apiIntro => _isPt
      ? 'A API combina o componente declarativo para casos locais e `LiToastService` com `li-toast-stack` para mensagens globais.'
      : 'The API combines the declarative component for local cases and `LiToastService` with `li-toast-stack` for global messages.';
  String get successStackLabel => _isPt ? 'Stack success' : 'Success stack';
  String get warningStackLabel => _isPt ? 'Stack warning' : 'Warning stack';
  String get persistentStackLabel =>
      _isPt ? 'Stack persistente' : 'Persistent stack';
  String get clearStackLabel => _isPt ? 'Limpar stack' : 'Clear stack';
  String get howToUseTitle => t.common.sectionHowToUse;
  String get mainInputsTitle => _isPt ? 'Entradas principais' : 'Main inputs';
  String get idleState => _isPt
      ? 'Toast: aguardando interação'
      : 'Toast: waiting for interaction';

  void reopenManualToast() {
    manualToast?.show();
    lastAction = _isPt
        ? 'Toast inline aberto por API.'
        : 'Inline toast reopened through the API.';
  }

  void reopenRoundedToast() {
    roundedToast?.show();
    lastAction = _isPt
        ? 'Toast com estilo pill reaberto.'
        : 'Pill-style toast reopened.';
  }

  void showSuccess() {
    toastService.show(
      header: _isPt ? 'Processamento concluído' : 'Processing complete',
      body: _isPt
          ? 'A operação foi concluída com sucesso e o toast vai desaparecer sozinho.'
          : 'The operation completed successfully and the toast will disappear on its own.',
      iconClass: 'ph-check-circle',
      toastClass: 'bg-success text-white border-0',
      headerClass: 'bg-black bg-opacity-10 text-white',
      delay: 3500,
      pauseOnHover: true,
    );
    lastAction = _isPt
        ? 'Toast global de sucesso enviado para a pilha.'
        : 'Global success toast sent to the stack.';
  }

  void showWarning() {
    toastService.show(
      header: _isPt ? 'Atenção' : 'Attention',
      body: _isPt
          ? 'Existe uma pendência aguardando revisão humana antes da próxima etapa.'
          : 'There is a pending item waiting for human review before the next step.',
      iconClass: 'ph-warning-circle',
      toastClass: 'border-warning',
      headerClass: 'bg-warning text-white border-warning',
      delay: 5000,
    );
    lastAction = _isPt
        ? 'Toast global de alerta enviado para a pilha.'
        : 'Global warning toast sent to the stack.';
  }

  void showPersistent() {
    toastService.show(
      header: _isPt ? 'Atualização disponível' : 'Update available',
      body: _isPt
          ? 'Este exemplo usa badge, helper text e autohide desativado para toasts persistentes.'
          : 'This example uses a badge, helper text, and disabled autohide for persistent toasts.',
      helperText: _isPt ? 'agora' : 'now',
      badgeText: _isPt ? 'Atualização' : 'Update',
      iconClass: 'ph-bell-ringing',
      toastClass: 'border-primary',
      headerClass: 'bg-primary text-white border-primary',
      autohide: false,
    );
    lastAction = _isPt
        ? 'Toast persistente enviado para a pilha.'
        : 'Persistent toast sent to the stack.';
  }

  void clearStack() {
    toastService.clear();
    lastAction = _isPt ? 'Pilha de toast limpa.' : 'Toast stack cleared.';
  }
}
