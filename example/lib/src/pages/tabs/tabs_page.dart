import 'package:limitless_ui_example/limitless_ui_example.dart';

import 'tabs_preview_component.dart';

@Component(
  selector: 'tabs-page',
  templateUrl: 'tabs_page.html',
  styleUrls: ['tabs_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiTabxHeaderDirective,
    TabsPreviewComponent,
  ],
)
class TabsPageComponent {
  TabsPageComponent(this.i18n);

  static const String apiSnippet = '''
<li-tabsx type="underline">
  <li-tabx header="Summary" [active]="true">
    <div class="p-3">Conteúdo</div>
  </li-tabx>

  <li-tabx header="Activity"></li-tabx>
</li-tabsx>

<li-tabsx type="solid" [justified]="true">
  <li-tabx header="Operation" [active]="true"></li-tabx>
  <li-tabx header="Monitoring"></li-tabx>
</li-tabsx>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get isPt => i18n.isPortuguese;
}
