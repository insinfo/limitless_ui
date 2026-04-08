import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'breadcrumbs-page',
  templateUrl: 'breadcrumbs_page.html',
  styleUrls: ['breadcrumbs_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiPageHeaderComponent,
    LiPageHeaderBreadcrumbItemDirective,
    LiTabsComponent,
    LiTabxDirective,
    liBreadcrumbDirectives,
  ],
)
class BreadcrumbsPageComponent {
  BreadcrumbsPageComponent(this.i18n);

  static const String apiSnippet = '''
<li-breadcrumb divider="dash" helperText="You are here:">
  <a liBreadcrumbItem href="#home">Home</a>
  <a liBreadcrumbItem href="#components">Components</a>
  <span liBreadcrumbItem [active]="true">Breadcrumbs</span>

  <div liBreadcrumbEnd class="d-flex gap-2">
    <button class="btn btn-sm btn-light">Duplicate</button>
    <button class="btn btn-sm btn-primary">Publish</button>
  </div>
</li-breadcrumb>''';

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get isPt => i18n.isPortuguese;

  String get pageTitle => isPt ? 'Navegação' : 'Navigation';
  String get pageSubtitle => 'Breadcrumbs';
  String get breadcrumb => isPt
      ? 'Layouts, divisores, ações laterais e superfícies no estilo Limitless'
      : 'Layouts, dividers, side actions, and Limitless-style surfaces';
  String get homeLabel => 'Home';
  String get componentsLabel => isPt ? 'Componentes' : 'Components';
  String get breadcrumbsLabel => 'Breadcrumbs';
  String get currentLabel => isPt ? 'Atual' : 'Current';
  String get locationLabel => isPt ? 'Localização' : 'Location';
  String get supportLabel => isPt ? 'Suporte' : 'Support';
  String get settingsLabel => isPt ? 'Configurações' : 'Settings';
  String get menuLabel => 'Menu';
}
