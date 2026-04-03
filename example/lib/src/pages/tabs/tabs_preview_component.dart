import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'tabs-preview-component',
  templateUrl: 'tabs_preview_component.html',
  styleUrls: ['tabs_preview_component.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiTabxHeaderDirective,
  ],
)
class TabsPreviewComponent {
  TabsPreviewComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get isPt => i18n.isPortuguese;
}