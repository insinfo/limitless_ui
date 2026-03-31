import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'pagination-page',
  templateUrl: 'pagination_page.html',
  styleUrls: ['pagination_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    liPaginationDirectives,
  ],
)
class PaginationPageComponent {
  int basicPage = 1;
  int compactPage = 7;
  int customPage = 3;
  int disabledPage = 2;

  String eventLog =
      'Troque de página para validar pageChange, templates e estados.';

  void onBasicPageChange(int page) {
    basicPage = page;
    eventLog = 'Paginação básica mudou para a página $page.';
  }

  void onCompactPageChange(int page) {
    compactPage = page;
    eventLog = 'Paginação compacta mudou para a página $page.';
  }

  void onCustomPageChange(int page) {
    customPage = page;
    eventLog = 'Template customizado mudou para a página $page.';
  }
}
