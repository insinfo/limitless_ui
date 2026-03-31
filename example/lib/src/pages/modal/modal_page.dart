import 'package:limitless_ui_example/limitless_ui_example.dart';
@Component(
  selector: 'modal-page',
  templateUrl: 'modal_page.html',
  styleUrls: ['modal_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiModalComponent,
  ],
)
class ModalPageComponent {
  ModalPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  @ViewChild('demoModal')
  LiModalComponent? demoModal;

  @ViewChild('scrollableModal')
  LiModalComponent? scrollableModal;

  @ViewChild('warningModal')
  LiModalComponent? warningModal;

  @ViewChild('fullModal')
  LiModalComponent? fullModal;

  @ViewChild('lockedModal')
  LiModalComponent? lockedModal;

  @ViewChild('lazyPreviewModal')
  LiModalComponent? lazyPreviewModal;

  final List<int> scrollLines = List<int>.generate(8, (index) => index + 1);
  final List<String> rolloutSteps = <String>[
    'Validar escopo com operação e produto.',
    'Gerar PDF com os indicadores do período.',
    'Publicar o pacote e avisar as áreas impactadas.',
  ];
  String modalEventLog =
      'Abra um dos exemplos para validar combinações de tamanho, cor, backdrop e lazyContent.';

  void openModal() {
    demoModal?.open();
    modalEventLog = 'Modal básico aberto.';
  }

  void openScrollableModal() {
    scrollableModal?.open();
    modalEventLog = 'Modal scrollable aberto.';
  }

  void openWarningModal() {
    warningModal?.open();
    modalEventLog = 'Modal com header contextual aberto.';
  }

  void openFullModal() {
    fullModal?.open();
    modalEventLog = 'Modal wide/full aberto.';
  }

  void openLockedModal() {
    lockedModal?.open();
    modalEventLog = 'Modal com backdrop travado aberto.';
  }

  void openLazyPreviewModal() {
    lazyPreviewModal?.open();
    modalEventLog = 'Modal lazy aberto. O conteúdo só foi montado agora.';
  }

  void onModalClosed(String label) {
    modalEventLog = '$label fechado.';
  }
}
