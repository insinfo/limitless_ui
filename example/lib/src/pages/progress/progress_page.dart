
import 'package:limitless_ui_example/limitless_ui_example.dart';


@Component(
  selector: 'progress-page',
  templateUrl: 'progress_page.html',
  styleUrls: ['progress_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiProgressComponent,
    LiProgressBarComponent,
  ],
)
class ProgressPageComponent {
  ProgressPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
}
