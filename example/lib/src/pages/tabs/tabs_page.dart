import 'package:limitless_ui_example/limitless_ui_example.dart';

import 'tabs_preview_component.dart';

@Component(
  selector: 'tabs-page',
  templateUrl: 'tabs_page.html',
  styleUrls: ['tabs_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiTabxHeaderDirective,
    TabsPreviewComponent,
  ],
)
class TabsPageComponent {
  TabsPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get isPt => i18n.isPortuguese;
}
