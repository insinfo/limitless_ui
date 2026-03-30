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

  final List<int> scrollLines = List<int>.generate(8, (index) => index + 1);

  void openModal() {
    demoModal?.open();
  }

  void openScrollableModal() {
    scrollableModal?.open();
  }
}
