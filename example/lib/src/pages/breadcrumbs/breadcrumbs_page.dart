import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'breadcrumbs-page',
  templateUrl: 'breadcrumbs_page.html',
  styleUrls: ['breadcrumbs_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    liBreadcrumbDirectives,
  ],
)
class BreadcrumbsPageComponent {}
