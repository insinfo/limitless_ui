import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'button-page',
  templateUrl: 'button_page.html',
  styleUrls: ['button_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiButtonComponent,
  ],
)
class ButtonPageComponent {
  ButtonPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
}
