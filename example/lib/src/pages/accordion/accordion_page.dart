

import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'accordion-page',
  templateUrl: 'accordion_page.html',
  styleUrls: ['accordion_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiAccordionComponent,
    LiAccordionHeaderDirective,
    LiAccordionItemComponent,
  ],
)
class AccordionPageComponent {
  AccordionPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  String get initialAccordionEventLog => t.pages.accordion.idle;
  String accordionEventLog = '';

  void onAccordionStateChange(String label, bool expanded) {
    accordionEventLog =
        '$label: ${expanded ? t.pages.accordion.expandedState : t.pages.accordion.collapsedState}.';
  }
}
