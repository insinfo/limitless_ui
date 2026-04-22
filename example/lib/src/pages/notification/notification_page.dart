import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'notification-page',
  templateUrl: 'notification_page.html',
  styleUrls: ['notification_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiNotificationOutletComponent,
  ],
)
class NotificationPageComponent {
  NotificationPageComponent(this.i18n);

  static const String apiSnippet = '''
final notificationService = LiNotificationToastService();

<li-notification-outlet [service]="notificationService"></li-notification-outlet>

notificationService.notify(
  'Sincronização concluída com sucesso.',
  title: 'Fila de eventos',
  type: LiNotificationToastColor.success,
  durationSeconds: 4,
);

notificationService.notify(
  'Clique para abrir a demonstração de datatable.',
  title: 'Atalho',
  type: LiNotificationToastColor.info,
  link: DemoRoutePaths.datatable.toUrl(),
);''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  final LiNotificationToastService notificationService = LiNotificationToastService();
  String lastAction = '';

  String get pageTitle => t.nav.notification;
  String get pageSubtitle => t.pages.notification.subtitle;
  String get breadcrumb => t.pages.notification.breadcrumb;
  String get overviewIntro => _isPt
      ? 'Esta página usa o li-notification-outlet real do pacote. O outlet fica fixo no canto superior direito do viewport, empilha os itens com deslocamento vertical e fecha cada toast automaticamente após o tempo configurado.'
      : 'This page uses the real li-notification-outlet from the package. The outlet stays fixed in the top-right corner of the viewport, stacks items with a vertical offset, and automatically closes each toast after the configured time.';
  String get outletCardTitle => _isPt ? 'Fluxo real do outlet' : 'Real outlet flow';
  String get outletCardBody => _isPt
      ? 'Use os botões abaixo para validar empilhamento, botão de fechar e clique com navegação por rota.'
      : 'Use the buttons below to validate stacking, close button behavior, and click navigation through the router.';
  String get stackBurstLabel => _isPt ? 'Empilhar 3 toasts' : 'Stack 3 toasts';
  String get stackBurstState => _isPt
      ? 'Lote de três notificações enviado para validar empilhamento e ordem visual.'
      : 'A batch of three notifications was sent to validate stacking and visual order.';
  String get visibilityHint => _isPt
      ? 'O preview não aparece dentro do card porque o componente é fixado no viewport. Dispare os exemplos e observe o canto superior direito da tela.'
      : 'The preview does not render inside the card because the component is pinned to the viewport. Trigger the examples and watch the top-right corner of the screen.';
    String get detailOne => _isPt
      ? 'Success e warning usam cores e temporização diferentes.'
      : 'Success and warning use different colors and timings.';
    String get detailTwo => _isPt
      ? 'O botão de fechar remove apenas o toast clicado.'
      : 'The close button removes only the toast that was clicked.';
    String get detailThree => _isPt
      ? 'Toasts com link navegam por rota e se removem ao clique.'
      : 'Toasts with links navigate through the router and remove themselves on click.';
    String get detailFour => _isPt
      ? 'O botão de lote empilha três itens para validar deslocamento vertical.'
      : 'The batch button stacks three items to validate the vertical offset.';
    String get shellTitle => _isPt ? 'Shell da página' : 'Page shell';
    String get shellBody => _isPt
      ? 'O componente real está montado fora do card e fixa os toasts no viewport.'
      : 'The real component is mounted outside the card and pins the toasts to the viewport.';
    String get shellNote => _isPt
      ? 'O outlet é um helper global. Monte uma única instância e mantenha a mesma referência do serviço durante toda a vida da página.'
      : 'The outlet is a global helper. Mount a single instance and keep the same service reference for the whole page lifecycle.';
  String get apiIntro => _isPt
      ? 'Use LiNotificationToastService para disparar mensagens globais e li-notification-outlet uma única vez no shell da página. O próprio toast resolve fila, animação de saída, fechamento individual e navegação opcional por link.'
      : 'Use LiNotificationToastService to trigger global messages and render li-notification-outlet once in the page shell. The toast itself handles the queue, exit animation, individual close action, and optional link navigation.';
  String get howToUseTitle => _isPt ? 'Como utilizar' : 'How to use';
  String get mainInputsTitle => _isPt ? 'Parâmetros úteis' : 'Useful parameters';
  String get waitingState => _isPt
      ? 'Notification outlet: aguardando interação.'
      : 'Notification outlet: waiting for interaction.';

  void showSuccess() {
    notificationService.notify(
      t.pages.notification.successMessage,
      title: t.pages.notification.successTitle,
      type: LiNotificationToastColor.success,
      durationSeconds: 4,
    );
    lastAction = t.pages.notification.successState;
  }

  void showWarning() {
    notificationService.notify(
      t.pages.notification.warningMessage,
      title: t.pages.notification.warningTitle,
      type: LiNotificationToastColor.warning,
      durationSeconds: 6,
    );
    lastAction = t.pages.notification.warningState;
  }

  void showWithLink() {
    notificationService.notify(
      t.pages.notification.linkMessage,
      title: t.pages.notification.linkTitle,
      type: LiNotificationToastColor.info,
      durationSeconds: 8,
      link: DemoRoutePaths.datatable.toUrl(),
    );
    lastAction = t.pages.notification.linkState;
  }

  void showBurst() {
    notificationService.notify(
      _isPt ? 'Primeiro evento confirmado.' : 'First event confirmed.',
      title: _isPt ? 'Fila' : 'Queue',
      type: LiNotificationToastColor.success,
      durationSeconds: 7,
    );
    notificationService.notify(
      _isPt ? 'Existe um item aguardando revisão manual.' : 'There is an item waiting for manual review.',
      title: _isPt ? 'Atenção' : 'Attention',
      type: LiNotificationToastColor.warning,
      durationSeconds: 8,
    );
    notificationService.notify(
      _isPt ? 'Clique neste item para abrir o datatable.' : 'Click this item to open the datatable.',
      title: _isPt ? 'Atalho' : 'Shortcut',
      type: LiNotificationToastColor.info,
      durationSeconds: 9,
      link: DemoRoutePaths.datatable.toUrl(),
    );
    lastAction = stackBurstState;
  }
}
