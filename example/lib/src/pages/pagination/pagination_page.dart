import 'dart:math' as math;

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
  int borderedPage = 1;
  int flatPage = 4;
  int spacedPage = 8;
  int roundedPage = 6;
  int toolbarPage = 2;
  int simplePagerPage = 4;
  int linkedPagerPage = 5;
  int dottedPage = 3;
  int borderlessPage = 2;
  int datatablePage = 3;
  int sizedBorderedPage = 2;
  int sizedFlatPage = 2;
  int sizedSpacedPage = 2;
  int leftAlignedPage = 2;
  int centerAlignedPage = 2;
  int rightAlignedPage = 2;

  int get toolbarStart => ((toolbarPage - 1) * 10) + 1;
  int get toolbarEnd => math.min(toolbarPage * 10, 120);
  int get datatableStart => ((datatablePage - 1) * 10) + 1;
  int get datatableEnd => math.min(datatablePage * 10, 96);

  String eventLog =
      'Troque de página para validar layouts, estilos, tamanhos e a variação usada no Datatable.';

  void updatePage(String demo, int page) {
    switch (demo) {
      case 'bordered':
        borderedPage = page;
        break;
      case 'flat':
        flatPage = page;
        break;
      case 'spaced':
        spacedPage = page;
        break;
      case 'rounded':
        roundedPage = page;
        break;
      case 'toolbar':
        toolbarPage = page;
        break;
      case 'simplePager':
        simplePagerPage = page;
        break;
      case 'linkedPager':
        linkedPagerPage = page;
        break;
      case 'dotted':
        dottedPage = page;
        break;
      case 'borderless':
        borderlessPage = page;
        break;
      case 'datatable':
        datatablePage = page;
        break;
      case 'sizedBordered':
        sizedBorderedPage = page;
        break;
      case 'sizedFlat':
        sizedFlatPage = page;
        break;
      case 'sizedSpaced':
        sizedSpacedPage = page;
        break;
      case 'leftAligned':
        leftAlignedPage = page;
        break;
      case 'centerAligned':
        centerAlignedPage = page;
        break;
      case 'rightAligned':
        rightAlignedPage = page;
        break;
    }

    eventLog = 'Demo "$demo" mudou para a página $page.';
  }
}
