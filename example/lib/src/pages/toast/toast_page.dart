import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'toast-page',
  templateUrl: 'toast_page.html',
  styleUrls: ['toast_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiToastComponent,
    LiToastStackComponent,
  ],
)
class ToastPageComponent {
  ToastPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  final LiToastService toastService = LiToastService();
  String lastAction = '';

  @ViewChild('manualToast')
  LiToastComponent? manualToast;

  @ViewChild('roundedToast')
  LiToastComponent? roundedToast;

  void reopenManualToast() {
    manualToast?.show();
    lastAction = 'Toast inline aberto por API.';
  }

  void reopenRoundedToast() {
    roundedToast?.show();
    lastAction = 'Toast com estilo pill reaberto.';
  }

  void showSuccess() {
    toastService.show(
      header: 'Processamento concluído',
      body:
          'A operação foi concluída com sucesso e o toast vai desaparecer sozinho.',
      iconClass: 'ph-check-circle',
      toastClass: 'bg-success text-white border-0',
      headerClass: 'bg-black bg-opacity-10 text-white',
      delay: 3500,
      pauseOnHover: true,
    );
    lastAction = 'Toast global de sucesso enviado para a pilha.';
  }

  void showWarning() {
    toastService.show(
      header: 'Atenção',
      body:
          'Existe uma pendência aguardando revisão humana antes da próxima etapa.',
      iconClass: 'ph-warning-circle',
      toastClass: 'border-warning',
      headerClass: 'bg-warning text-white border-warning',
      delay: 5000,
    );
    lastAction = 'Toast global de alerta enviado para a pilha.';
  }

  void showPersistent() {
    toastService.show(
      header: 'Atualização disponível',
      body:
          'Este exemplo usa badge, helper text e autohide desativado para toasts persistentes.',
      helperText: 'agora',
      badgeText: 'Update',
      iconClass: 'ph-bell-ringing',
      toastClass: 'border-primary',
      headerClass: 'bg-primary text-white border-primary',
      autohide: false,
    );
    lastAction = 'Toast persistente enviado para a pilha.';
  }

  void clearStack() {
    toastService.clear();
    lastAction = 'Pilha de toast limpa.';
  }
}
