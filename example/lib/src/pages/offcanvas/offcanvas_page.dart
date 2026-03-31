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
  OffcanvasPageComponent(this.i18n, this.offcanvasService);

  final DemoI18nService i18n;
  final LiOffcanvasService offcanvasService;
  Messages get t => i18n.t;

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

  final List<String> reviewSteps = <String>[
    'Conferir os filtros ativos antes de abrir a lista lateral.',
    'Revisar contexto adicional sem trocar de rota.',
    'Fechar ao concluir para devolver o foco ao gatilho.',
  ];

  String eventLog =
      'Abra um exemplo para validar posição, backdrop, foco e lazy content.';
  bool blockGuardDismiss = true;
  LiOffcanvasRef? activeServiceRef;

  void openBasic() {
    basicOffcanvas?.open();
    eventLog = 'Offcanvas lateral direito aberto.';
  }

  void openStart() {
    startOffcanvas?.open();
    eventLog = 'Offcanvas lateral esquerdo aberto com foco inicial.';
  }

  void openTop() {
    topOffcanvas?.open();
    eventLog = 'Offcanvas superior aberto.';
  }

  void openFooter() {
    footerOffcanvas?.open();
    eventLog = 'Offcanvas com header/footer customizados aberto.';
  }

  void openNoBackdrop() {
    noBackdropOffcanvas?.open();
    eventLog = 'Offcanvas sem backdrop aberto; a página continua interativa.';
  }

  void openLazy() {
    lazyOffcanvas?.open();
    eventLog = 'Offcanvas lazy aberto. O conteúdo só entrou no DOM agora.';
  }

  void openGuarded() {
    guardedOffcanvas?.open();
    eventLog = 'Offcanvas com beforeDismiss aberto.';
  }

  void openLarge() {
    largeOffcanvas?.open();
    eventLog = 'Offcanvas largo aberto.';
  }

  void openViaService() {
    final ref = offcanvasService.open('service-demo');
    activeServiceRef = ref;
    eventLog =
        'LiOffcanvasService.open("service-demo") abriu o painel e retornou uma ref reutilizável.';
  }

  void closeViaServiceRef() {
    activeServiceRef?.close();
    eventLog = 'LiOffcanvasRef.close() acionado pela ref salva no componente.';
  }

  Future<bool> guardBeforeDismiss(LiOffcanvasDismissReason reason) async {
    if (!blockGuardDismiss) {
      return true;
    }

    eventLog =
        'beforeDismiss bloqueou a saída por ${reason.name}. Libere manualmente para dispensar.';
    return false;
  }

  Future<void> forceGuardDismiss() async {
    blockGuardDismiss = false;
    await guardedOffcanvas?.dismiss();
    blockGuardDismiss = true;
  }

  void onShown(String label) {
    eventLog = '$label exibido e pronto para interação.';
  }

  void onClosed(String label) {
    eventLog = '$label fechado.';
  }

  void onHidden(String label) {
    eventLog = '$label ocultado e removido do fluxo visível.';
  }

  void onDismissed(String label, LiOffcanvasDismissReason reason) {
    eventLog = '$label dispensado por ${reason.name}.';
  }
}
