import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'disclosure-page',
  templateUrl: 'disclosure_page.html',
  styleUrls: ['disclosure_page.css'],
  directives: [
    coreDirectives,
    LiAccordionComponent,
    LiAccordionItemComponent,
    LiModalComponent,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class DisclosurePageComponent {
  @ViewChild('demoModal')
  LiModalComponent? demoModal;

  void openModal() {
    demoModal?.open();
  }
}
