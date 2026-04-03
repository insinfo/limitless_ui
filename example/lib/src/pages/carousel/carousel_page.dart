import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'carousel-page',
  templateUrl: 'carousel_page.html',
  styleUrls: ['carousel_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiCarouselComponent,
    LiCarouselCaptionComponent,
    LiCarouselItemComponent,
  ],
)
class CarouselPageComponent {
  CarouselPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  String get overviewIntro => _isPt
      ? 'A página do carousel reúne modos padrão, grid e transições adicionais, mantendo a mesma API do componente base.'
      : 'The carousel page brings together default mode, grid mode, and additional transitions while keeping the same base component API.';
}
